defmodule SiweTest do
  use ExUnit.Case
  doctest Siwe

  test "helper functions are equivalent" do
    msg = "login.xyz wants you to sign in with your Ethereum account:
0xfA151B5453CE69ABf60f0dbdE71F6C9C5868800E

Sign-In With Ethereum Example Statement

URI: https://login.xyz
Version: 1
Chain ID: 1
Nonce: ToTaLLyRanDOM
Issued At: 2021-12-16T20:21:39.911Z
Expiration Time: 2021-12-18T20:21:39.907Z"

    {:ok, res} = Siwe.parse(msg)
    {:ok, msg_2} = Siwe.to_str(res)

    assert(msg_2 == msg)

    sig =
      "0x30893d6bb4b171e540f0ca705c31f2431bdb4e5c712b6e2eb0c87ed6fbfb87e14f1a90da08473bf1e084a41311c0fd2174a676eb53301f9d4703824b5bc2e1b21c"

    bad_sig =
      "0x111111a1abbdf172875e5be41706c50fc3bede8af363b67aefbb543d6d082fb76a22057d7cb6d668ceba883f7d70ab7f1dc015b76b51d226af9d610fa20360ad1c"

    assert(Siwe.verify_sig(res, sig))
    assert(!Siwe.verify_sig(res, bad_sig))
    assert(Siwe.verify(res, sig, struct(Siwe.Opts)))
    assert(!Siwe.verify(res, bad_sig, struct(Siwe.Opts)))
    assert(Siwe.verify(res, sig, struct(Siwe.Opts, domain_binding: "login.xyz")))
    assert(!Siwe.verify(res, sig, struct(Siwe.Opts, domain_binding: "login.abc")))

    assert(
      Siwe.verify(
        res,
        sig,
        struct(Siwe.Opts, domain_binding: "login.xyz", match_nonce: "ToTaLLyRanDOM")
      )
    )

    assert(
      !Siwe.verify(
        res,
        sig,
        struct(Siwe.Opts, domain_binding: "login.xyz", match_nonce: "totallyrandom")
      )
    )

    assert(
      Siwe.verify(
        res,
        sig,
        struct(Siwe.Opts,
          domain_binding: "login.xyz",
          match_nonce: "ToTaLLyRanDOM",
          timestamp: "2021-12-16T20:22:39.911Z"
        )
      )
    )

    assert(
      !Siwe.verify(
        res,
        sig,
        struct(Siwe.Opts,
          domain_binding: "login.xyz",
          match_nonce: "totallyrandom",
          timestamp: "2021-12-19T20:22:39.911Z"
        )
      )
    )
  end

  # TODO: Add test for time using on-fly-generated message and sig, requiring local key to test?
  test "verifies message and signature" do
    msg = "login.xyz wants you to sign in with your Ethereum account:
0xfA151B5453CE69ABf60f0dbdE71F6C9C5868800E

Sign-In With Ethereum Example Statement

URI: https://login.xyz
Version: 1
Chain ID: 1
Nonce: ToTaLLyRanDOM
Issued At: 2021-12-17T00:38:39.834Z"

    sig =
      "0x8d1327a1abbdf172875e5be41706c50fc3bede8af363b67aefbb543d6d082fb76a22057d7cb6d668ceba883f7d70ab7f1dc015b76b51d226af9d610fa20360ad1c"

    {:ok, res} = Siwe.parse_if_valid(msg, sig)
    assert(res.domain == "login.xyz")
    assert(res.address == "0xfA151B5453CE69ABf60f0dbdE71F6C9C5868800E")
    assert(res.uri == "https://login.xyz")
    assert(res.version == "1")
    assert(res.chain_id == 1)
    assert(res.nonce == "ToTaLLyRanDOM")
    assert(res.issued_at == "2021-12-17T00:38:39.834Z")
    assert(res.expiration_time == nil)
    assert(res.not_before == nil)
    assert(res.request_id == nil)
    assert(res.resources == [])
  end

  test "rejects bad signature" do
    msg = "login.xyz wants you to sign in with your Ethereum account:
0xfA151B5453CE69ABf60f0dbdE71F6C9C5868800E

Sign-In With Ethereum Example Statement

URI: https://login.xyz
Version: 1
Chain ID: 1
Nonce: ToTaLLyRanDOM
Issued At: 2021-12-17T00:38:39.834Z"

    sig =
      "0x8d1327a1abbdf172875e5be41706c50fc3bede8af363b67aefbb543d6d082fb76a22057d7cb6d668ceba883f7d70ab7f1dc015b76b51d226af9d610fa20360ad1d"

    {:error, _} = Siwe.parse_if_valid(msg, sig)
  end

  test "rejects expired message with valid signature" do
    msg = "login.xyz wants you to sign in with your Ethereum account:
0xfA151B5453CE69ABf60f0dbdE71F6C9C5868800E

Sign-In With Ethereum Example Statement

URI: https://login.xyz
Version: 1
Chain ID: 1
Nonce: ToTaLLyRanDOM
Issued At: 2021-12-16T20:21:39.911Z
Expiration Time: 2021-12-18T20:21:39.907Z"

    sig =
      "0x30893d6bb4b171e540f0ca705c31f2431bdb4e5c712b6e2eb0c87ed6fbfb87e14f1a90da08473bf1e084a41311c0fd2174a676eb53301f9d4703824b5bc2e1b21c"

    {:error, _} = Siwe.parse_if_valid(msg, sig)
  end
end
