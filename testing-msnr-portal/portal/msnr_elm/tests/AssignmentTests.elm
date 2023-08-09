module AssignmentTests exposing (decoderTests, shallowDecoderTests)
import Assignment exposing (Assignment)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, string, map6, intRange, maybe, bool, triple)
import Test exposing (..)
import Json.Encode as Encode exposing (string, int, null, Value)
import Json.Decode as Decode exposing (decodeValue, decodeString)
import Group exposing (..)
import FuzzerHelper exposing (shallowAssignmentFuzzer, assignmentFuzzer, success, encodeActivityType)
import Assignment exposing (encodeActivity)
import ActivityType exposing (ActivityType)
import Activity exposing (Activity)
import Svg exposing (desc)

decoderTests = 
    describe "Assignment decoder" 
    [fuzz assignmentFuzzer "Fuzz tests for decoding assignment" <|
    \assignment -> 
        [("id", Encode.int assignment.id),
         ("grade", assignment.grade |> Maybe.map Encode.int
                                    |> Maybe.withDefault Encode.null),
         ("completed", Encode.bool assignment.completed),
         ("comment", assignment.comment |> Maybe.map Encode.string
                                        |> Maybe.withDefault Encode.null),
         ("activity", encodeActivity assignment.activity),
         ("activity_type", encodeActivityType assignment.activityType)]
        |> Encode.object
        |> Decode.decodeValue Assignment.decoder
        |> success
        |> Expect.equal True
    ]

shallowDecoderTests = 
    describe "Shallow assignment decoder" 
    [fuzz shallowAssignmentFuzzer "Fuzz tests for decoding shallow assignment" <|
     \shallowAssignment -> 
     [("id", Encode.int shallowAssignment.id),
      ("activity_id", Encode.int shallowAssignment.activityId),
      ("student_id", shallowAssignment.studentId |> Maybe.map Encode.int
                                                 |> Maybe.withDefault Encode.null),
      ("group_id", shallowAssignment.groupId |> Maybe.map Encode.int
                                             |> Maybe.withDefault Encode.null),
      ("grade", shallowAssignment.grade |> Maybe.map Encode.int
                                        |> Maybe.withDefault Encode.null),
      ("comment", shallowAssignment.comment |> Maybe.map Encode.string
                                            |> Maybe.withDefault Encode.null),
      ("completed", Encode.bool shallowAssignment.completed)]
      |> Encode.object
      |> Decode.decodeValue Assignment.shallowDecoder
      |> success
      |> Expect.equal True
    ]

encodeActivity : Activity -> Encode.Value
encodeActivity activity = 
    Encode.object
   [("id", Encode.int activity.id),
    ("start_date", Encode.int activity.startDate),
    ("end_date", Encode.int activity.endDate),
    ("points", Encode.int activity.points), 
    ("activity_type_id", Encode.int activity.activityTypeId),
    ("is_signup", Encode.bool activity.isSignup)
   ]


