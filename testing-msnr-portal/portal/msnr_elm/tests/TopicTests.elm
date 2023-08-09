module TopicTests exposing (decoderTests, toStringTests)
import Expect exposing (Expectation, err)
import Fuzz exposing (Fuzzer, int, string, map3, intRange, maybe, bool, triple)
import Test exposing (..)
import Json.Encode as Encode exposing (string, int, null)
import Json.Decode as Decode exposing (decodeValue)
import Topic exposing (..)
import Json.Decode exposing (decodeString)
import Svg.Styled.Attributes exposing (type_)
import FuzzerHelper exposing (topicFuzzer, success)

decoderTests = 
    describe "Topic decoder" 
    [test "Decodes json into valid fields" <|
    \_ ->
        let input = """
            { "id" : 1,
              "title" : "Naslov",
              "number" : 1 }
            """                
            decodedOutput = decodeString Topic.decoder input
        in
            Expect.equal decodedOutput
            (Ok
            { id = 1,
              title = "Naslov",
              number = 1
            }),

      test "Given invalid input returns false" <|
      \_ -> 
        let input = """
                { "id" : 1,
                  "title" : "naslov",
                  "number" : "1"} 
            """
            decodedOutput = decodeString Topic.decoder input
        in 
            Expect.err decodedOutput,
          --Expect.equal (success decodedOutput) False,

      fuzz topicFuzzer "decodes json into valid fields" <|
      \topic ->
        let fieldList = [("id", Encode.int topic.id),
                         ("title", Encode.string topic.title),
                         ("number", Encode.int topic.number)]
            decodedOutput = fieldList 
                            |> Encode.object
                            |> decodeValue Topic.decoder
        in 
          Expect.equal (success decodedOutput) True 
      
    ]

toStringTests = 
  describe "toString" 
  [fuzz topicFuzzer "returns a string with number and title" <| 
      \topic -> 
        if topic.number < 10 then 
          Topic.toString topic  
          |> Expect.equal 
          ("0" ++
           (topic.number |> String.fromInt) 
           ++ " " 
           ++ topic.title)
        else 
          Topic.toString topic 
          |> Expect.equal
          (
           (topic.number
           |> String.fromInt) 
           ++ " " 
           ++ topic.title)
  ]
      