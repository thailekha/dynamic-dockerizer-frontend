module Views exposing (..)

import Html exposing (..)
import Array exposing (Array)
import Dict exposing (Dict)
import RemoteData
import Material.Tabs as Tabs
import Navigation
import RouteUrl as Routing
import Types.Auth as Auth
import State exposing (..)
import Helpers exposing (..)


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
                    ]

            Auth.LoggedOut ->
                text "Error"
          )
        ]


logoutView : Model -> Html Msg
logoutView model =
    buttonMdl model 1 Logout "Logout"


view : Model -> Html Msg
view model =
    (case model.login.authenticationState of
        Auth.LoggedIn _ ->
            div []
                [ nav model
                , (Array.get model.selectedTab tabViews |> Maybe.withDefault e404) model
                ]

        Auth.LoggedOut ->
            loginView model
    )


nav : Model -> Html Msg
nav model =
    Tabs.render Mdl
        [ 0 ]
        model.mdl
        [ Tabs.ripple
        , Tabs.onSelectTab SelectTab
        , Tabs.activeTab model.selectedTab
        ]
        tabLabels
        []


e404 : x -> Html Msg
e404 _ =
    div []
        [ text "route not found" ]



-- ROUTING


tabs : List ( String, String, Model -> Html Msg )
tabs =
    [ ( "Home", "home", homeView )
    , ( "Account", "account", logoutView )
    ]


tabLabels : List (Tabs.Label Msg)
tabLabels =
    List.map (\( label, _, _ ) -> Tabs.label [] [ text label ]) tabs


tabUrls : Array String
tabUrls =
    List.map (\( _, url, _ ) -> url) tabs |> Array.fromList


tabViews : Array (Model -> Html Msg)
tabViews =
    List.map (\( _, _, v ) -> v) tabs |> Array.fromList


urlTabs : Dict String Int
urlTabs =
    List.indexedMap (\idx ( _, url, _ ) -> ( url, idx )) tabs |> Dict.fromList


urlOf : Model -> String
urlOf model =
    "#" ++ (Array.get model.selectedTab tabUrls |> Maybe.withDefault "")


delta2url : Model -> Model -> Maybe Routing.UrlChange
delta2url model1 model2 =
    if model1.selectedTab /= model2.selectedTab then
        { entry = Routing.NewEntry
        , url = urlOf model2
        }
            |> Just
    else
        Nothing


location2messages : Navigation.Location -> List Msg
location2messages location =
    [ case location.hash |> String.dropLeft 1 of
        "" ->
            SelectTab 0

        x ->
            Dict.get x urlTabs
                |> Maybe.withDefault -1
                |> SelectTab
    ]
