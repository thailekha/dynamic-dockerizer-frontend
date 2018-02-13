module Pages.Router exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type GantrySubRoute
    = ContainerRoute
    | ImageRoute


type Route
    = LandingRoute
    | GantryRoute GantrySubRoute
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map LandingRoute top
        , map (GantryRoute ContainerRoute) (s "gantry" </> s "container")
        , map (GantryRoute ImageRoute) (s "gantry" </> s "image")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
