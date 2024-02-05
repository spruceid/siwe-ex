defmodule Siwe.MixProject do
  use Mix.Project

  @description "Elixir library to parse and validate Sign In with Ethereum Messages"
  @organization "Spruce Systems, Inc."
  @source_url "https://github.com/spruceid/siwe-ex"
  @version "0.6.0"

  def application, do: [extra_applications: [:logger]]

  def project do
    [
      app: :siwe,
      deps: [
        {:rustler, "~> 0.30", optional: true},
        {:rustler_precompiled, "~> 0.7"},
        {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      ],
      description: @description,
      docs: [
        main: "readme",
        extras: ["README.md"],
        source_url_pattern: "#{@source_url}/blob/v#{@version}/%{path}#L%{line}"
      ],
      elixir: "~> 1.10",
      organization: @organization,
      package: [
        exclude_patterns: [
          ~r/\W\.DS_Store$/,
          ~r/target/
        ],
        files: [
          "LICENSE-APACHE",
          "LICENSE-MIT",
          "README.md",
          "lib",
          "native/siwe_native/.cargo",
          "native/siwe_native/src",
          "native/siwe_native/Cargo*",
          "checksum-*.exs",
          "mix.exs"
        ],
        licenses: ["MIT", "Apache-2.0"],
        links: %{"GitHub" => @source_url},
        maintainers: [@organization]
      ],
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end
end
