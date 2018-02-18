module Pages.Images exposing (..)

import RemoteData exposing (WebData)
import Types.Images exposing (..)
import Types.CommonResponses exposing (StringResponse)
import Dict exposing (Dict)
import Array


type alias Model =
    { imagesWebdata : WebData Images
    , imagesManagementWebData : Dict String (WebData StringResponse)
    }


init : Model
init =
    { imagesWebdata = RemoteData.NotAsked
    , imagesManagementWebData = Dict.empty
    }


updateImagesWebdata : Model -> WebData Images -> Model
updateImagesWebdata model response =
    { model
        | imagesWebdata = response
    }


updateImagesManagementWebData : Model -> String -> WebData StringResponse -> Model
updateImagesManagementWebData model key response =
    { model
        | imagesManagementWebData =
            if Dict.member key model.imagesManagementWebData then
                model.imagesManagementWebData
                    |> Dict.remove key
                    |> Dict.insert key response
            else
                model.imagesManagementWebData
                    |> Dict.insert key response
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
