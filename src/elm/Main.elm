module Main exposing (..)

import Html
import Views
import Types.Auth
import State exposing (Model, Msg, init, update)


main : Program (Maybe Types.Auth.Credentials) Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = Views.view
        , update = update
        , subscriptions = (\model -> Sub.none)
        }
