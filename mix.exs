defmodule Siwe.MixProject do
  use Mix.Project

  # TODO: Add :links to docs!
  # TODO: Add :source_url to github!
  # TODO: Add :homepage_url to devportal!
  def project do
    [
      app: :siwe,
      description: description(),
      version: "0.2.3",
      organization: "Spruce Systems Inc",
      package: package(),
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:rustler, "~> 0.22.2"},
      # NOTE: For M1 compat:
      # {:rustler, git: "https://github.com/rusterlium/rustler.git", sparse: "rustler_mix"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description() do
    "Elixir library to parse and validate Sign In with Ethereum Messages"
  end

  defp package() do
    [
      licenses: ["MIT", "Apache-2.0"],
      links: %{}
    ]
  end
end
