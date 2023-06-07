defmodule MsnrApi.AssignmentFactory do

  alias MsnrApi.Queries.AssignmentsTest
  alias MsnrApi.Assignments.Assignment

  defmacro __using__(_opts) do
    quote do
      def assignment_factory do
        %Assignment {
          comment: Faker.Lorem.sentence(),
          grade: Faker.random_between(5, 10)
        }
      end
    end
  end

end
