module Pages.Router exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type ContainerSubRoute
    = ContainerViewRoute
    | ContainerCreateRoute


type GantrySubRoute
    = ContainerRoute ContainerSubRoute
    | ImageRoute


type Route
    = LandingRoute
    | GantryRoute GantrySubRoute
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map LandingRoute top
        , (map <| GantryRoute <| ContainerRoute ContainerViewRoute) <| s "gantry" </> s "container"
        , (map <| GantryRoute <| ContainerRoute ContainerCreateRoute) <| s "gantry" </> s "container" </> s "create"
        , (map <| GantryRoute ImageRoute) <| s "gantry" </> s "image"
        ]


globalTabs : List ( String, String )
globalTabs =
    [ ( "Home", "" )
    , ( "Gantry", "gantry/container" )
    ]


gantryTabs : List ( String, String )
gantryTabs =
    [ ( "Container", "gantry/container" )
    , ( "Image", "gantry/image" )
    ]


containerTabs : List ( String, String )
containerTabs =
    [ ( "CONTAINERS", "gantry/container" )
    , ( "CREATE NEW", "gantry/container/create" )
    ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
