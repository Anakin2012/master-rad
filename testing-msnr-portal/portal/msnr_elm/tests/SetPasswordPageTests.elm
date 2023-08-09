module SetPasswordPageTests exposing (updateTests, formViewTests)

import Expect exposing (Expectation, err)
import Fuzz exposing (Fuzzer, string, bool)
import Test exposing (..)
import FuzzerHelper exposing (httpErrorFuzzer)
import SetPasswordPage exposing (Msg(..), Model)
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, tag, text, containing)
import Test.Html.Event as Event
import Accessibility.Styled as Html exposing (Html)
import Route exposing (Route(..))
import Html.Attributes as Attributes
import Session exposing (Msg(..))

setPasswordModelFuzzer : Fuzzer Model 
setPasswordModelFuzzer =
    Fuzz.map8 Model
        string
        string 
        string 
        string 
        string 
        bool 
        bool 
        bool

updateTests =
    describe "SetPasswordPage update"
    [fuzz2 string setPasswordModelFuzzer "Email msg sets the email" <|
    \email model -> 
        model
        |> SetPasswordPage.update (Email email)
        |> Tuple.first 
        |> .email 
        |> Expect.equal email,

    fuzz2 string setPasswordModelFuzzer "Password msg sets the password" <|
    \password model -> 
        model
        |> SetPasswordPage.update (Password password)
        |> Tuple.first 
        |> .password
        |> Expect.equal password,

    fuzz2 string setPasswordModelFuzzer "ConfirmPassword msg sets the password" <|
    \password model -> 
        model
        |> SetPasswordPage.update (ConfirmPassword password)
        |> Tuple.first 
        |> .confirmPassword
        |> Expect.equal password,

    fuzz setPasswordModelFuzzer "SubmittedForm msg sets error" <|
    \model -> 
        model
        |> SetPasswordPage.update SubmittedForm 
        |> Tuple.first
        |> .processing 
        |> Expect.equal True,

    fuzz2 httpErrorFuzzer setPasswordModelFuzzer "GotSetPasswordResult Error msg returns model" <|
    \error model -> 
        model 
        |> SetPasswordPage.update (GotSetPasswordResult (Result.Err error))
        |> Tuple.first 
        |> Expect.equal model,

    fuzz setPasswordModelFuzzer "GotSetPasswordResult Ok msg returns model" <|
    \model -> 
        model 
        |> SetPasswordPage.update (GotSetPasswordResult (Result.Ok ()))
        |> Tuple.first 
        |> Expect.equal model,

    fuzz2 bool setPasswordModelFuzzer "SetShowPassword1 msg sets showPassword1" <|
    \show model -> 
        model 
        |> SetPasswordPage.update (SetShowPassword1 show)
        |> Tuple.first 
        |> .showPassword1
        |> Expect.equal show,

    fuzz2 bool setPasswordModelFuzzer "SetShowPassword2 msg sets showPassword2" <|
    \show model -> 
        model 
        |> SetPasswordPage.update (SetShowPassword2 show)
        |> Tuple.first 
        |> .showPassword2
        |> Expect.equal show    
    ]

formViewTests = 
    describe "form view" 
    [fuzz setPasswordModelFuzzer "Correctly renders text in DOM" <|
     \model ->
        model
        |> SetPasswordPage.formView  
        |> Html.toUnstyled
        |> Query.fromHtml
        |> Query.has [ text "Podešavanje lozinke" ],
    
    test "Password fields are of the right type when empty" <|
    \_ ->
        let model = Model "apiurl" "123" "email.com" "" "" False False False
        in model
           |> SetPasswordPage.formView  
           |> Html.toUnstyled
           |> Query.fromHtml
           |> Query.findAll [ attribute <| Attributes.type_ "password" ]
           |> Query.count (Expect.equal 2),

    test "Password field is type text when not empty" <|
    \_ -> 
        let model = Model "" "" "" "newpass" "newpass" True True True
        in model 
           |> SetPasswordPage.formView  
           |> Html.toUnstyled
           |> Query.fromHtml
           |> Query.find [ attribute <| Attributes.placeholder "Lozinka"]
           |> Query.has [ attribute <| Attributes.type_ "text"],

    test "Password confirm field is type text when not empty" <|
    \_ -> 
        let model = Model "" "" "" "newpass" "newpass" True True True
        in model 
           |> SetPasswordPage.formView  
           |> Html.toUnstyled
           |> Query.fromHtml
           |> Query.find [ attribute <| Attributes.placeholder "Potvrda lozinke"]
           |> Query.has [ attribute <| Attributes.type_ "text"],

    test "When showPassword1 is true, click button to hide it" <| 
    \_ -> 
        let model = Model "" "" "" "newPass" "" True True True
        in model 
           |> SetPasswordPage.formView  
           |> Html.toUnstyled
           |> Query.fromHtml
           |> Query.find [ tag "button"
                         , containing [ text "Hide password" ]
                         ]
           |> Event.simulate Event.click
           |> Event.expect (SetShowPassword1 False),

    test "When showPassword2 is true, click button to hide it" <| 
    \_ -> 
        let model = Model "" "" "" "" "confirm" True True True
        in model 
           |> SetPasswordPage.formView  
           |> Html.toUnstyled
           |> Query.fromHtml
           |> Query.find [ tag "button"
                         , containing [ text "Hide password" ]
                         ]
           |> Event.simulate Event.click
           |> Event.expect (SetShowPassword2 False),
           
    test "Button confirm is disabled when fields are empty" <| 
    \_ -> 
        let model = Model "" "" "" "" "confirm" True True True
        in model 
           |> SetPasswordPage.formView  
           |> Html.toUnstyled
           |> Query.fromHtml
           |> Query.find [ tag "button"
                         , containing [ text "Potvrdi" ]
                         ]
           |> Query.has [ attribute <| Attributes.disabled True],

    test "Button confirm is disabled when password and confirm password dont match" <| 
    \_ -> 
        let model = Model "" "" "" "confirm1" "confirm" True True True
        in model 
           |> SetPasswordPage.formView  
           |> Html.toUnstyled
           |> Query.fromHtml
           |> Query.find [ tag "button"
                         , containing [ text "Potvrdi" ]
                         ]
           |> Query.has [ attribute <| Attributes.disabled True],

    fuzz setPasswordModelFuzzer "enabled/disabled button" <|
    \model -> 
        let disabled = buttonDisabled model
            foundButton = (model 
                           |> SetPasswordPage.formView  
                           |> Html.toUnstyled
                           |> Query.fromHtml
                           |> Query.find [ tag "button"
                                         , containing [ text "Potvrdi" ]
                                         ])
        in 
            if disabled then 
                foundButton 
                |> Query.has [ attribute <| Attributes.disabled True]

            else  
                foundButton           
                |> Query.has [ attribute <| Attributes.disabled False],
                
    fuzz setPasswordModelFuzzer "Click on button event" <| 
    \model -> 
        let disabled = buttonDisabled model 
        in
            if disabled then Expect.pass  
            else  
                model
                |> SetPasswordPage.formView  
                |> Html.toUnstyled
                |> Query.fromHtml
                |> Query.find [ tag "button"
                              , containing [ text "Potvrdi" ]
                              ]
                |> Event.simulate Event.click 
                |> Event.expect SubmittedForm
    ]

buttonDisabled : Model -> Bool 
buttonDisabled model = 
    String.isEmpty model.email 
        || String.isEmpty model.password
        || String.isEmpty model.confirmPassword
        || model.password /= model.confirmPassword 
