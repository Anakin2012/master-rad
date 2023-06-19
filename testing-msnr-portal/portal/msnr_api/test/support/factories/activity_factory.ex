defmodule MsnrApi.ActivityFactory do

  alias MsnrApi.Queries.ActivitiesTest
  alias MsnrApi.Activities.Activity

  defmacro __using__(_opts) do
    quote do
      def activity_factory do
        %Activity {
          end_date: Faker.random_between(1000000000, 2147483647),
          start_date: Faker.random_between(1000000000, 2147483647),
          points: Faker.random_between(1, 100)
        }
      end
    end
  end
end
