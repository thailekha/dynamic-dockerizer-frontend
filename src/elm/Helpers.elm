module Helpers exposing (..)

import Html exposing (Html, text, div, p, br)
import Html.Attributes exposing (class, style, href)
import Material.Options as Options exposing (when)
import Material.Button as Button
import Material.Textfield as Textfield
import Material.Typography as Typo
import Material.Tabs as Tabs
import Material.Table as Table
import Material.Toggles as Toggles
import Material.List as Lists
import Material.Chip as Chip
import Material.Color as Color
import Types.Auth as Auth
import Types.Containers as Containers
import Pages.Containers as ContainersPage
import State exposing (Model, Msg)
import Set exposing (Set)


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


navMdl : Int -> Int -> Model -> List (Tabs.Label Msg) -> Html Msg
navMdl index activeTabIndex model labels =
    Tabs.render State.Mdl
        [ index ]
        model.mdl
        [ Tabs.ripple
        , Tabs.activeTab activeTabIndex
        ]
        labels
        []


listMdl : List String -> Html Msg
listMdl items =
    items
        |> List.map (\item -> Lists.li [] [ Lists.content [] [ text item ] ])
        |> Lists.ul []


colorChipMdl : String -> Html Msg
colorChipMdl str =
    Chip.span []
        [ Chip.content
            (if str == "running" then
                [ Color.background (Color.color Color.Green Color.A400) ]
             else
                []
            )
            [ text str ]
        ]


containersTableMdl : Model -> Html Msg
containersTableMdl model =
    Table.table []
        [ Table.thead []
            [ Table.tr []
                [ Table.th []
                    [ Toggles.checkbox State.Mdl
                        [ -1 ]
                        model.mdl
                        [ Options.onToggle State.ToggleAllContainers
                        , Toggles.value (State.allContainersSelected model)
                        ]
                        []
                    ]
                , Table.th [] [ text "Name" ]
                , Table.th [] [ text "State" ]
                , Table.th [] [ text "Status" ]
                , Table.th [] [ text "Ports" ]
                , Table.th [] [ text "Image" ]
                ]
            ]
        , Table.tbody []
            (ContainersPage.tryGetContainers model.containersPage
                |> List.indexedMap
                    (\idx container ->
                        Table.tr
                            [ when (Set.member (Containers.containerKey container) model.selectedContainers) Table.selected ]
                            [ Table.td []
                                [ Toggles.checkbox State.Mdl
                                    [ idx ]
                                    model.mdl
                                    [ Options.onToggle (State.ToggleContainers container)
                                    , Toggles.value <| Set.member (Containers.containerKey container) model.selectedContainers
                                    ]
                                    []
                                ]
                            , Table.td [] [ text <| toString container.names ]
                            , Table.td [] [ colorChipMdl container.state ]
                            , Table.td [] [ text <| toString container.status ]
                            , Table.td [] [ text <| toString container.ports ]
                            , Table.td [] [ text <| toString container.image ]
                            ]
                    )
            )
        ]



-- Auth


protectedView : Model -> Html Msg -> Html Msg
protectedView model loggedInView =
    (case model.loginPage.authenticationState of
        Auth.LoggedIn _ ->
            loggedInView

        Auth.LoggedOut ->
            text "Error"
    )



-- Routing


tabLabels : List ( String, String ) -> List (Tabs.Label Msg)
tabLabels tabs =
    List.map (\( label, url ) -> Tabs.label [ Options.attribute <| href ("#/" ++ url) ] [ text label ]) tabs
