defmodule MsnrApi.SemesterFactory do

  alias MsnrApi.Queries.SemestersTest
  alias MsnrApi.Semesters.Semester

  defmacro __using__(_opts) do
    quote do
      def semester_factory do
        %Semester {
          year: Faker.random_between(2015, 2023)
        }
      end
    end
  end
end
