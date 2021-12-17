defmodule Siwe do
  @moduledoc """
  Siwe provides validation and parsing for Sign-In with Ethereum messages and signatures.
  Exposes the verify!(message, signature) which raises if invalid
  and returns a Message if valid.
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
      expiration_time: nil, # or a string datetime
      not_before: nil, # or a string datetime
      request_id: nil, # or string
      resources: []
  end

  # Overwritten by the Rustler NIF, uses siwe-rs to do the heavy lifting.
  @doc false
  @spec verify(String.t(), String.t()) :: Message.t()
  defp verify(_msg, _sig) do
    :erlang.nif_error(:nif_not_loaded)
  end


  @doc """
   Tests that a message and signature pair correspond and that the current
   time is valid (after not_before, and before expiration_time)
   any validation of other fields to server's expectation are left
   to the calling application. Just a wrapper around the Rustler NIF

   Returns a Message structure based on the passed message

   ## Examples
    iex> Siwe.verify!(Enum.join(["login.xyz wants you to sign in with your Ethereum account:",
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
    ...> %{
    ...> __struct__: Siwe,
    ...> address: "0xfA151B5453CE69ABf60f0dbdE71F6C9C5868800E",
    ...> chain_id: "1",
    ...> domain: "login.xyz",
    ...> expiration_time: "2021-12-18T20:21:39.907Z",
    ...> issued_at: "2021-12-16T20:21:39.911Z",
    ...> nonce: "ToTaLLyRanDOM",
    ...> not_before: nil,
    ...> request_id: nil,
    ...> resources: [],
    ...> statement: "Sign-In With Ethereum Example Statement",
    ...> uri: "https://login.xyz",
    ...> version: "1"
    ...> }
  """
  @spec verify!(String.t(), String.t()) :: Message.t()
  def verify!(message, signature) do
    verify(message, signature)
  end
end
