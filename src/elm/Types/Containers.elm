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
        (field "containers" (list decodeContainerIgnorePrivileged))


type alias Container =
    { id : String
    , names : List String
    , image : String
    , imageID : String
    , command : String
    , created : Int
    , status : String
    , privileged : Maybe String
    }


decodeContainer : Decoder Container
decodeContainer =
    map8 Container
        (field "Id" string)
        (field "Names" (list string))
        (field "Image" string)
        (field "ImageID" string)
        (field "Command" string)
        (field "Created" int)
        (field "Status" string)
        (field "Privileged" (maybe string))


decodeContainerIgnorePrivileged : Decoder Container
decodeContainerIgnorePrivileged =
    let
        alwaysNothing =
            (\res ->
                case res of
                    _ ->
                        succeed Nothing
            )
    in
        map8 Container
            (field "Id" string)
            (field "Names" (list string))
            (field "Image" string)
            (field "ImageID" string)
            (field "Command" string)
            (field "Created" int)
            (field "Status" string)
            (field "Privileged" (maybe string)
                |> maybe
                |> andThen alwaysNothing
            )


type alias ContainerGet =
    { container : Container
    }


decodeContainerGet : Decoder ContainerGet
decodeContainerGet =
    map ContainerGet
        (field "container" decodeContainer)
