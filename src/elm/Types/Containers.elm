module Types.Containers exposing (..)

import Json.Decode exposing (list, int, string, bool, nullable, Decoder)
import Json.Decode.Pipeline exposing (decode, hardcoded, required)


type alias Containers =
    { containers : List Container
    }


decodeContainers : Decoder Containers
decodeContainers =
    decode Containers
        |> required "containers" (list decodeContainer)



--type alias Labels =
--    -- revise
--    List String
--decodeLabels : Decoder Labels
--decodeLabels =
--    decode Labels
--        |> hardcoded "revised"


type alias Bridge =
    { iPAMConfig : Maybe String -- revise
    , links : Maybe String -- revise
    , aliases : Maybe String -- revise
    , networkID : String
    , endpointID : String
    , gateway : String
    , iPAddress : String
    , iPPrefixLen : Int
    , iPv6Gateway : String
    , globalIPv6Address : String
    , globalIPv6PrefixLen : Int
    , macAddress : String
    }


decodeBridge : Decoder Bridge
decodeBridge =
    decode Bridge
        |> required "IPAMConfig" (nullable string)
        |> required "Links" (nullable string)
        |> required "Aliases" (nullable string)
        |> required "NetworkID" string
        |> required "EndpointID" string
        |> required "Gateway" string
        |> required "IPAddress" string
        |> required "IPPrefixLen" int
        |> required "IPv6Gateway" string
        |> required "GlobalIPv6Address" string
        |> required "GlobalIPv6PrefixLen" int
        |> required "MacAddress" string


type alias Networks =
    { bridge : Bridge
    }


decodeNetworks : Decoder Networks
decodeNetworks =
    decode Networks
        |> required "bridge" decodeBridge


type alias Networksettings =
    { networks : Networks
    }


decodeNetworksettings : Decoder Networksettings
decodeNetworksettings =
    decode Networksettings
        |> required "Networks" decodeNetworks


type alias Hostconfig =
    { networkMode : String
    }


decodeHostconfig : Decoder Hostconfig
decodeHostconfig =
    decode Hostconfig
        |> required "NetworkMode" string


type alias Container =
    { id : String
    , names : List String
    , image : String
    , imageID : String
    , command : String
    , created : Int
    , state : String
    , status : String
    , ports : List Port
    , labels : String -- revise

    --, sizeRw : Int
    --, sizeRootFs : Int
    , hostConfig : Hostconfig
    , networkSettings : Networksettings
    , mounts : List Mount
    }


decodeContainer : Decoder Container
decodeContainer =
    decode Container
        |> required "Id" string
        |> required "Names" (list string)
        |> required "Image" string
        |> required "ImageID" string
        |> required "Command" string
        |> required "Created" int
        |> required "State" string
        |> required "Status" string
        |> required "Ports" (list decodePort)
        |> hardcoded "labels - revise !!!"
        -- revise "Labels"
        --|> required "SizeRw" int
        --|> required "SizeRootFs" int
        |> required "HostConfig" decodeHostconfig
        |> required "NetworkSettings" decodeNetworksettings
        |> required "Mounts" (list decodeMount)


type alias Mount =
    { name : String
    , source : String
    , destination : String
    , driver : String
    , mode : String
    , rW : Bool
    , propagation : String
    }


decodeMount : Decoder Mount
decodeMount =
    decode Mount
        |> required "Name" string
        |> required "Source" string
        |> required "Destination" string
        |> required "Driver" string
        |> required "Mode" string
        |> required "RW" bool
        |> required "Propagation" string


type alias Port =
    { privatePort : Int
    , publicPort : Int
    , type_ : String
    }


decodePort : Decoder Port
decodePort =
    decode Port
        |> required "PrivatePort" int
        |> required "PublicPort" int
        |> required "Type" string
