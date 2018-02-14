module Pages.Containers exposing (..)

import Html exposing (Html, text, div)
import RemoteData exposing (WebData)
import Types.Containers exposing (..)
import Types.CommonResponses exposing (StringResponse)
import Dict exposing (Dict)
import Array


type alias Model =
    { containersWebdata : WebData Containers
    , containersManagementWebData : Dict String (WebData StringResponse)
    }


init : Model
init =
    { containersWebdata = RemoteData.NotAsked
    , containersManagementWebData = Dict.empty
    }


updateContainersWebdata : Model -> WebData Containers -> Model
updateContainersWebdata model response =
    { model
        | containersWebdata = response
    }


updateContainersManagementWebData : Model -> String -> WebData StringResponse -> Model
updateContainersManagementWebData model key response =
    { model
        | containersManagementWebData =
            if Dict.member key model.containersManagementWebData then
                model.containersManagementWebData
                    |> Dict.remove key
                    |> Dict.insert key response
            else
                model.containersManagementWebData
                    |> Dict.insert key response
    }


tryGetContainers : Model -> List Container
tryGetContainers model =
    case model.containersWebdata of
        RemoteData.Success response ->
            response.containers

        _ ->
            []


tryGetContainerFromId : Model -> String -> Maybe Container
tryGetContainerFromId model id =
    case model.containersWebdata of
        RemoteData.Success response ->
            List.filter (\c -> containerKey c == id) response.containers
                |> Array.fromList
                |> Array.get 0

        _ ->
            Nothing


containerView : Container -> Html msg
containerView container =
    div []
        [ text <| List.foldr (++) ", " container.names
        , text container.image
        , text container.state
        , text container.status
        , text <| toString container.ports
        ]


webdataString : WebData StringResponse -> String
webdataString wd =
    case wd of
        RemoteData.Success res ->
            res.message

        _ ->
            toString wd


containersManagementWebDataString : Model -> List String
containersManagementWebDataString model =
    model.containersManagementWebData
        |> Dict.toList
        |> List.map
            (\( containerId, webdata ) ->
                case (tryGetContainerFromId model containerId) of
                    Just container ->
                        case
                            (container.names
                                |> Array.fromList
                                |> Array.get 0
                            )
                        of
                            Just name ->
                                name ++ " - " ++ (webdataString webdata)

                            Nothing ->
                                "No name container - " ++ (webdataString webdata)

                    Nothing ->
                        "Cannot find container " ++ containerId
            )


portView : Port -> Html msg
portView p =
    div []
        [ text <| toString p.privatePort

        --, text <| toString p.publicPort
        , text p.type_
        ]
