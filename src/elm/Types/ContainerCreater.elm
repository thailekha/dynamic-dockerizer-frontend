module Types.ContainerCreater exposing (..)

import Array
import Json.Encode exposing (Value, object, string, list, bool)


consoleModes : List ( String, String, ( Bool, Bool ) )
consoleModes =
    [ ( "both", "Interactive & TTY (-i -t)", ( True, True ) )
    , ( "std", "Interactive (-i)", ( True, False ) )
    , ( "tty", "TTY (-t)", ( False, True ) )
    , ( "none", "No Console", ( False, False ) )
    ]


consoleValue : String -> Maybe ( Bool, Bool )
consoleValue mode =
    consoleModes
        |> List.filter (\( m, _, _ ) -> m == mode)
        |> List.map (\( _, _, ( x, y ) ) -> ( x, y ))
        |> Array.fromList
        |> Array.get 0


encodeBinding : List ( String, String ) -> Value
encodeBinding bindings =
    bindings
        |> List.map
            (\( container, host ) ->
                (object
                    [ ( "container", string container )
                    , ( "host", string host )
                    ]
                )
            )
        |> list


encodeContainerCreater : String -> String -> String -> String -> List ( String, String ) -> List String -> Bool -> Bool -> Bool -> Value
encodeContainerCreater gantryUrl token name image bindings binds privileged openStdin tty =
    object
        [ ( "url", string gantryUrl )
        , ( "token", string token )
        , ( "name", string name )
        , ( "image", string image )
        , ( "bindings", encodeBinding bindings )
        , ( "binds", list <| List.map string binds )
        , ( "privileged", bool privileged )
        , ( "openStdin", bool openStdin )
        , ( "tty", bool tty )
        ]
