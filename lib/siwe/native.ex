defmodule Siwe.Native do
  @moduledoc false

  version = Mix.Project.config()[:version]
  env_config = Application.compile_env(:rustler_precompiled, :force_build, [])

  use RustlerPrecompiled,
    otp_app: :siwe,
    crate: "siwe_native",
    base_url: "https://github.com/spruceid/siwe-ex/releases/download/v#{version}",
    force_build: System.get_env("RUSTLER_BUILD") in ["1", "true"] or env_config[:siwe],
    nif_versions: ["2.15"],
    targets: [
      "aarch64-apple-darwin",
      "aarch64-unknown-linux-gnu",
      "aarch64-unknown-linux-musl",
      "arm-unknown-linux-gnueabihf",
      "x86_64-apple-darwin",
      "x86_64-pc-windows-gnu",
      "x86_64-pc-windows-msvc",
      "x86_64-unknown-linux-gnu",
      "x86_64-unknown-linux-musl"
    ],
    version: version

  def parse(_msg), do: nif_error()
  def to_str(_msg), do: nif_error()
  def verify_sig(_msg, _sig), do: nif_error()
  def verify(_msg, _sig, _domain_binding, _match_nonce, _timestamp), do: nif_error()
  def parse_if_valid(_msg, _sig), do: nif_error()
  def generate_nonce, do: nif_error()

  defp nif_error, do: :erlang.nif_error(:nif_not_loaded)
end
