defmodule MsnrApi.TopicFactory do

  alias MsnrApi.Queries.TopicsTest
  alias MsnrApi.Topics.Topic
  alias MsnrApi.Semesters

  defmacro __using__(_opts) do
    quote do
      def topic_factory do
        %Topic {
          semester_id: Semesters.get_active_semester!().id,
          title: Faker.Lorem.word()
        }
      end
    end
  end
end
