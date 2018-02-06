port module Components.CredsController exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Components.Creds as Creds
import RemoteData exposing (WebData)
import Http


type alias Model =
    { state : Creds.AuthenticationState
    , credentialsResponse : WebData Creds.Credentials
    , credentialsInput : Creds.Credentials
    }


init : Maybe Creds.Credentials -> Model
init initialData =
    { state =
        case initialData of
            Just creds ->
                Creds.LoggedIn creds

            Nothing ->
                Creds.LoggedOut
    , credentialsResponse = RemoteData.NotAsked
    , credentialsInput = initCredentialsInput
    }


initCredentialsInput : Creds.Credentials
initCredentialsInput =
    { userName = ""
    , accessKeyId = ""
    , secretAccessKey = ""
    }


type Msg
    = UserNameInput String
    | AccessKeyIdInput String
    | SecretAccessKeyInput String
    | Login
    | LoginResponse (WebData Creds.Credentials)
    | Logout


port logout : () -> Cmd msg


port saveCreds : Creds.Credentials -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserNameInput str ->
            ( { model | credentialsInput = Creds.updateUserNameInput model.credentialsInput str }, Cmd.none )

        AccessKeyIdInput str ->
            ( { model | credentialsInput = Creds.updateAccessKeyIdInput model.credentialsInput str }, Cmd.none )

        SecretAccessKeyInput str ->
            ( { model | credentialsInput = Creds.updateSecretAccessKeyInput model.credentialsInput str }, Cmd.none )

        Login ->
            ( model, reqLogin model )

        LoginResponse response ->
            ( { model
                | credentialsResponse = response
                , state =
                    (case response of
                        RemoteData.Success creds ->
                            Creds.LoggedIn creds

                        _ ->
                            model.state
                    )
              }
            , (case response of
                RemoteData.Success creds ->
                    saveCreds creds

                _ ->
                    Cmd.none
              )
            )

        Logout ->
            ( { model
                | state = Creds.LoggedOut
                , credentialsResponse = RemoteData.NotAsked
                , credentialsInput = initCredentialsInput
              }
            , logout ()
            )


loginForm : Model -> Html Msg
loginForm model =
    div []
        [ (case model.credentialsResponse of
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
        , button [ onClick Login ] [ text "Login" ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ (case (tryGetCreds model) of
            Just creds ->
                text ("Hi " ++ creds.userName)

            Nothing ->
                text "Error"
          )
        , br [] []
        , button [ onClick Logout ] [ text "Logout" ]
        ]


tryGetCreds : Model -> Maybe Creds.Credentials
tryGetCreds model =
    case model.state of
        Creds.LoggedIn creds ->
            Just creds

        Creds.LoggedOut ->
            Nothing


either : Model -> a -> a -> a
either model x y =
    case model.state of
        Creds.LoggedIn _ ->
            x

        Creds.LoggedOut ->
            y


reqLogin : Model -> Cmd Msg
reqLogin model =
    Http.post
        ("http://localhost:8083/ec2/user")
        (Http.jsonBody (Creds.encodeCredentials model.credentialsInput))
        (Creds.decodeCredentials model.credentialsInput)
        |> RemoteData.sendRequest
        |> Cmd.map LoginResponse
