module SessionTests exposing (decodeSessionTests, decodeStudentInfoTests, decodeUserTests)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import Test exposing (..)
import Json.Encode as Encode exposing (string, int, null, Value)
import Json.Decode as Decode exposing (decodeValue, decodeString)
import FuzzerHelper exposing (sessionFuzzer, userInfoFuzzer, studentInfoFuzzer, success)
import Session exposing (..)  

decodeSessionTests = 
    describe "Session decoder"
    [fuzz sessionFuzzer "fuzz test for valid decoding session" <| 
     \session -> 
        [("access_token", Encode.string session.accessToken),
         ("expires_in", Encode.float session.expiresIn),
         ("user", encodeUserInfo session.userInfo),
         ("semester_id", Encode.int session.semesterId), 
         ("student_info", session.studentInfo |> Maybe.map encodeStudentInfo
                                              |> Maybe.withDefault Encode.null)]
         |> Encode.object
         |> Decode.decodeValue Session.decodeSession
         |> success
         |> Expect.equal True,

     fuzz sessionFuzzer "decoding session with no student info, field should be Nothing" <| 
     \session -> 
        [("access_token", Encode.string session.accessToken),
         ("expires_in", Encode.float session.expiresIn),
         ("user", encodeUserInfo session.userInfo),
         ("semester_id", Encode.int session.semesterId), 
         ("student_info", Encode.null)]
         |> Encode.object
         |> Decode.decodeValue Session.decodeSession
         |> Result.map (\s -> s.studentInfo)
         |> Expect.equal (Ok Nothing)
    ]

decodeUserTests = 
    describe "UserInfo decoder"
    [fuzz userInfoFuzzer "fuzz tests for user info" <| 
    \user -> 
        encodeUserInfo user 
        |> Decode.decodeValue Session.decodeUser
        |> success
        |> Expect.equal True
    ]

decodeStudentInfoTests = 
    describe "StudentInfo decoder" 
    [fuzz studentInfoFuzzer "fuzz tests for student info" <| 
    \student -> 
        encodeStudentInfo student 
        |> Decode.decodeValue Session.decodeStudentInfo
        |> success
        |> Expect.equal True
    ]

encodeUserInfo : UserInfo -> Value
encodeUserInfo user = 
    [("id", Encode.int user.id),
     ("email", Encode.string user.email),
     ("first_name", Encode.string user.firstName),
     ("last_name", Encode.string user.lastName),
     ("role", Encode.string user.role)]
     |> Encode.object

encodeStudentInfo : StudentInfo -> Value
encodeStudentInfo student = 
    [("group_id", student.groupId |> Maybe.map Encode.int
                                  |> Maybe.withDefault Encode.null),
     ("index_number", Encode.string student.indexNumber)]
    |> Encode.object



