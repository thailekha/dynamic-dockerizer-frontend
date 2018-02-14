module Views exposing (..)

import Html exposing (..)
import RemoteData
import Types.Auth as Auth
import Pages.Router as Router
import Pages.Containers as Containers
import State exposing (..)
import Helpers exposing (..)


globalView : Model -> Html Msg
globalView model =
    (case model.login.authenticationState of
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
            [ (case model.login.credentialsWebdata of
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


homeView : Model -> Html Msg
homeView model =
    centerDiv
        [ -- inline CSS (literal)
          (case model.login.authenticationState of
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


imagesView : Model -> Html Msg
imagesView model =
    div []
        [ navMdl 1 1 model <| tabLabels Router.gantryTabs
        , text "Images"
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
        , buttonMdl model 0 ReqContainers "Get containers"
        , (case model.containers.containersWebdata of
            RemoteData.NotAsked ->
                text "Get containers"

            RemoteData.Loading ->
                text "Loading ..."

            RemoteData.Success response ->
                div [] (List.map (\c -> Containers.containerView c) response.containers)

            RemoteData.Failure error ->
                text (toString error)
          )
        ]


containersCreateView : Model -> Html Msg
containersCreateView model =
    div []
        [ navMdl 2 1 model <| tabLabels Router.containerTabs
        ]



-- ROUTING


e404 : x -> Html Msg
e404 _ =
    div []
        [ text "route not found" ]
