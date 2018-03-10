module Pages.Process exposing (..)

import RemoteData exposing (WebData)
import Types.Processes exposing (..)
import Types.CommonResponses exposing (StringResponse)


type alias Model =
    { processWebData : WebData ProcessMetadata
    , processConvertWebData : WebData StringResponse
    }


init : Model
init =
    { processWebData = RemoteData.NotAsked
    , processConvertWebData = RemoteData.NotAsked
    }


updateProcessWebdata : Model -> WebData ProcessMetadata -> Model
updateProcessWebdata model response =
    { model
        | processWebData = response
    }


updateProcessManagementWebData : Model -> WebData StringResponse -> Model
updateProcessManagementWebData model response =
    { model
        | processConvertWebData = response
    }
