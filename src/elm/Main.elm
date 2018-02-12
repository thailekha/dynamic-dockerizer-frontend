module Main exposing (..)

import Views
import Types.Auth
import RouteUrl as Routing
import State exposing (Model, Msg, init, update)


main : Routing.RouteUrlProgram (Maybe Types.Auth.Credentials) Model Msg
main =
    Routing.programWithFlags
        { delta2url = Views.delta2url
        , location2messages = Views.location2messages
        , init = init
        , view = Views.view
        , subscriptions = (\model -> Sub.none)
        , update = update
        }
