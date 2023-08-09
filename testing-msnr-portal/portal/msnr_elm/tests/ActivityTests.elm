module ActivityTests exposing (decoderTests, encodeTests)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, string, map6, intRange, maybe, bool, triple)
import Test exposing (..)
import Json.Encode as Encode exposing (string, int, null, Value)
import Json.Decode as Decode exposing (decodeValue, decodeString)
import Group exposing (..)
import FuzzerHelper exposing (activityFuzzer, success)
import Student exposing (Student)
import Topic exposing (Topic)
import Activity exposing (Activity)

decoderTests =
    describe "Activity decoder"
    [test "decode" <|
    \_ -> 
        let input = """
            { "id" : 1,
              "start_date" : 1,
              "end_date" : 3,
              "points" : 1,
              "activity_type_id" : 2,
              "is_signup" : false}
            """                
            decodedOutput = decodeString Activity.decoder input
        in
            Expect.equal decodedOutput
            (Ok
            { 
              id = 1,
              startDate = 1,
              endDate = 3,
              points = 1,
              activityTypeId = 2,
              isSignup = False
            }),
        
    fuzz activityFuzzer "decodes a json into valid fields" <|
     \activity -> 
        [("id", Encode.int activity.id),
         ("start_date", Encode.int activity.startDate),
         ("end_date", Encode.int activity.endDate),
         ("points", Encode.int activity.points), 
         ("activity_type_id", Encode.int activity.activityTypeId),
         ("is_signup", Encode.bool activity.isSignup)]
         |> Encode.object
         |> Decode.decodeValue Activity.decoder
         |> success
         |> Expect.equal True
    ]

encodeTests = 
    describe "Encode"
    [test "Encodes activity fields to json" <|
    \_ -> 
        let activity = { startDate = 1, 
                         endDate = 5, 
                         points = 10,
                         activityTypeId = 1,
                         isSignup = True
                       }
            encodedOutput = Activity.encode activity
        in
           Expect.equal (Encode.encode 0 encodedOutput) 
            """{"start_date":1,"end_date":5,"points":10,"activity_type_id":1,"is_signup":true}"""  
    ] 

