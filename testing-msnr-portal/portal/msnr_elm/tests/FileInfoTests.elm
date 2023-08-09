module FileInfoTests exposing (decoderTests)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, string, map6, intRange, maybe, bool, triple)
import Test exposing (..)
import Json.Encode as Encode exposing (string, int, null, Value)
import Json.Decode as Decode exposing (decodeValue, decodeString)
import Group exposing (..)
import FuzzerHelper exposing (fileInfoFuzzer, success)
import FileInfo exposing (FileInfo)

decoderTests =
    describe "FileInfo decoder" 
    [fuzz fileInfoFuzzer "Decodes json into valid string" <|
     \fileInfo -> 
        [("id", Encode.int fileInfo.id),
         ("attached", Encode.bool fileInfo.attached),
         ("file_name", Encode.string fileInfo.fileName)]
        |> Encode.object
        |> Decode.decodeValue FileInfo.decoder
        |> success
        |> Expect.equal True
    ]
