module Types.Images exposing (..)

import Json.Decode exposing (..)


type alias Images =
    { images : List Image
    }


decodeImages : Decoder Images
decodeImages =
    map Images
        (field "images" (list decodeImage))


type alias Image =
    { created : Int
    , id : String
    , repoTags : List String
    , size : Int
    , virtualSize : Int
    }


decodeImage : Decoder Image
decodeImage =
    map5 Image
        (field "Created" int)
        (field "Id" string)
        (field "RepoTags" (list string))
        (field "Size" int)
        (field "VirtualSize" int)


imageKey : Image -> String
imageKey =
    .id
