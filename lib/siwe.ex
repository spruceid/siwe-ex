defmodule Siwe do
  @moduledoc """
  Siwe provides validation and parsing for Sign-In with Ethereum messages and signatures.
  """

  use Rustler, otp_app: :siwe, crate: "siwe_ex"

  # The result of the Siwe.verify!, a formatted form
  # of what siwe-rs uses
  defmodule Message do
    defstruct domain: "",
              address: "",
              statement: "",
              uri: "",
              version: "",
              chain_id: "",
              nonce: "",
              issued_at: "",
              expiration_time: nil,
              # or a string datetime
              not_before: nil,
              # or a string datetime
              request_id: nil,
              # or string
              resources: []
  end

  # Overwritten by the Rustler NIF, uses siwe-rs to do the heavy lifting.
  @doc false
  @spec from_str(String.t()) :: Message.t()
  defp from_str(_msg) do
    :erlang.nif_error(:nif_not_loaded)
  end

  @spec to_str(Message.t()) :: String.t()
  defp to_str(_msg) do
    :erlang.nif_error(:nif_not_loaded)
  end

  # Overwritten by the Rustler NIF, uses siwe-rs to do the heavy lifting.
  @doc false
  @spec validate_sig(Message.t(), String.t()) :: boolean()
  def validate_sig(_msg, _sig) do
    :erlang.nif_error(:nif_not_loaded)
  end

  # Overwritten by the Rustler NIF, uses siwe-rs to do the heavy lifting.
  @doc false
  @spec validate_time(Message.t()) :: boolean()
  def validate_time(_msg) do
    :erlang.nif_error(:nif_not_loaded)
  end

  # Overwritten by the Rustler NIF, uses siwe-rs to do the heavy lifting.
  # Optimized form of validate_sig(m) && validate_time(m)
  @doc false
  @spec validate(Message.t(), String.t()) :: boolean()
  def validate(_msg, _sig) do
    :erlang.nif_error(:nif_not_loaded)
  end

  # Overwritten by the Rustler NIF, uses siwe-rs to do the heavy lifting.
  # Optimized form of validate_sig(from_str(s))
  @doc false
  @spec parse_if_valid_sig(String.t(), String.t()) :: Message.t()
  defp parse_if_valid_sig(_msg, _sig) do
    :erlang.nif_error(:nif_not_loaded)
  end

  # Overwritten by the Rustler NIF, uses siwe-rs to do the heavy lifting.
  # Optimized form of validate_time(from_str(s))
  @doc false
  @spec parse_if_valid_time(String.t()) :: Message.t()
  defp parse_if_valid_time(_msg) do
    :erlang.nif_error(:nif_not_loaded)
  end

  # Overwritten by the Rustler NIF, uses siwe-rs to do the heavy lifting.
  # Optimized form of validate(from_str(s)) && from_str(s)
  @doc false
  @spec parse_if_valid(String.t(), String.t()) :: Message.t()
  defp parse_if_valid(_msg, _sig) do
    :erlang.nif_error(:nif_not_loaded)
  end

  @doc """
    Parses a SIWE message string into Siwe.Message struct if conforming to standards.
    Will parse messages without checking for validity.
  """
  @spec from_str!(String.t()) :: Message
  def from_str!(msg) do
    from_str(msg)
  end

  @doc """
    Formats parsed SIWE message into string matching signing material
  """
  @spec to_str!(String.t()) :: Message.t()
  def to_str!(msg) do
    to_str(msg)
  end

  @doc """
    Parses a SIWE message string into a Siwe Message Struct if the given signature matches
    the message string.
  """
  @spec parse_if_valid_sig!(String.t(), String.t()) :: Message.t()
  def parse_if_valid_sig!(msg, sig) do
    parse_if_valid_sig(msg, sig)
  end

  @doc """
    Parses a SIWE message string into a Siwe Message Struct if the current time is valid in
    terms of the message string.
  """
  @spec parse_if_valid_time!(String.t()) :: Message.t()
  def parse_if_valid_time!(msg) do
    parse_if_valid_time(msg)
  end

  @doc """
   Tests that a message and signature pair correspond and that the current
   time is valid (after not_before, and before expiration_time)
   any validation of other fields to server's expectation are left
   to the calling application. Just a wrapper around the Rustler NIF

   Returns a Message structure based on the passed message

   ## Examples
    iex> Siwe.parse_if_valid!(Enum.join(["login.xyz wants you to sign in with your Ethereum account:",
    ...> "0xfA151B5453CE69ABf60f0dbdE71F6C9C5868800E",
    ...> "",
    ...> "Sign-In With Ethereum Example Statement",
    ...> "",
    ...> "URI: https://login.xyz",
    ...> "Version: 1",
    ...> "Chain ID: 1",
    ...> "Nonce: ToTaLLyRanDOM",
    ...> "Issued At: 2021-12-17T00:38:39.834Z",
    ...> ], "\\n"),
    ...> "0x8d1327a1abbdf172875e5be41706c50fc3bede8af363b67aefbb543d6d082fb76a22057d7cb6d668ceba883f7d70ab7f1dc015b76b51d226af9d610fa20360ad1c")
    %{ __struct__: Siwe, address: "0xfA151B5453CE69ABf60f0dbdE71F6C9C5868800E", chain_id: "1", domain: "login.xyz", expiration_time: nil, issued_at: "2021-12-17T00:38:39.834Z", nonce: "ToTaLLyRanDOM", not_before: nil, request_id: nil, resources: [], statement: "Sign-In With Ethereum Example Statement", uri: "https://login.xyz", version: "1" }
  """
  @spec parse_if_valid!(String.t(), String.t()) :: Message.t()
  def parse_if_valid!(message, signature) do
    parse_if_valid(message, signature)
  end

  @doc """
  Generates an alphanumeric nonce for use in SIWE messages.
  """
  @spec generate_nonce() :: String.t()
  def generate_nonce() do
    :erlang.nif_error(:nif_not_loaded)
  end
end
