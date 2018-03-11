module Pages.Convert exposing (..)

import RemoteData exposing (WebData)
import Types.Instances exposing (..)
import Types.Processes exposing (..)
import Types.CommonResponses exposing (..)
import Dict exposing (Dict)


type alias Model =
    { cloneWebdata : WebData ImportedAndCloned
    , checkhostWebdata : WebData StringResponse
    , processesWebdata : WebData Processes
    , processesConvertWebdata : Dict String (WebData StringResponse)
    , destroyWebdata : WebData StringResponse
    }


init : Model
init =
    { cloneWebdata = RemoteData.NotAsked
    , checkhostWebdata = RemoteData.NotAsked
    , processesWebdata = RemoteData.NotAsked
    , processesConvertWebdata = Dict.empty
    , destroyWebdata = RemoteData.NotAsked
    }


updateCloneWebdata : Model -> WebData ImportedAndCloned -> Model
updateCloneWebdata model response =
    let
        nResponse =
            (case response of
                RemoteData.Success response ->
                    { response
                        | cloned =
                            Maybe.map
                                (\clone ->
                                    { clone
                                        | publicIp =
                                            if String.contains "http://" clone.publicIp then
                                                clone.publicIp
                                            else
                                                "http://" ++ clone.publicIp
                                    }
                                )
                                response.cloned
                    }
                        |> RemoteData.succeed

                _ ->
                    response
            )
    in
        { model
            | cloneWebdata = nResponse
        }


updateCheckhostWebdata : Model -> WebData StringResponse -> Model
updateCheckhostWebdata model response =
    { model
        | checkhostWebdata = response
    }


updateDestroywebdata : Model -> WebData StringResponse -> Model
updateDestroywebdata model response =
    { model
        | destroyWebdata = response
    }


updateProcessesWebdata : Model -> WebData Processes -> Model
updateProcessesWebdata model response =
    { model
        | processesWebdata = response
    }


updateProcessesConvertWebdata : Model -> String -> WebData StringResponse -> Model
updateProcessesConvertWebdata model key response =
    { model
        | processesConvertWebdata =
            if Dict.member key model.processesConvertWebdata then
                model.processesConvertWebdata
                    |> Dict.remove key
                    |> Dict.insert key response
            else
                model.processesConvertWebdata
                    |> Dict.insert key response
    }


tryGetProcesses : Model -> List Process
tryGetProcesses model =
    case model.processesWebdata of
        RemoteData.Success response ->
            response.processes

        _ ->
            []


tryGetCloneIP : Model -> String
tryGetCloneIP model =
    case model.cloneWebdata of
        RemoteData.Success res ->
            case res.cloned of
                Just cloned ->
                    cloned.publicIp

                Nothing ->
                    ""

        _ ->
            ""
