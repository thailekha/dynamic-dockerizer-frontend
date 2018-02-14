module Pages.Containers exposing (..)

import Html exposing (Html, text, div)
import RemoteData exposing (WebData)
import Types.Containers exposing (..)


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


tryGetContainers : Model -> List Container
tryGetContainers model =
    case model.containersWebdata of
        RemoteData.Success response ->
            response.containers

        _ ->
            []


containerView : Container -> Html msg
containerView container =
    div []
        [ text <| List.foldr (++) ", " container.names
        , text container.image
        , text container.state
        , text container.status
        , text <| toString container.ports
        ]


portView : Port -> Html msg
portView p =
    div []
        [ text <| toString p.privatePort

        --, text <| toString p.publicPort
        , text p.type_
        ]
