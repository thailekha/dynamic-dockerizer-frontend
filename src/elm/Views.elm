module Views exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import RemoteData
import Types.Auth as Auth
import State exposing (..)


loginView : Model -> Html Msg
loginView model =
    div []
        [ (case model.login.credentialsWebdata of
            RemoteData.NotAsked ->
                text "Please login"

            RemoteData.Loading ->
                text "Loading ..."

            RemoteData.Success rooms ->
                text "Error"

            RemoteData.Failure error ->
                text (toString error)
          )
        , br [] []
        , text "Username:"
        , br [] []
        , input [ name "userName", type_ "text", onInput UserNameInput ] []
        , br [] []
        , text "Access key ID:"
        , br [] []
        , input [ name "accessKeyId", type_ "text", onInput AccessKeyIdInput ] []
        , br [] []
        , text "Secret access key:"
        , br [] []
        , input [ name "secretAccessKey", type_ "password", onInput SecretAccessKeyInput ] []
        , br [] []
        , button [ onClick LoginSubmit ] [ text "Login" ]
        ]


homeView : String -> Html Msg
homeView userName =
    div []
        [ text ("Hi " ++ userName)
        , br [] []
        , button [ onClick Logout ] [ text "Logout" ]
        ]


view : Model -> Html Msg
view model =
    div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
        [ -- inline CSS (literal)
          (case model.login.authenticationState of
            Auth.LoggedIn creds ->
                homeView creds.userName

            Auth.LoggedOut ->
                loginView model
          )
        ]
