defmodule IP do
  @moduledoc """
  `IP` provides representations for IP addresses and subnets for Elixir with a
  bunch of helpful stuff tacked on the side.

  Also provides a `__using__` macro so that `use IP` will result in
  `import IP.Sigil`, which is just less typing, yo.

  ## Examples

      iex> ~i(192.0.2.1)
      #IP.Address<192.0.2.1 Documentation (TEST-NET-1), GLOBAL, RESERVED>

      iex> ~i(2001:db8::)
      #IP.Address<2001:db8:: Documentation, GLOBAL, RESERVED>

      iex> outside = ~i(2001:db8::/64)
      ...> inside  = IP.Prefix.eui_64!(outside, "60:f8:1d:ad:d8:90")
      ...> IP.Prefix.contains_address?(outside, inside)
      true
  """

  defmacro __using__(_opts) do
    quote do
      import IP.Sigil
    end
  end
end
