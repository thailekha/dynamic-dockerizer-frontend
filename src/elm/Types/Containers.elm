module Types.Containers exposing (..)

import Json.Decode exposing (..)


containerKey : Container -> String
containerKey =
    .id


type alias Containers =
    { containers : List Container
    }


decodeContainers : Decoder Containers
decodeContainers =
    map Containers
        (field "containers" (list decodeContainer))


type alias Container =
    { id : String
    , names : List String
    , image : String
    , imageID : String
    , command : String
    , created : String
    , status : String
    , privileged : String
    }


decodeContainer : Decoder Container
decodeContainer =
    map8 Container
        (field "Id" string)
        (field "Names" (list string))
        (field "Image" string)
        (field "ImageID" string)
        (field "Command" string)
        (field "Created" string)
        (field "Status" string)
        (field "Privileged" string)


type alias ContainerGet =
    { container : Container
    }


decodeContainerGet : Decoder ContainerGet
decodeContainerGet =
    map ContainerGet
        (field "container" decodeContainer)
