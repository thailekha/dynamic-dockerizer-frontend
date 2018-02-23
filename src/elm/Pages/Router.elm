module Pages.Router exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = LandingRoute
    | CloneRoute
    | ConvertRoute
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
        , map ConvertRoute <| s "convert"
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
    , ( "Gantry", "gantry/containers" )
    ]


gantryTabs : List ( String, String )
gantryTabs =
    [ ( "Containers", "gantry/containers" )
    , ( "Image", "gantry/image" )
    ]


containersTabs : List ( String, String )
containersTabs =
    [ ( "CONTAINERS", "gantry/containers" )
    , ( "CREATE NEW", "gantry/containers/create" )
    ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
