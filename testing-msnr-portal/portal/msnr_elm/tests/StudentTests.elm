module StudentTests exposing (decoderTests, toStringTests)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, string, map6, intRange, maybe, bool, triple)
import Test exposing (..)
import Json.Encode as Encode exposing (string, int, null)
import Json.Decode as Decode exposing (decodeValue)
import Student exposing (..)
import Json.Decode exposing (decodeString)
import FuzzerHelper exposing (studentFuzzer)

decoderTests =
    describe "Student decoder" 
    [test "Decodes json into valid fields and group id into Nothing" <|
        \_ -> """{"id": 1, "email": "pana@gmail.com", "first_name": "ana",
                 "last_name": "petrovic", "index_number": "12345", "group_id": null}"""
                |> decodeString Student.decoder
                |> Result.map .groupId
                |> Expect.equal (Ok Nothing),
    
     fuzz studentFuzzer "Group id should be Nothing when null" <|
        \student ->
         [("id", Encode.int student.id),
          ("email", Encode.string student.email),
          ("first_name", Encode.string student.firstName),
          ("last_name", Encode.string student.lastName),
          ("index_number", Encode.string student.indexNumber),
          ("group_id", Encode.null) ]
              |> Encode.object
              |> Decode.decodeValue Student.decoder
              |> Result.map (\s -> s.groupId)
              |> Expect.equal (Ok Nothing)
    ]
    

toStringTests = 
    describe "toString" 
    [fuzz2 bool studentFuzzer "returns info with index number" <| 
        \withIndex student -> 
            if withIndex then 
                Student.toString withIndex student 
                |> Expect.equal (student.firstName ++ " " ++ student.lastName ++ " " ++ student.indexNumber)
                                
            else 
                Student.toString withIndex student 
                |> Expect.equal (student.firstName ++ " " ++ student.lastName)
    ]