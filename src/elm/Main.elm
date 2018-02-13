module Main exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Views
import Types.Auth
import Navigation
import RouteUrl as Routing
import State exposing (Model, Msg, init, update)


main : Routing.RouteUrlProgram (Maybe Types.Auth.Credentials) Model Msg
main =
    Routing.programWithFlags
        { delta2url = delta2url
        , location2messages = location2messages
        , init = init
        , view = Views.globalView
        , subscriptions = (\model -> Sub.none)
        , update = update
        }



-- Boiler plate for RouteUrl


delta2url : Model -> Model -> Maybe Routing.UrlChange
delta2url model1 model2 =
    let
        urlOfSelectedTab =
            "#"
                ++ (Views.allTabs
                        |> List.map (\( _, url, _ ) -> url)
                        |> Array.fromList
                        |> Array.get model2.selectedTab
                        |> Maybe.withDefault ""
                   )
    in
        if model1.selectedTab /= model2.selectedTab then
            { entry = Routing.NewEntry
            , url = urlOfSelectedTab
            }
                |> Just
        else
            Nothing


location2messages : Navigation.Location -> List Msg
location2messages location =
    [ case location.hash |> String.dropLeft 1 of
        "" ->
            State.SelectTab 0

        x ->
            Views.allTabs
                |> List.indexedMap (\idx ( _, url, _ ) -> ( url, idx ))
                |> Dict.fromList
                |> Dict.get x
                |> Maybe.withDefault -1
                |> State.SelectTab
    ]
