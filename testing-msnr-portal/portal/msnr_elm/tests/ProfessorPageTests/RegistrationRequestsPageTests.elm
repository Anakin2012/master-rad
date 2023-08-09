module ProfessorPageTests.RegistrationRequestsPageTests exposing (requestDecoderTests, requestsListDecoderTests)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, string, map6, intRange, maybe, bool, triple)
import Test exposing (..)
import Json.Encode as Encode exposing (int, null, Value)
import Json.Decode as Decode exposing (decodeValue, decodeString, Error)
import Group exposing (..)
import FuzzerHelper exposing (requestEncoder, registrationRequestFuzzer, success)
import ProfessorPage.RegistrationRequestsPage as RRP
import Http exposing (Error(..))
import Json.Decode as Decode

requestDecoderTests = 
    describe "Request decoder"
    [fuzz registrationRequestFuzzer "decodes json correctly" <|
    \request -> 
        let result = requestEncoder request
                     |> Decode.decodeValue RRP.requestDecoder
        in 
            case result of 
                Ok _ -> 
                    Expect.pass 
                Err err ->
                    Expect.fail (Decode.errorToString err)    
    ]

requestsListDecoderTests = 
    describe "Request list decoder"
    [fuzz (list registrationRequestFuzzer) "decodes json correctly" <| 
    \requests -> 
        [("data", (Encode.list requestEncoder requests))]
        |> Encode.object
        |> Decode.decodeValue RRP.requestsListDecoder
        |> success
        |> Expect.equal True
    ]







