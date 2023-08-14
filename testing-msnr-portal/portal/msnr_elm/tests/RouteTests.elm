module RouteTests exposing (toStringTests, subrouteStringTests)
import Route
import Expect exposing (Expectation, err)
import Fuzz exposing (Fuzzer, string, bool, int)
import FuzzerHelper exposing (professorSubrouteFuzzer)
import Test exposing (..)
import Url.Parser exposing (query)
import Url.Parser exposing (fragment)


{-
professorParser : Parser (ProfessorSubRoute -> a) a
professorParser =
    Parser.oneOf
        [ Parser.map RegistrationRequests (s "registrations")
        , Parser.map Activities (s "activities")
        , Parser.map ActivityAssignments (s "activities" </> Parser.int </> s "assignments")
        , Parser.map Topics (s "topics")
        , Parser.map Groups (s "groups")
        ]

-}




toStringTests = 
    describe "Route to String"
    [test "Route is home" <|
    \_ -> 
        Route.toString Route.Home
        |> Expect.equal "/",

    test "Route is student" <|
    \_ -> 
        Route.toString Route.Student
        |> Expect.equal "/student",

    test "Route is login" <|
    \_ -> 
        Route.toString Route.Login
        |> Expect.equal "/login",

    test "Route is registration" <|
    \_ -> 
        Route.toString Route.Registration
        |> Expect.equal "/register",

    fuzz professorSubrouteFuzzer "Route is Professor" <|
    \subroute -> 
        Route.toString (Route.Professor subroute)
        |> Expect.equal ("/professor" ++ (Route.professorSubRouteToString subroute)),

    fuzz string "Route is SetPassword" <|
    \uuid -> 
        Route.toString (Route.SetPassword uuid)
        |> Expect.equal ("/setPassword/" ++ uuid), 

    test "Route is Not Found" <|
    \_ -> 
        Route.toString Route.NotFound
        |> Expect.equal "/notFound"
    ]

subrouteStringTests = 
    describe "professorSubRoute to String" 
    [test "subroute is RegistrationRequests" <|
    \_ -> 
        Route.professorSubRouteToString Route.RegistrationRequests
        |> Expect.equal "/registrations",

    test "subroute is Activities" <|
    \_ -> 
        Route.professorSubRouteToString Route.Activities
        |> Expect.equal "/activities",

    fuzz (Fuzz.intRange 1 5) "subroute is ActivityAssignments" <|
    \id -> 
        Route.professorSubRouteToString (Route.ActivityAssignments id)
        |> Expect.equal ("/activities/" ++ String.fromInt id ++ "/assignments"),

    test "subroute is Topics" <|
    \_ -> 
        Route.professorSubRouteToString Route.Topics
        |> Expect.equal "/topics",

    test "subroute is Groups" <|
    \_ -> 
        Route.professorSubRouteToString Route.Groups
        |> Expect.equal "/groups"

    ]

