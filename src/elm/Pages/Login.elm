module Pages.Login exposing (..)

import Types.Auth as Auth
import RemoteData exposing (WebData)


type alias Model =
    { authenticationState : Auth.AuthenticationState
    , credentialsWebdata : WebData Auth.Credentials
    }


init : Maybe Auth.Credentials -> Model
init initialData =
    { authenticationState =
        case initialData of
            Just credentials ->
                Auth.LoggedIn credentials

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
