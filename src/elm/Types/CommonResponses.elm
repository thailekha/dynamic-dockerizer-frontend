module Types.CommonResponses exposing (..)

import Json.Decode exposing (string, bool, Decoder)
import Json.Decode.Pipeline exposing (decode, required)


type alias StringResponse =
    { message : String
    }


decodeStringResponse : Decoder StringResponse
decodeStringResponse =
    decode StringResponse
        |> required "message" string


type alias StringStatusResponse =
    { success : Bool
    , message : String
    }


decodeStringStatusResponse : Decoder StringStatusResponse
decodeStringStatusResponse =
    decode StringStatusResponse
        |> required "success" bool
        |> required "message" string
