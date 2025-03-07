defmodule IP.Sigil do
  alias IP.{Address, Prefix}
  alias IP.Sigil.InvalidValue

  @moduledoc """
  Provides the `~i` sigil.

  You can use with `import IP.Sigil` or `use IP`.

  Valid modifiers are `f` to parse specifically as an IPv4 value, and `s` to
  parse specifically as an IPv6 value.  As a side note, digits can't be used as
  sigil modifiers. Ask me how I know.

  `~i` will raise `IP.Sigil.InvalidValue` in the event of a parsing failure.

  ## Examples

      iex> ~i(192.0.2.1/32)
      #IP.Prefix<192.0.2.1/32 Documentation (TEST-NET-1), GLOBAL, RESERVED>

      iex> ~i(192.0.2.1)f
      #IP.Address<192.0.2.1 Documentation (TEST-NET-1), GLOBAL, RESERVED>

      iex> ~i(2001:db8::/32)
      #IP.Prefix<2001:db8::/32 Documentation, GLOBAL, RESERVED>

      iex> ~i(2001:db8::/32)s
      #IP.Prefix<2001:db8::/32 Documentation, GLOBAL, RESERVED>
  """

  @doc """
  Implements `sigil_i` for parsing IP addresses and prefixes.

  * `value` is a string which will be passed to `IP.Prefix.from_string` and
    `IP.Address.from_string` sequentially.

  * `options` is a charlist of flags provided to the sigil.  Valid flags are:
    - `f` parse string specifically as an IPv4 value.
    - `s` parse string specifically as an IPv6 value.

  ## Examples

      iex> IP.Sigil.sigil_i("192.0.2.1", ~c"")
      #IP.Address<192.0.2.1 Documentation (TEST-NET-1), GLOBAL, RESERVED>

      iex> IP.Sigil.sigil_i("192.0.2.0/24", ~c"")
      #IP.Prefix<192.0.2.0/24 Documentation (TEST-NET-1), GLOBAL, RESERVED>

      iex> IP.Sigil.sigil_i("2001:db8::/32", ~c"")
      #IP.Prefix<2001:db8::/32 Documentation, GLOBAL, RESERVED>

      iex> IP.Sigil.sigil_i("2001:db8::", ~c"")
      #IP.Address<2001:db8:: Documentation, GLOBAL, RESERVED>

      iex> IP.Sigil.sigil_i("Marty McFly", ~c"")
      ** (IP.Sigil.InvalidValue) Unable to parse "Marty McFly" as an IP address or prefix.

      iex> IP.Sigil.sigil_i("192.0.2.1", ~c"f")
      #IP.Address<192.0.2.1 Documentation (TEST-NET-1), GLOBAL, RESERVED>

      iex> IP.Sigil.sigil_i("2001:db8::/32", ~c"f")
      ** (IP.Sigil.InvalidValue) Unable to parse "2001:db8::/32" as an IPv4 address or prefix.

      iex> IP.Sigil.sigil_i("192.0.2.1", ~c"s")
      ** (IP.Sigil.InvalidValue) Unable to parse "192.0.2.1" as an IPv6 address or prefix.

      iex> IP.Sigil.sigil_i("2001:db8::/32", ~c"s")
      #IP.Prefix<2001:db8::/32 Documentation, GLOBAL, RESERVED>
  """
  @spec sigil_i(binary, [non_neg_integer]) :: Prefix.t() | Address.t()
  def sigil_i(value, ~c"" = _options) do
    case Prefix.from_string(value) do
      {:ok, prefix} ->
        prefix

      {:error, _} ->
        case Address.from_string(value) do
          {:ok, address} ->
            address

          {:error, _} ->
            raise(InvalidValue,
              message: "Unable to parse #{inspect(value)} as an IP address or prefix."
            )
        end
    end
  end

  def sigil_i(value, ~c"f" = _options) do
    case Prefix.from_string(value, 4) do
      {:ok, prefix} ->
        prefix

      {:error, _} ->
        case Address.from_string(value, 4) do
          {:ok, address} ->
            address

          {:error, _} ->
            raise(InvalidValue,
              message: "Unable to parse #{inspect(value)} as an IPv4 address or prefix."
            )
        end
    end
  end

  def sigil_i(value, ~c"s" = _options) do
    case Prefix.from_string(value, 6) do
      {:ok, prefix} ->
        prefix

      {:error, _} ->
        case Address.from_string(value, 6) do
          {:ok, address} ->
            address

          {:error, _} ->
            raise(InvalidValue,
              message: "Unable to parse #{inspect(value)} as an IPv6 address or prefix."
            )
        end
    end
  end
end
