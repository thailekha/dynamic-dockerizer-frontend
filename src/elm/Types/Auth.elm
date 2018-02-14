module Types.Auth exposing (..)

import Json.Decode exposing (Decoder)
import Json.Decode exposing (int, string, float, nullable, Decoder)
import Json.Decode.Pipeline exposing (decode, hardcoded)
import Json.Encode


type alias Credentials =
    { userName : String
    , accessKeyId : String
    , secretAccessKey : String
    }


type AuthenticationState
    = LoggedOut
    | LoggedIn Credentials


constructCredentials : String -> String -> String -> Credentials
constructCredentials userName accessKeyId secretAccessKey =
    { userName = userName
    , accessKeyId = accessKeyId
    , secretAccessKey = secretAccessKey
    }


emptyCredentials : Credentials
emptyCredentials =
    constructCredentials "" "" ""


decodeCredentials : Credentials -> Decoder Credentials
decodeCredentials credentialsInput =
    decode Credentials
        |> hardcoded credentialsInput.userName
        |> hardcoded credentialsInput.accessKeyId
        |> hardcoded credentialsInput.secretAccessKey


encodeCredentials : Credentials -> Json.Encode.Value
encodeCredentials record =
    Json.Encode.object
        [ ( "userName", Json.Encode.string record.userName )
        , ( "accessKeyId", Json.Encode.string record.accessKeyId )
        , ( "secretAccessKey", Json.Encode.string record.secretAccessKey )
        ]
