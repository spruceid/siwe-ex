defmodule Siwe.Message do
  @moduledoc false

  # The result of the Siwe.parse and parse_if_valid, a formatted form
  # of what siwe-rs uses

  @type t :: %__MODULE__{}

  defstruct domain: "",
            address: "",
            # or a string statement.
            statement: nil,
            uri: "",
            version: "",
            chain_id: "",
            nonce: "",
            issued_at: "",
            # or a string datetime
            expiration_time: nil,
            # or a string datetime
            not_before: nil,
            # or string
            request_id: nil,
            resources: []
end
