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
      #IP.Prefix<192.0.2.1/32 DOCUMENTATION>

      iex> ~i(192.0.2.1)f
      #IP.Address<192.0.2.1 DOCUMENTATION>

      iex> ~i(2001:db8::/32)
      #IP.Prefix<2001:db8::/32 DOCUMENTATION>

      iex> ~i(2001:db8::/32)s
      #IP.Prefix<2001:db8::/32 DOCUMENTATION>
  """

  @doc """
  Implements `sigil_i` for parsing IP addresses and prefixes.

  * `value` is a string which will be passed to `IP.Prefix.from_string` and
    `IP.Address.from_string` sequentially.

  * `options` is a charlist of flags provided to the sigil.  Valid flags are:
    - `f` parse string specifically as an IPv4 value.
    - `s` parse string specifically as an IPv6 value.

  ## Examples

      iex> IP.Sigil.sigil_i("192.0.2.1", '')
      #IP.Address<192.0.2.1 DOCUMENTATION>

      iex> IP.Sigil.sigil_i("192.0.2.0/24", '')
      #IP.Prefix<192.0.2.0/24 DOCUMENTATION>

      iex> IP.Sigil.sigil_i("2001:db8::/32", '')
      #IP.Prefix<2001:db8::/32 DOCUMENTATION>

      iex> IP.Sigil.sigil_i("2001:db8::", '')
      #IP.Address<2001:db8:: DOCUMENTATION>

      iex> IP.Sigil.sigil_i("Marty McFly", '')
      ** (IP.Sigil.InvalidValue) Unable to parse "Marty McFly" as an IP address or prefix.

      iex> IP.Sigil.sigil_i("192.0.2.1", 'f')
      #IP.Address<192.0.2.1 DOCUMENTATION>

      iex> IP.Sigil.sigil_i("2001:db8::/32", 'f')
      ** (IP.Sigil.InvalidValue) Unable to parse "2001:db8::/32" as an IPv4 address or prefix.

      iex> IP.Sigil.sigil_i("192.0.2.1", 's')
      ** (IP.Sigil.InvalidValue) Unable to parse "192.0.2.1" as an IPv6 address or prefix.

      iex> IP.Sigil.sigil_i("2001:db8::/32", 's')
      #IP.Prefix<2001:db8::/32 DOCUMENTATION>
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
