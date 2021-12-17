defmodule Siwe.MixProject do
  use Mix.Project

  # TODO: Add :links to docs!
  # TODO: Add :source_url to github!
  # TODO: Add :homepage_url to devportal!
  def project do
    [
      app: :siwe,
      description: description(),
      version: "0.1.0",
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
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # NOTE: For M1 compat:
      # {:rustler, git: "https://github.com/rusterlium/rustler.git", sparse: "rustler_mix"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description() do
    "The elixir implementation of the Sign in With Ethereum providing a verify! method which takes a message and signature, validates it, then returns a parsed format."
  end

  defp package() do
    [
      licenses: ["MIT", "Apache-2.0"],
      links: %{}
    ]
  end
end
