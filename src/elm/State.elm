port module State exposing (..)

import Http
import RemoteData exposing (WebData)
import Pages.Login as LoginPage
import Pages.Containers as ContainersPage
import Types.Auth as Auth
import Types.Containers as Containers
import Material
import Navigation exposing (Location)
import Pages.Router as Router


type alias Model =
    { login : LoginPage.Model
    , containers : ContainersPage.Model
    , userNameInput : String
    , accessKeyIdInput : String
    , secretAccessKeyInput : String
    , route : Router.Route
    , mdl : Material.Model
    }


initModel : Maybe Auth.Credentials -> Router.Route -> Model
initModel initialUser initialRoute =
    { login = LoginPage.init initialUser
    , containers = ContainersPage.init
    , userNameInput = ""
    , accessKeyIdInput = ""
    , secretAccessKeyInput = ""
    , route = initialRoute
    , mdl = Material.model
    }


init : Maybe Auth.Credentials -> Location -> ( Model, Cmd Msg )
init initialUser location =
    ( location
        |> Router.parseLocation
        |> initModel initialUser
    , Cmd.none
    )


type Msg
    = UserNameInput String
    | AccessKeyIdInput String
    | SecretAccessKeyInput String
    | LoginSubmit
    | LoginResponse (WebData Auth.Credentials)
    | Logout
    | ReqContainers
    | OnContainersResponse (WebData Containers.Containers)
    | OnLocationChange Location
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
                | login = LoginPage.updateCredentialsWebdata model.login response
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
                | login = LoginPage.init Nothing
                , userNameInput = ""
                , accessKeyIdInput = ""
                , secretAccessKeyInput = ""
              }
            , logout ()
            )

        ReqContainers ->
            ( model, reqContainers )

        OnContainersResponse response ->
            ( { model | containers = ContainersPage.updateContainersWebdata model.containers response }, Cmd.none )

        OnLocationChange location ->
            ( { model | route = (Router.parseLocation location) }, Cmd.none )

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


reqContainers : Cmd Msg
reqContainers =
    Http.get ("http://localhost:3001/api/containers/all") Containers.decodeContainers
        |> RemoteData.sendRequest
        |> Cmd.map OnContainersResponse
