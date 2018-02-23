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
    }


decodeInstance : Decoder Instance
decodeInstance =
    map4 Instance
        (field "InstanceId" string)
        (field "ImageId" string)
        (field "PublicDnsName" string)
        (field "Tags" <| list string)


type alias Clone =
    { clone : Maybe Instance
    }


decodeClone : Decoder Clone
decodeClone =
    map Clone
        (field "clone" <| maybe decodeInstance)
