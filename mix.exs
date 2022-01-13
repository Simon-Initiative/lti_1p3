defmodule Lti_1p3.MixProject do
  use Mix.Project

  def project do
    [
      app: :lti_1p3,
      version: "0.4.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: elixirc_options(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      package: package(),
      description: description(),
      name: "Lti 1p3",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.0"},
      {:joken, "~> 2.2.0"},
      {:mox, "~> 0.5", only: :test},
      {:timex, "~> 3.5"},
      {:uuid, "~> 1.1"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp elixirc_options(:dev), do: []
  defp elixirc_options(:test), do: []
  defp elixirc_options(_), do: [warnings_as_errors: true]

  defp description do
    """
    A library for LTI 1.3 Platform and Tool integrations
    """
  end

  defp package do
    [
      links: %{
        "Open Learning Initiative" => "https://oli.cmu.edu/",
        "Github" => "https://github.com/Simon-Initiative/lti_1p3"
      },
      homepage_url: "https://oli.cmu.edu/",
      files: ["lib", "docs", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Open Learning Initiative"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Simon-Initiative/lti_1p3"}
    ]
  end

  defp docs() do
    [
      main: "readme",
      extras: [
        "README.md",
        "docs/lti_1p3_overview.md"
      ],
      groups_for_extras: [
        "LTI 1.3": Path.wildcard("docs/*.md")
      ]
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      # runs tests and produces a coverage report
      "test.coverage": ["coveralls.html"],

      # runs tests and produces a coverage report
      "test.coverage.xml": ["coveralls.xml"],

      # runs tests in deterministic order, only shows one failure at a time and reruns tests if any changes are made
      "test.watch": ["test.watch --stale --max-failures 1 --trace --seed 0"]
    ]
  end
end
