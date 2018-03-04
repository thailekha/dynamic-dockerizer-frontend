module Types.CommonResponses exposing (..)

import Json.Decode exposing (..)


type alias StringResponse =
    { message : String
    }


decodeStringResponse : Decoder StringResponse
decodeStringResponse =
    map StringResponse
        (field "message" string)


type alias PortResponse =
    { success : Bool
    , statusCode : Int
    , message : String
    }


decodePortResponse : Decoder PortResponse
decodePortResponse =
    map3 PortResponse
        (field "success" bool)
        (field "statusCode" int)
        (field "message" string)


constructErr : String -> PortResponse
constructErr msg =
    { success = False
    , statusCode = -1
    , message = msg
    }
