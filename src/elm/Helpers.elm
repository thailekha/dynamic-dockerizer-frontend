module Helpers exposing (..)

import Html exposing (Html, text, div, p, br)
import Html.Attributes exposing (class, style)
import Material.Options as Options
import Material.Button as Button
import Material.Textfield as Textfield
import Material.Typography as Typo
import Types.Auth as Auth
import State exposing (Model, Msg)


buttonMdl : Model -> Int -> Msg -> String -> Html Msg
buttonMdl model index cb display =
    Button.render State.Mdl
        [ index ]
        model.mdl
        -- onClick cannot be used multiple times
        [ Options.onClick cb ]
        [ text display ]


inputMdl : Model -> Int -> (String -> Msg) -> String -> String -> String -> Html Msg
inputMdl model index cb name textType display =
    (Textfield.render State.Mdl
        [ index ]
        model.mdl
        [ Textfield.label display
        , Textfield.floatingLabel
        , (if textType == "password" then
            Textfield.password
           else
            Textfield.text_
          )
        , (Options.attribute <| Html.Attributes.name name)
        , Options.onInput cb
        ]
    )
        "JUST A PATCH HERE"


textMdl : String -> Html Msg
textMdl display =
    Options.styled p
        [ Typo.display1 ]
        [ text display ]


centerDiv : List (Html msg) -> Html msg
centerDiv =
    div [ class "container", style [ ( "text-align", "center" ) ] ]


breaker : List (Html msg) -> List (Html msg)
breaker =
    List.concatMap (\htmlI -> [ htmlI, br [] [] ])


protectedView : Model -> Html Msg -> Html Msg
protectedView model loggedInView =
    (case model.login.authenticationState of
        Auth.LoggedIn _ ->
            loggedInView

        Auth.LoggedOut ->
            text "Error"
    )