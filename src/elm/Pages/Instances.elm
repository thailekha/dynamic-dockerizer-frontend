module Pages.Instances exposing (..)

import RemoteData exposing (WebData)
import Types.Instances exposing (..)
import Types.CommonResponses exposing (..)
import Array


type alias Model =
    { instancesWebdata : WebData Instances
    , cloneWebdata : WebData StringResponse
    }


init : Model
init =
    { instancesWebdata = RemoteData.NotAsked
    , cloneWebdata = RemoteData.NotAsked
    }


updateInstancesWebdata : Model -> WebData Instances -> Model
updateInstancesWebdata model response =
    { model
        | instancesWebdata = response
    }


updateCloneWebdata : Model -> WebData StringResponse -> Model
updateCloneWebdata model response =
    { model
        | cloneWebdata = response
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
