module GroupTests exposing (decoderTests, encoderStudent, toStringTests, viewTests)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, string, map6, intRange, maybe, bool, triple)
import Test exposing (..)
import Json.Encode as Encode exposing (string, int, null, Value)
import Json.Decode as Decode exposing (decodeValue, decodeString)
import Group exposing (..)
import FuzzerHelper exposing (topicFuzzer, groupFuzzer, success, studentListFuzzer)
import Student exposing (Student)
import Topic exposing (Topic)
import Accessibility.Styled as Html exposing (Html)
import Html.Attributes as Attributes
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, tag, text, containing)



encoderStudent : Student -> Value
encoderStudent student = 
    [("id", Encode.int student.id),
     ("email", Encode.string student.email),
     ("first_name", Encode.string student.firstName),
     ("last_name", Encode.string student.lastName),
     ("index_number", Encode.string student.indexNumber),
     ("group_id", student.groupId |> Maybe.map Encode.int
                                  |> Maybe.withDefault Encode.null)]
     |> Encode.object

encoderTopic : Topic -> Value
encoderTopic topic = 
    [("id", Encode.int topic.id),
     ("title", Encode.string topic.title),
     ("number", Encode.int topic.number)]
     |> Encode.object

decoderTests = 
    describe "Group decoder"
    [fuzz groupFuzzer "Decodes json into valid string fields" <|
     \group -> 
        [("id", Encode.int group.id),
         ("students", Encode.list encoderStudent group.students),
         ("topic", group.topic |> Maybe.map encoderTopic
                               |> Maybe.withDefault Encode.null)]
         |> Encode.object
         |> Decode.decodeValue Group.decoder
         |> success
         |> Expect.equal True,
    
     fuzz groupFuzzer "Topic should be Nothing when no topics" <|
     \group -> 
        [("id", Encode.int group.id),
         ("students", Encode.list encoderStudent group.students),
         ("topic", Encode.null)]
         |> Encode.object
         |> Decode.decodeValue Group.decoder
         |> Result.map (\g -> g.topic)
         |> Expect.equal (Ok Nothing)           
    ]

toStringTests = 
    describe "toString" 
    [test "string representation when topic is Nothing" <|
     \_ -> 
        let studentList = [{ id = 1, email = "john@gmail.com", firstName = "John", lastName = "Doe", indexNumber = "1234", groupId = Just 1},
                           { id = 2, email = "jane@gmail.com", firstName = "Jane", lastName = "Doo", indexNumber = "2223", groupId = Just 1}]

            group = {id = 1, topic = Nothing, students = studentList }
        in Group.toString group
           |> Expect.equal "Doe, Doo",

      fuzz2 (intRange 1 50) studentListFuzzer "fuzzer when topic is Nothing" <|
      \id students ->
            let group = { id = id, topic = Nothing, students = students}
                lastNames = List.map .lastName group.students
                            |> String.join ", "

            in Group.toString group 
               |> Expect.equal lastNames
    ]

viewTests = 
    describe "Group view" 
    [fuzz2 (intRange 1 10) studentListFuzzer "check when topic is Nothing" <|
    \id students -> 
        let group = { id = id, topic = Nothing, students = students}
            studentListString = List.map (Student.toString False) group.students
                                |> String.join ", "

        in Group.view group
           |> Html.toUnstyled
           |> Query.fromHtml
           |> Query.has [ tag "h5", containing [text studentListString]],

    fuzz groupFuzzer "fuzz when topic" <|
    \group -> 
        case group.topic of 
            Nothing -> Expect.pass
            Just t ->     
                let     
                 topicString = Topic.toString t

                in Group.view group
                   |> Html.toUnstyled
                   |> Query.fromHtml
                   |> Query.has [ tag "h4"
                                , containing [ text topicString ]
                                ]

    ]


