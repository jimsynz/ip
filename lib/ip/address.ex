defmodule IP.Address do
  alias __MODULE__
  alias IP.Address.{InvalidAddress, Helpers, Prefix}
  defstruct ~w(address version)a
  import Helpers
  use Bitwise

  @moduledoc """
  Simple representations of IP Addresses.
  """

  @type t :: %Address{}
  @type ipv4 :: 0..0xffffffff
  @type ipv6 :: 0..0xffffffffffffffffffffffffffffffff
  @type ip_version :: 4 | 6

  @doc """
  Convert from (packed) binary representations (either 32 or 128 bits long) into an address.

  ## Examples

      iex> <<192, 0, 2, 1>>
      ...> |> IP.Address.from_binary()
      {:ok, %IP.Address{address: 3221225985, version: 4}}

      iex> <<32, 1, 13, 184, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
      ...> |> IP.Address.from_binary()
      {:ok, %IP.Address{address: 42540766411282592856903984951653826560, version: 6}}

      iex> "192.0.2.1"
      ...> |> IP.Address.from_binary()
      {:error, "Unable to convert binary to address"}
  """
  @spec from_binary(binary) :: {:ok, t} | {:error, term}
  def from_binary(<<address :: unsigned-integer-size(32)>>), do: {:ok, %Address{address: address, version: 4}}
  def from_binary(<<address :: unsigned-integer-size(128)>>), do: {:ok, %Address{address: address, version: 6}}
  def from_binary(_address), do: {:error, "Unable to convert binary to address"}

  @doc """
  Convert from a packed binary presentation to an address or raise an
  `IP.Address.InvalidAddress` exception.

  ## Examples

      iex> <<192, 0, 2, 1>>
      ...> |> IP.Address.from_binary!()
      %IP.Address{address: 3221225985, version: 4}

      iex> <<32, 1, 13, 184, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1>>
      ...> |> IP.Address.from_binary!()
      %IP.Address{address: 42540766411282592856903984951653826561, version: 6}
  """
  @spec from_binary!(binary) :: t
  def from_binary!(address) do
    case from_binary(address) do
      {:ok, address} -> address
      {:error, msg} -> raise(InvalidAddress, message: msg)
    end
  end

  @doc """
  Convert an integer into an IP address of specified version.

  ## Examples

      iex> 3221225985
      ...> |> IP.Address.from_integer(4)
      {:ok, %IP.Address{address: 3221225985, version: 4}}

      iex> 42540766411282592856903984951653826561
      ...> |> IP.Address.from_integer(6)
      {:ok, %IP.Address{address: 42540766411282592856903984951653826561, version: 6}}
  """
  @spec from_integer(ipv4 | ipv6, ip_version) :: {:ok, t} | {:error, term}
  def from_integer(address, 4) when valid_ipv4_integer?(address) do
    {:ok, %Address{address: address, version: 4}}
  end

  def from_integer(address, 6) when valid_ipv6_integer?(address) do
    {:ok, %Address{address: address, version: 6}}
  end

  def from_integer(_address, 4), do: {:error, "Supplied address not within IPv4 address space"}
  def from_integer(_address, 6), do: {:error, "Supplied address not within IPv6 address space"}
  def from_integer(_address, version), do: {:error, "No such IP version #{inspect version}"}

  @doc """
  Convert an integer into an IP address of specified version or raise an
  `IP.Address.InvalidAddress` exception.

  ## Examples

      iex> 3221225985
      ...> |> IP.Address.from_integer!(4)
      %IP.Address{address: 3221225985, version: 4}

      iex> 42540766411282592856903984951653826561
      ...> |> IP.Address.from_integer!(6)
      %IP.Address{address: 42540766411282592856903984951653826561, version: 6}
  """
  @spec from_integer!(ipv4 | ipv6, ip_version) :: t
  def from_integer!(address, version) do
    case from_integer(address, version) do
      {:ok, address} -> address
      {:error, msg} -> raise(InvalidAddress, message: msg)
    end
  end

  @doc """
  Convert a string representation into an IP address of unknown version.

  Tries to parse the string as IPv6, then IPv4 before failing.  Obviously if
  you know the version then using `from_string/2` is faster.

  ## Examples

      iex> "192.0.2.1"
      ...> |> IP.Address.from_string()
      {:ok, %IP.Address{address: 3221225985, version: 4}}

      iex> "2001:db8::1"
      ...> |> IP.Address.from_string()
      {:ok, %IP.Address{address: 42540766411282592856903984951653826561, version: 6}}
  """
  @spec from_string(binary) :: {:ok, t} | {:error, term}
  def from_string(address) when is_binary(address) do
    case from_string(address, 6) do
      {:ok, address} -> {:ok, address}
      {:error, _} ->
        case from_string(address, 4) do
          {:ok, address} -> {:ok, address}
          {:error, _} -> {:error, "Unable to parse IP address"}
        end
    end
  end

  @doc """
  Convert a string representation into an IP address or raise an
  `IP.Address.InvalidAddress` exception.

  ## Examples

      iex> "192.0.2.1"
      ...> |> IP.Address.from_string!()
      %IP.Address{address: 3221225985, version: 4}

      iex> "2001:db8::1"
      ...> |> IP.Address.from_string!()
      %IP.Address{address: 42540766411282592856903984951653826561, version: 6}
  """
  @spec from_string!(binary) :: t
  def from_string!(address) when is_binary(address) do
    case from_string(address) do
      {:ok, addr} -> addr
      {:error, msg} -> raise(InvalidAddress, message: msg)
    end
  end

  @doc """
  Convert a string representation into an IP address of specified version.

  ## Examples

      iex> "192.0.2.1"
      ...> |> IP.Address.from_string(4)
      {:ok, %IP.Address{address: 3221225985, version: 4}}

      iex> "2001:db8::1"
      ...> |> IP.Address.from_string(6)
      {:ok, %IP.Address{address: 42540766411282592856903984951653826561, version: 6}}
  """
  @spec from_string(binary, ip_version) :: {:ok, t} | {:error, term}
  def from_string(address, 4) when is_binary(address) do
    case :inet.parse_ipv4_address(String.to_charlist(address)) do
      {:ok, addr} ->
        addr = addr
          |> Tuple.to_list()
          |> from_bytes()
        {:ok, %Address{version: 4, address: addr}}
      {:error, _} -> {:error, "Cannot parse IPv4 address"}
    end
  end

  def from_string(address, 6) when is_binary(address) do
    case :inet.parse_ipv6strict_address(String.to_charlist(address)) do
      {:ok, addr} ->
        addr = addr
          |> Tuple.to_list()
          |> from_bytes()
        {:ok, %Address{version: 6, address: addr}}
      {:error, _} -> {:error, "Cannot parse IPv6 address"}
    end
  end

  def from_string(_address, 4), do: {:error, "Cannot parse IPv4 address"}
  def from_string(_address, 6), do: {:error, "Cannot parse IPv6 address"}
  def from_string(_address, version), do: {:error, "No such IP version #{inspect version}"}

  @doc """
  Convert a string representation into an IP address of specified version or raise an
  `IP.Address.InvalidAddress` exception.

  ## Examples

      iex> "192.0.2.1"
      ...> |> IP.Address.from_string!(4)
      %IP.Address{address: 3221225985, version: 4}

      iex> "2001:db8::1"
      ...> |> IP.Address.from_string!(6)
      %IP.Address{address: 42540766411282592856903984951653826561, version: 6}
  """
  @spec from_string!(binary, ip_version) :: t
  def from_string!(address, version) do
    case from_string(address, version) do
      {:ok, address} -> address
      {:error, msg} -> raise(InvalidAddress, msg)
    end
  end

  @doc """
  Convert an `address` into a string.

  ## Examples

      iex> IP.Address.from_string!("192.0.2.1", 4)
      ...> |> IP.Address.to_string()
      "192.0.2.1"

      iex> IP.Address.from_string!("2001:db8::1", 6)
      ...> |> IP.Address.to_string()
      "2001:db8::1"
  """
  @spec to_string(t) :: binary
  def to_string(%Address{version: 4, address: addr}) do
    a = addr >>> 0x18 &&& 0xff
    b = addr >>> 0x10 &&& 0xff
    c = addr >>> 0x08 &&& 0xff
    d = addr &&& 0xff
    {a, b, c, d}
    |> :inet.ntoa()
    |> List.to_string()
  end

  def to_string(%Address{version: 6, address: addr}) do
    a = addr >>> 0x70 &&& 0xffff
    b = addr >>> 0x60 &&& 0xffff
    c = addr >>> 0x50 &&& 0xffff
    d = addr >>> 0x40 &&& 0xffff
    e = addr >>> 0x30 &&& 0xffff
    f = addr >>> 0x20 &&& 0xffff
    g = addr >>> 0x10 &&& 0xffff
    h = addr &&& 0xffff
    {a, b, c, d, e, f, g, h}
    |> :inet.ntoa()
    |> List.to_string()
  end

  @doc """
  Convert an `address` to an `IP.Prefix`.

  ## Examples

      iex> IP.Address.from_string!("192.0.2.1", 4)
      ...> |> IP.Address.to_prefix(32)
      #IP.Prefix<192.0.2.1/32>
  """
  @spec to_prefix(t, Prefix.ipv4_prefix_length | Prefix.ipv6_prefix_length) \
    :: Prefix.t
  def to_prefix(%Address{} = address, length), do: IP.Prefix.new(address, length)

  defp from_bytes([a, b, c, d]) do
    (a <<< 24) + (b <<< 16) + (c <<< 8) + d
  end

  defp from_bytes([a, b, c, d, e, f, g, h]) do
    (a <<< 0x70) + (b <<< 0x60) + (c <<< 0x50) + (d <<< 0x40) +
    (e <<< 0x30) + (f <<< 0x20) + (g <<< 0x10) + h
  end
end
