defmodule EnumerableIPPrefixTest do
  use ExUnit.Case
  import IP.Sigil
  doctest Enumerable.IP.Prefix

  # Regression: https://harton.dev/james/ip/issues/1
  test "correctly returns the first address in the range" do
    assert Enum.take(~i(10.10.10.0/24), 1) == [~i(10.10.10.0)]
  end
end
