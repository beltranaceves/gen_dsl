defmodule GenDSL.MixProject do
  use Mix.Project

  def project do
    [
      app: :gen_dsl,
      description: "Model, parser and serializer for gen_dsl",
      version: "0.3.7",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/beltranaceves/gen_dsl",
      homepage_url: "HEX_URL",
      package: [
        maintainers: ["Beltrán Aceves Gil"],
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/beltranaceves/gen_dsl"
        }
      ]
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:stream_data, "~> 0.6.0", only: :test},
      {:jason, "~> 1.4"},
      {:ecto, "~> 3.11.1"},
      {:phx_new, "~> 1.7.10"}
    ]
  end
end
