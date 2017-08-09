module Data.Entry exposing (..)

import Date exposing (Date)
import Date.Extra.Format exposing (utcIsoString)
import Json.Encode
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra
import Json.Decode.Pipeline as Pipeline exposing (decode, required)


type alias Entry =
    { content : String
    , translation : String
    , addedAt : Date
    , location : EntryLocation
    , id : EntryId
    }


type alias EntryLocation =
    { latitude : Float
    , longitude : Float
    , accuracy : Float
    }



-- SERIALISATION --


decodeEntry : Decoder Entry
decodeEntry =
    decode Entry
        |> required "content" (Decode.string)
        |> required "translation" (Decode.string)
        |> required "added_at" (Json.Decode.Extra.date)
        |> required "location" (decodeEntryLocation)
        |> required "id" entryIdDecoder


decodeEntryLocation : Decoder EntryLocation
decodeEntryLocation =
    decode EntryLocation
        |> required "latitude" (Json.Decode.Extra.parseFloat)
        |> required "longitude" (Json.Decode.Extra.parseFloat)
        |> required "accuracy" (Json.Decode.Extra.parseFloat)


encodeEntry : Entry -> Json.Encode.Value
encodeEntry record =
    Json.Encode.object
        [ ( "content", Json.Encode.string <| record.content )
        , ( "translation", Json.Encode.string <| record.translation )
        , ( "added_at", Json.Encode.string <| utcIsoString record.addedAt )
        , ( "location", encodeEntryLocation <| record.location )
        ]


encodeEntryLocation : EntryLocation -> Json.Encode.Value
encodeEntryLocation record =
    Json.Encode.object
        [ ( "latitude", Json.Encode.string <| toString record.latitude )
        , ( "longitude", Json.Encode.string <| toString record.longitude )
        , ( "accuracy", Json.Encode.string <| toString record.accuracy )
        ]



-- IDENTIFIERS --


type EntryId
    = EntryId Int


idToString : EntryId -> String
idToString (EntryId id) =
    toString id


entryIdDecoder : Decoder EntryId
entryIdDecoder =
    Decode.map EntryId Decode.int
