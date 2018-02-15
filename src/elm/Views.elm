module Views exposing (..)

import Html exposing (..)
import RemoteData
import Types.Auth as Auth
import Pages.Router as Router


--import Pages.Containers as ContainersPage
--import Pages.Images as ImagesPage

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

        Router.GantryRoute gantrySubRoute ->
            gantryView gantrySubRoute model

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
            , inputMdl model 0 UserNameInput "userName" "text" "User name"
            , inputMdl model 1 AccessKeyIdInput "accessKeyId" "text" "Access key ID"
            , inputMdl model 2 SecretAccessKeyInput "secretAccessKey" "password" "Secret access key"
            , buttonMdl model 3 LoginSubmit "Login"
            ]


e404 : x -> Html Msg
e404 _ =
    div []
        [ textMdl "route not found" ]


homeView : Model -> Html Msg
homeView model =
    centerDiv
        [ -- inline CSS (literal)
          (case model.loginPage.authenticationState of
            Auth.LoggedIn creds ->
                div []
                    [ navMdl 0 0 model <| tabLabels Router.globalTabs
                    , text ("Hi " ++ creds.userName)
                    , logoutView model
                    ]

            Auth.LoggedOut ->
                text "Error"
          )
        ]


logoutView : Model -> Html Msg
logoutView model =
    buttonMdl model 1 Logout "Logout"



-- Gantry subview


gantryView : Router.GantrySubRoute -> Model -> Html Msg
gantryView subRoute model =
    div []
        [ navMdl 0 1 model <| tabLabels Router.globalTabs
        , (case subRoute of
            Router.ContainerRoute containerSubRoute ->
                containersView containerSubRoute model

            Router.ImageRoute ->
                imagesView model
          )
        ]



-- Containers subsubview


containersView : Router.ContainerSubRoute -> Model -> Html Msg
containersView subRoute model =
    div []
        [ navMdl 1 0 model <| tabLabels Router.gantryTabs
        , (case subRoute of
            Router.ContainerViewRoute ->
                containersListView model

            Router.ContainerCreateRoute ->
                containersCreateView model
          )
        ]


containersListView : Model -> Html Msg
containersListView model =
    div []
        [ navMdl 2 0 model <| tabLabels Router.containerTabs
        , br [] []
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
        , br [] []
        , buttonMdl model 1 State.ReqStartContainer "Start"
        , buttonMdl model 2 State.ReqStopContainer "Stop"
        , buttonMdl model 3 State.ReqRestartContainer "Restart"
        , buttonMdl model 4 State.NoChange "Pause"
        , buttonMdl model 5 State.NoChange "Unpause"
        , buttonMdl model 6 State.NoChange "Delete"
        , containersTableMdl model
        ]


containersCreateView : Model -> Html Msg
containersCreateView model =
    div []
        [ navMdl 2 1 model <| tabLabels Router.containerTabs
        ]



-- Images subsubview


imagesView : Model -> Html Msg
imagesView model =
    div []
        [ navMdl 1 1 model <| tabLabels Router.gantryTabs
        , br [] []
        , (let
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
        , buttonMdl model 1 State.ReqRemoveImage "Remove"
        , imagesTableMdl model
        ]
