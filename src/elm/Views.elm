module Views exposing (..)

import Html exposing (..)
import RemoteData
import Types.Auth as Auth
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
    div []
        [ Helpers.nav 0 model (tabLabels globalTabs)
        , model |> tryGetTabView model.selectedTab globalTabs
        ]


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
                    [ text ("Hi " ++ creds.userName)
                    , logoutView model
                    ]

            Auth.LoggedOut ->
                text "Error"
          )
        ]


logoutView : Model -> Html Msg
logoutView model =
    buttonMdl model 1 Logout "Logout"


-- Gantry


gantryView : Model -> Html Msg
gantryView model =
    div []
        [ subNav 1 globalTabsLength model (tabLabels gantryTabs)
        , text "Gantry"
        , model |> tryGetTabView (model.selectedTab - globalTabsLength) gantryTabs
        ]


containersView : Model -> Html Msg
containersView model =
    div []
        [ text "Containers"
        ]


imagesView : Model -> Html Msg
imagesView model =
    div []
        [ text "Images"
        ]



-- ROUTING


gantryTabs : List ( String, String, Model -> Html Msg )
gantryTabs =
    [ ( "Containers", "containers", containersView )
    , ( "Images", "images", imagesView )
    ]


globalTabs : List ( String, String, Model -> Html Msg )
globalTabs =
    [ ( "Home", "homes", homeView )
    , ( "Gantry", "gantry", gantryView )
    ]


globalTabsLength : Int
globalTabsLength =
    2


allTabs : List ( String, String, Model -> Html Msg )
allTabs =
    List.concat [ globalTabs, gantryTabs ]
