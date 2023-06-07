defmodule MsnrApi.Support.Factory do
  use ExMachina.Ecto, repo: MsnrApi.Repo
  use MsnrApi.UserFactory
  use MsnrApi.ActivityFactory
  use MsnrApi.ActivityTypeFactory
  use MsnrApi.AssignmentFactory
  use MsnrApi.DocumentFactory

end
