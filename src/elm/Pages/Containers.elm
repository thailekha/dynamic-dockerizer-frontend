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


tryGetContainerIdentifierFromId : Model -> String -> String
tryGetContainerIdentifierFromId model id =
    case model.containersWebdata of
        RemoteData.Success response ->
            case
                (List.filter (\c -> containerKey c == id) response.containers
                    |> Array.fromList
                    |> Array.get 0
                )
            of
                Just container ->
                    case
                        (container.names
                            |> Array.fromList
                            |> Array.get 0
                        )
                    of
                        Just name ->
                            name

                        Nothing ->
                            id

                Nothing ->
                    id

        _ ->
            id


tryGetContainers : Model -> List Container
tryGetContainers model =
    case model.containersWebdata of
        RemoteData.Success response ->
            response.containers

        _ ->
            []
