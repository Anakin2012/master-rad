module ProfessorPageTests.RegistrationRequestsPageTests exposing (processDataTests, requestDecoderTests, requestsListDecoderTests)

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
import Nri.Ui.Modal.V11 as Modal


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

processDataTests = 
    describe "processData returns new Model"
    [test "takes model and list of req, returns new model" <|
    \_ ->
        let  
            req1 = RRP.RegistrationRequest 1 "name" "lastname" "email" "index" "pending"
            req2 = RRP.RegistrationRequest 2 "name2" "lastname2" "email2" "index2" "accepted"
            req3 = RRP.RegistrationRequest 3 "name3" "lastname3" "email3" "index3" "rejected"
            allReqs = [ req1, req2, req3]
            model = RRP.init
            expectedModel = (RRP.Model [req2] [req3] [req1] False RRP.Pending True RRP.None Modal.init False False)
        in 
            RRP.processData model allReqs
            |> Expect.equal expectedModel, 

     fuzz requestsFuzzer "fuzz for processData accepted" <|
     \data -> 
        let
            model = RRP.init
            accepted = List.filter (\x -> x.status == "accepted") data 
        in
            RRP.processData model data 
            |> .acceptedRequests
            |> Expect.equal accepted,

     fuzz requestsFuzzer "fuzz for processData rejected" <|
     \data -> 
        let
            model = RRP.init
            rejected = List.filter (\x -> x.status == "rejected") data 
        in
            RRP.processData model data 
            |> .rejectedRequests
            |> Expect.equal rejected,

    fuzz requestsFuzzer "fuzz for processData pending" <|
     \data -> 
        let
            model = RRP.init
            pending = List.filter (\x -> x.status == "pending") data 
        in
            RRP.processData model data 
            |> .pendingRequests
            |> Expect.equal pending
        
    ]




requestsFuzzer : Fuzzer (List RRP.RegistrationRequest)
requestsFuzzer =
    Fuzz.list registrationRequestFuzzer



{-
type alias Model =
    { acceptedRequests : List RegistrationRequest
    , rejectedRequests : List RegistrationRequest
    , pendingRequests : List RegistrationRequest
    , hasProcessingError : Bool
    , tab : Tab
    , isInitialized : Bool
    , modalAction : ModalAction
    , modalState : Modal.Model
    , updatingRequest : Bool
    , dismissedMsg : Bool
    }

-}

