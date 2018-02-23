module Types.Processes exposing (..)

import Json.Decode exposing (..)


type alias Processes =
    { processes : List Process
    }


decodeProcesses : Decoder Processes
decodeProcesses =
    map Processes
        (field "processes" (list decodeProcess))


type alias Process =
    { pid : String
    , port_ : String
    , program : String
    }


decodeProcess : Decoder Process
decodeProcess =
    map3 Process
        (field "pid" string)
        (field "port" string)
        (field "program" string)
