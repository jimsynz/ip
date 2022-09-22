defmodule IPPrefixTest do
  @moduledoc false
  use ExUnit.Case
  import IP.Sigil
  doctest IP.Prefix

  test "fails to parse invalid prefixes" do
    assert {:error, "Unable to parse IP prefix"} =
             IP.Prefix.from_string("192.168.1.1/250.250.250.0")
  end
end
