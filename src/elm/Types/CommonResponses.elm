module Types.CommonResponses exposing (..)

import Json.Decode exposing (int, string, bool, field, map3, Decoder)
import Json.Decode.Pipeline exposing (decode, required)


type alias StringResponse =
    { message : String
    }


decodeStringResponse : Decoder StringResponse
decodeStringResponse =
    decode StringResponse
        |> required "message" string


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
