module Pages.Instances exposing (..)

import RemoteData exposing (WebData)
import Types.Instances exposing (..)
import Array


type alias Model =
    { instancesWebdata : WebData Instances
    }


init : Model
init =
    { instancesWebdata = RemoteData.NotAsked
    }


updateInstancesWebdata : Model -> WebData Instances -> Model
updateInstancesWebdata model response =
    { model
        | instancesWebdata = response
    }


tryGetInstanceFromId : Model -> String -> Maybe Instance
tryGetInstanceFromId model id =
    case model.instancesWebdata of
        RemoteData.Success response ->
            List.filter (\c -> c.instanceId == id) response.instances
                |> Array.fromList
                |> Array.get 0

        _ ->
            Nothing


tryGetInstances : Model -> List Instance
tryGetInstances model =
    case model.instancesWebdata of
        RemoteData.Success response ->
            response.instances

        _ ->
            []
