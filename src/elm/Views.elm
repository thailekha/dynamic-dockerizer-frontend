module Views exposing (..)

import Html exposing (..)
import RemoteData
import Types.Auth as Auth
import Pages.Router as Router
import Pages.Container as ContainerPage
import Pages.Process as ProcessPage
import Types.ProgressKeys as ProgressKeys
import State exposing (..)
import ViewComponents exposing (..)


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
    case model.route of
        Router.LandingRoute ->
            homeView model

        Router.CloneRoute ->
            view_ model
                [ instancesView model
                ]

        Router.ConvertCloneViewRoute ->
            view_ model
                [ navMdl 1 0 model <| tabLabels Router.convertTabs
                , convertCloneView model
                ]

        Router.ConvertProcessesViewRoute ->
            view_ model
                [ navMdl 1 1 model <| tabLabels Router.convertTabs
                , convertProcessesView model
                ]

        Router.ConvertProcessViewRoute pid ->
            view_ model
                [ navMdl 1 1 model <| tabLabels Router.convertTabs
                , convertProcessView model pid
                ]

        Router.GantryContainersViewRoute ->
            view_ model
                [ navMdl 1 0 model <| tabLabels Router.gantryTabs
                , containersListView model
                ]

        Router.GantryContainersCreateRoute ->
            view_ model
                [ navMdl 1 0 model <| tabLabels Router.gantryTabs
                , containersCreateView model
                ]

        Router.GantryContainerViewRoute containerID ->
            view_ model
                [ navMdl 1 0 model <| tabLabels Router.gantryTabs
                , containerView model containerID
                ]

        Router.GantryImageRoute ->
            view_ model
                [ navMdl 1 1 model <| tabLabels Router.gantryTabs
                , imagesView model
                ]

        Router.NotFoundRoute ->
            e404 model


loginView : Model -> Html Msg
loginView model =
    centerDiv <|
        breaker
            [ (case model.loginPage.credentialsWebdata of
                RemoteData.NotAsked ->
                    textMdl "Please login"

                RemoteData.Loading ->
                    textMdl "Loading ..."

                RemoteData.Success rooms ->
                    textMdl "Error"

                RemoteData.Failure error ->
                    textMdl (toString error)
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
                view_ model
                    [ yellowDivMdl
                        [ textMdl ("Hi " ++ creds.userName)
                        , if model.selectedRegion == "" then
                            textMidMdl "Please select EC2 region"
                          else
                            textMidMdl <| "Selected EC2 region: " ++ model.selectedRegion ++ ", or you can select another region"
                        , regionsSelectBox model
                        , case model.homePage.awsConfigWebdata of
                            RemoteData.Failure error ->
                                textMdl <| "Cannot update region config" ++ (toString error)

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
                    textMdl (toString error)

                RemoteData.Success res ->
                    div []
                        [ rightButtonMdl model 0 State.Req_InstancesPage_CloneInstance "Clone"
                        , keyFileSelector model
                        , inputMdl model 0 Input_InstancesPage_KeypairName "keypair_name" "text" "Key pair name"
                        , instancesTableMdl model res.instances
                        ]
    in
        yellowDivMdl
            [ case model.instancesPage.cloneWebdata of
                RemoteData.Loading ->
                    progressBar model.master_progressKeys "Cloning instance" ProgressKeys.doClone ""

                RemoteData.Failure error ->
                    div []
                        [ textMdl (toString error)
                        , selectForClone
                        ]

                _ ->
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
                [ case model.processPage.processConvertWebData of
                    RemoteData.NotAsked ->
                        br [] []

                    RemoteData.Loading ->
                        textMdl "Loading ..."

                    RemoteData.Success webdata ->
                        textMdl <| toString webdata

                    RemoteData.Failure error ->
                        textMdl <| toString error
                , processTableMdl foundProcess
                ]

        RemoteData.Loading ->
            progressBar model.agent_progressKeys "Fetching process" ProgressKeys.getProcess ""

        RemoteData.Failure error ->
            textMdl <| toString error


containersListView : Model -> Html Msg
containersListView model =
    whiteDivMdl
        [ navMdl 2 0 model <| tabLabels Router.containersTabs
        , (let
            managementStatus =
                containersManagementWebDataString model
           in
            if List.length managementStatus > 0 then
                div []
                    [ textMdl "Management status"
                    , listMdl managementStatus
                    ]
            else
                textMdl "No management status"
          )
        , buttonMdl model 1 State.Req_Gantry_ContainersPage_Start "Start"
        , buttonMdl model 2 State.Req_Gantry_ContainersPage_Stop "Stop"
        , buttonMdl model 3 State.Req_Gantry_ContainersPage_Restart "Restart"
        , buttonMdl model 4 State.Req_Gantry_ContainersPage_Pause "Pause"
        , buttonMdl model 5 State.Req_Gantry_ContainersPage_UnPause "Unpause"
        , buttonMdl model 6 State.Req_Gantry_ContainersPage_Delete "Delete"
        , yellowDivMdl [ containersTableMdl model ]
        ]


containerView : Model -> String -> Html Msg
containerView model containerID =
    case ContainerPage.tryGetContainer model.containerPage of
        Ok foundContainer ->
            yellowDivMdl
                [ case model.containerPage.containerManagementWebData of
                    RemoteData.NotAsked ->
                        br [] []

                    RemoteData.Loading ->
                        textMdl "Loading ..."

                    RemoteData.Success webdata ->
                        textMdl <| toString webdata

                    RemoteData.Failure error ->
                        textMdl <| toString error
                , buttonMdl model 1 (State.Req_Gantry_ContainerPage_Start foundContainer.id) "Start"
                , buttonMdl model 2 (State.Req_Gantry_ContainerPage_Stop foundContainer.id) "Stop"
                , buttonMdl model 3 (State.Req_Gantry_ContainerPage_Restart foundContainer.id) "Restart"
                , buttonMdl model 4 (State.Req_Gantry_ContainerPage_Pause foundContainer.id) "Pause"
                , buttonMdl model 5 (State.Req_Gantry_ContainerPage_UnPause foundContainer.id) "Unpause"
                , textMdl "Information"
                , containerTableMdl foundContainer
                ]

        Err err ->
            textMdl <| toString err


containersCreateView : Model -> Html Msg
containersCreateView model =
    whiteDivMdl
        [ navMdl 2 1 model <| tabLabels Router.containersTabs
        , yellowDivMdl
            [ case model.containerCreatePage.containerCreateWebdata of
                RemoteData.NotAsked ->
                    br [] []

                RemoteData.Loading ->
                    textMdl "Loading ..."

                RemoteData.Success webdata ->
                    textMdl <| toString webdata

                RemoteData.Failure error ->
                    textMdl <| toString error
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
        [ (let
            managementStatus =
                imagesManagementWebDataString model
           in
            if List.length managementStatus > 0 then
                div []
                    [ textMdl "Management status"
                    , listMdl managementStatus
                    ]
            else
                textMdl "No management status"
          )
        , br [] []
        , buttonMdl model 1 State.Req_Gantry_ImagesPage_Remove "Remove"
        , imagesTableMdl model
        ]
