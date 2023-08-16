defmodule MsnrApi.StudentFactory do

  alias MsnrApi.Queries.StudentsTest
  alias MsnrApi.Students.Student
  alias MsnrApi.Accounts.User
  alias MsnrApi.Semesters

  defmacro __using__(_opts) do
    quote do
      def student_factory do
        %Student {
          index_number: List.to_string(Faker.Lorem.characters(9))
        }
      end

    end
  end
end
