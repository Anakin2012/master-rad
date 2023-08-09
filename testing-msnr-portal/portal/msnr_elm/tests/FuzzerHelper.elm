module FuzzerHelper exposing (..)
import Fuzz exposing (Fuzzer, intRange, string, float, map7, map3, map6, int, bool)
import Topic exposing (..)
import Student exposing (..)
import Group exposing (..)
import Activity exposing (..) 
import Json.Decode exposing (int)
import Json.Encode as Encode exposing (Value)
import ActivityType exposing (Content, FileUploadInfo, TypeCode, ActivityType)
import Assignment exposing (Assignment, ShallowAssignment)
import FileInfo exposing (FileInfo)
import Session exposing (Session, UserInfo, StudentInfo)
import Http exposing (Error(..))

httpErrorFuzzer : Fuzzer Error
httpErrorFuzzer = 
    Fuzz.oneOfValues
        [ 
          BadUrl "somestring",
          Timeout, 
          NetworkError,
          BadStatus 500,
          BadBody "somestring"
        ]

studentInfoFuzzer : Fuzzer StudentInfo
studentInfoFuzzer = 
    Fuzz.map2 StudentInfo
        (Fuzz.maybe (intRange 1 100))
        string

userInfoFuzzer : Fuzzer UserInfo
userInfoFuzzer = 
    Fuzz.map5 UserInfo
        (intRange 1 100)
        string
        string
        string
        string

sessionFuzzer : Fuzzer Session
sessionFuzzer = 
    Fuzz.map5 Session
        string
        float
        userInfoFuzzer
        (intRange 1 4)
        (Fuzz.maybe studentInfoFuzzer)

fileInfoFuzzer : Fuzzer FileInfo
fileInfoFuzzer = 
    Fuzz.map3 FileInfo
        (intRange 1 100)
        (bool)
        string

assignmentFuzzer : Fuzzer Assignment
assignmentFuzzer = 
    Fuzz.map6 Assignment
        (intRange 1 100)
        (Fuzz.maybe (intRange 5 10))
        bool 
        (Fuzz.maybe string)
        activityFuzzer
        activityTypeFuzzer 

shallowAssignmentFuzzer : Fuzzer ShallowAssignment
shallowAssignmentFuzzer = 
    Fuzz.map7 ShallowAssignment
        (intRange 1 100)
        (intRange 1 100)
        (Fuzz.maybe (intRange 1 100))
        (Fuzz.maybe (intRange 1 100))
        (Fuzz.maybe (intRange 5 10))
        (Fuzz.maybe string)
        bool

fileUploadInfoFuzzer : Fuzzer FileUploadInfo
fileUploadInfoFuzzer = 
    Fuzz.map2 FileUploadInfo
        string 
        string

typeCodeFuzzer : Fuzzer TypeCode
typeCodeFuzzer =
    Fuzz.oneOfValues
        [ ActivityType.Group, 
          ActivityType.Topic,
          ActivityType.Other
        ]

contentFuzzer : Fuzzer Content
contentFuzzer = 
    Fuzz.map ActivityType.Files (Fuzz.list fileUploadInfoFuzzer)

activityTypeFuzzer : Fuzzer ActivityType
activityTypeFuzzer =
    Fuzz.map7 ActivityType
        (intRange 1 100)
        string 
        typeCodeFuzzer
        string
        bool 
        bool 
        contentFuzzer

activityFuzzer : Fuzzer Activity
activityFuzzer = 
    Fuzz.map6 Activity
        (intRange 1 100)
        (intRange 1 6)
        (intRange 1 50)
        (intRange 50 100)
        bool 
        (intRange 0 100)

topicFuzzer : Fuzzer Topic 
topicFuzzer = 
  Fuzz.map3 Topic
    (intRange 1 100)
    Fuzz.string
    (intRange 1 100)

studentFuzzer : Fuzzer Student
studentFuzzer = 
    Fuzz.map6 Student
        (intRange 1 100)
        Fuzz.string
        Fuzz.string
        Fuzz.string 
        Fuzz.string
        (Fuzz.maybe (intRange 1 100))

studentListFuzzer = 
    Fuzz.list studentFuzzer

groupFuzzer : Fuzzer Group
groupFuzzer = 
    Fuzz.map3 Group
        (intRange 1 100)
        studentListFuzzer
        (Fuzz.maybe topicFuzzer)

success : Result a b -> Bool
success result =
    case result of
        Ok _ -> True
        Err _ -> False


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
            Encode.null

encodeActivityType : ActivityType -> Value 
encodeActivityType activityType =
    Encode.object
    [("id", Encode.int activityType.id),
     ("name", Encode.string activityType.name),
     ("code", encodeCode activityType.code),
     ("description", Encode.string activityType.description), 
     ("is_group", Encode.bool activityType.isGroup),
     ("has_signup", Encode.bool activityType.hasSignup),
     ("content", encodeContent activityType.content)]