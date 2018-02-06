module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Components.CredsController as CredsController
import Components.Creds as Creds


main : Program (Maybe Creds.Credentials) Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type alias Model =
    { credsModel : CredsController.Model
    }


init : Maybe Creds.Credentials -> ( Model, Cmd Msg )
init initialUser =
    ( { credsModel = CredsController.init initialUser
      }
    , Cmd.none
    )


type Msg
    = CredsControllerMsg CredsController.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CredsControllerMsg subMsg ->
            let
                ( subModel, subCmd ) =
                    CredsController.update subMsg model.credsModel
            in
                ( { model | credsModel = subModel }, Cmd.map CredsControllerMsg subCmd )


liftCredsControllerView : Html CredsController.Msg -> Html Msg
liftCredsControllerView credsControllerHtml =
    Html.map CredsControllerMsg credsControllerHtml


view : Model -> Html Msg
view model =
    div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
        [ -- inline CSS (literal)
          CredsController.either model.credsModel
            (liftCredsControllerView (CredsController.view model.credsModel))
            (liftCredsControllerView (CredsController.loginForm model.credsModel))
        ]
