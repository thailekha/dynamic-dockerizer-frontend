port module State exposing (..)

import Http
import RemoteData exposing (WebData)
import Pages.Login as LoginPage
import Pages.Containers as ContainersPage
import Types.Auth as Auth
import Types.Containers as Containers
import Types.CommonResponses as CommonResponses
import Material
import Navigation exposing (Location)
import Pages.Router as Router
import Set exposing (Set)
import Debug


type alias Model =
    { loginPage : LoginPage.Model
    , containersPage : ContainersPage.Model
    , userNameInput : String
    , accessKeyIdInput : String
    , secretAccessKeyInput : String
    , selectedContainers : Set String
    , route : Router.Route
    , mdl : Material.Model
    }


initModel : Maybe Auth.Credentials -> Router.Route -> Model
initModel initialUser initialRoute =
    { loginPage = LoginPage.init initialUser
    , containersPage = ContainersPage.init
    , userNameInput = ""
    , accessKeyIdInput = ""
    , secretAccessKeyInput = ""
    , selectedContainers = Set.empty
    , route = initialRoute
    , mdl = Material.model
    }


init : Maybe Auth.Credentials -> Location -> ( Model, Cmd Msg )
init initialUser location =
    let
        route =
            Router.parseLocation location
    in
        ( initModel initialUser route, cmdReqContainers route )


type Msg
    = UserNameInput String
    | AccessKeyIdInput String
    | SecretAccessKeyInput String
    | ToggleAllContainers
    | ToggleContainers Containers.Container
    | LoginSubmit
    | LoginResponse (WebData Auth.Credentials)
    | Logout
    | OnContainersResponse (WebData Containers.Containers)
    | ReqStartContainer
    | OnStartContainerResponse String (WebData CommonResponses.StringResponse)
    | ReqStopContainer
    | OnStopContainerResponse String (WebData CommonResponses.StringResponse)
    | OnLocationChange Location
    | Mdl (Material.Msg Msg)
    | NoChange


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserNameInput str ->
            ( { model | userNameInput = str }, Cmd.none )

        AccessKeyIdInput str ->
            ( { model | accessKeyIdInput = str }, Cmd.none )

        SecretAccessKeyInput str ->
            ( { model | secretAccessKeyInput = str }, Cmd.none )

        ToggleAllContainers ->
            let
                fetchedContainers =
                    ContainersPage.tryGetContainers model.containersPage
            in
                { model
                    | selectedContainers =
                        if allContainersSelected model then
                            Set.empty
                        else
                            Set.fromList <|
                                List.map Containers.containerKey <|
                                    ContainersPage.tryGetContainers model.containersPage
                }
                    ! []

        ToggleContainers container ->
            { model
                | selectedContainers =
                    if Set.member (Containers.containerKey container) model.selectedContainers then
                        Set.remove (Containers.containerKey container) model.selectedContainers
                    else
                        Set.insert (Containers.containerKey container) model.selectedContainers
            }
                ! []

        LoginSubmit ->
            ( model, reqLogin model )

        LoginResponse response ->
            ( { model
                | loginPage = LoginPage.updateCredentialsWebdata model.loginPage response
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
                | loginPage = LoginPage.init Nothing
                , userNameInput = ""
                , accessKeyIdInput = ""
                , secretAccessKeyInput = ""
              }
            , logout ()
            )

        OnContainersResponse response ->
            ( { model | containersPage = ContainersPage.updateContainersWebdata model.containersPage response }, Cmd.none )

        ReqStartContainer ->
            ( { model
                | containersPage = List.foldr containersPageFolder model.containersPage <| Set.toList model.selectedContainers
              }
            , batchReqContainers model reqStartContainer
            )

        OnStartContainerResponse containerID response ->
            ( { model
                | containersPage = ContainersPage.updateContainersManagementWebData model.containersPage containerID response
              }
            , cmdForStringResponse response
            )

        ReqStopContainer ->
            ( { model
                | containersPage = List.foldr containersPageFolder model.containersPage <| Set.toList model.selectedContainers
              }
            , batchReqContainers model reqStopContainer
            )

        OnStopContainerResponse containerID response ->
            ( { model
                | containersPage = ContainersPage.updateContainersManagementWebData model.containersPage containerID response
              }
            , cmdForStringResponse response
            )

        OnLocationChange location ->
            let
                newRoute =
                    Router.parseLocation location
            in
                ( { model | route = newRoute }, cmdReqContainers newRoute )

        Mdl msg_ ->
            Material.update Mdl msg_ model

        NoChange ->
            ( model, Cmd.none )


port logout : () -> Cmd msg


port saveCreds : Auth.Credentials -> Cmd msg


containersPageFolder : String -> ContainersPage.Model -> ContainersPage.Model
containersPageFolder containerID nContainersPage =
    ContainersPage.updateContainersManagementWebData nContainersPage containerID RemoteData.Loading


batchReqContainers : Model -> (String -> Cmd Msg) -> Cmd Msg
batchReqContainers model reqCb =
    Cmd.batch <| List.map (\containerID -> reqCb containerID) <| Set.toList model.selectedContainers


cmdForStringResponse : WebData CommonResponses.StringResponse -> Cmd Msg
cmdForStringResponse response =
    case response of
        RemoteData.Success _ ->
            reqContainers

        _ ->
            Cmd.none


cmdReqContainers : Router.Route -> Cmd Msg
cmdReqContainers newRoute =
    case newRoute of
        Router.GantryRoute gantryRoute ->
            case gantryRoute of
                Router.ContainerRoute containerRoute ->
                    case containerRoute of
                        Router.ContainerViewRoute ->
                            Debug.log "reqContainers due to ContainerViewRoute" reqContainers

                        _ ->
                            Cmd.none

                _ ->
                    Cmd.none

        _ ->
            Cmd.none


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


reqStartContainer : String -> Cmd Msg
reqStartContainer containerID =
    Http.post ("http://localhost:3001/api/containers/" ++ containerID ++ "/start") Http.emptyBody CommonResponses.decodeStringResponse
        |> RemoteData.sendRequest
        |> Cmd.map (OnStartContainerResponse containerID)


reqStopContainer : String -> Cmd Msg
reqStopContainer containerID =
    Http.post ("http://localhost:3001/api/containers/" ++ containerID ++ "/stop") Http.emptyBody CommonResponses.decodeStringResponse
        |> RemoteData.sendRequest
        |> Cmd.map (OnStopContainerResponse containerID)


allContainersSelected : Model -> Bool
allContainersSelected model =
    Set.size model.selectedContainers == (List.length <| ContainersPage.tryGetContainers model.containersPage)
