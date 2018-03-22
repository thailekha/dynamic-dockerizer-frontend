module Pages.ContainerCreate exposing (..)

import RemoteData exposing (WebData)
import Types.CommonResponses exposing (..)


type alias Model =
    { containerCreateWebdata : WebData StringResponse
    }


init : Model
init =
    { containerCreateWebdata = RemoteData.NotAsked
    }


updateContainerCreateWebdata : Model -> WebData StringResponse -> Model
updateContainerCreateWebdata model response =
    { model
        | containerCreateWebdata = response
    }
