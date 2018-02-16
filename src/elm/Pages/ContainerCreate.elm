module Pages.ContainerCreate exposing (..)

import RemoteData exposing (WebData)
import Types.CommonResponses exposing (PortResponse)


type alias Model =
    { containerCreateWebdata : WebData PortResponse
    }


init : Model
init =
    { containerCreateWebdata = RemoteData.NotAsked
    }


updateContainerCreateWebdata : Model -> WebData PortResponse -> Model
updateContainerCreateWebdata model response =
    { model
        | containerCreateWebdata = response
    }
