module Pages.Router exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = LandingRoute
    | CloneRoute
    | ConvertCloneViewRoute
    | ConvertProcessesViewRoute
    | ConvertProcessViewRoute String
    | GantryContainersViewRoute
    | GantryContainersCreateRoute
    | GantryContainerViewRoute String
    | GantryImageRoute
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map LandingRoute top
        , map CloneRoute <| s "clone"
        , map ConvertCloneViewRoute <| s "convert"
        , map ConvertProcessesViewRoute <| s "convert" </> s "processes"
        , map ConvertProcessViewRoute <| s "convert" </> s "processes" </> string
        , map GantryContainersViewRoute <| s "gantry" </> s "containers"
        , map GantryContainersCreateRoute <| s "gantry" </> s "containers" </> s "create"
        , map GantryImageRoute <| s "gantry" </> s "image"
        , map GantryContainerViewRoute <| s "gantry" </> s "containers" </> string
        ]


globalTabs : List ( String, String )
globalTabs =
    [ ( "Home", "" )
    , ( "Clone", "clone" )
    , ( "Convert", "convert" )
    , ( "Containers/Images Lifecycle", "gantry/containers" )
    ]


convertTabs : List ( String, String )
convertTabs =
    [ ( "Cloned Instance", "convert" )
    , ( "Processes", "convert/processes" )
    ]


gantryTabs : List ( String, String )
gantryTabs =
    [ ( "Containers", "gantry/containers" )
    , ( "Image", "gantry/image" )
    ]


containersTabs : List ( String, String )
containersTabs =
    [ ( "List", "gantry/containers" )
    , ( "Create new", "gantry/containers/create" )
    ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
