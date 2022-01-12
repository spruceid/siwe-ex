defmodule Siwe do
  @moduledoc """
  Siwe provides validation and parsing for Sign-In with Ethereum messages and signatures.
  """

  use Rustler, otp_app: :siwe, crate: "siwe_ex"

  # The result of the Siwe.parse and parse_if_valid, a formatted form
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

  @doc """
    Parses a Sign In With Ethereum message string into the Message struct, or reports an error
  """
  @spec parse(String.t()) :: {:ok | :error, Message.t() | String.t()}
  def parse(_msg) do
    {:error, "NIF not loaded"}
  end

  @doc """
    Converts a Message struct to a Sign In With Ethereum message string, or reports an error
  """
  @spec to_str(Message.t()) :: {:ok | :error, String.t()}
  def to_str(_msg) do
    {:error, "NIF not loaded"}
  end

  @doc """
    Given a Message struct and a signature, returns true if the Message.address
    signing the Message would produce the signature.
  """
  @spec validate_sig(Message.t(), String.t()) :: boolean()
  def validate_sig(_msg, _sig) do
    :erlang.nif_error(:nif_not_loaded)
  end

  @doc """
    Returns true if the current time is between the messages' not_before and expiration_time
  """
  @spec validate_time(Message.t()) :: boolean()
  def validate_time(_msg) do
    :erlang.nif_error(:nif_not_loaded)
  end

  @doc """
    Given a Message and signature returns true if:
    the current time is between the messages' not_before and expiration_time
    the Message.address signing the Message would produce the signature.
  """
  @spec validate(Message.t(), String.t()) :: boolean()
  def validate(_msg, _sig) do
    :erlang.nif_error(:nif_not_loaded)
  end

  @doc """
   Tests that a message and signature pair correspond and that the current
   time is valid (after not_before, and before expiration_time)

   Returns a Message structure based on the passed message

   ## Examples
    iex> Siwe.parse_if_valid(Enum.join(["login.xyz wants you to sign in with your Ethereum account:",
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
    {:ok, %{ __struct__: Siwe, address: "0xfA151B5453CE69ABf60f0dbdE71F6C9C5868800E", chain_id: "1", domain: "login.xyz", expiration_time: nil, issued_at: "2021-12-17T00:38:39.834Z", nonce: "ToTaLLyRanDOM", not_before: nil, request_id: nil, resources: [], statement: "Sign-In With Ethereum Example Statement", uri: "https://login.xyz", version: "1" }}
  """
  @spec parse_if_valid(String.t(), String.t()) :: {:ok | :error, Message.t() | String.t()}
  def parse_if_valid(_msg, _sig) do
    {:error, "NIF not loaded"}
  end

  @doc """
  Generates an alphanumeric nonce for use in SIWE messages.
  """
  @spec generate_nonce() :: String.t()
  def generate_nonce() do
    :erlang.nif_error(:nif_not_loaded)
  end
end
