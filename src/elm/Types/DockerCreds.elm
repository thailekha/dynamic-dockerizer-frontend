module Types.DockerCreds exposing (..)

import Json.Decode exposing (..)


type alias DockerCreds =
    { username : String
    , password : String
    }


init : DockerCreds
init =
    { username = ""
    , password = ""
    }


decode : Decoder DockerCreds
decode =
    map2 DockerCreds
        (field "username" string)
        (field "password" string)
