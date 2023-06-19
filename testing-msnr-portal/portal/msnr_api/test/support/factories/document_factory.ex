defmodule MsnrApi.DocumentFactory do

  alias MsnrApi.Queries.DocumentsTest
  alias MsnrApi.Documents.Document
  alias MsnrApi.Assignments.AssignmentDocument

  defmacro __using__(_opts) do
    quote do
      def document_factory do
        %Document {
          file_name: Faker.File.file_name(),
          file_path: Faker.File.file_name(),
         # creator_id: Faker.random_between(1, 1000)
        }
      end

      def assignment_document_factory do
        %AssignmentDocument {
          attached: Enum.random([true, false])
        }
      end
    end
  end

end
