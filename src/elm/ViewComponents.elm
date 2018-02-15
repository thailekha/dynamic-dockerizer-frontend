module ViewComponents exposing (..)

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
import Types.Images as Images
import Types.CommonResponses exposing (StringResponse)
import Pages.Containers as ContainersPage
import Pages.Images as ImagesPage
import State exposing (Model, Msg)
import Set exposing (Set)
import Dict exposing (Dict)
import Array
import RemoteData exposing (WebData)


centerDiv : List (Html msg) -> Html msg
centerDiv =
    div [ class "container", style [ ( "text-align", "center" ) ] ]


breaker : List (Html msg) -> List (Html msg)
breaker =
    List.concatMap (\htmlI -> [ htmlI, br [] [] ])


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


imagesTableMdl : Model -> Html Msg
imagesTableMdl model =
    Table.table []
        [ Table.thead []
            [ Table.tr []
                [ Table.th []
                    [ Toggles.checkbox State.Mdl
                        [ -1 ]
                        model.mdl
                        [ Options.onToggle State.ToggleAllImages
                        , Toggles.value (State.allImagesSelected model)
                        ]
                        []
                    ]
                , Table.th [] [ text "Id" ]
                , Table.th [] [ text "Created" ]
                , Table.th [] [ text "RepoTags" ]
                , Table.th [] [ text "Size" ]
                , Table.th [] [ text "VirtualSize" ]
                ]
            ]
        , Table.tbody []
            (ImagesPage.tryGetImages model.imagesPage
                |> List.indexedMap
                    (\idx image ->
                        Table.tr
                            [ when (Set.member (Images.imageKey image) model.selectedImages) Table.selected ]
                            [ Table.td []
                                [ Toggles.checkbox State.Mdl
                                    [ idx ]
                                    model.mdl
                                    [ Options.onToggle (State.ToggleImages image)
                                    , Toggles.value <| Set.member (Images.imageKey image) model.selectedImages
                                    ]
                                    []
                                ]
                            , Table.td [] [ text <| toString image.id ]
                            , Table.td [] [ text <| toString image.created ]
                            , Table.td [] [ text <| toString image.repoTags ]
                            , Table.td [] [ text <| toString <| toMB <| image.size ]
                            , Table.td [] [ text <| toString <| toMB <| image.virtualSize ]
                            ]
                    )
            )
        ]


containersManagementWebDataString : Model -> List String
containersManagementWebDataString model =
    model.containersPage.containersManagementWebData
        |> Dict.toList
        |> List.map
            (\( containerId, webdata ) ->
                case (ContainersPage.tryGetContainerFromId model.containersPage containerId) of
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


imagesManagementWebDataString : Model -> List String
imagesManagementWebDataString model =
    model.imagesPage.imagesManagementWebData
        |> Dict.toList
        |> List.map
            (\( imageId, webdata ) ->
                case (ImagesPage.tryGetImageFromId model.imagesPage imageId) of
                    Just image ->
                        case
                            (image.repoTags
                                |> Array.fromList
                                |> Array.get 0
                            )
                        of
                            Just name ->
                                name ++ " - " ++ (webdataString webdata)

                            Nothing ->
                                "No name image - " ++ (webdataString webdata)

                    Nothing ->
                        "Cannot find image " ++ imageId
            )


protectedView : Model -> Html Msg -> Html Msg
protectedView model loggedInView =
    (case model.loginPage.authenticationState of
        Auth.LoggedIn _ ->
            loggedInView

        Auth.LoggedOut ->
            text "Error"
    )


tabLabels : List ( String, String ) -> List (Tabs.Label Msg)
tabLabels tabs =
    List.map (\( label, url ) -> Tabs.label [ Options.attribute <| href ("#/" ++ url) ] [ text label ]) tabs


toMB : Int -> String
toMB byte =
    (toString <| round <| (toFloat byte) * 0.000000995) ++ " MB"


webdataString : WebData StringResponse -> String
webdataString wd =
    case wd of
        RemoteData.Success res ->
            res.message

        _ ->
            toString wd
