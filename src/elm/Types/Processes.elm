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


type alias ProcessMetadata =
    { cmdline : String
    , exe : String
    , bin : String
    , entrypointCmd : String
    , entrypointArgs : List String
    , cwd : String
    , packagesSequence : List String
    }


decodeProcessMetadata : Decoder ProcessMetadata
decodeProcessMetadata =
    map7 ProcessMetadata
        (field "cmdline" string)
        (field "exe" string)
        (field "bin" string)
        (field "entrypointCmd" string)
        (field "entrypointArgs" (list string))
        (field "cwd" string)
        (field "packagesSequence" (list string))
