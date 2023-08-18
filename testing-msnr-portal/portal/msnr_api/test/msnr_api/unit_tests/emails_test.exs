defmodule MsnrApi.UnitTests.EmailsTest do
  alias MsnrApi.Emails
  alias MsnrApi.Accounts.User
  alias MsnrApi.StudentRegistrations.StudentRegistration
  use ExUnit.Case

  describe "accept/1" do
    test "success: creates an email about accepted registration" do

      password_url = "http://localhost:8080/setPassword/"
      user = %User{
        email: "pana.petrovic@gmail.com",
        first_name: "ana",
        last_name: "petrovic",
        role: :student,
        password_url_path: Ecto.UUID.generate()
      }

      email = Emails.accept(user)

      to = List.first(email.to) |> elem(1)
      from = elem(email.from, 1)

      assert to == user.email
      assert from == "msnr-admin@test.com"
      assert email.subject == "[MSNR] Prihvaćen zahtev za registraciju"
      assert String.contains?(email.html_body, "Zdravo #{user.first_name}")
      assert String.contains?(email.html_body, "Vaš zahtev za kreiranje naloga je prihvaćen.")
      assert String.contains?(email.html_body, "<a href=\"#{password_url <> user.password_url_path}\"")
    end

    test "error: returns an ArgumentError when given invalid arguments" do
      user = %User{}
      assert_raise ArgumentError, fn ->
        Emails.accept(user) end
    end
  end

  describe "reject/1" do
    test "success: creates an email about rejected registration" do

      registration = %StudentRegistration{
        email: "pana.petrovic@gmail.com",
        first_name: "ana",
        last_name: "petrovic"
      }

      email = Emails.reject(registration)

      to = List.first(email.to) |> elem(1)
      from = elem(email.from, 1)

      assert to == registration.email
      assert from == "msnr-admin@test.com"
      assert email.subject == "[MSNR] Odbijen zahtev za registraciju"
      assert String.contains?(email.html_body, "Zdravo #{registration.first_name}")
      assert String.contains?(email.html_body, "Vas zahtev za kreiranje naloga je odbijen.")
      assert String.contains?(email.html_body, "Kontaktirajte profesora ukoliko imate dodatnih pitanja.")
    end
  end
end
