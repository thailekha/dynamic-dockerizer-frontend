module Pages.Container exposing (..)

import RemoteData exposing (WebData)
import Types.Containers exposing (..)
import Types.CommonResponses exposing (StringResponse)


type alias Model =
    { containerWebdata : WebData ContainerGet
    , containerManagementWebData : WebData StringResponse
    }


init : Model
init =
    { containerWebdata = RemoteData.NotAsked
    , containerManagementWebData = RemoteData.NotAsked
    }


updateContainerWebdata : Model -> WebData ContainerGet -> Model
updateContainerWebdata model response =
    { model
        | containerWebdata = response
    }


updateContainerManagementWebData : Model -> WebData StringResponse -> Model
updateContainerManagementWebData model response =
    { model
        | containerManagementWebData = response
    }


tryGetContainer : Model -> Result (WebData ContainerGet) Container
tryGetContainer model =
    case model.containerWebdata of
        RemoteData.Success response ->
            Ok response.container

        _ ->
            Err model.containerWebdata
