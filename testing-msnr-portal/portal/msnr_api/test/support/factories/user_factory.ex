defmodule MsnrApi.UserFactory do

  alias MsnrApi.Queries.AccountsTest
  alias MsnrApi.Accounts.User

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %User {
          email: Faker.Internet.email(),
          first_name: Faker.Person.first_name(),
          last_name: Faker.Person.last_name(),
          role: :student
        }
      end
    end
  end
end
