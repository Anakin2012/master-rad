defmodule MsnrApi.GroupFactory do

  alias MsnrApi.Queries.GroupsTest
  alias MsnrApi.Groups.Group

  defmacro __using__(_opts) do
    quote do
      def group_factory do
        %Group {

        }
      end
    end
  end

end
