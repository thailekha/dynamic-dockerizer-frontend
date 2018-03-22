module Pages.Images exposing (..)

import RemoteData exposing (WebData)
import Types.Images exposing (..)
import Array


type alias Model =
    { imagesWebdata : WebData Images
    }


init : Model
init =
    { imagesWebdata = RemoteData.NotAsked
    }


updateImagesWebdata : Model -> WebData Images -> Model
updateImagesWebdata model response =
    { model
        | imagesWebdata = response
    }


tryGetImageFromId : Model -> String -> Maybe Image
tryGetImageFromId model id =
    case model.imagesWebdata of
        RemoteData.Success response ->
            List.filter (\i -> imageKey i == id) response.images
                |> Array.fromList
                |> Array.get 0

        _ ->
            Nothing


tryGetImages : Model -> List Image
tryGetImages model =
    case model.imagesWebdata of
        RemoteData.Success response ->
            response.images

        _ ->
            []
