defmodule IP.Scope do
  alias IP.{Address, Prefix}
  use Bitwise
  require IP.Prefix
  import IP.Prefix.Helpers

  @moduledoc """
  Implements scope lookup for all (currently) known scopes.

  Please open a pull-request if this needs changing.
  """

  @v4_scopes [
    {"0.0.0.0/8", "CURRENT NETWORK"},
    {"10.0.0.0/8", "RFC1918 PRIVATE"},
    {"127.0.0.0/8", "LOOPBACK"},
    {"168.254.0.0/16", "AUTOCONF PRIVATE"},
    {"172.16.0.0/12", "RFC1918 PRIVATE"},
    {"192.0.0.0/24", "RESERVED (IANA)"},
    {"192.0.2.0/24", "DOCUMENTATION"},
    {"192.88.99.0/24", "6to4 ANYCAST"},
    {"192.168.0.0/16", "RFC1918 PRIVATE"},
    {"198.18.0.0/15", "NETWORK BENCHMARK TESTS"},
    {"198.51.100.0/24", "DOCUMENTATION"},
    {"203.0.113.0/24", "DOCUMENTATION"},
    {"239.0.0.0/8", "LOCAL MULTICAST"},
    {"224.0.0.0/4", "GLOBAL MULTICAST"},
    {"240.0.0.0/4", "RESERVED"},
    {"255.255.255.255/32", "GLOBAL BROADCAST"},
    {"0.0.0.0/0", "GLOBAL UNICAST"}
  ]

  @v6_scopes [
    {"2002::/16", "GLOBAL UNICAST (6to4)"},
    {"2001::/32", "GLOBAL UNICAST (TEREDO)"},
    {"2001:10::/28", "ORCHID"},
    {"2001:db8::/32", "DOCUMENTATION"},
    {"2000::/3", "GLOBAL UNICAST"},
    {"::/128", "UNSPECIFIED ADDRESS"},
    {"::1/128", "LINK LOCAL LOOPBACK"},
    {"::ffff:0:0/96", "IPv4 MAPPED"},
    {"::/96", "IPv4 TRANSITION (deprecated)"},
    {"fc00::/7", "UNIQUE LOCAL UNICAST"},
    {"fec0::/10", "SITE LOCAL (deprecated)"},
    {"fe80::/10", "LINK LOCAL UNICAST"},
    {"ff00::/8", "MULTICAST"},
    {"::/0", "RESERVED"}
  ]

  @doc """
  Return the scope of `address`

  ## Examples

      iex> ~i(192.0.2.0)
      ...> |> IP.Scope.address_scope()
      "DOCUMENTATION"

      iex> ~i(2001:db8::)
      ...> |> IP.Scope.address_scope()
      "DOCUMENTATION"
  """
  @spec address_scope(Address.t()) :: binary

  Enum.each(@v4_scopes, fn {prefix, description} ->
    %Prefix{address: %Address{address: addr0}, mask: mask} =
      prefix
      |> Prefix.from_string!()

    def address_scope(%Address{address: addr1, version: 4})
        when lowest_address(unquote(addr0), unquote(mask)) <= addr1 and
               highest_address(unquote(addr0), unquote(mask), 4) >= addr1 do
      unquote(description)
    end
  end)

  Enum.each(@v6_scopes, fn {prefix, description} ->
    %Prefix{address: %Address{address: addr0}, mask: mask} =
      prefix
      |> Prefix.from_string!()

    def address_scope(%Address{address: addr1, version: 6})
        when lowest_address(unquote(addr0), unquote(mask)) <= addr1 and
               highest_address(unquote(addr0), unquote(mask), 6) >= addr1 do
      unquote(description)
    end
  end)

  @doc """
  Return the scope of `prefix`

  ## Examples

      iex> ~i(192.0.2.0/24)
      ...> |> IP.Scope.prefix_scope()
      "DOCUMENTATION"

      iex> ~i(2001:db8::/32)
      ...> |> IP.Scope.prefix_scope()
      "DOCUMENTATION"
  """
  @spec prefix_scope(Prefix.t()) :: binary

  Enum.each(@v4_scopes, fn {prefix0, description} ->
    %Prefix{address: %Address{address: addr0}, mask: mask0} =
      prefix0
      |> Prefix.from_string!()

    def prefix_scope(%Prefix{address: %Address{address: addr1, version: 4}, mask: mask1})
        when lowest_address(unquote(addr0), unquote(mask0)) <= lowest_address(addr1, mask1) and
               highest_address(unquote(addr0), unquote(mask0), 4) >=
                 highest_address(addr1, mask1, 4) do
      unquote(description)
    end
  end)

  Enum.each(@v6_scopes, fn {prefix0, description} ->
    %Prefix{address: %Address{address: addr0}, mask: mask0} =
      prefix0
      |> Prefix.from_string!()

    def prefix_scope(%Prefix{address: %Address{address: addr1, version: 6}, mask: mask1})
        when lowest_address(unquote(addr0), unquote(mask0)) <= lowest_address(addr1, mask1) and
               highest_address(unquote(addr0), unquote(mask0), 6) >=
                 highest_address(addr1, mask1, 6) do
      unquote(description)
    end
  end)
end
