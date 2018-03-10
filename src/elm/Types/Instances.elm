module Types.Instances exposing (..)

import Json.Decode exposing (..)


type alias Instances =
    { instances : List Instance
    }


decodeInstances : Decoder Instances
decodeInstances =
    map Instances
        (field "instances" (list decodeInstance))


type alias Instance =
    { instanceId : String
    , imageId : String
    , dns : String
    , tags : List String
    , publicIp : String
    }


decodeInstance : Decoder Instance
decodeInstance =
    map5 Instance
        (field "InstanceId" string)
        (field "ImageId" string)
        (field "PublicDnsName" string)
        (field "Tags" <| list string)
        (field "PublicIpAddress" string)


type alias ImportedAndCloned =
    { imported : Maybe Instance
    , cloned : Maybe Instance
    }


decodeImportedAndCloned : Decoder ImportedAndCloned
decodeImportedAndCloned =
    map2 ImportedAndCloned
        (field "imported" <| maybe decodeInstance)
        (field "cloned" <| maybe decodeInstance)


decodeInstanceResponse : Decoder ImportedAndCloned
decodeInstanceResponse =
    let
        alwaysNothing =
            (\res ->
                case res of
                    _ ->
                        succeed Nothing
            )
    in
        map2 ImportedAndCloned
            --ignore the "imported" field
            (field "imported" (maybe decodeInstance)
                |> maybe
                |> andThen alwaysNothing
            )
            (field "instance" <| maybe decodeInstance)


manualClone : String -> ImportedAndCloned
manualClone ip =
    let
        clone =
            { instanceId = ""
            , imageId = ""
            , dns = ""
            , tags = []
            , publicIp = ip
            }
    in
        { imported = Nothing
        , cloned = Just clone
        }
