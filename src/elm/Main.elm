module Main exposing (..)

import Views
import Types.Auth
import Navigation
import State exposing (Model, Msg, init, update, subscriptions)


main : Program (Maybe Types.Auth.Credentials) Model Msg
main =
    Navigation.programWithFlags State.OnLocationChange
        { init = init
        , view = Views.globalView
        , subscriptions = subscriptions
        , update = update
        }
