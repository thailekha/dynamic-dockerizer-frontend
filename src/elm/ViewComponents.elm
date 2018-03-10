module ViewComponents exposing (..)

import Html exposing (Html, a, text, div, p, br, option, select, img, input)
import Html.Attributes exposing (class, style, href, value, attribute, src, height, width, type_, multiple)
import Html.Events exposing (on)
import Material.Options as Options exposing (when, css)
import Material.Button as Button
import Material.Textfield as Textfield
import Material.Typography as Typo
import Material.Tabs as Tabs
import Material.Table as Table
import Material.Toggles as Toggles
import Material.List as Lists
import Material.Chip as Chip
import Material.Color as Color
import Material.Grid exposing (grid, cell, size, Device(..))
import Material.Progress as Loading
import Material.Layout as Layout
import Types.Auth as Auth
import Types.Containers as Containers
import Types.Instances as Instances
import Types.Processes as Processes
import Types.Images as Images
import Types.CommonResponses exposing (StringResponse)
import Types.ContainerCreater as ContainerCreater
import Types.ProgressKeys as ProgressKeys
import Pages.Containers as ContainersPage
import Pages.Images as ImagesPage
import Pages.Home as HomePage
import Pages.Router as Router
import State exposing (Model, Msg)
import Set exposing (Set)
import Dict exposing (Dict)
import Array
import RemoteData exposing (WebData)
import Json.Decode as Decode
import FileReader


centerDiv : List (Html msg) -> Html msg
centerDiv =
    div [ class "container", style [ ( "text-align", "center" ) ] ]


breaker : List (Html msg) -> List (Html msg)
breaker =
    List.concatMap (\htmlI -> [ htmlI, br [] [] ])



-- ref: https://github.com/tkshill/tkshill.github.io/blob/master/src/Main.elm


view_ : Model -> List (Html Msg) -> Html Msg
view_ model main_ =
    let
        ( header, drawer ) =
            ( [ Layout.row
                    []
                    [ Layout.title [] [ text "Dynamic Dockerizer" ]
                    , Layout.spacer
                    , Layout.navigation []
                        [ Layout.link
                            [ Layout.href ""
                            , Color.background <| Color.black
                            , Options.onClick State.Req_LoginPage_Logout
                            ]
                            [ text "Logout" ]
                        ]
                    ]
              ]
            , [ Layout.title
                    [ Color.background <| Color.color Color.Teal Color.S500

                    --, Options.css "border-bottom-style" "solid"
                    --, Options.css "border-color" "#ffffff"
                    --, Options.css "border-width" "5px"
                    ]
                    [ img [ src "static/img/logo1.png", height 50, width 150 ] [] ]
              , Layout.navigation
                    --[ Color.background Color.black
                    --]
                    []
                <|
                    List.map
                        (\( label, url ) ->
                            Layout.link
                                [ Layout.href ("#/" ++ url)

                                --, Options.onClick (Layout.toggleDrawer Mdl)
                                ]
                                [ text label ]
                        )
                    <|
                        Router.globalTabs
              ]
            )
    in
        Layout.render State.Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.fixedDrawer
            , Layout.rippleTabs
            ]
            { header = header
            , drawer = drawer
            , tabs = ( [], [] )
            , main = main_
            }


buttonMdl : Model -> Int -> Msg -> String -> Html Msg
buttonMdl model index cb display =
    Button.render State.Mdl
        [ index ]
        model.mdl
        -- onClick cannot be used multiple times
        [ Button.raised
        , Button.colored
        , Options.onClick cb
        ]
        [ text display ]


rightButtonMdl : Model -> Int -> Msg -> String -> Html Msg
rightButtonMdl model index cb display =
    Button.render State.Mdl
        [ index ]
        model.mdl
        -- onClick cannot be used multiple times
        [ Options.css "float" "right"
        , Button.raised
        , Button.colored
        , Options.onClick cb
        ]
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


textMidMdl : String -> Html Msg
textMidMdl display =
    Options.styled p
        [ Typo.headline ]
        [ text display ]


bodyTextMdl : String -> Html Msg
bodyTextMdl display =
    Options.styled p
        [ Typo.body2 ]
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
            [ Color.background (Color.color Color.Green Color.A400) ]
            [ text str ]
        ]


chipMdl : String -> Html Msg
chipMdl str =
    Chip.span []
        [ Chip.content
            []
            [ text str ]
        ]


gridMdl : List (Html msg) -> Html msg
gridMdl htmlStuff =
    grid []
        [ cell [ size All 6 ] htmlStuff
        ]


whiteDivMdl : List (Html msg) -> Html msg
whiteDivMdl htmlStuff =
    Options.div
        [ css "position" "relative"
        , css "margin" "auto"
        , css "padding-top" "2rem"
        , css "padding-bottom" "5rem"
        , css "padding-left" "8%"
        , css "padding-right" "8%"
        ]
        htmlStuff


yellowDivMdl : List (Html msg) -> Html msg
yellowDivMdl htmlStuff =
    Options.div
        [ Color.background <| Color.color Color.Yellow Color.S50
        , css "position" "relative"
        , css "margin" "auto"
        , css "padding-top" "2rem"
        , css "padding-bottom" "5rem"
        , css "padding-left" "8%"
        , css "padding-right" "8%"
        ]
        htmlStuff


checkbox : Model -> Bool -> Msg -> String -> Html Msg
checkbox model checked cb display =
    Toggles.checkbox State.Mdl
        [ 0 ]
        model.mdl
        [ Options.onToggle cb
        , Toggles.ripple
        , Toggles.value checked
        ]
        [ text display ]


containersTableMdl : Model -> Html Msg
containersTableMdl model =
    Table.table []
        [ Table.thead []
            [ Table.tr []
                [ Table.th []
                    [ Toggles.checkbox State.Mdl
                        [ -1 ]
                        model.mdl
                        [ Options.onToggle State.Input_Gantry_ContainersPage_ToggleAll
                        , Toggles.value (State.allContainersSelected model)
                        ]
                        []
                    ]
                , Table.th [] [ text "Name" ]
                , Table.th [] [ text "Status" ]
                , Table.th [] [ text "Image" ]
                ]
            ]
        , Table.tbody []
            (ContainersPage.tryGetContainers model.containersPage
                |> List.indexedMap
                    (\idx container ->
                        Table.tr
                            [ when (Set.member (Containers.containerKey container) model.input_Gantry_ContainersPage_SelectedContainers) Table.selected ]
                            [ Table.td []
                                [ Toggles.checkbox State.Mdl
                                    [ idx ]
                                    model.mdl
                                    [ Options.onToggle (State.Input_Gantry_ContainersPage_Toggle container)
                                    , Toggles.value <| Set.member (Containers.containerKey container) model.input_Gantry_ContainersPage_SelectedContainers
                                    ]
                                    []
                                ]
                            , Table.td [] [ a [ href ("#/gantry/containers/" ++ container.id) ] [ text <| toString container.names ] ]
                            , Table.td []
                                [ let
                                    status =
                                        toString container.status
                                  in
                                    if
                                        (status
                                            |> String.toLower
                                            |> String.contains "running"
                                        )
                                    then
                                        colorChipMdl status
                                    else
                                        text status
                                ]
                            , Table.td [] [ text <| toString container.image ]
                            ]
                    )
            )
        ]


containerTableMdl : Containers.Container -> Html Msg
containerTableMdl container =
    Table.table []
        [ Table.thead [] []
        , Table.tbody []
            [ Table.tr []
                [ Table.td [] [ text "Status" ]
                , Table.td []
                    [ let
                        status =
                            toString container.status
                      in
                        if
                            (status
                                |> String.toLower
                                |> String.contains "running"
                            )
                        then
                            colorChipMdl status
                        else
                            text status
                    ]
                ]
            , Table.tr []
                [ Table.td [] [ text "Path" ]
                , Table.td [] [ text <| toString container.command ]
                ]
            , Table.tr []
                [ Table.td [] [ text "Privileged mode" ]
                , Table.td [] [ text container.privileged ]
                ]
            ]
        ]


processTableMdl : Processes.ProcessMetadata -> Html Msg
processTableMdl process =
    Table.table []
        [ Table.thead [] []
        , Table.tbody []
            [ Table.tr []
                [ Table.td [] [ text "Command" ]
                , Table.td [ Options.css "text-align" "left" ] [ text process.cmdline ]
                ]
            , Table.tr []
                [ Table.td [] [ text "Executable" ]
                , Table.td [ Options.css "text-align" "left" ] [ text process.exe ]
                ]
            , Table.tr []
                [ Table.td [] [ text "Binary" ]
                , Table.td [ Options.css "text-align" "left" ] [ text process.bin ]
                ]
            , Table.tr []
                [ Table.td [] [ text "Entrypoint command" ]
                , Table.td [ Options.css "text-align" "left" ] [ text process.entrypointCmd ]
                ]
            , Table.tr []
                [ Table.td [] [ text "Entrypoint arguments" ]
                , Table.td [ Options.css "text-align" "left" ] [ text <| toString process.entrypointArgs ]
                ]
            , Table.tr []
                [ Table.td [] [ text "Working directory" ]
                , Table.td [ Options.css "text-align" "left" ] [ text process.cwd ]
                ]
            , Table.tr []
                [ Table.td [] [ text "Packages required" ]
                , Table.td [ Options.css "text-align" "left" ] (List.concat <| List.map (\pkg -> [ text pkg, br [] [] ]) <| process.packagesSequence)
                ]
            ]
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
                        [ Options.onToggle State.Input_Gantry_ImagesPage_ToggleAll
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
                            [ when (Set.member (Images.imageKey image) model.input_Gantry_ImagesPage_SelectedImages) Table.selected ]
                            [ Table.td []
                                [ Toggles.checkbox State.Mdl
                                    [ idx ]
                                    model.mdl
                                    [ Options.onToggle (State.Input_Gantry_ImagesPage_Toggle image)
                                    , Toggles.value <| Set.member (Images.imageKey image) model.input_Gantry_ImagesPage_SelectedImages
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


progressBar : ProgressKeys.ProgressKeys -> String -> String -> String -> Html Msg
progressBar progressKeys message key subKey =
    let
        bars =
            Dict.values progressKeys
                |> List.filter (\( x, y, _ ) -> x == key && y == subKey)
                |> List.map
                    (\( _, _, progress ) ->
                        div []
                            [ Loading.buffered progress progress
                            , br [] []
                            ]
                    )
    in
        if List.length bars > 0 then
            bars
                |> (::) (div [] [ textMdl message ])
                |> div []
        else
            div [] bars


instancesTableMdl : Model -> List Instances.Instance -> Html Msg
instancesTableMdl model fetchedInstances =
    if List.length fetchedInstances == 0 then
        textMdl "No instances found to be cloned"
    else
        Table.table []
            [ Table.thead []
                [ Table.tr []
                    [ Table.th [] [ text "" ]
                    , Table.th [] [ text "Tags" ]
                    , Table.th [] [ text "Id" ]
                    , Table.th [] [ text "Public DNS" ]
                    , Table.th [] [ text "Public IP" ]
                    ]
                ]
            , Table.tbody []
                (fetchedInstances
                    |> List.indexedMap
                        (\idx instance ->
                            Table.tr
                                []
                                [ Table.td []
                                    [ Toggles.checkbox State.Mdl
                                        [ idx ]
                                        model.mdl
                                        [ Options.onToggle (State.Input_InstancesPage_Toggle instance)
                                        , Toggles.value <| instance.instanceId == model.input_InstancesPage_SelectedInstance
                                        ]
                                        []
                                    ]
                                , Table.td [] [ text <| toString instance.tags ]
                                , Table.td [] [ text <| toString instance.instanceId ]
                                , Table.td [] [ text <| toString instance.dns ]
                                , Table.td [] [ text <| toString instance.publicIp ]
                                ]
                        )
                )
            ]


convertTableMdl : Model -> Html Msg
convertTableMdl model =
    let
        query =
            div []
                [ checkbox model model.input_ConvertPage_SetCloneManually State.Input_ConvertPage_SetCloneManually "Set clone manually"
                , if model.input_ConvertPage_SetCloneManually then
                    div []
                        [ inputMdl model 1 State.Input_ConvertPage_Ec2Url "ec2Url" "text" "IP address"
                        , buttonMdl model 2 State.Ec2_URL_Set "Set"
                        ]
                  else
                    buttonMdl model 0 State.Req_GetProgressKey_Then_GetClone "Find clone"
                ]
    in
        case model.convertPage.cloneWebdata of
            RemoteData.NotAsked ->
                query

            RemoteData.Loading ->
                progressBar model.master_progressKeys "Fetching clone" ProgressKeys.getClone ""

            RemoteData.Failure error ->
                div []
                    [ textMdl (toString error)
                    , query
                    ]

            RemoteData.Success fetchedClone ->
                div []
                    [ query
                    , case fetchedClone.cloned of
                        Nothing ->
                            textMdl "No clone found"

                        Just clone ->
                            div []
                                [ textMdl "Found clone"
                                , Table.table []
                                    [ Table.thead []
                                        [ Table.tr []
                                            [ Table.th [] [ text "Tags" ]
                                            , Table.th [] [ text "Id" ]
                                            , Table.th [] [ text "Public DNS" ]
                                            , Table.th [] [ text "Public IP" ]
                                            ]
                                        ]
                                    , Table.tbody []
                                        [ Table.tr
                                            []
                                            [ Table.td [] [ text <| toString clone.tags ]
                                            , Table.td [] [ text <| toString clone.instanceId ]
                                            , Table.td [] [ text <| toString clone.dns ]
                                            , Table.td [] [ text <| toString clone.publicIp ]
                                            ]
                                        ]
                                    ]
                                ]
                    ]


processesTableMdl : Model -> Html Msg
processesTableMdl model =
    case model.convertPage.processesWebdata of
        RemoteData.NotAsked ->
            textMdl "Processes not fetched"

        RemoteData.Loading ->
            textMdl "Loading ..."

        RemoteData.Failure error ->
            textMdl (toString error)

        RemoteData.Success processes ->
            div []
                [ textMdl "Found processes"
                , buttonMdl model 0 State.Req_ConvertProcesses "Convert"
                , Table.table []
                    [ Table.thead []
                        [ Table.tr []
                            [ Table.th []
                                [ Toggles.checkbox State.Mdl
                                    [ -1 ]
                                    model.mdl
                                    [ Options.onToggle State.Input_ConvertPage_ToggleAll
                                    , Toggles.value (State.allProcessesSelected model)
                                    ]
                                    []
                                ]
                            , Table.th [] [ text "Pid" ]
                            , Table.th [] [ text "Port" ]
                            , Table.th [] [ text "Program" ]
                            , Table.th [] [ text "Status" ]
                            ]
                        ]
                    , Table.tbody []
                        (processes.processes
                            |> List.indexedMap
                                (\idx p ->
                                    Table.tr
                                        [ when (Set.member p.pid model.input_ConvertPage_SelectedProcesses) Table.selected ]
                                        [ Table.td []
                                            [ Toggles.checkbox State.Mdl
                                                [ idx ]
                                                model.mdl
                                                [ Options.onToggle (State.Input_ConvertPage_Toggle p)
                                                , Toggles.value <| Set.member p.pid model.input_ConvertPage_SelectedProcesses
                                                ]
                                                []
                                            ]
                                        , Table.td [] [ a [ href ("#/convert/processes/" ++ p.pid) ] [ text <| toString p.pid ] ]
                                        , Table.td [] [ text <| toString p.port_ ]
                                        , Table.td [] [ text <| toString p.program ]
                                        , Table.td [] [ progressBar model.agent_progressKeys "Converting " ProgressKeys.convertProcess p.pid ]
                                        ]
                                )
                        )
                    ]
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


cssSelectBox : Html.Attribute msg
cssSelectBox =
    style
        [ ( "border", "1px solid #ccc" )
        , ( "font-size", "16px" )
        , ( "height", "34px" )
        , ( "width", "268px" )
        ]


regionsSelectBox : Model -> Html Msg
regionsSelectBox model =
    model.homePage
        |> HomePage.tryGetRegions
        |> List.map
            (\region ->
                option [ value region ] [ text region ]
            )
        |> (::) (option [ attribute "disabled" "", attribute "selected" "", value "" ] [ text "-- select a region -- " ])
        |> select
            [ onChange State.Input_HomePage_Region
            , cssSelectBox
            ]


imagesSelectBox : Model -> Html Msg
imagesSelectBox model =
    model.imagesPage
        |> ImagesPage.tryGetImages
        |> List.map
            (\image ->
                case
                    (image.repoTags |> Array.fromList |> Array.get 0)
                of
                    Just tag ->
                        option [ value tag ] [ text <| toString image.repoTags ]

                    Nothing ->
                        option [ value image.id ] [ text image.id ]
            )
        |> (::) (option [ attribute "disabled" "", attribute "selected" "", value "" ] [ text "-- select an image -- " ])
        |> select
            [ onChange State.Input_Gantry_ContainersPage_Create_Image
            , cssSelectBox
            ]


consoleModeSelectBox : Html Msg
consoleModeSelectBox =
    ContainerCreater.consoleModes
        |> List.map (\( modeCode, modeDisplay, _ ) -> option [ value modeCode ] [ text modeDisplay ])
        |> (::) (option [ attribute "disabled" "", attribute "selected" "", value "" ] [ text "-- select a console mode -- " ])
        |> select
            [ onChange State.Input_Gantry_ContainersPage_Create_ConsoleMode
            , cssSelectBox
            ]


keyFileSelector : Model -> Html Msg
keyFileSelector model =
    div []
        [ input
            [ type_ "file"
            , FileReader.onFileChange State.Input_InstancesPage_Keyfile
            , multiple False
            ]
            []
        ]


protectedView : Model -> Html Msg -> Html Msg
protectedView model loggedInView =
    (case model.loginPage.authenticationState of
        Auth.LoggedIn _ ->
            loggedInView

        Auth.LoggedOut ->
            text "Error"
    )



-- Helpers


onChange : (String -> Msg) -> Html.Attribute Msg
onChange tagger =
    on "change" (Decode.map tagger Html.Events.targetValue)


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
