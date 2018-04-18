module Views exposing (..)

import Html exposing (..)
import RemoteData
import Types.Auth as Auth
import Pages.Router as Router
import Pages.Container as ContainerPage
import Types.ProgressKeys as ProgressKeys
import State exposing (..)
import ViewComponents exposing (..)
import Material.Snackbar as Snackbar


globalView : Model -> Html Msg
globalView model =
    (case model.loginPage.authenticationState of
        Auth.LoggedIn _ ->
            view model

        Auth.LoggedOut ->
            loginView model
    )


view : Model -> Html Msg
view model =
    div []
        [ case model.route of
            Router.LandingRoute ->
                homeView model

            Router.CloneRoute ->
                view_ "Clone"
                    model
                    [ instancesView model
                    ]

            Router.ConvertCloneViewRoute ->
                view_ "Convert"
                    model
                    [ navMdl 1 0 model <| tabLabels Router.convertTabs
                    , convertCloneView model
                    ]

            Router.ConvertProcessesViewRoute ->
                view_ "Convert"
                    model
                    [ navMdl 1 1 model <| tabLabels Router.convertTabs
                    , convertProcessesView model
                    ]

            Router.ConvertProcessViewRoute pid ->
                view_ "Convert"
                    model
                    [ navMdl 1 1 model <| tabLabels Router.convertTabs
                    , convertProcessView model pid
                    ]

            Router.GantryContainersViewRoute ->
                view_ "Containers/Images Lifecycle"
                    model
                    [ navMdl 1 0 model <| tabLabels Router.gantryTabs
                    , containersListView model
                    ]

            Router.GantryContainersCreateRoute ->
                view_ "Containers/Images Lifecycle"
                    model
                    [ navMdl 1 0 model <| tabLabels Router.gantryTabs
                    , containersCreateView model
                    ]

            Router.GantryContainerViewRoute containerID ->
                view_ "Containers/Images Lifecycle"
                    model
                    [ navMdl 1 0 model <| tabLabels Router.gantryTabs
                    , containerView model containerID
                    ]

            Router.GantryImageRoute ->
                view_ "Containers/Images Lifecycle"
                    model
                    [ navMdl 1 1 model <| tabLabels Router.gantryTabs
                    , imagesView model
                    ]

            Router.NotFoundRoute ->
                e404 model
        , Snackbar.view model.snackbar |> Html.map Snackbar
        ]


loginView : Model -> Html Msg
loginView model =
    centerDiv <|
        breaker
            [ (case model.loginPage.credentialsWebdata of
                RemoteData.NotAsked ->
                    textMdl "Please login"

                RemoteData.Loading ->
                    httpLoadingMessage "Loading ..."

                RemoteData.Success rooms ->
                    textMdl "Error"

                RemoteData.Failure error ->
                    httpFailureMessage "login" error
              )
            , inputMdl model 0 Input_LoginPage_UserName "userName" "text" "User name"
            , inputMdl model 1 Input_LoginPage_AccessKeyId "accessKeyId" "text" "Access key ID"
            , inputMdl model 2 Input_LoginPage_SecretAccessKey "secretAccessKey" "password" "Secret access key"
            , buttonMdl model 3 Req_LoginPage_Submit "Login"
            ]


e404 : x -> Html Msg
e404 _ =
    div []
        [ textMdl "route not found" ]


homeView : Model -> Html Msg
homeView model =
    div []
        [ (case model.loginPage.authenticationState of
            Auth.LoggedIn creds ->
                view_ "Home"
                    model
                    [ yellowDivMdl
                        [ textMdl ("Hi " ++ creds.userName)
                        , if model.selectedRegion == "" then
                            text ""
                          else
                            textMidMdl <| "Selected EC2 region: " ++ model.selectedRegion
                        , case model.homePage.regionsWebdata of
                            RemoteData.NotAsked ->
                                textMdl "Regions has not been fetched"

                            RemoteData.Failure error ->
                                httpFailureMessage "fetch regions" error

                            RemoteData.Success res ->
                                div []
                                    [ if model.selectedRegion == "" then
                                        textMidMdl "Select a region"
                                      else
                                        textMidMdl "Or select another region"
                                    , regionsSelectBox res.regions
                                    ]

                            _ ->
                                text ""
                        , case model.homePage.awsConfigWebdata of
                            RemoteData.Failure error ->
                                httpFailureMessage "update region config" error

                            _ ->
                                text ""
                        ]
                    ]

            Auth.LoggedOut ->
                text "Error"
          )
        ]


instancesView : Model -> Html Msg
instancesView model =
    let
        selectForClone =
            case model.instancesPage.instancesWebdata of
                RemoteData.NotAsked ->
                    textMdl "Instances has not been fetched"

                RemoteData.Loading ->
                    progressBar model.master_progressKeys "Fetching instances" ProgressKeys.getInstances ""

                RemoteData.Failure error ->
                    httpFailureMessage "fetch instances" error

                RemoteData.Success res ->
                    div []
                        [ instancesTableMdl model res.instances
                        ]
    in
        yellowDivMdl
            [ case model.instancesPage.cloneWebdata of
                RemoteData.Loading ->
                    progressBar model.master_progressKeys "Cloning instance" ProgressKeys.doClone ""

                RemoteData.Failure error ->
                    div []
                        [ httpFailureMessage "clone the instance" error
                        , selectForClone
                        ]

                RemoteData.Success res ->
                    div []
                        [ httpSuccessMessage res.message
                        , selectForClone
                        ]

                RemoteData.NotAsked ->
                    selectForClone
            ]


convertCloneView : Model -> Html Msg
convertCloneView model =
    yellowDivMdl
        [ convertTableMdl model
        ]


convertProcessesView : Model -> Html Msg
convertProcessesView model =
    yellowDivMdl
        [ processesTableMdl model
        ]


convertProcessView : Model -> String -> Html Msg
convertProcessView model pid =
    case model.processPage.processWebData of
        RemoteData.NotAsked ->
            textMdl "Process not fetched"

        RemoteData.Success foundProcess ->
            yellowDivMdl
                [ processTableMdl foundProcess
                ]

        RemoteData.Loading ->
            progressBar model.agent_progressKeys "Fetching process" ProgressKeys.getProcess ""

        RemoteData.Failure error ->
            httpFailureMessage "fetch the process" error


containersListView : Model -> Html Msg
containersListView model =
    whiteDivMdl
        [ navMdl 2 0 model <| tabLabels Router.containersTabs
        , yellowDivMdl
            [ case model.containersPage.containersWebdata of
                RemoteData.NotAsked ->
                    textMdl "Containers has not been fetched"

                RemoteData.Loading ->
                    httpLoadingMessage "Loading ..."

                RemoteData.Success webdata ->
                    containersTableMdl model webdata.containers

                RemoteData.Failure error ->
                    httpFailureMessage "fetch containers" error
            ]
        ]


containerView : Model -> String -> Html Msg
containerView model containerID =
    case model.containerPage.containerWebdata of
        RemoteData.NotAsked ->
            textMdl "Containers has not been fetched"

        RemoteData.Loading ->
            httpLoadingMessage "Loading ..."

        RemoteData.Success webdata ->
            yellowDivMdl
                [ case model.containerPage.containerManagementWebData of
                    RemoteData.NotAsked ->
                        br [] []

                    RemoteData.Loading ->
                        httpLoadingMessage "Loading ..."

                    RemoteData.Success webdata ->
                        httpSuccessMessage webdata.message

                    RemoteData.Failure error ->
                        httpFailureMessage "manage the container" error
                , buttonMdl model 1 (State.Req_Gantry_ContainerPage_Start webdata.container.id) "Start"
                , buttonMdl model 2 (State.Req_Gantry_ContainerPage_Stop webdata.container.id) "Stop"
                , buttonMdl model 3 (State.Req_Gantry_ContainerPage_Restart webdata.container.id) "Restart"
                , buttonMdl model 4 (State.Req_Gantry_ContainerPage_Pause webdata.container.id) "Pause"
                , buttonMdl model 5 (State.Req_Gantry_ContainerPage_UnPause webdata.container.id) "Unpause"
                , containerTableMdl webdata.container
                ]

        RemoteData.Failure error ->
            httpFailureMessage "fetch the container" error


containersCreateView : Model -> Html Msg
containersCreateView model =
    whiteDivMdl
        [ navMdl 2 1 model <| tabLabels Router.containersTabs
        , yellowDivMdl
            [ case model.containerCreatePage.containerCreateWebdata of
                RemoteData.NotAsked ->
                    br [] []

                RemoteData.Loading ->
                    httpLoadingMessage "Loading ..."

                RemoteData.Success webdata ->
                    httpSuccessMessage webdata.message

                RemoteData.Failure error ->
                    httpFailureMessage "create container" error
            , textMidMdl "Details"
            , rightButtonMdl model 0 State.Req_Gantry_ContainersPage_Create "Create"
            , br [] []
            , inputMdl model 0 Input_Gantry_ContainersPage_Create_Name "name" "text" "Name"
            , br [] []
            , checkbox model model.input_Gantry_ContainersPage_Create_Privileged Input_Gantry_ContainersPage_Create_Privileged "Privileged Mode"
            ]
        , yellowDivMdl
            [ textMidMdl "Image"
            , imagesSelectBox model
            ]
        , yellowDivMdl
            [ textMidMdl "Console mode"
            , consoleModeSelectBox
            ]
        , yellowDivMdl
            [ textMidMdl "Port mappings"
            , model.input_Gantry_ContainersPage_Create_Bindings
                |> List.concatMap (\( c, h ) -> [ chipMdl ("Container | " ++ c), chipMdl ("Host | " ++ h), br [] [] ])
                |> div []
            , inputMdl model 2 Input_Gantry_ContainersPage_Create_Container_Port "containerPort" "text" "Container port"
            , inputMdl model 3 Input_Gantry_ContainersPage_Create_Host_Port "hostPort" "text" "Host port"
            , buttonMdl model 1 (InputUpdate_Gantry_ContainersPage_Create_Bindings ( model.input_Gantry_ContainersPage_Create_Container_Port, model.input_Gantry_ContainersPage_Create_Host_Port )) "Add"
            ]
        ]


imagesView : Model -> Html Msg
imagesView model =
    yellowDivMdl
        [ case model.imagesPage.imagesWebdata of
            RemoteData.NotAsked ->
                textMdl "Images has not been fetched"

            RemoteData.Loading ->
                httpLoadingMessage "Loading ..."

            RemoteData.Success webdata ->
                div []
                    [ dockerCredentialsDialog model
                    , br [] []
                    , imagesTableMdl model webdata.images
                    ]

            RemoteData.Failure error ->
                httpFailureMessage "fetch images" error
        ]
