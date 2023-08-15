defmodule MsnrApi.ActivityTypeFactory do

  alias MsnrApi.Queries.ActivityTypesTest
  alias MsnrApi.ActivityTypes.ActivityType

  defmacro __using__(_opts) do
    quote do
      def activity_type_factory do
        %ActivityType {
          content: %{"files" => [%{"name" => "CV", "extension" => ".pdf"}]},
          description: Faker.Lorem.paragraph(1),
          name: Enum.random(["Grupe", "Tema rada", "CV", "Prva verzija rada", "Recenzija", "Finalna verzija rada"]),
          code: Enum.random(["group", "topic", "cv", "v1", "vFinal"])
        }
      end
    end
  end

end
