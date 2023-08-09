module UtilTests exposing (toTwoDigitMonthTests, intToMonthTests)
import Expect exposing (..)
import Fuzz exposing (intRange)
import Util exposing (..)
import Test exposing (..)
import Time exposing (Month(..))

toTwoDigitMonthTests = 
    describe "ToDigitMonth" 
        [test "output is 01 when input is Jan" <|
        \_ -> toTwoDigitMonth Jan
              |> Expect.equal "01", 
         test "output is 02 when the input is Feb" <|
         \_  -> toTwoDigitMonth Feb
                |> Expect.equal "02",
        test "output is 03 when the input is Mar" <|
         \_  -> toTwoDigitMonth Mar
                |> Expect.equal "03",
        test "output is 04 when the input is Apr" <|
         \_  -> toTwoDigitMonth Apr
                |> Expect.equal "04",
        test "output is 05 when the input is May" <|
         \_  -> toTwoDigitMonth May
                |> Expect.equal "05",
        test "output is 06 when the input is Jun" <|
         \_  -> toTwoDigitMonth Jun
                |> Expect.equal "06",
        test "output is 07 when the input is Jul" <|
         \_  -> toTwoDigitMonth Jul
                |> Expect.equal "07",
        test "output is 08 when the input is Aug" <|
         \_  -> toTwoDigitMonth Aug
                |> Expect.equal "08",
        test "output is 09 when the input is Sep" <|
         \_  -> toTwoDigitMonth Sep
                |> Expect.equal "09",
        test "output is 10 when the input is Oct" <|
         \_  -> toTwoDigitMonth Oct
                |> Expect.equal "10",
        test "output is 11 when the input is Nov" <|
         \_  -> toTwoDigitMonth Nov
                |> Expect.equal "11",
        test "output is 12 when the input is Dec" <|
         \_  -> toTwoDigitMonth Dec
                |> Expect.equal "12"
        ]

intToMonthTests =
        describe "intToMonth"
        [test "output is Jan when input is 1" <|
        \_ -> intToMonth 1
              |> Expect.equal (Just Jan),
        test "output is Feb when input is 2" <|
        \_ -> intToMonth 2
              |> Expect.equal (Just Feb),
        test "output is Mar when input is 3" <|
        \_ -> intToMonth 3
              |> Expect.equal (Just Mar),
        test "output is Apr when input is 4" <|
        \_ -> intToMonth 4
              |> Expect.equal (Just Apr),
        test "output is May when input is 5" <|
        \_ -> intToMonth 5
              |> Expect.equal (Just May),
        test "output is Jun when input is 6" <|
        \_ -> intToMonth 6
              |> Expect.equal (Just Jun),
        test "output is Jul when inuput is 7" <|
        \_ -> intToMonth 7
              |> Expect.equal (Just Jul),
        test "output is Aug when input is 8" <|
        \_ -> intToMonth 8
              |> Expect.equal (Just Aug),
        test "output is Sep when input is 9" <|
        \_ -> intToMonth 9
              |> Expect.equal (Just Sep),
        test "output is Oct when input is 10" <|
        \_ -> intToMonth 10
              |> Expect.equal (Just Oct),
        test "output is Nov when input is 11" <|
        \_ -> intToMonth 11
              |> Expect.equal (Just Nov),
        test "output is Dec when input is 12" <|
        \_ -> intToMonth 12
              |> Expect.equal (Just Dec),
        fuzz (intRange -50 0) "output is Nothing if input < 1" <|
        \month -> intToMonth month
              |> Expect.equal Nothing, 
        fuzz (intRange 13 50) "output is Nothing if input > 12" <|
        \month -> intToMonth month
              |> Expect.equal Nothing
        ]