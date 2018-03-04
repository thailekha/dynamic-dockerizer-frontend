module Types.ProgressKeys exposing (..)

import Json.Decode exposing (..)
import Dict exposing (Dict)


type alias ProgressKeys =
    Dict String ( String, Float )


init : ProgressKeys
init =
    Dict.empty


getClone : String
getClone =
    "get_clone"


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
