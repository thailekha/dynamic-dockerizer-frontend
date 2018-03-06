module Pages.Home exposing (..)

import RemoteData exposing (WebData)
import Types.CommonResponses exposing (..)


type alias Model =
    { regionsWebdata : WebData RegionsResponse
    , awsConfigWebdata : WebData StringResponse
    }


init : Model
init =
    { regionsWebdata = RemoteData.NotAsked
    , awsConfigWebdata = RemoteData.NotAsked
    }


updateRegionswebdata : Model -> WebData RegionsResponse -> Model
updateRegionswebdata model response =
    { model
        | regionsWebdata = response
    }


updateAwsconfigwebdata : Model -> WebData StringResponse -> Model
updateAwsconfigwebdata model response =
    { model
        | awsConfigWebdata = response
    }


tryGetRegions : Model -> List String
tryGetRegions model =
    case model.regionsWebdata of
        RemoteData.Success response ->
            response.regions

        _ ->
            []
