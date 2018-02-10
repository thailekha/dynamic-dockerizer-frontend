port module State exposing (..)

import Http
import RemoteData exposing (WebData)
import Pages.Login as Login
import Types.Auth as Auth


type alias Model =
    { login : Login.Model
    , userNameInput : String
    , accessKeyIdInput : String
    , secretAccessKeyInput : String
    }


init : Maybe Auth.Credentials -> ( Model, Cmd Msg )
init initialUser =
    ( { login = Login.init initialUser
      , userNameInput = ""
      , accessKeyIdInput = ""
      , secretAccessKeyInput = ""
      }
    , Cmd.none
    )


type Msg
    = UserNameInput String
    | AccessKeyIdInput String
    | SecretAccessKeyInput String
    | LoginSubmit
    | LoginResponse (WebData Auth.Credentials)
    | Logout


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserNameInput str ->
            ( { model | userNameInput = str }, Cmd.none )

        AccessKeyIdInput str ->
            ( { model | accessKeyIdInput = str }, Cmd.none )

        SecretAccessKeyInput str ->
            ( { model | secretAccessKeyInput = str }, Cmd.none )

        LoginSubmit ->
            ( model, reqLogin model )

        LoginResponse response ->
            ( { model
                | login = Login.updateCredentialsWebdata model.login response
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
                | login = Login.init Nothing
                , userNameInput = ""
                , accessKeyIdInput = ""
                , secretAccessKeyInput = ""
              }
            , logout ()
            )


port logout : () -> Cmd msg


port saveCreds : Auth.Credentials -> Cmd msg


reqLogin : Model -> Cmd Msg
reqLogin model =
    let
        credentialsInput =
            Auth.constructCredentials model.userNameInput model.accessKeyIdInput model.secretAccessKeyInput
    in
        Http.post
            ("http://localhost:8083/iam/verify")
            (Http.jsonBody <| Auth.encodeCredentials credentialsInput)
            (Auth.decodeCredentials credentialsInput)
            |> RemoteData.sendRequest
            |> Cmd.map LoginResponse
