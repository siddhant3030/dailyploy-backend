defmodule Dailyploy.MixProject do
  use Mix.Project

  def project do
    [
      app: :dailyploy,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      # Coveralls
      app: :excoveralls,
      version: "1.0.0",
      elixir: "~> 1.0.0",
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Dailyploy.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :calendar,
        :timex,
        :arc_ecto,
        :httpotion,
        :quantum,
        :scrivener_ecto,
        :scout_apm
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # pagination
      {:phoenix, "~> 1.6"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.1"},
      {:phoenix_html, "~> 3.0", override: true},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:comeonin, "~> 5.1.2"},
      {:bcrypt_elixir, "~> 2.0"},
      {:cors_plug, "~> 2.0"},
      {:guardian, "~> 1.0"},
      {:ecto_enum, "~> 1.3"},
      {:sendgrid, "~> 2.0"},
      {:calendar, "~> 0.17.5"},
      {:quantum, "~> 2.3"},
      {:timex, "~> 3.5"},
      {:params, "~> 2.0"},
      {:nimble_csv, "~> 0.6"},
      {:csv, "~> 2.3"},
      {:scout_apm, "~> 1.0"},

      # csv upload
      {:arc, "~> 0.11.0"},
      {:arc_ecto, "~> 0.11.0"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:poison, "~> 3.1"},
      {:tesla, "~> 1.3.0"},
      {:google_api_firestore, "~> 0.14"},
      {:httpotion, "~> 3.1.0"},

      # Testing Library
      {:ex_machina, "~> 2.7.0", only: :test},
      {:excoveralls, "~> 0.10", only: :test},

      # Pagination
      {:scrivener_ecto, "~> 2.3"},
      {:scrivener_list, "~> 2.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
