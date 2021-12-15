defmodule SiweTest do
  use ExUnit.Case
  doctest Siwe

  test "greets the world" do
    assert Siwe.hello() == :world
  end
end
