module Types.ProgressKeys exposing (..)

import Json.Decode exposing (..)
import Dict exposing (Dict)


type alias ProgressKeys =
    Dict String ( String, String, Float )


init : ProgressKeys
init =
    Dict.empty


getClone : String
getClone =
    "get_clone"


doClone : String
doClone =
    "do_clone"


getInstances : String
getInstances =
    "get_instances"


convertProcess : String
convertProcess =
    "convert_process"


getProcess : String
getProcess =
    "get_process"


destroyClone : String
destroyClone =
    "destroy_Clone"


type alias ProgressKey =
    { key : String
    }


decodeProgressKey : Decoder ProgressKey
decodeProgressKey =
    map ProgressKey
        (field "key" string)


type alias ProgressStatus =
    { status : Float
    }


decodeProgressStatus : Decoder ProgressStatus
decodeProgressStatus =
    map ProgressStatus
        (field "status" float)
