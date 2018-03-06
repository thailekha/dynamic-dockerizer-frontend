port module State exposing (..)

import Http
import RemoteData exposing (WebData)
import Pages.Login as LoginPage
import Pages.Containers as ContainersPage
import Pages.ContainerCreate as ContainerCreatePage
import Pages.Container as ContainerPage
import Pages.Images as ImagesPage
import Pages.Instances as InstancesPage
import Pages.Convert as ConvertPage
import Pages.Home as HomePage
import Types.Auth as Auth
import Types.Containers as Containers
import Types.ContainerCreater as ContainerCreater
import Types.CommonResponses as CommonResponses
import Types.Images as Images
import Types.Instances as Instances
import Types.Processes as Processes
import Types.ProgressKeys as ProgressKeys
import Material
import Navigation exposing (Location)
import Pages.Router as Router
import Set exposing (Set)
import Debug
import Json.Encode as Encode
import Json.Decode exposing (Value, decodeValue, string, field)
import Dict
import Time exposing (Time, second)
import FileReader exposing (NativeFile)
import Task


type alias Model =
    { loginPage : LoginPage.Model
    , homePage : HomePage.Model
    , instancesPage : InstancesPage.Model
    , convertPage : ConvertPage.Model
    , containersPage : ContainersPage.Model
    , containerCreatePage : ContainerCreatePage.Model
    , containerPage : ContainerPage.Model
    , imagesPage : ImagesPage.Model
    , selectedRegion : String
    , input_InstancesPage_Keyfile : Maybe NativeFile
    , input_InstancesPage_KeypairName : String
    , input_InstancesPage_SelectedInstance : String
    , input_ConvertPage_SelectedProcesses : Set String
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
    , ec2_url_input : String
    , ec2_url : String
    , progressKeys : ProgressKeys.ProgressKeys
    , route : Router.Route
    , mdl : Material.Model
    }


initModel : Maybe Value -> Router.Route -> Model
initModel config initialRoute =
    { loginPage = LoginPage.init config
    , homePage = HomePage.init
    , instancesPage = InstancesPage.init
    , convertPage = ConvertPage.init
    , containersPage = ContainersPage.init
    , containerCreatePage = ContainerCreatePage.init
    , containerPage = ContainerPage.init
    , imagesPage = ImagesPage.init
    , selectedRegion =
        case config of
            Just initialData ->
                case (decodeValue (field "ec2Region" string) initialData) of
                    Ok ec2Region ->
                        ec2Region

                    Err _ ->
                        Debug.log "Cannot decode ec2Region from config" config
                            |> always "eu-west-1"

            Nothing ->
                "eu-west-1"
    , input_InstancesPage_Keyfile = Nothing
    , input_InstancesPage_KeypairName = ""
    , input_InstancesPage_SelectedInstance = ""
    , input_ConvertPage_SelectedProcesses = Set.empty
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
    , ec2_url_input = ""
    , ec2_url =
        case config of
            Just initialData ->
                case (decodeValue (field "ec2Url" string) initialData) of
                    Ok ec2Url ->
                        ec2Url

                    Err _ ->
                        Debug.log "Cannot decode ec2Url from config" config
                            |> always ""

            Nothing ->
                ""
    , progressKeys = ProgressKeys.init
    , route = initialRoute
    , mdl = Material.model
    }


init : Maybe Value -> Location -> ( Model, Cmd Msg )
init config location =
    let
        route =
            Router.parseLocation location
    in
        let
            initializedModel =
                initModel config route
        in
            sendRequestsBasedOnRoute initializedModel route


type Msg
    = Input_LoginPage_UserName String
    | Input_LoginPage_AccessKeyId String
    | Input_LoginPage_SecretAccessKey String
    | Req_LoginPage_Submit
    | Res_LoginPage_Login (WebData Auth.Credentials)
    | Req_LoginPage_Logout
    | Res_HomePage_CreateWorkspace (WebData CommonResponses.StringResponse)
    | Res_HomePage_GetRegions (WebData CommonResponses.RegionsResponse)
    | Input_HomePage_Region String
    | Res_HomePage_UpdateAWSConfig (WebData CommonResponses.StringResponse)
    | Input_InstancesPage_Keyfile (List NativeFile)
    | Input_InstancesPage_KeypairName String
    | Input_InstancesPage_Toggle Instances.Instance
    | Req_InstancesPage_GetInstances (WebData ProgressKeys.ProgressKey)
    | Res_InstancesPage_GetInstances String (WebData Instances.Instances)
    | Req_InstancesPage_CloneInstance
    | Req_InstancesPage_PrepareForClone (WebData ProgressKeys.ProgressKey)
    | Req_InstancesPage_Clone String (WebData CommonResponses.StringResponse)
    | Res_InstancesPage_Clone String (WebData CommonResponses.StringResponse)
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
    | Ec2_URL_Input String
    | Ec2_URL_Set
    | Ec2_URL_From_LocalStorage String
    | Ec2_URL_NotSet -- make a snackbar for this
    | Req_GetClone (WebData ProgressKeys.ProgressKey)
    | Res_GetClone_Then_Req_GetProcess String (WebData Instances.Clone)
    | Res_GetProcesses (WebData Processes.Processes)
    | Input_ConvertPage_ToggleAll
    | Input_ConvertPage_Toggle Processes.Process
    | Req_ConvertProcesses
    | Res_ConvertProcess String (WebData CommonResponses.StringResponse)
    | Res_ProgressStatus String (WebData ProgressKeys.ProgressStatus)
    | NotSendingRequest_DeleteProgressKey String
    | OnLocationChange Location -- routing
    | Mdl (Material.Msg Msg) -- styling
    | Tick Time
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
            let
                newModel =
                    { model
                        | loginPage = LoginPage.updateCredentialsWebdata model.loginPage response
                    }
            in
                case response of
                    RemoteData.Success creds ->
                        ( newModel, Cmd.batch [ saveCreds creds, reqCreateWorkspace newModel, reqRegions newModel ] )

                    _ ->
                        newModel ! []

        Req_LoginPage_Logout ->
            ( { model
                | loginPage = LoginPage.init Nothing
                , input_LoginPage_UserName = ""
                , input_LoginPage_AccessKeyId = ""
                , input_LoginPage_SecretAccessKey = ""
              }
            , logout ()
            )

        Res_HomePage_CreateWorkspace _ ->
            model ! []

        Res_HomePage_GetRegions response ->
            { model | homePage = HomePage.updateRegionswebdata model.homePage response } ! []

        Input_HomePage_Region region ->
            let
                newModel =
                    { model | selectedRegion = region }
            in
                newModel ! [ saveEc2Region region, reqUpdateAWSConfig newModel ]

        Res_HomePage_UpdateAWSConfig response ->
            { model | homePage = HomePage.updateAwsconfigwebdata model.homePage response } ! []

        Input_InstancesPage_Keyfile file ->
            case file of
                -- Only handling case of a single file
                [ f ] ->
                    { model | input_InstancesPage_Keyfile = Just f } ! []

                _ ->
                    model ! []

        Input_InstancesPage_KeypairName name ->
            { model | input_InstancesPage_KeypairName = name } ! []

        Input_InstancesPage_Toggle instance ->
            { model
                | input_InstancesPage_SelectedInstance =
                    if model.input_InstancesPage_SelectedInstance == instance.instanceId then
                        ""
                    else
                        instance.instanceId
            }
                ! []

        Req_InstancesPage_GetInstances progressKeyRes ->
            case progressKeyRes of
                RemoteData.Success progressKey ->
                    ( { model
                        | progressKeys = Dict.insert progressKey.key ( ProgressKeys.getInstances, 0 ) model.progressKeys
                      }
                    , reqInstances model progressKey.key
                    )

                _ ->
                    model ! []

        Req_InstancesPage_CloneInstance ->
            ( model, reqProgressKey model Req_InstancesPage_PrepareForClone )

        Req_InstancesPage_PrepareForClone progressKeyRes ->
            case progressKeyRes of
                RemoteData.Success progressKey ->
                    ( { model
                        | progressKeys = Dict.insert progressKey.key ( ProgressKeys.doClone, 0 ) model.progressKeys
                      }
                    , reqPrepareForClone model (Req_InstancesPage_Clone progressKey.key) (deleteProgressKeyInCaseOfError progressKey.key)
                    )

                _ ->
                    model ! []

        Req_InstancesPage_Clone progressKey prepareResponse ->
            case prepareResponse of
                RemoteData.Success _ ->
                    ( { model
                        | instancesPage = InstancesPage.updateCloneWebdata model.instancesPage RemoteData.Loading
                      }
                    , reqClone model progressKey
                    )

                _ ->
                    model ! []

        Res_InstancesPage_Clone progressKey response ->
            let
                newModel =
                    { model
                        | instancesPage = InstancesPage.updateCloneWebdata model.instancesPage response
                        , progressKeys = Dict.remove progressKey model.progressKeys
                    }
            in
                case response of
                    RemoteData.Success _ ->
                        ( { newModel
                            | input_InstancesPage_Keyfile = Nothing
                            , input_InstancesPage_KeypairName = ""
                            , input_InstancesPage_SelectedInstance = ""
                          }
                        , reqProgressKey model Req_InstancesPage_GetInstances
                        )

                    _ ->
                        newModel ! []

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
            , batchReqImages model (reqRemoveImage model)
            )

        Req_Gantry_ContainersPage_Start ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerManagement model "POST" "/start"
            )

        Req_Gantry_ContainersPage_Stop ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerManagement model "POST" "/stop"
            )

        Req_Gantry_ContainersPage_Restart ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerManagement model "POST" "/restart"
            )

        Req_Gantry_ContainersPage_Pause ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerManagement model "POST" "/pause"
            )

        Req_Gantry_ContainersPage_UnPause ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerManagement model "POST" "/unpause"
            )

        Req_Gantry_ContainersPage_Delete ->
            ( updateContainersPageFromSelectedContainers model
            , batchReqContainers model <| reqContainerManagement model "DELETE" "/remove"
            )

        Req_Gantry_ContainerPage_Start containerID ->
            ( { model
                | containerPage = ContainerPage.updateContainerManagementWebData model.containerPage RemoteData.Loading
              }
            , reqContainerManagement2 model "POST" "/start" containerID
            )

        Req_Gantry_ContainerPage_Stop containerID ->
            ( { model
                | containerPage = ContainerPage.updateContainerManagementWebData model.containerPage RemoteData.Loading
              }
            , reqContainerManagement2 model "POST" "/stop" containerID
            )

        Req_Gantry_ContainerPage_Restart containerID ->
            ( { model
                | containerPage = ContainerPage.updateContainerManagementWebData model.containerPage RemoteData.Loading
              }
            , reqContainerManagement2 model "POST" "/restart" containerID
            )

        Req_Gantry_ContainerPage_Pause containerID ->
            ( { model
                | containerPage = ContainerPage.updateContainerManagementWebData model.containerPage RemoteData.Loading
              }
            , reqContainerManagement2 model "POST" "/pause" containerID
            )

        Req_Gantry_ContainerPage_UnPause containerID ->
            ( { model
                | containerPage = ContainerPage.updateContainerManagementWebData model.containerPage RemoteData.Loading
              }
            , reqContainerManagement2 model "POST" "/unpause" containerID
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
                    (model.ec2_url ++ ":3001")
                    (LoginPage.tryGetToken model.loginPage)
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
            , cmdForStringResponse (reqContainers <| getContainersQuery model) response
            )

        Res_Gantry_ContainerPage_Management containerID response ->
            ( { model
                | containerPage = ContainerPage.updateContainerManagementWebData model.containerPage response
              }
            , reqContainer <| getContainerQuery model containerID
            )

        Res_Gantry_ImagesPage_Remove imageID response ->
            ( { model
                | imagesPage = ImagesPage.updateImagesManagementWebData model.imagesPage imageID response
              }
            , cmdForStringResponse (reqImages model) response
            )

        Ec2_URL_Input character ->
            { model
                | ec2_url_input = character
            }
                ! []

        Ec2_URL_Set ->
            ( { model
                | ec2_url = model.ec2_url_input
              }
            , saveEc2Url model.ec2_url_input
            )

        Ec2_URL_From_LocalStorage url ->
            { model
                | ec2_url = url
            }
                ! []

        Ec2_URL_NotSet ->
            model ! []

        Res_InstancesPage_GetInstances progressKey response ->
            { model
                | instancesPage = InstancesPage.updateInstancesWebdata model.instancesPage response
                , progressKeys = Dict.remove progressKey model.progressKeys
            }
                ! []

        Req_GetClone progressKeyResponse ->
            case progressKeyResponse of
                RemoteData.Success progressKey ->
                    ( { model
                        | progressKeys = Dict.insert progressKey.key ( ProgressKeys.getClone, 0 ) model.progressKeys
                      }
                    , reqGetClone model progressKey.key (Res_GetClone_Then_Req_GetProcess progressKey.key)
                    )

                _ ->
                    model ! []

        Res_GetClone_Then_Req_GetProcess progressKey response ->
            let
                ( newModel, ec2Url ) =
                    { model | progressKeys = Dict.remove progressKey model.progressKeys }
                        |> updateModelForGetCloneResponse response
            in
                if ec2Url /= "" then
                    ( newModel, Cmd.batch [ saveEc2Url ec2Url, reqGetProcesses model ] )
                else
                    newModel ! []

        Res_GetProcesses response ->
            { model | convertPage = ConvertPage.updateProcessesWebdata model.convertPage response } ! []

        Input_ConvertPage_ToggleAll ->
            let
                fetchedProcesses =
                    ConvertPage.tryGetProcesses model.convertPage
            in
                { model
                    | input_ConvertPage_SelectedProcesses =
                        if allProcessesSelected model then
                            Set.empty
                        else
                            Set.fromList <|
                                List.map (\p -> p.pid) <|
                                    ConvertPage.tryGetProcesses model.convertPage
                }
                    ! []

        Input_ConvertPage_Toggle process ->
            { model
                | input_ConvertPage_SelectedProcesses =
                    if Set.member process.pid model.input_ConvertPage_SelectedProcesses then
                        Set.remove process.pid model.input_ConvertPage_SelectedProcesses
                    else
                        Set.insert process.pid model.input_ConvertPage_SelectedProcesses
            }
                ! []

        Req_ConvertProcesses ->
            ( updateConvertPageFromSelectedProcesses model
            , batchReqConvertProcesses model <| reqConvertProcess model
            )

        Res_ConvertProcess pid response ->
            { model
                | convertPage = ConvertPage.updateProcessesConvertWebdata model.convertPage pid response
            }
                ! []

        Res_ProgressStatus progressKey response ->
            case response of
                RemoteData.Success progressStatus ->
                    { model
                        | progressKeys = Dict.update progressKey (\maybeStatus -> Maybe.map (\( x, _ ) -> ( x, progressStatus.status )) maybeStatus) model.progressKeys
                    }
                        ! []

                _ ->
                    model ! []

        NotSendingRequest_DeleteProgressKey progressKey ->
            Debug.log "Request canceled, deleting progressKey" progressKey
                |> always ({ model | progressKeys = Dict.remove progressKey model.progressKeys } ! [])

        OnLocationChange location ->
            let
                newRoute =
                    Router.parseLocation location
            in
                let
                    newModel =
                        { model | route = newRoute }
                in
                    sendRequestsBasedOnRoute newModel newRoute

        Mdl msg_ ->
            Material.update Mdl msg_ model

        Tick _ ->
            ( model
            , model.progressKeys
                |> Dict.keys
                |> List.map (\progressKey -> reqProgressStatus model progressKey)
                |> Cmd.batch
            )

        NoChange ->
            ( model, Cmd.none )

        NoChangeText _ ->
            ( model, Cmd.none )


port logout : () -> Cmd msg


port saveCreds : Auth.Credentials -> Cmd msg


port saveEc2Url : String -> Cmd msg


port saveEc2Region : String -> Cmd msg


port reqContainers : Value -> Cmd msg


port onContainersResponse : (Value -> msg) -> Sub msg


port reqContainer : Value -> Cmd msg


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
        , Time.every second Tick
        ]


reqLogin : Model -> Cmd Msg
reqLogin model =
    let
        credentialsInput =
            Auth.constructCredentials model.input_LoginPage_UserName model.input_LoginPage_AccessKeyId model.input_LoginPage_SecretAccessKey ""
    in
        Http.post
            ("http://localhost:8083/iam/authenticate")
            (Http.jsonBody <| Auth.encodeCredentials credentialsInput)
            Auth.decodeCredentials
            |> RemoteData.sendRequest
            |> Cmd.map Res_LoginPage_Login


reqUpdateAWSConfig : Model -> Cmd Msg
reqUpdateAWSConfig model =
    let
        token =
            LoginPage.tryGetToken model.loginPage

        accessKeyId =
            LoginPage.tryGetAccessKeyId model.loginPage

        secretAccessKey =
            LoginPage.trySecretAccessKey model.loginPage
    in
        if allNonemptyStrings [ token, accessKeyId, secretAccessKey, model.selectedRegion ] then
            Http.request
                { method = "POST"
                , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
                , url = "http://localhost:8083/ec2/" ++ accessKeyId ++ "/awsconfig"
                , body =
                    Http.jsonBody <|
                        Encode.object
                            [ ( "secretAccessKey", Encode.string secretAccessKey )
                            , ( "region", Encode.string model.selectedRegion )
                            ]
                , expect = Http.expectJson CommonResponses.decodeStringResponse
                , timeout = Nothing
                , withCredentials = False
                }
                |> RemoteData.sendRequest
                |> Cmd.map Res_HomePage_UpdateAWSConfig
        else
            Cmd.none



-- regions


reqRegions : Model -> Cmd Msg
reqRegions model =
    let
        token =
            LoginPage.tryGetToken model.loginPage

        accessKeyId =
            LoginPage.tryGetAccessKeyId model.loginPage
    in
        if token /= "" && accessKeyId /= "" then
            Http.request
                { method = "GET"
                , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
                , url = "http://localhost:8083/ec2/" ++ accessKeyId ++ "/regions"
                , body = Http.emptyBody
                , expect = Http.expectJson CommonResponses.decodeRegionsResponse
                , timeout = Nothing
                , withCredentials = False
                }
                |> RemoteData.sendRequest
                |> Cmd.map Res_HomePage_GetRegions
        else
            Cmd.none


reqCreateWorkspace : Model -> Cmd Msg
reqCreateWorkspace model =
    let
        token =
            LoginPage.tryGetToken model.loginPage

        accessKeyId =
            LoginPage.tryGetAccessKeyId model.loginPage

        secretAccessKey =
            LoginPage.trySecretAccessKey model.loginPage
    in
        if allNonemptyStrings [ token, accessKeyId, secretAccessKey, model.selectedRegion ] then
            Http.request
                { method = "POST"
                , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
                , url = "http://localhost:8083/ec2/" ++ accessKeyId
                , body =
                    Http.jsonBody <|
                        Encode.object
                            [ ( "secretAccessKey", Encode.string secretAccessKey )
                            , ( "region", Encode.string model.selectedRegion )
                            ]
                , expect = Http.expectJson CommonResponses.decodeStringResponse
                , timeout = Nothing
                , withCredentials = False
                }
                |> RemoteData.sendRequest
                |> Cmd.map Res_HomePage_CreateWorkspace
        else
            Debug.log "NOT requesting create workspace" (toString <| [ token, accessKeyId, secretAccessKey, model.selectedRegion ])
                |> always Cmd.none



-- Instances


reqInstances : Model -> String -> Cmd Msg
reqInstances model progressKey =
    let
        token =
            LoginPage.tryGetToken model.loginPage

        accessKeyId =
            LoginPage.tryGetAccessKeyId model.loginPage
    in
        if token /= "" && accessKeyId /= "" then
            Http.request
                { method = "GET"
                , headers =
                    [ Http.header "Authorization" ("Bearer " ++ token)
                    , Http.header "x-dd-progress" progressKey
                    ]
                , url = "http://localhost:8083/ec2/" ++ accessKeyId ++ "/instances"
                , body = Http.emptyBody
                , expect = Http.expectJson Instances.decodeInstances
                , timeout = Nothing
                , withCredentials = False
                }
                |> RemoteData.sendRequest
                |> Cmd.map (Res_InstancesPage_GetInstances progressKey)
        else
            deleteProgressKeyInCaseOfError progressKey



-- Clone


reqProgressKey : Model -> (WebData ProgressKeys.ProgressKey -> Msg) -> Cmd Msg
reqProgressKey model cb =
    let
        token =
            LoginPage.tryGetToken model.loginPage
    in
        if token /= "" then
            Http.request
                { method = "GET"
                , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
                , url = "http://localhost:8083/progress/generate"
                , body = Http.emptyBody
                , expect = Http.expectJson ProgressKeys.decodeProgressKey
                , timeout = Nothing
                , withCredentials = False
                }
                |> RemoteData.sendRequest
                |> Cmd.map cb
        else
            Cmd.none


reqProgressStatus : Model -> String -> Cmd Msg
reqProgressStatus model progressKey =
    let
        token =
            LoginPage.tryGetToken model.loginPage
    in
        if token /= "" then
            Http.request
                { method = "GET"
                , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
                , url = "http://localhost:8083/progress/status/" ++ progressKey
                , body = Http.emptyBody
                , expect = Http.expectJson ProgressKeys.decodeProgressStatus
                , timeout = Nothing
                , withCredentials = False
                }
                |> RemoteData.sendRequest
                |> Cmd.map (Res_ProgressStatus progressKey)
        else
            deleteProgressKeyInCaseOfError progressKey


reqGetClone : Model -> String -> (WebData Instances.Clone -> Msg) -> Cmd Msg
reqGetClone model progressKey cb =
    let
        token =
            LoginPage.tryGetToken model.loginPage

        accessKeyId =
            LoginPage.tryGetAccessKeyId model.loginPage
    in
        if token /= "" && accessKeyId /= "" then
            Http.request
                { method = "GET"
                , headers =
                    [ Http.header "Authorization" ("Bearer " ++ token)
                    , Http.header "x-dd-progress" progressKey
                    ]
                , url = "http://localhost:8083/ec2/" ++ accessKeyId ++ "/clone"
                , body = Http.emptyBody
                , expect = Http.expectJson Instances.decodeClone
                , timeout = Nothing
                , withCredentials = False
                }
                |> RemoteData.sendRequest
                |> Cmd.map cb
        else
            deleteProgressKeyInCaseOfError progressKey


allNonemptyStrings : List String -> Bool
allNonemptyStrings strings =
    strings
        |> List.filter (\s -> s == "")
        |> List.length
        |> (==) 0


reqPrepareForClone : Model -> (WebData CommonResponses.StringResponse -> Msg) -> Cmd Msg -> Cmd Msg
reqPrepareForClone model cb errorHandler =
    let
        token =
            LoginPage.tryGetToken model.loginPage

        accessKeyId =
            LoginPage.tryGetAccessKeyId model.loginPage

        secretAccessKey =
            LoginPage.trySecretAccessKey model.loginPage
    in
        Debug.log "prepare" (toString [ token, accessKeyId, secretAccessKey, model.input_InstancesPage_SelectedInstance, model.selectedRegion, model.input_InstancesPage_KeypairName ])
            |> always
                (if allNonemptyStrings [ token, accessKeyId, secretAccessKey, model.input_InstancesPage_SelectedInstance, model.selectedRegion, model.input_InstancesPage_KeypairName ] then
                    case model.input_InstancesPage_Keyfile of
                        Just nf ->
                            let
                                body =
                                    Http.multipartBody
                                        [ Http.stringPart "InstanceId" model.input_InstancesPage_SelectedInstance
                                        , Http.stringPart "accessKeyId" accessKeyId
                                        , Http.stringPart "secretAccessKey" secretAccessKey
                                        , Http.stringPart "region" model.selectedRegion
                                        , Http.stringPart "keypair_name" model.input_InstancesPage_KeypairName
                                        , FileReader.filePart "keyFile" nf
                                        ]
                            in
                                Http.request
                                    { method = "PUT"
                                    , headers =
                                        [ Http.header "Authorization" ("Bearer " ++ token)
                                        ]
                                    , url = "http://localhost:8083/ec2/" ++ accessKeyId
                                    , body = body
                                    , expect = Http.expectJson CommonResponses.decodeStringResponse
                                    , timeout = Nothing
                                    , withCredentials = False
                                    }
                                    |> RemoteData.sendRequest
                                    |> Cmd.map cb

                        Nothing ->
                            errorHandler
                 else
                    errorHandler
                )


reqClone : Model -> String -> Cmd Msg
reqClone model progressKey =
    let
        token =
            LoginPage.tryGetToken model.loginPage

        accessKeyId =
            LoginPage.tryGetAccessKeyId model.loginPage
    in
        Debug.log "asdasdsd" (toString [ token, accessKeyId, model.input_InstancesPage_SelectedInstance ])
            |> always
                (if allNonemptyStrings [ token, accessKeyId, model.input_InstancesPage_SelectedInstance ] then
                    Http.request
                        { method = "GET"
                        , headers =
                            [ Http.header "Authorization" ("Bearer " ++ token)
                            , Http.header "x-dd-progress" progressKey
                            ]
                        , url = "http://localhost:8083/ec2/" ++ accessKeyId ++ "/" ++ model.input_InstancesPage_SelectedInstance ++ "/clone"
                        , body = Http.emptyBody
                        , expect = Http.expectJson CommonResponses.decodeStringResponse
                        , timeout = Nothing
                        , withCredentials = False
                        }
                        |> RemoteData.sendRequest
                        |> Cmd.map (Res_InstancesPage_Clone progressKey)
                 else
                    deleteProgressKeyInCaseOfError progressKey
                )



-- Processes


reqGetProcesses : Model -> Cmd Msg
reqGetProcesses model =
    let
        token =
            LoginPage.tryGetToken model.loginPage
    in
        if token /= "" then
            Http.request
                { method = "GET"
                , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
                , url = model.ec2_url ++ ":8081" ++ "/process"
                , body = Http.emptyBody
                , expect = Http.expectJson Processes.decodeProcesses
                , timeout = Nothing
                , withCredentials = False
                }
                |> RemoteData.sendRequest
                |> Cmd.map Res_GetProcesses
        else
            Cmd.none


reqConvertProcess : Model -> String -> Cmd Msg
reqConvertProcess model pid =
    let
        token =
            LoginPage.tryGetToken model.loginPage
    in
        if token /= "" && model.ec2_url /= "" then
            Http.request
                { method = "GET"
                , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
                , url = model.ec2_url ++ ":8081" ++ "/process/" ++ pid ++ "/convert"
                , body = Http.emptyBody
                , expect = Http.expectJson CommonResponses.decodeStringResponse
                , timeout = Nothing
                , withCredentials = False
                }
                |> RemoteData.sendRequest
                |> Cmd.map (Res_ConvertProcess pid)
        else
            Cmd.none



-- Containers


reqContainerManagement : Model -> String -> String -> String -> Cmd Msg
reqContainerManagement model verb suffix containerID =
    Http.request
        { method = verb
        , headers = [ Http.header "Authorization" ("Bearer " ++ (LoginPage.tryGetToken model.loginPage)) ]
        , url = model.ec2_url ++ ":3001" ++ "/api/containers/" ++ containerID ++ suffix
        , body = Http.emptyBody
        , expect = Http.expectJson CommonResponses.decodeStringResponse
        , timeout = Nothing
        , withCredentials = False
        }
        |> RemoteData.sendRequest
        |> Cmd.map (Res_Gantry_ContainersPage_Management containerID)


reqContainerManagement2 : Model -> String -> String -> String -> Cmd Msg
reqContainerManagement2 model verb suffix containerID =
    Http.request
        { method = verb
        , headers = [ Http.header "Authorization" ("Bearer " ++ (LoginPage.tryGetToken model.loginPage)) ]
        , url = model.ec2_url ++ ":3001" ++ "/api/containers/" ++ containerID ++ suffix
        , body = Http.emptyBody
        , expect = Http.expectJson CommonResponses.decodeStringResponse
        , timeout = Nothing
        , withCredentials = False
        }
        |> RemoteData.sendRequest
        |> Cmd.map (Res_Gantry_ContainerPage_Management containerID)



-- Image


reqImages : Model -> Cmd Msg
reqImages model =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ (LoginPage.tryGetToken model.loginPage)) ]
        , url = model.ec2_url ++ ":3001" ++ "/api/images/"
        , body = Http.emptyBody
        , expect = Http.expectJson Images.decodeImages
        , timeout = Nothing
        , withCredentials = False
        }
        |> RemoteData.sendRequest
        |> Cmd.map Res_Gantry_ImagesPage_Get


reqRemoveImage : Model -> String -> Cmd Msg
reqRemoveImage model imageID =
    Http.request
        { method = "DELETE"
        , headers = [ Http.header "Authorization" ("Bearer " ++ (LoginPage.tryGetToken model.loginPage)) ]
        , url = model.ec2_url ++ ":3001" ++ "/api/images/" ++ imageID
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


allProcessesSelected : Model -> Bool
allProcessesSelected model =
    Set.size model.input_ConvertPage_SelectedProcesses == (List.length <| ConvertPage.tryGetProcesses model.convertPage)


containersPageFolder : String -> ContainersPage.Model -> ContainersPage.Model
containersPageFolder containerID nContainersPage =
    ContainersPage.updateContainersManagementWebData nContainersPage containerID RemoteData.Loading


convertPageFolder : String -> ConvertPage.Model -> ConvertPage.Model
convertPageFolder pid nConvertPage =
    ConvertPage.updateProcessesConvertWebdata nConvertPage pid RemoteData.Loading


updateContainersPageFromSelectedContainers : Model -> Model
updateContainersPageFromSelectedContainers model =
    { model
        | containersPage = List.foldr containersPageFolder model.containersPage <| Set.toList model.input_Gantry_ContainersPage_SelectedContainers
    }


updateConvertPageFromSelectedProcesses : Model -> Model
updateConvertPageFromSelectedProcesses model =
    { model
        | convertPage = List.foldr convertPageFolder model.convertPage <| Set.toList model.input_ConvertPage_SelectedProcesses
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


batchReqConvertProcesses : Model -> (String -> Cmd Msg) -> Cmd Msg
batchReqConvertProcesses model reqCb =
    Cmd.batch <| List.map (\pid -> reqCb pid) <| Set.toList model.input_ConvertPage_SelectedProcesses


cmdForStringResponse : Cmd Msg -> WebData CommonResponses.StringResponse -> Cmd Msg
cmdForStringResponse cb response =
    case response of
        RemoteData.Success _ ->
            cb

        _ ->
            Cmd.none


getContainersQuery : Model -> Value
getContainersQuery model =
    Encode.object
        [ ( "url", Encode.string (model.ec2_url ++ ":3001") )
        , ( "token", Encode.string <| LoginPage.tryGetToken model.loginPage )
        ]


getContainerQuery : Model -> String -> Value
getContainerQuery model containerID =
    Encode.object
        [ ( "url", Encode.string (model.ec2_url ++ ":3001") )
        , ( "token", Encode.string <| LoginPage.tryGetToken model.loginPage )
        , ( "containerID", Encode.string containerID )
        ]


deleteProgressKeyInCaseOfError : String -> Cmd Msg
deleteProgressKeyInCaseOfError key =
    -- This won't work: Cmd.map (always <| NotSendingRequest_DeleteProgressKey key) Cmd.none
    Task.perform (always <| NotSendingRequest_DeleteProgressKey key) (Task.succeed "")


updateModelForGetCloneResponse : WebData Instances.Clone -> Model -> ( Model, String )
updateModelForGetCloneResponse response model =
    let
        newModel =
            ConvertPage.updateCloneWebdata model.convertPage response
    in
        case response of
            RemoteData.Success response ->
                case response.clone of
                    Just clone ->
                        ( { model
                            | convertPage = newModel
                            , ec2_url = "http://" ++ clone.dns
                          }
                        , "http://" ++ clone.dns
                        )

                    Nothing ->
                        ( { model | convertPage = newModel }, "" )

            _ ->
                ( { model | convertPage = newModel }, "" )


sendRequestsBasedOnRoute : Model -> Router.Route -> ( Model, Cmd Msg )
sendRequestsBasedOnRoute model newRoute =
    case model.loginPage.authenticationState of
        Auth.LoggedIn _ ->
            case newRoute of
                Router.LandingRoute ->
                    ( { model | homePage = HomePage.updateRegionswebdata model.homePage RemoteData.Loading }, reqRegions model )

                Router.CloneRoute ->
                    if model.selectedRegion /= "" then
                        ( { model | instancesPage = InstancesPage.updateInstancesWebdata model.instancesPage RemoteData.Loading }, reqProgressKey model Req_InstancesPage_GetInstances )
                    else
                        model ! []

                Router.ConvertRoute ->
                    case model.convertPage.cloneWebdata of
                        RemoteData.Success _ ->
                            model ! []

                        RemoteData.Loading ->
                            model ! []

                        _ ->
                            ( { model | convertPage = ConvertPage.updateCloneWebdata model.convertPage RemoteData.Loading }, reqProgressKey model Req_GetClone )

                Router.GantryContainersViewRoute ->
                    ( model, reqContainers <| getContainersQuery model )

                Router.GantryContainerViewRoute containerID ->
                    ( model, reqContainer <| getContainerQuery model containerID )

                Router.GantryContainersCreateRoute ->
                    ( model, reqImages model )

                Router.GantryImageRoute ->
                    ( model, reqImages model )

                _ ->
                    model ! []

        Auth.LoggedOut ->
            model ! []
