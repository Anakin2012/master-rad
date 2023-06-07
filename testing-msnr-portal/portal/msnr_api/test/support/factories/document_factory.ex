defmodule MsnrApi.DocumentFactory do

  alias MsnrApi.Queries.DocumentsTest
  alias MsnrApi.Documents.Document

  defmacro __using__(_opts) do
    quote do
      def document_factory do
        %Document {
          file_name: Faker.File.file_name(),
          file_path: Faker.File.file_name(),
          creator_id: Faker.random_between(1, 1000)
        }
      end
    end
  end

end
