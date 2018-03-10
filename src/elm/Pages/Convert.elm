module Pages.Convert exposing (..)

import RemoteData exposing (WebData)
import Types.Instances exposing (..)
import Types.Processes exposing (..)
import Types.CommonResponses exposing (..)
import Dict exposing (Dict)


type alias Model =
    { cloneWebdata : WebData ImportedAndCloned
    , processesWebdata : WebData Processes
    , processesConvertWebdata : Dict String (WebData StringResponse)
    }


init : Model
init =
    { cloneWebdata = RemoteData.NotAsked
    , processesWebdata = RemoteData.NotAsked
    , processesConvertWebdata = Dict.empty
    }


updateCloneWebdata : Model -> WebData ImportedAndCloned -> Model
updateCloneWebdata model response =
    { model
        | cloneWebdata = response
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
