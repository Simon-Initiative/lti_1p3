Logger.configure(level: :warn)

ExUnit.start(exclude: [:skip])

# Ensure that symlink to custom ecto priv directory exists
source = Lti_1p3.Test.Repo.config()[:priv]
target = Application.app_dir(:lti_1p3, source)
File.rm_rf(target)
File.mkdir_p(target)
File.rmdir(target)
:ok = :file.make_symlink(Path.expand(source), target)


Mix.Task.run("ecto.drop", ~w(--quiet -r Lti_1p3.Test.Repo))
Mix.Task.run("ecto.create", ~w(--quiet -r Lti_1p3.Test.Repo))
Mix.Task.run("ecto.migrate", ~w(--quiet -r Lti_1p3.Test.Repo))

{:ok, _pid} = Lti_1p3.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Lti_1p3.Test.Repo, :manual)
