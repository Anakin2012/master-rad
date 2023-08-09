module ActivityTypeTests exposing (contentDecoderTests, decoderTests, fileUploadDecoderTests, codeDecoderTests)
import Expect exposing (..)
import Test exposing (..)
import Json.Encode as Encode exposing (null, Value)
import Json.Decode as Decode exposing (decodeValue, decodeString)
import Group exposing (..)
import FuzzerHelper exposing (activityTypeFuzzer, fileUploadInfoFuzzer, success)
import ActivityType exposing (Content, FileUploadInfo, TypeCode, contentDecoder, codeDecoder)

encodeCode : TypeCode -> Value
encodeCode code =
    case code of
        ActivityType.Group -> Encode.string "group"
        ActivityType.Topic -> Encode.string "topic"
        ActivityType.Other -> Encode.string "other"

encodeFileUploadInfo : FileUploadInfo -> Value
encodeFileUploadInfo info =
    Encode.object
        [("name", Encode.string info.name),
         ("extension", Encode.string info.extension)
        ]


encodeContent : Content -> Value
encodeContent content =
    case content of
        ActivityType.Files fileUploadInfos ->
            Encode.object
                [ ("files", Encode.list encodeFileUploadInfo fileUploadInfos)
                ]

        ActivityType.Empty ->
            null

decoderTests = 
    describe "decoder" 
    [test "Activity type decoder with empty content" <|
     \_ -> 
        let input = """
            {"id" : 1, 
             "name" : "ana",
             "code" : "group",
             "description" : "opis",
             "is_group" : true, 
             "has_signup" : true,
             "content" : "empty"}
            """
            decodedOutput = decodeString ActivityType.decoder input 

        in 
            Expect.equal decodedOutput
            (Ok
            { 
              id = 1,
              name = "ana",
              code = ActivityType.Group,
              description = "opis",
              isGroup = True,
              hasSignup = True,
              content = ActivityType.Empty
            }),


    test "Activity type decoder with content" <|
     \_ -> 
        let input = """
            {"id" : 1, 
             "name" : "ana",
             "code" : "topic",
             "description" : "opis",
             "is_group" : true, 
             "has_signup" : true,
             "content" : {
                "files": [
                    { "name": "name", "extension": "ext" }
                ]
             }
            }
            """
            decodedOutput = decodeString ActivityType.decoder input 

        in 
            Expect.equal decodedOutput
            (Ok
            { 
              id = 1,
              name = "ana",
              code = ActivityType.Topic,
              description = "opis",
              isGroup = True,
              hasSignup = True,
              content = ActivityType.Files [ { name = "name", extension = "ext" } ]
            }),

     fuzz activityTypeFuzzer "fuzzer test" <|
     \activityType -> 
        [("id", Encode.int activityType.id),
        ("name", Encode.string activityType.name),
        ("code", encodeCode activityType.code),
        ("description", Encode.string activityType.description), 
        ("is_group", Encode.bool activityType.isGroup),
        ("has_signup", Encode.bool activityType.hasSignup),
        ("content", encodeContent activityType.content)]
        |> Encode.object
        |> decodeValue ActivityType.decoder
        |> success
        |> Expect.equal True
    ]
       

fileUploadDecoderTests =
    describe "fileUploadDecoder" 
    [fuzz fileUploadInfoFuzzer "valid file upload" <| 
    \fileUploadInfo ->
        [("name", Encode.string fileUploadInfo.name),
         ("extension", Encode.string fileUploadInfo.extension)]
        |> Encode.object
        |> Decode.decodeValue ActivityType.fileUploadDecoder
        |> success
        |> Expect.equal True
    ]


codeDecoderTests =
    describe "codeDecoder" 
    [test "Decodes TypeCode Group" <|
     \_ ->
        decodeString codeDecoder "\"group\""
        |> Expect.equal
        (Ok ActivityType.Group),

     test "Decodes TypeCode Topic" <|
     \_ ->
        decodeString codeDecoder "\"topic\""
        |> Expect.equal
        (Ok ActivityType.Topic),

     test "Decodes TypeCode Other" <|
     \_ ->
        decodeString codeDecoder "\"something\""
        |> Expect.equal
        (Ok ActivityType.Other)
    ]


contentDecoderTests =
    describe "contentDecoder"
    [test "Decodes Empty content" <|
    \_ -> 
        decodeString contentDecoder "{}"
        |> Expect.equal 
        (Ok ActivityType.Empty),
     
     test "Decodes Files content" <|
     \_ -> 
        decodeString contentDecoder "{ \"files\": [{ \"name\": \"file1\", \"extension\": \"txt\" }] }"
        |> Expect.equal
        (Ok (ActivityType.Files [{ name = "file1", extension = "txt"}])),

    test "invalid Files content returns Empty" <|
     \_ -> 
        decodeString contentDecoder "{ \"invalid_field\": \"data\" }"
        |> Expect.equal
        (Ok ActivityType.Empty)
    ]