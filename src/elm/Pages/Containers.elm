module Pages.Containers exposing (..)

import RemoteData exposing (WebData)
import Types.Containers exposing (..)
import Array


type alias Model =
    { containersWebdata : WebData Containers
    }


init : Model
init =
    { containersWebdata = RemoteData.NotAsked
    }


updateContainersWebdata : Model -> WebData Containers -> Model
updateContainersWebdata model response =
    { model
        | containersWebdata = response
    }


tryGetContainerFromId : Model -> String -> Maybe Container
tryGetContainerFromId model id =
    case model.containersWebdata of
        RemoteData.Success response ->
            List.filter (\c -> containerKey c == id) response.containers
                |> Array.fromList
                |> Array.get 0

        _ ->
            Nothing


tryGetContainers : Model -> List Container
tryGetContainers model =
    case model.containersWebdata of
        RemoteData.Success response ->
            response.containers

        _ ->
            []
