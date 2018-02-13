module Helpers exposing (..)

import Html exposing (Html, text, div, p, br)
import Html.Attributes exposing (class, style)
import Array exposing (Array)
import Material.Options as Options
import Material.Button as Button
import Material.Textfield as Textfield
import Material.Typography as Typo
import Material.Tabs as Tabs
import Types.Auth as Auth
import State exposing (Model, Msg)


-- HTML


centerDiv : List (Html msg) -> Html msg
centerDiv =
    div [ class "container", style [ ( "text-align", "center" ) ] ]


breaker : List (Html msg) -> List (Html msg)
breaker =
    List.concatMap (\htmlI -> [ htmlI, br [] [] ])



-- MDL


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



-- Auth


protectedView : Model -> Html Msg -> Html Msg
protectedView model loggedInView =
    (case model.login.authenticationState of
        Auth.LoggedIn _ ->
            loggedInView

        Auth.LoggedOut ->
            text "Error"
    )



-- Routing


nav : Int -> Model -> List (Tabs.Label Msg) -> Html Msg
nav index model labels =
    Tabs.render State.Mdl
        [ index ]
        model.mdl
        [ Tabs.ripple
        , Tabs.onSelectTab State.SelectTab
        , Tabs.activeTab model.selectedTab
        ]
        labels
        []


subNav : Int -> Int -> Model -> List (Tabs.Label Msg) -> Html Msg
subNav index patch model labels =
    -- patch: the length of the global tabs
    Tabs.render State.Mdl
        [ index ]
        model.mdl
        [ Tabs.ripple
        , Tabs.onSelectTab (State.SelectTabPatch patch)
        , Tabs.activeTab model.selectedTab
        ]
        labels
        []


tabLabels : List ( String, String, Model -> Html Msg ) -> List (Tabs.Label Msg)
tabLabels tabList =
    let
        labelGetter =
            (\( label, _, _ ) -> Tabs.label [] [ text label ])
    in
        List.map labelGetter tabList


tabViews : List ( String, String, Model -> Html Msg ) -> Array (Model -> Html Msg)
tabViews tabList =
    let
        viewGetter =
            (\( _, _, v ) -> v)
    in
        tabList
            |> List.map viewGetter
            |> Array.fromList


tryGetTabView : Int -> List ( String, String, Model -> Html Msg ) -> (Model -> Html Msg)
tryGetTabView index tabList =
    tabViews tabList
        |> Array.get index
        |> Maybe.withDefault e404


e404 : x -> Html Msg
e404 _ =
    div []
        [ text "route not found" ]
