module Pages.Login exposing (..)

import Types.Auth as Auth
import RemoteData exposing (WebData)
import Json.Decode exposing (Value, decodeValue)
import Debug


type alias Model =
    { authenticationState : Auth.AuthenticationState
    , credentialsWebdata : WebData Auth.Credentials
    }


init : Maybe Value -> Model
init config =
    { authenticationState =
        case config of
            Just initialData ->
                case (decodeValue Auth.decodeCredentials initialData) of
                    Ok decodedCredentials ->
                        Auth.LoggedIn decodedCredentials

                    Err _ ->
                        Debug.log "Cannot decode auth data from config" ""
                            |> always Auth.LoggedOut

            Nothing ->
                Auth.LoggedOut
    , credentialsWebdata = RemoteData.NotAsked
    }


updateCredentialsWebdata : Model -> WebData Auth.Credentials -> Model
updateCredentialsWebdata model response =
    { model
        | credentialsWebdata = response
        , authenticationState =
            (case response of
                RemoteData.Success creds ->
                    Auth.LoggedIn creds

                _ ->
                    model.authenticationState
            )
    }


tryGetToken : Model -> String
tryGetToken model =
    case model.authenticationState of
        Auth.LoggedIn creds ->
            creds.token

        Auth.LoggedOut ->
            ""


tryGetAccessKeyId : Model -> String
tryGetAccessKeyId model =
    case model.authenticationState of
        Auth.LoggedIn creds ->
            creds.accessKeyId

        Auth.LoggedOut ->
            ""
