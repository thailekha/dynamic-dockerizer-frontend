module Pages.Process exposing (..)

import RemoteData exposing (WebData)
import Types.Processes exposing (..)


type alias Model =
    { processWebData : WebData ProcessMetadata
    }


init : Model
init =
    { processWebData = RemoteData.NotAsked
    }


updateProcessWebdata : Model -> WebData ProcessMetadata -> Model
updateProcessWebdata model response =
    { model
        | processWebData = response
    }
