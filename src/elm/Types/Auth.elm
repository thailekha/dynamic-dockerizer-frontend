module Types.Auth exposing (..)

import Json.Decode exposing (..)
import Json.Encode


type alias Credentials =
    { userName : String
    , accessKeyId : String
    , secretAccessKey : String
    , token : String
    }


type AuthenticationState
    = LoggedOut
    | LoggedIn Credentials


constructCredentials : String -> String -> String -> String -> Credentials
constructCredentials userName accessKeyId secretAccessKey token =
    { userName = userName
    , accessKeyId = accessKeyId
    , secretAccessKey = secretAccessKey
    , token = token
    }


emptyCredentials : Credentials
emptyCredentials =
    constructCredentials "" "" "" ""


decodeCredentials : Decoder Credentials
decodeCredentials =
    map4 Credentials
        (field "userName" string)
        (field "accessKeyId" string)
        (field "secretAccessKey" string)
        (field "token" string)



-- For login i.e. ignore token


encodeCredentials : Credentials -> Json.Encode.Value
encodeCredentials record =
    Json.Encode.object
        [ ( "userName", Json.Encode.string record.userName )
        , ( "accessKeyId", Json.Encode.string record.accessKeyId )
        , ( "secretAccessKey", Json.Encode.string record.secretAccessKey )
        ]
