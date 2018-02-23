module Main exposing (..)

import Views
import Navigation
import Json.Decode exposing (Value)
import State exposing (Model, Msg, init, update, subscriptions)


main : Program (Maybe Value) Model Msg
main =
    Navigation.programWithFlags State.OnLocationChange
        { init = init
        , view = Views.globalView
        , subscriptions = subscriptions
        , update = update
        }
