module Pages.Containers exposing (..)

import RemoteData exposing (WebData)
import Types.Containers exposing (..)
import Types.CommonResponses exposing (StringResponse)
import Dict exposing (Dict)
import Array


type alias Model =
    { containersWebdata : WebData Containers
    , containersManagementWebData : Dict String (WebData StringResponse)
    }


init : Model
init =
    { containersWebdata = RemoteData.NotAsked
    , containersManagementWebData = Dict.empty
    }


updateContainersWebdata : Model -> WebData Containers -> Model
updateContainersWebdata model response =
    { model
        | containersWebdata = response
    }


updateContainersManagementWebData : Model -> String -> WebData StringResponse -> Model
updateContainersManagementWebData model key response =
    { model
        | containersManagementWebData =
            if Dict.member key model.containersManagementWebData then
                model.containersManagementWebData
                    |> Dict.remove key
                    |> Dict.insert key response
            else
                model.containersManagementWebData
                    |> Dict.insert key response
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
