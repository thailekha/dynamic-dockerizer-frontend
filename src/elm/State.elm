port module State exposing (..)

import Http
import RemoteData exposing (WebData)
import Pages.Login as LoginPage
import Pages.Containers as ContainersPage
import Pages.ContainerCreate as ContainerCreatePage
import Pages.Container as ContainerPage
import Pages.Images as ImagesPage
import Types.Auth as Auth
import Types.Containers as Containers
import Types.ContainerCreater as ContainerCreater
import Types.CommonResponses as CommonResponses
import Types.Images as Images
import Material
import Navigation exposing (Location)
import Pages.Router as Router
import Set exposing (Set)
import Debug
import Json.Encode exposing (Value)
import Json.Decode exposing (decodeValue)
import Dict


type alias Model =
    { loginPage : LoginPage.Model
    , containersPage : ContainersPage.Model
    , containerCreatePage : ContainerCreatePage.Model
    , containerPage : ContainerPage.Model
    , imagesPage : ImagesPage.Model
    , input_LoginPage_UserName : String
    , input_LoginPage_AccessKeyId : String
    , input_LoginPage_SecretAccessKey : String
    , input_Gantry_ContainersPage_SelectedContainers : Set String
    , input_Gantry_ImagesPage_SelectedImages : Set String
    , input_Gantry_ContainersPage_Create_Name : String
    , input_Gantry_ContainersPage_Create_Image : String
    , input_Gantry_ContainersPage_Create_Container_Port : String
    , input_Gantry_ContainersPage_Create_Host_Port : String
    , input_Gantry_ContainersPage_Create_Bindings : List ( String, String )
    , input_Gantry_ContainersPage_Create_Binds : List String
    , input_Gantry_ContainersPage_Create_Privileged : Bool
    , input_Gantry_ContainersPage_Create_OpenStdin : Bool
    , input_Gantry_ContainersPage_Create_Tty : Bool
    , input_Gantry_ImagesPage : String
    , res_Gantry_ContainersPage_Create : WebData CommonResponses.PortResponse
    , route : Router.Route
    , mdl : Material.Model
    }


initModel : Maybe Auth.Credentials -> Router.Route -> Model
initModel initialUser initialRoute =
    { loginPage = LoginPage.init initialUser
    , containersPage = ContainersPage.init
    , containerCreatePage = ContainerCreatePage.init
    , containerPage = ContainerPage.init
    , imagesPage = ImagesPage.init
    , input_LoginPage_UserName = ""
    , input_LoginPage_AccessKeyId = ""
    , input_LoginPage_SecretAccessKey = ""
    , input_Gantry_ContainersPage_SelectedContainers = Set.empty
    , input_Gantry_ImagesPage_SelectedImages = Set.empty
    , input_Gantry_ContainersPage_Create_Name = ""
    , input_Gantry_ContainersPage_Create_Image = ""
    , input_Gantry_ContainersPage_Create_Container_Port = ""
    , input_Gantry_ContainersPage_Create_Host_Port = ""
    , input_Gantry_ContainersPage_Create_Bindings = []
    , input_Gantry_ContainersPage_Create_Binds = []
    , input_Gantry_ContainersPage_Create_Privileged = False
    , input_Gantry_ContainersPage_Create_OpenStdin = True
    , input_Gantry_ContainersPage_Create_Tty = True
    , input_Gantry_ImagesPage = ""
    , res_Gantry_ContainersPage_Create = RemoteData.NotAsked
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
    = Input_LoginPage_UserName String
    | Input_LoginPage_AccessKeyId String
    | Input_LoginPage_SecretAccessKey String
    | Req_LoginPage_Submit
    | Res_LoginPage_Login (WebData Auth.Credentials)
    | Req_LoginPage_Logout
    | Input_Gantry_ContainersPage_ToggleAll
    | Input_Gantry_ContainersPage_Toggle Containers.Container
    | Res_Gantry_ContainersPage_Containers Value
    | Req_Gantry_ContainersPage_Start
    | Req_Gantry_ContainersPage_Stop
    | Req_Gantry_ContainersPage_Pause
    | Req_Gantry_ContainersPage_UnPause
    | Req_Gantry_ContainersPage_Delete
    | Req_Gantry_ContainersPage_Restart
    | Req_Gantry_ContainersPage_Create
    | Res_Gantry_ContainersPage_Create Value
    | Res_Gantry_ContainersPage_Management String (WebData CommonResponses.StringResponse)
    | Res_Gantry_ContainerPage_Management String (WebData CommonResponses.StringResponse)
    | Input_Gantry_ContainersPage_Create_Name String
    | Input_Gantry_ContainersPage_Create_Image String
    | Input_Gantry_ContainersPage_Create_Container_Port String
    | Input_Gantry_ContainersPage_Create_Host_Port String
    | InputUpdate_Gantry_ContainersPage_Create_Bindings ( String, String )
    | InputUpdate_Gantry_ContainersPage_Create_Binds String
    | InputDelete_Gantry_ContainersPage_Create_Bindings ( String, String )
    | InputDelete_Gantry_ContainersPage_Create_Binds String
    | Input_Gantry_ContainersPage_Create_Privileged
    | Input_Gantry_ContainersPage_Create_ConsoleMode String
    | Res_Gantry_ContainerPage_Get Value
    | Req_Gantry_ContainerPage_Start String
    | Req_Gantry_ContainerPage_Stop String
    | Req_Gantry_ContainerPage_Restart String
    | Req_Gantry_ContainerPage_Pause String
    | Req_Gantry_ContainerPage_UnPause String
    | Res_Gantry_ImagesPage_Get (WebData Images.Images)
    | Input_Gantry_ImagesPage_ToggleAll
    | Input_Gantry_ImagesPage_Toggle Images.Image
    | Req_Gantry_ImagesPage_Remove
    | Res_Gantry_ImagesPage_Remove String (WebData CommonResponses.StringResponse)
    | OnLocationChange Location -- routing
    | Mdl (Material.Msg Msg) -- styling
    | NoChange -- for dev
    | NoChangeText String -- for dev


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input_LoginPage_UserName str ->
            ( { model | input_LoginPage_UserName = str }, Cmd.none )

        Input_LoginPage_AccessKeyId str ->
            ( { model | input_LoginPage_AccessKeyId = str }, Cmd.none )

        Input_LoginPage_SecretAccessKey str ->
            ( { model | input_LoginPage_SecretAccessKey = str }, Cmd.none )

        Input_Gantry_ContainersPage_ToggleAll ->
            let
                fetchedContainers =
                    ContainersPage.tryGetContainers model.containersPage
            in
                { model
                    | input_Gantry_ContainersPage_SelectedContainers =
                        if allContainersSelected model then
                            Set.empty
                        else
                            Set.fromList <|
                                List.map Containers.containerKey <|
                                    ContainersPage.tryGetContainers model.containersPage
                }
                    ! []

        Input_Gantry_ContainersPage_Toggle container ->
            { model
                | input_Gantry_ContainersPage_SelectedContainers =
                    if Set.member (Containers.containerKey container) model.input_Gantry_ContainersPage_SelectedContainers then
                        Set.remove (Containers.containerKey container) model.input_Gantry_ContainersPage_SelectedContainers
                    else
                        Set.insert (Containers.containerKey container) model.input_Gantry_ContainersPage_SelectedContainers
            }
                ! []

        Input_Gantry_ImagesPage_ToggleAll ->
            let
                fetchedImages =
                    ImagesPage.tryGetImages model.imagesPage
            in
                { model
                    | input_Gantry_ImagesPage_SelectedImages =
                        if allImagesSelected model then
                            Set.empty
                        else
                            Set.fromList <|
                                List.map Images.imageKey <|
                                    ImagesPage.tryGetImages model.imagesPage
                }
                    ! []

        Input_Gantry_ImagesPage_Toggle image ->
            { model
                | input_Gantry_ImagesPage_SelectedImages =
                    if Set.member (Images.imageKey image) model.input_Gantry_ImagesPage_SelectedImages then
                        Set.remove (Images.imageKey image) model.input_Gantry_ImagesPage_SelectedImages
                    else
                        Set.insert (Images.imageKey image) model.input_Gantry_ImagesPage_SelectedImages
            }
                ! []

        Req_LoginPage_Submit ->
            ( model, reqLogin model )

        Res_LoginPage_Login response ->
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

        Req_LoginPage_Logout ->
            ( { model
                | loginPage = LoginPage.init Nothing
                , input_LoginPage_UserName = ""
                , input_LoginPage_AccessKeyId = ""
                , input_LoginPage_SecretAccessKey = ""
              }
            , logout ()
            )

        Res_Gantry_ContainersPage_Containers response ->
            let
                nWebdata =
                    (case
                        decodeValue CommonResponses.decodePortResponse response
                     of
                        Ok decodedResponse ->
                            if decodedResponse.success then
                                (case
                                    decodeValue Containers.decodeContainers response
                                 of
                                    Ok decodedContainers ->
                                        RemoteData.succeed decodedContainers

                                    Err message ->
                                        badPayloadHttp message
                                )
                            else
                                badPayloadHttp decodedResponse.message

                        Err message ->
                            badPayloadHttp message
                    )
            in
                { model | containersPage = ContainersPage.updateContainersWebdata model.containersPage nWebdata } ! []

        Res_Gantry_ContainerPage_Get response ->
            case
                decodeValue CommonResponses.decodePortResponse response
            of
                Ok decodedResponse ->
                    if decodedResponse.success then
                        (case
                            decodeValue Containers.decodeContainerGet response
                         of
                            Ok decodedContainer ->
                                { model
                                    | containerPage =
                                        RemoteData.succeed decodedContainer
                                            |> ContainerPage.updateContainerWebdata model.containerPage
                                }
                                    ! []

                            Err message ->
                                { model
                                    | containerPage =
                                        badPayloadHttp message
                                            |> ContainerPage.updateContainerWebdata model.containerPage
                                }
                                    ! []
                        )
                    else
                        { model
                            | containerPage =
                                badPayloadHttp decodedResponse.message
                                    |> ContainerPage.updateContainerWebdata model.containerPage
                        }
                            ! []

                Err message ->
                    { model
                        | containerPage =
                            badPayloadHttp message
                                |> ContainerPage.updateContainerWebdata model.containerPage
                    }
                        ! []

        Res_Gantry_ImagesPage_Get response ->
            ( { model
                | imagesPage = ImagesPage.updateImagesWebdata model.imagesPage response
              }
            , Cmd.none
            )

        Req_Gantry_ImagesPage_Remove ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqImages model reqRemoveImage
            )

        Req_Gantry_ContainersPage_Start ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerManagement "POST" "/start"
            )

        Req_Gantry_ContainersPage_Stop ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerManagement "POST" "/stop"
            )

        Req_Gantry_ContainersPage_Restart ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerManagement "POST" "/restart"
            )

        Req_Gantry_ContainersPage_Pause ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerManagement "POST" "/pause"
            )

        Req_Gantry_ContainersPage_UnPause ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerManagement "POST" "/unpause"
            )

        Req_Gantry_ContainersPage_Delete ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerManagement "DELETE" "/remove"
            )

        Req_Gantry_ContainerPage_Start containerID ->
            ( { model
                | containerPage = ContainerPage.updateContainerManagementWebData model.containerPage RemoteData.Loading
              }
            , reqContainerManagement2 "POST" "/start" containerID
            )

        Req_Gantry_ContainerPage_Stop containerID ->
            ( { model
                | containerPage = ContainerPage.updateContainerManagementWebData model.containerPage RemoteData.Loading
              }
            , reqContainerManagement2 "POST" "/stop" containerID
            )

        Req_Gantry_ContainerPage_Restart containerID ->
            ( { model
                | containerPage = ContainerPage.updateContainerManagementWebData model.containerPage RemoteData.Loading
              }
            , reqContainerManagement2 "POST" "/restart" containerID
            )

        Req_Gantry_ContainerPage_Pause containerID ->
            ( { model
                | containerPage = ContainerPage.updateContainerManagementWebData model.containerPage RemoteData.Loading
              }
            , reqContainerManagement2 "POST" "/pause" containerID
            )

        Req_Gantry_ContainerPage_UnPause containerID ->
            ( { model
                | containerPage = ContainerPage.updateContainerManagementWebData model.containerPage RemoteData.Loading
              }
            , reqContainerManagement2 "POST" "/unpause" containerID
            )

        Input_Gantry_ContainersPage_Create_Name str ->
            ( { model
                | input_Gantry_ContainersPage_Create_Name = str
              }
            , Cmd.none
            )

        Input_Gantry_ContainersPage_Create_Image imageID ->
            ( { model
                | input_Gantry_ContainersPage_Create_Image = imageID
              }
            , Cmd.none
            )

        Input_Gantry_ContainersPage_Create_Container_Port str ->
            ( { model
                | input_Gantry_ContainersPage_Create_Container_Port = str
              }
            , Cmd.none
            )

        Input_Gantry_ContainersPage_Create_Host_Port str ->
            ( { model
                | input_Gantry_ContainersPage_Create_Host_Port = str
              }
            , Cmd.none
            )

        InputUpdate_Gantry_ContainersPage_Create_Bindings ( containerPort, hostPort ) ->
            let
                ( parsedContainerPort, parsedHostPort ) =
                    ( String.toInt containerPort, String.toInt hostPort )
            in
                case parsedContainerPort of
                    Ok _ ->
                        case parsedHostPort of
                            Ok _ ->
                                ( { model
                                    | input_Gantry_ContainersPage_Create_Bindings =
                                        Set.toList <| Set.fromList <| ( containerPort, hostPort ) :: model.input_Gantry_ContainersPage_Create_Bindings
                                  }
                                , Cmd.none
                                )

                            Err _ ->
                                ( model, Cmd.none )

                    Err _ ->
                        ( model, Cmd.none )

        InputDelete_Gantry_ContainersPage_Create_Bindings ( containerPort, hostPort ) ->
            ( { model
                | input_Gantry_ContainersPage_Create_Bindings =
                    Set.toList <| Set.remove ( containerPort, hostPort ) <| Set.fromList <| model.input_Gantry_ContainersPage_Create_Bindings
              }
            , Cmd.none
            )

        InputUpdate_Gantry_ContainersPage_Create_Binds bind ->
            ( { model
                | input_Gantry_ContainersPage_Create_Binds = Set.toList <| Set.fromList <| bind :: model.input_Gantry_ContainersPage_Create_Binds
              }
            , Cmd.none
            )

        InputDelete_Gantry_ContainersPage_Create_Binds bind ->
            ( { model
                | input_Gantry_ContainersPage_Create_Binds = Set.toList <| Set.remove bind <| Set.fromList model.input_Gantry_ContainersPage_Create_Binds
              }
            , Cmd.none
            )

        Input_Gantry_ContainersPage_Create_Privileged ->
            ( { model
                | input_Gantry_ContainersPage_Create_Privileged = not model.input_Gantry_ContainersPage_Create_Privileged
              }
            , Cmd.none
            )

        Input_Gantry_ContainersPage_Create_ConsoleMode mode ->
            let
                modeValue =
                    ContainerCreater.consoleValue mode
            in
                case modeValue of
                    Just ( std, tty ) ->
                        ( { model
                            | input_Gantry_ContainersPage_Create_OpenStdin = std
                            , input_Gantry_ContainersPage_Create_Tty = tty
                          }
                        , Cmd.none
                        )

                    Nothing ->
                        ( model, Cmd.none )

        Req_Gantry_ContainersPage_Create ->
            ( { model
                | containerCreatePage = ContainerCreatePage.updateContainerCreateWebdata model.containerCreatePage RemoteData.Loading
              }
            , reqCreateContainer <|
                ContainerCreater.encodeContainerCreater
                    model.input_Gantry_ContainersPage_Create_Name
                    model.input_Gantry_ContainersPage_Create_Image
                    model.input_Gantry_ContainersPage_Create_Bindings
                    model.input_Gantry_ContainersPage_Create_Binds
                    model.input_Gantry_ContainersPage_Create_Privileged
                    model.input_Gantry_ContainersPage_Create_OpenStdin
                    model.input_Gantry_ContainersPage_Create_Tty
            )

        Res_Gantry_ContainersPage_Create response ->
            let
                nWebdata =
                    (case
                        decodeValue CommonResponses.decodePortResponse response
                     of
                        Ok decodedResponse ->
                            if decodedResponse.success then
                                RemoteData.succeed decodedResponse
                            else
                                badPayloadHttp decodedResponse.message

                        Err message ->
                            badPayloadHttp message
                    )
            in
                { model
                    | res_Gantry_ContainersPage_Create = nWebdata
                    , containerCreatePage = ContainerCreatePage.updateContainerCreateWebdata model.containerCreatePage nWebdata
                }
                    ! []

        Res_Gantry_ContainersPage_Management containerID response ->
            ( { model
                | containersPage = ContainersPage.updateContainersManagementWebData model.containersPage containerID response
              }
            , cmdForStringResponse (reqContainers ()) response
            )

        Res_Gantry_ContainerPage_Management containerID response ->
            ( { model
                | containerPage = ContainerPage.updateContainerManagementWebData model.containerPage response
              }
            , reqContainer containerID
            )

        Res_Gantry_ImagesPage_Remove imageID response ->
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

        NoChangeText _ ->
            ( model, Cmd.none )


port logout : () -> Cmd msg


port saveCreds : Auth.Credentials -> Cmd msg


port reqContainers : () -> Cmd msg


port onContainersResponse : (Value -> msg) -> Sub msg


port reqContainer : String -> Cmd msg


port onContainerResponse : (Value -> msg) -> Sub msg


port reqCreateContainer : Value -> Cmd msg


port onCreateContainerResponse : (Value -> msg) -> Sub msg


badPayloadHttp : String -> RemoteData.RemoteData Http.Error a
badPayloadHttp body =
    RemoteData.mapError
        (Http.Response "" { code = -1, message = "" } Dict.empty body
            |> Http.BadPayload "Cannot decode payload from port"
            |> always
        )
        (RemoteData.Failure "")


subscriptions : a -> Sub Msg
subscriptions model =
    Sub.batch
        [ onContainersResponse Res_Gantry_ContainersPage_Containers
        , onCreateContainerResponse Res_Gantry_ContainersPage_Create
        , onContainerResponse Res_Gantry_ContainerPage_Get
        ]


reqLogin : Model -> Cmd Msg
reqLogin model =
    let
        credentialsInput =
            Auth.constructCredentials model.input_LoginPage_UserName model.input_LoginPage_AccessKeyId model.input_LoginPage_SecretAccessKey
    in
        Http.post
            ("http://localhost:8083/iam/verify")
            (Http.jsonBody <| Auth.encodeCredentials credentialsInput)
            (Auth.decodeCredentials credentialsInput)
            |> RemoteData.sendRequest
            |> Cmd.map Res_LoginPage_Login



-- Containers


reqContainerManagement : String -> String -> String -> Cmd Msg
reqContainerManagement verb suffix containerID =
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
        |> Cmd.map (Res_Gantry_ContainersPage_Management containerID)


reqContainerManagement2 : String -> String -> String -> Cmd Msg
reqContainerManagement2 verb suffix containerID =
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
        |> Cmd.map (Res_Gantry_ContainerPage_Management containerID)



-- Image


reqImages : Cmd Msg
reqImages =
    Http.get ("http://localhost:3001/api/images/") Images.decodeImages
        |> RemoteData.sendRequest
        |> Cmd.map Res_Gantry_ImagesPage_Get


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
        |> Cmd.map (Res_Gantry_ImagesPage_Remove imageID)


allContainersSelected : Model -> Bool
allContainersSelected model =
    Set.size model.input_Gantry_ContainersPage_SelectedContainers == (List.length <| ContainersPage.tryGetContainers model.containersPage)


allImagesSelected : Model -> Bool
allImagesSelected model =
    Set.size model.input_Gantry_ImagesPage_SelectedImages == (List.length <| ImagesPage.tryGetImages model.imagesPage)


containersPageFolder : String -> ContainersPage.Model -> ContainersPage.Model
containersPageFolder containerID nContainersPage =
    ContainersPage.updateContainersManagementWebData nContainersPage containerID RemoteData.Loading


updateContainersPageFromSelectedContainers : Model -> Model
updateContainersPageFromSelectedContainers model =
    { model
        | containersPage = List.foldr containersPageFolder model.containersPage <| Set.toList model.input_Gantry_ContainersPage_SelectedContainers
    }


imagesPageFolder : String -> ImagesPage.Model -> ImagesPage.Model
imagesPageFolder imageID nImagesPage =
    ImagesPage.updateImagesManagementWebData nImagesPage imageID RemoteData.Loading


batchReqContainers : Model -> (String -> Cmd Msg) -> Cmd Msg
batchReqContainers model reqCb =
    Cmd.batch <| List.map (\containerID -> reqCb containerID) <| Set.toList model.input_Gantry_ContainersPage_SelectedContainers


batchReqImages : Model -> (String -> Cmd Msg) -> Cmd Msg
batchReqImages model reqCb =
    Cmd.batch <| List.map (\imageID -> reqCb imageID) <| Set.toList model.input_Gantry_ImagesPage_SelectedImages


cmdForStringResponse : Cmd Msg -> WebData CommonResponses.StringResponse -> Cmd Msg
cmdForStringResponse cb response =
    case response of
        RemoteData.Success _ ->
            cb

        _ ->
            Cmd.none


cmdReqs : Router.Route -> Cmd Msg
cmdReqs newRoute =
    case newRoute of
        Router.GantryContainersViewRoute ->
            Debug.log "reqContainers due to GantryContainersViewRoute" (reqContainers ())

        Router.GantryContainerViewRoute containerID ->
            Debug.log "reqContainer due to GantryContainerViewRoute" (reqContainer containerID)

        Router.GantryContainersCreateRoute ->
            Debug.log "reqContainers due to GantryContainersCreateRoute" Cmd.batch [ (reqContainers ()), reqImages ]

        Router.GantryImageRoute ->
            Debug.log "reqImages due to GantryImageRoute" reqImages

        _ ->
            Cmd.none
