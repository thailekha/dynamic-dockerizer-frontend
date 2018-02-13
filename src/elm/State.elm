port module State exposing (..)

import Http
import RemoteData exposing (WebData)
import Pages.Login as Login
import Types.Auth as Auth
import Material


type alias Model =
    { login : Login.Model
    , userNameInput : String
    , accessKeyIdInput : String
    , secretAccessKeyInput : String
    , selectedTab : Int
    , mdl : Material.Model
    }


init : Maybe Auth.Credentials -> ( Model, Cmd Msg )
init initialUser =
    ( { login = Login.init initialUser
      , userNameInput = ""
      , accessKeyIdInput = ""
      , secretAccessKeyInput = ""
      , selectedTab = 1
      , mdl = Material.model
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
    | SelectTab Int
    | SelectTabPatch Int Int
    | Mdl (Material.Msg Msg)


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

        SelectTab idx ->
            ( { model | selectedTab = idx }, Cmd.none )

        SelectTabPatch patch idx ->
            ( { model | selectedTab = patch + idx }, Cmd.none )

        Mdl msg_ ->
            Material.update Mdl msg_ model


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
