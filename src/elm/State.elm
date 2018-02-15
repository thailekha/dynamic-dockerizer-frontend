port module State exposing (..)

import Http
import RemoteData exposing (WebData)
import Pages.Login as LoginPage
import Pages.Containers as ContainersPage
import Pages.Images as ImagesPage
import Types.Auth as Auth
import Types.Containers as Containers
import Types.CommonResponses as CommonResponses
import Types.Images as Images
import Material
import Navigation exposing (Location)
import Pages.Router as Router
import Set exposing (Set)
import Debug


type alias Model =
    { loginPage : LoginPage.Model
    , containersPage : ContainersPage.Model
    , imagesPage : ImagesPage.Model
    , userNameInput : String
    , accessKeyIdInput : String
    , secretAccessKeyInput : String
    , selectedContainers : Set String
    , selectedImages : Set String
    , route : Router.Route
    , mdl : Material.Model
    }


initModel : Maybe Auth.Credentials -> Router.Route -> Model
initModel initialUser initialRoute =
    { loginPage = LoginPage.init initialUser
    , containersPage = ContainersPage.init
    , imagesPage = ImagesPage.init
    , userNameInput = ""
    , accessKeyIdInput = ""
    , secretAccessKeyInput = ""
    , selectedContainers = Set.empty
    , selectedImages = Set.empty
    , route = initialRoute
    , mdl = Material.model
    }


init : Maybe Auth.Credentials -> Location -> ( Model, Cmd Msg )
init initialUser location =
    let
        route =
            Router.parseLocation location
    in
        ( initModel initialUser route, cmdReqs route )


type Msg
    = UserNameInput String
    | AccessKeyIdInput String
    | SecretAccessKeyInput String
    | ToggleAllContainers
    | ToggleContainers Containers.Container
    | ToggleAllImages
    | ToggleImages Images.Image
    | LoginSubmit
    | LoginResponse (WebData Auth.Credentials)
    | Logout
    | OnContainersResponse (WebData Containers.Containers)
    | ReqStartContainer
    | ReqStopContainer
    | ReqPauseContainer
    | ReqUnPauseContainer
    | ReqDeleteContainer
    | ReqRestartContainer
    | OnContainerManagementResponse String (WebData CommonResponses.StringResponse)
    | OnImagesResponse (WebData Images.Images)
    | ReqRemoveImage
    | OnRemoveImageResponse String (WebData CommonResponses.StringResponse)
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

        ToggleAllImages ->
            let
                fetchedImages =
                    ImagesPage.tryGetImages model.imagesPage
            in
                { model
                    | selectedImages =
                        if allImagesSelected model then
                            Set.empty
                        else
                            Set.fromList <|
                                List.map Images.imageKey <|
                                    ImagesPage.tryGetImages model.imagesPage
                }
                    ! []

        ToggleImages image ->
            { model
                | selectedImages =
                    if Set.member (Images.imageKey image) model.selectedImages then
                        Set.remove (Images.imageKey image) model.selectedImages
                    else
                        Set.insert (Images.imageKey image) model.selectedImages
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

        OnImagesResponse response ->
            ( { model | imagesPage = ImagesPage.updateImagesWebdata model.imagesPage response }, Cmd.none )

        ReqRemoveImage ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqImages model reqRemoveImage
            )

        ReqStartContainer ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerContainerManagement "POST" "/start"
            )

        ReqStopContainer ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerContainerManagement "POST" "/stop"
            )

        ReqRestartContainer ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerContainerManagement "POST" "/restart"
            )

        ReqPauseContainer ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerContainerManagement "POST" "/pause"
            )

        ReqUnPauseContainer ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerContainerManagement "POST" "/unpause"
            )

        ReqDeleteContainer ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerContainerManagement "DELETE" "/remove"
            )

        OnContainerManagementResponse containerID response ->
            ( { model
                | containersPage = ContainersPage.updateContainersManagementWebData model.containersPage containerID response
              }
            , cmdForStringResponse reqContainers response
            )

        OnRemoveImageResponse imageID response ->
            ( { model
                | imagesPage = ImagesPage.updateImagesManagementWebData model.imagesPage imageID response
              }
            , cmdForStringResponse reqImages response
            )

        OnLocationChange location ->
            let
                newRoute =
                    Router.parseLocation location
            in
                ( { model | route = newRoute }, cmdReqs newRoute )

        Mdl msg_ ->
            Material.update Mdl msg_ model

        NoChange ->
            ( model, Cmd.none )


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


reqContainerContainerManagement : String -> String -> String -> Cmd Msg
reqContainerContainerManagement verb suffix containerID =
    Http.request
        { method = verb
        , headers = []
        , url = "http://localhost:3001/api/containers/" ++ containerID ++ suffix
        , body = Http.emptyBody
        , expect = Http.expectJson CommonResponses.decodeStringResponse
        , timeout = Nothing
        , withCredentials = False
        }
        |> RemoteData.sendRequest
        |> Cmd.map (OnContainerManagementResponse containerID)


reqImages : Cmd Msg
reqImages =
    Http.get ("http://localhost:3001/api/images/") Images.decodeImages
        |> RemoteData.sendRequest
        |> Cmd.map OnImagesResponse


reqRemoveImage : String -> Cmd Msg
reqRemoveImage imageID =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = "http://localhost:3001/api/images/" ++ imageID
        , body = Http.emptyBody
        , expect = Http.expectJson CommonResponses.decodeStringResponse
        , timeout = Nothing
        , withCredentials = False
        }
        |> RemoteData.sendRequest
        |> Cmd.map (OnRemoveImageResponse imageID)


allContainersSelected : Model -> Bool
allContainersSelected model =
    Set.size model.selectedContainers == (List.length <| ContainersPage.tryGetContainers model.containersPage)


allImagesSelected : Model -> Bool
allImagesSelected model =
    Set.size model.selectedImages == (List.length <| ImagesPage.tryGetImages model.imagesPage)


containersPageFolder : String -> ContainersPage.Model -> ContainersPage.Model
containersPageFolder containerID nContainersPage =
    ContainersPage.updateContainersManagementWebData nContainersPage containerID RemoteData.Loading


updateContainersPageFromSelectedContainers : Model -> Model
updateContainersPageFromSelectedContainers model =
    { model
        | containersPage = List.foldr containersPageFolder model.containersPage <| Set.toList model.selectedContainers
    }


imagesPageFolder : String -> ImagesPage.Model -> ImagesPage.Model
imagesPageFolder imageID nImagesPage =
    ImagesPage.updateImagesManagementWebData nImagesPage imageID RemoteData.Loading


batchReqContainers : Model -> (String -> Cmd Msg) -> Cmd Msg
batchReqContainers model reqCb =
    Cmd.batch <| List.map (\containerID -> reqCb containerID) <| Set.toList model.selectedContainers


batchReqImages : Model -> (String -> Cmd Msg) -> Cmd Msg
batchReqImages model reqCb =
    Cmd.batch <| List.map (\imageID -> reqCb imageID) <| Set.toList model.selectedImages


cmdForStringResponse : Cmd Msg -> WebData CommonResponses.StringResponse -> Cmd Msg
cmdForStringResponse cb response =
    case response of
        RemoteData.Success _ ->
            cb

        _ ->
            Cmd.none


cmdReqs : Router.Route -> Cmd Msg
cmdReqs newRoute =
    Cmd.batch [ (cmdReqContainers newRoute), (cmdReqImages newRoute) ]


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


cmdReqImages : Router.Route -> Cmd Msg
cmdReqImages newRoute =
    case newRoute of
        Router.GantryRoute gantryRoute ->
            case gantryRoute of
                Router.ImageRoute ->
                    Debug.log "reqContainers due to ImageRoute" reqImages

                _ ->
                    Cmd.none

        _ ->
            Cmd.none
