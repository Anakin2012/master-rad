ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(MsnrApi.Repo, :manual)

Mox.defmock(MsnrApi.SemestersMock, for: MsnrApiWeb.SemestersController)
