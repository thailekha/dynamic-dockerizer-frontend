module Components.Creds exposing (..)

import Json.Decode as Decode
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


decodeCredentials : Credentials -> Decode.Decoder Credentials
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


updateUserNameInput : Credentials -> String -> Credentials
updateUserNameInput cred userName =
    { cred
        | userName = userName
    }


updateAccessKeyIdInput : Credentials -> String -> Credentials
updateAccessKeyIdInput cred accessKeyId =
    { cred
        | accessKeyId = accessKeyId
    }


updateSecretAccessKeyInput : Credentials -> String -> Credentials
updateSecretAccessKeyInput cred secretAccessKey =
    { cred
        | secretAccessKey = secretAccessKey
    }
