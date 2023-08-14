module StudentPageTests.GroupContentTests exposing(viewTests, updateTests)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, bool, int, string, map6, intRange, maybe, bool, triple)
import Test exposing (..)
import StudentPage.AssignmentContent.GroupContent as GC exposing(Msg(..))
import FuzzerHelper exposing (httpErrorFuzzer)
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, tag, text, containing)
import Test.Html.Event as Event
import Accessibility.Styled as Html exposing (Html)
import Student as Student
import Dict
import Group 
import Clock exposing (Time)
import Assignment exposing (Assignment)
import Activity exposing (Activity)
import ActivityType exposing (ActivityType)
import ActivityType exposing (TypeCode(..), Content(..))
import StudentPage exposing (getAssignments)
import StudentPage.AssignmentContent.GroupContent exposing (StudentAction(..))

updateTests = 
    describe "Group Content update"
    [fuzz2 FuzzerHelper.studentFuzzer FuzzerHelper.studentFuzzer "Add student to group" <|
    \student1 student2 -> 
        let
            model = GC.Model (Dict.fromList [ ( student1.id
                                              , student1 
                                             )]) False
        in
            {token = "token", apiBaseUrl = "api"}
            |> GC.update (AddStudent student2) model
            |> Tuple.first 
            |> .selectedStudents
            |> Dict.get student2.id 
            |> Expect.equal (Just student2),

    test "Remove student from group" <|
    \_ -> 
        let
            student = Student.Student 1 "someemail" "john" "doe" "12334" (Just 3) 
            model = GC.Model (Dict.fromList [ ( student.id
                                              , student 
                                             )]) False
        in
            {token = "token", apiBaseUrl = "api"}
            |> GC.update (RemoveStudent student.id) model
            |> Tuple.first 
            |> .selectedStudents
            |> Dict.get student.id 
            |> Expect.equal Nothing,

    fuzz FuzzerHelper.studentListFuzzer "Submit group msg" <|
    \students -> 
        let
            pairList = List.map (\x -> (x.id, x)) students
            model = GC.Model (Dict.fromList pairList) False
        in
            {token = "token", apiBaseUrl = "api"}
            |> GC.update (SubmitGroup 1) model
            |> Tuple.first 
            |> .processingRequest
            |> Expect.equal True,

    fuzz FuzzerHelper.studentListFuzzer "Group created Ok" <|
    \students -> 
        let
            dict = List.map setGroupId students
                       |> List.map (\x -> (x.id, x))
                       |> Dict.fromList
            model = GC.Model dict True
            group = Group.Group 1 (List.map setGroupId students) Nothing 
        in
            {token = "token", apiBaseUrl = "api"}
            |> GC.update (GroupCreated (Ok group)) model
            |> Tuple.first 
            |> .processingRequest
            |> Expect.equal False,

    fuzz2 httpErrorFuzzer FuzzerHelper.studentListFuzzer "Group created Error" <|
    \error students -> 
        let
            dict = List.map setGroupId students
                       |> List.map (\x -> (x.id, x))
                       |> Dict.fromList
            model = GC.Model dict True
            group = Group.Group 1 (List.map setGroupId students) Nothing 
        in
            {token = "token", apiBaseUrl = "api"}
            |> GC.update (GroupCreated (Err error)) model
            |> Tuple.first 
            |> .processingRequest
            |> Expect.equal False
    ]

viewTests = 
    describe "Group content view" 
    [fuzz2 FuzzerHelper.assignmentFuzzer FuzzerHelper.studentListFuzzer "when group is nothing" <|
    \assignment students-> 
        let 
            inputParams = {
                groupId = Nothing,
                group = Nothing,
                studentId = 1,
                students = students, 
                loadingStudents = False,
                loadingGroup = False,
                semesterId = 1,
                currentTimeSec = 122344
                }
            dict = List.map setGroupId students
                       |> List.map (\x -> (x.id, x))
                       |> Dict.fromList
            model = GC.Model dict False        
        in 
            model
            |> GC.view assignment inputParams 
            |> Html.toUnstyled
            |> Query.fromHtml
            |> Query.has [text "Jos uvek niste rasporedjeni u grupu"],

    fuzz2 FuzzerHelper.assignmentFuzzer FuzzerHelper.studentListFuzzer "when group is just group" <|
    \assignment students-> 
        let 
            inputParams = {
                groupId = Just 1,
                group = Just (Group.Group 1 (List.map setGroupId students) Nothing),
                studentId = 1,
                students = students, 
                loadingStudents = False,
                loadingGroup = False,
                semesterId = 1,
                currentTimeSec = 122344
                }
            dict = List.map setGroupId students
                       |> List.map (\x -> (x.id, x))
                       |> Dict.fromList
            model = GC.Model dict False  
            group = Group.Group 1 students Nothing   
        in
           model
           |> GC.view assignment inputParams
           |> Expect.equal (Group.view (Maybe.withDefault group inputParams.group))
{- ,
    test "When group is Nothing and assignment is active" <|
    \_ ->
        let  
            students = [Student.Student 1 "email" "john" "doe" "1234" (Just 1)]
            inputParams = {
                groupId = Just 1,
                group = Nothing,
                studentId = 1,
                students = students, 
                loadingStudents = False,
                loadingGroup = False,
                semesterId = 1,
                currentTimeSec = 1343445677 
                }
             
            dict = List.map setGroupId students
                       |> List.map (\x -> (x.id, x))
                       |> Dict.fromList
            model = GC.Model dict False  
        in 
        model
           |> GC.view testAssignment inputParams
           |> Expect.equal (GC.studentSelectionView inputParams.semesterId inputParams.studentId students model)
-}
    ]


setGroupId : Student.Student -> Student.Student 
setGroupId student = 
    Student.Student student.id student.email student.firstName student.lastName student.indexNumber (Just 1)


testAssignment : Assignment
testAssignment = 
    let 
        activity = Activity 1 2 1234567788 1323445677 True 20
        actType = ActivityType 1 "cv" Other "opis" False False Empty    
    in
        Assignment 1 Nothing False (Just "comment") activity actType