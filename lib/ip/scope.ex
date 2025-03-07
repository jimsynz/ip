defmodule IP.Scope do
  alias IP.{Address, Prefix}
  require IP.Prefix
  import IP.Prefix.Helpers

  alias IP.{Address, Prefix}

  require IP.Prefix

  @moduledoc """
  Implements scope lookup for all (currently) known scopes.

  Please open a pull-request if this needs changing.
  """

  @v4_scopes IP.RegistryParser.parse!("iana-ipv4-special-registry")
  @v6_scopes IP.RegistryParser.parse!("iana-ipv6-special-registry")

  @doc """
  Return the scope of `address`

  ## Examples

      iex> ~i(192.0.2.0)
      ...> |> IP.Scope.address_scope()
      "Documentation (TEST-NET-1), GLOBAL, RESERVED"

      iex> ~i(2001:db8::)
      ...> |> IP.Scope.address_scope()
      "Documentation, GLOBAL, RESERVED"
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

  def address_scope(_), do: "GLOBAL UNICAST"

  @doc """
  Return the scope of `prefix`

  ## Examples

      iex> ~i(192.0.2.0/24)
      ...> |> IP.Scope.prefix_scope()
      "Documentation (TEST-NET-1), GLOBAL, RESERVED"

      iex> ~i(2001:db8::/32)
      ...> |> IP.Scope.prefix_scope()
      "Documentation, GLOBAL, RESERVED"
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

  def prefix_scope(_), do: "GLOBAL UNICAST"
end
