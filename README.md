# Sign-In with Ethereum 

Sign-In with Ethereum message validation for Elixir.

## Installation

SIWE can be installed by including it in your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:siwe, "~> 0.1.0"}
  ]
end
```

## Usage

Full documentation found at <https://hexdocs.pm/siwe>.

This library exposes the `verify!(message, signature)` function that takes a [SIWE](https://eips.ethereum.org/EIPS/eip-4361) message and the corresponding signature, and returns a parsed form of the SIWE message if the message is valid.

Valid in this context means:

- The signature matches the message for the address present in the message.

- The current time is after the message's optional `not_before`.

- The current time is before the message's optional `expiration_time`.

Other considerations, such as domain and nonce matching, are left to the calling application.

The returned structure is useful for this purpose:
```elixir
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
```

### Example

Clone this repository and from the root run:
```bash
$ mix deps.get
```

Then create two files
`message.txt`:
```
login.xyz wants you to sign in with your Ethereum account:
0xfA151B5453CE69ABf60f0dbdE71F6C9C5868800E

Sign-In With Ethereum Example Statement

URI: https://login.xyz
Version: 1
Chain ID: 1
Nonce: ToTaLLyRanDOM
Issued At: 2021-12-17T00:38:39.834Z
```
`signature.txt`:
```
0x8d1327a1abbdf172875e5be41706c50fc3bede8af363b67aefbb543d6d082fb76a22057d7cb6d668ceba883f7d70ab7f1dc015b76b51d226af9d610fa20360ad1c
```
then run 
```
$ iex -S mix
```
Once in iex, you can then run the following to see the result:
```
iex)> {:ok, msg} = File.read("./message.txt")
iex)> {:ok, sig} = File.read("./signature.txt")
iex)> Siwe.verify!(msg, sig)
```
Any valid SIWE message and signature pair can be substituted.

## See Also

- [Sign-In with Ethereum: TypeScript](https://github.com/spruceid/siwe)
- [Example SIWE application: login.xyz](https://login.xyz)
- [EIP-4361 Specification Draft](https://eips.ethereum.org/EIPS/eip-4361)
- [EIP-191 Specification](https://eips.ethereum.org/EIPS/eip-191)