defmodule Siwe.MixProject do
  use Mix.Project

  # TODO: Add :links to docs!
  # TODO: Add :source_url to github!
  # TODO: Add :homepage_url to devportal!
  def project do
    [
      app: :siwe,
      description: description(),
      version: "0.5.0",
      organization: "Spruce Systems Inc",
      package: package(),
      elixir: "~> 1.10",
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
      {:rustler, "~> 0.27.0"},
      # NOTE: For M1 compat:
      # {:rustler, git: "https://github.com/rusterlium/rustler.git", sparse: "rustler_mix"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Elixir library to parse and validate Sign In with Ethereum Messages"
  end

  defp package() do
    [
      files: [
        "mix.exs",
        "native/siwe_ex/src",
        "native/siwe_ex/Cargo.toml",
        "lib",
        "LICENSE-APACHE",
        "LICENSE-MIT",
        "README.md"
      ],
      licenses: ["MIT", "Apache-2.0"],
      links: %{}
    ]
  end
end
