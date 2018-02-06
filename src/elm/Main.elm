module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import RemoteData exposing (WebData)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, hardcoded)
import Json.Encode
import Http


-- APP


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MODEL


type alias Model =
    { credentials : WebData Credentials
    , credentialsInput : Credentials
    }


type alias Credentials =
    { userName : String
    , accessKeyId : String
    , secretAccessKey : String
    }


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


initCredentialsInput : Credentials
initCredentialsInput =
    { userName = ""
    , accessKeyId = ""
    , secretAccessKey = ""
    }


init : ( Model, Cmd Msg )
init =
    ( { credentials = RemoteData.NotAsked
      , credentialsInput = initCredentialsInput
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = UserNameInput String
    | AccessKeyIdInput String
    | SecretAccessKeyInput String
    | Login
    | LoginResponse (WebData Credentials)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserNameInput str ->
            ( { model | credentialsInput = updateUserNameInput model.credentialsInput str }, Cmd.none )

        AccessKeyIdInput str ->
            ( { model | credentialsInput = updateAccessKeyIdInput model.credentialsInput str }, Cmd.none )

        SecretAccessKeyInput str ->
            ( { model | credentialsInput = updateSecretAccessKeyInput model.credentialsInput str }, Cmd.none )

        Login ->
            ( model, reqLogin model )

        LoginResponse response ->
            ( { model | credentials = response }, Cmd.none )



-- VIEW


loginForm : Html Msg
loginForm =
    div []
        [ text "Username:"
        , br [] []
        , input [ name "userName", type_ "text", onInput UserNameInput ] []
        , br [] []
        , text "Access key ID:"
        , br [] []
        , input [ name "accessKeyId", type_ "text", onInput AccessKeyIdInput ] []
        , br [] []
        , text "Secret access key:"
        , br [] []
        , input [ name "secretAccessKey", type_ "password", onInput SecretAccessKeyInput ] []
        , br [] []
        , button [ onClick Login ] [ text "Login" ]
        ]


maybeLoggedIn : WebData Credentials -> Html Msg
maybeLoggedIn response =
    case response of
        RemoteData.Success stockHoldings ->
            text "Hi ..."

        _ ->
            loginForm


view : Model -> Html Msg
view model =
    div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
        [ -- inline CSS (literal)
          maybeLoggedIn model.credentials
        ]


decodeCredentials : Model -> Decode.Decoder Credentials
decodeCredentials model =
    decode Credentials
        |> hardcoded model.credentialsInput.userName
        |> hardcoded model.credentialsInput.accessKeyId
        |> hardcoded model.credentialsInput.secretAccessKey


encodeCredentials : Credentials -> Json.Encode.Value
encodeCredentials record =
    Json.Encode.object
        [ ( "userName", Json.Encode.string record.userName )
        , ( "accessKeyId", Json.Encode.string record.accessKeyId )
        , ( "secretAccessKey", Json.Encode.string record.secretAccessKey )
        ]


reqLogin : Model -> Cmd Msg
reqLogin model =
    Http.post ("http://localhost:8083/ec2/user") (Http.jsonBody (encodeCredentials model.credentialsInput)) (decodeCredentials model)
        |> RemoteData.sendRequest
        |> Cmd.map LoginResponse
