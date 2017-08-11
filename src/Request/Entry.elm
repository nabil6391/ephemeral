module Request.Entry
    exposing
        ( list
        , create
        , update
        , decodeEntryList
        , decodePouchEntries
        , decodePouchEntry
        )

import Data.Entry as Entry
    exposing
        ( Entry
        , EntryId
        , EntryLocation
        , encodeEntry
        , encodeEntryLocation
        , idToString
        , decodeEntry
        )
import Date exposing (Date)
import Date.Extra.Format exposing (utcIsoString)
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Pouch.Ports


-- LIST --


list : Cmd msg
list =
    Pouch.Ports.listEntries "list"



-- CREATE --


type alias CreateConfig record =
    { record
        | content : String
        , translation : String
        , addedAt : Date
        , location : EntryLocation
    }


type alias EditConfig record =
    { record
        | content : String
        , translation : String
    }


create : CreateConfig record -> Cmd msg
create config =
    let
        entry =
            Encode.object
                [ ( "content", Encode.string config.content )
                , ( "translation", Encode.string config.translation )
                , ( "added_at", Encode.string <| utcIsoString config.addedAt )
                , ( "location", encodeEntryLocation config.location )
                ]
    in
        Pouch.Ports.saveEntry entry


update : EntryId -> String -> EditConfig record -> Cmd msg
update entryId rev config =
    let
        id_ =
            idToString entryId

        entry =
            Encode.object
                [ ( "content", Encode.string config.content )
                , ( "translation", Encode.string config.translation )
                , ( "_id", Encode.string id_ )
                , ( "_rev", Encode.string rev )
                ]
    in
        Pouch.Ports.updateEntry entry



-- Called from subscriptions --


decodePouchEntries : (Result String (List Entry) -> msg) -> Value -> msg
decodePouchEntries toMsg entries =
    let
        result =
            Decode.decodeValue decodeEntryList entries
    in
        toMsg result


decodePouchEntry : (Result String Entry -> msg) -> Value -> msg
decodePouchEntry toMsg entry =
    let
        result =
            Decode.decodeValue decodeEntry entry
    in
        toMsg result


decodeEntryList : Decode.Decoder (List Entry)
decodeEntryList =
    Decode.list (Entry.decodeEntry)
