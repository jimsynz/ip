defmodule IP.Address do
  alias IP.{Address, Prefix}
  alias IP.Address.{InvalidAddress, Helpers, ULA}
  defstruct ~w(address version)a
  import Helpers
  use Bitwise

  @moduledoc """
  Simple representations of IP Addresses.
  """

  @typedoc "Valid IPv4 address - integer between zero and 32 ones."
  @type ipv4 :: 0..0xffffffff

  @typedoc "Valid IPv6 address - integer between zero and 128 ones."
  @type ipv6 :: 0..0xffffffffffffffffffffffffffffffff

  @typedoc "Valid IP address"
  @type ip :: ipv4 | ipv6

  @typedoc "Valid IP version (currently only 4 and 6 are deployed in the wild)."
  @type version :: 4 | 6

  @typedoc "IP address struct type, contains a valid address and version."
  @type t :: %Address{address: ip, version: version}

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
  @spec from_integer(ip, version) :: {:ok, t} | {:error, term}
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
  @spec from_integer!(ip, version) :: t
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
  @spec from_string(binary, version) :: {:ok, t} | {:error, term}
  def from_string(address, 4) when is_binary(address) do
    case :inet.parse_ipv4strict_address(String.to_charlist(address)) do
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
  @spec from_string!(binary, version) :: t
  def from_string!(address, version) do
    case from_string(address, version) do
      {:ok, address} -> address
      {:error, msg} -> raise(InvalidAddress, msg)
    end
  end

  @doc """
  Convert an `address` into a string.

  ## Examples

      iex> ~i(192.0.2.1)
      ...> |> IP.Address.to_string()
      "192.0.2.1"

      iex> ~i(2001:db8::1)
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

      iex> ~i(192.0.2.1)
      ...> |> IP.Address.to_prefix(32)
      #IP.Prefix<192.0.2.1/32 DOCUMENTATION>
  """
  @spec to_prefix(t, Prefix.prefix_length) :: Prefix.t
  def to_prefix(%Address{} = address, length), do: Prefix.new(address, length)

  @doc """
  Returns the IP version of the address.

  ## Examples

      iex> ~i(192.0.2.1)
      ...> |> IP.Address.version()
      4

      iex> ~i(2001:db8::1)
      ...> |> IP.Address.version()
      6
  """
  @spec version(t) :: version
  def version(%Address{version: version}), do: version

  @doc """
  Returns the IP Address as an integer

  ## Examples

      iex> ~i(192.0.2.1)
      ...> |> IP.Address.to_integer()
      3221225985

      iex> ~i(2001:db8::1)
      ...> |> IP.Address.to_integer()
      42540766411282592856903984951653826561
  """
  @spec to_integer(t) :: ip
  def to_integer(%Address{address: address}), do: address

  @doc """
  Returns true if `address` is version 6.

  ## Examples

      iex> ~i(192.0.2.1)
      ...> |> IP.Address.v6?
      false

      iex> ~i(2001:db8::)
      ...> |> IP.Address.v6?
      true
  """
  @spec v6?(t) :: boolean
  def v6?(%Address{version: 6} = _address), do: true
  def v6?(_address), do: false

  @doc """
  Returns true if `address` is version 4.

  ## Examples

      iex> ~i(192.0.2.1)
      ...> |> IP.Address.v4?
      true

      iex> ~i(2001:db8::)
      ...> |> IP.Address.v4?
      false
  """
  @spec v4?(t) :: boolean
  def v4?(%Address{version: 4} = _address), do: true
  def v4?(_address), do: false

  @doc """
  Returns true if the address is an EUI-64 address.

  ## Examples

      iex> ~i(2001:db8::62f8:1dff:fead:d890)
      ...> |> IP.Address.eui_64?()
      true
  """
  @spec eui_64?(t) :: boolean
  def eui_64?(%Address{address: address, version: 6})
  when (address &&& 0x20000fffe000000) == 0x20000fffe000000,
  do: true

  def eui_64?(_address), do: false

  @doc """
  Return a MAC address coded in an EUI-64 address.

  ## Examples

      iex> ~i(2001:db8::62f8:1dff:fead:d890)
      ...> |> IP.Address.eui_64_mac()
      {:ok, "60f8.1dad.d890"}
  """
  @spec eui_64_mac(t) :: {:ok, binary} | {:error, term}
  def eui_64_mac(%Address{address: address, version: 6})
  when (address &&& 0x20000fffe000000) == 0x20000fffe000000
  do
    mac  = address &&& 0xffffffffffffffff
    head = mac >>> 40
    tail = mac &&& 0xffffff
    mac  = ((head <<< 24) + tail) ^^^ 0x20000000000
    <<a::binary-size(4), b::binary-size(4), c::binary-size(4)>> = mac
      |> Integer.to_string(16)
      |> String.downcase()
      |> String.pad_leading(12, "0")
    {:ok, "#{a}.#{b}.#{c}"}
  end

  def eui_64_mac(_address), do: {:error, "Not an EUI-64 address"}

  @doc """
  Convert an IPv4 address into a 6to4 address.

  ## Examples

      iex> ~i(192.0.2.1)
      ...> |> IP.Address.to_6to4()
      #IP.Address<2002:c000:201:: GLOBAL UNICAST (6to4)>
  """
  @spec to_6to4(t) :: {:ok, t} | {:error, term}
  def to_6to4(%Address{address: address, version: 4}) do
    address = (0x2002 <<< 112) + (address <<< 80)
    %Address{address: address, version: 6}
  end

  def to_6to4(_address), do: {:error, "Not an IPv4 address"}

  @doc """
  Determine if the IP address is a 6to4 address.

  ## Examples

      iex> ~i(2002:c000:201::)
      ...> |> IP.Address.is_6to4?()
      true

      iex> ~i(2001:db8::)
      ...> |> IP.Address.is_6to4?()
      false
  """
  @spec is_6to4?(t) :: boolean
  def is_6to4?(%Address{address: address, version: 6})
  when (address >>> 112) == 0x2002, do: true

  def is_6to4?(_address), do: false

  @doc """
  Convert a 6to4 IPv6 address to it's correlated IPv6 address.

  ## Examples

      iex> ~i(2002:c000:201::)
      ...> |> IP.Address.from_6to4()
      ...> |> inspect()
      "{:ok, #IP.Address<192.0.2.1 DOCUMENTATION>}"

      iex> ~i(2001:db8::)
      ...> |> IP.Address.from_6to4()
      {:error, "Not a 6to4 address"}
  """
  @spec from_6to4(t) :: {:ok, t} | {:error, term}
  def from_6to4(%Address{address: address, version: 6})
  when (address >>> 112) == 0x2002
  do
    address = (address >>> 80) &&& 0xffffffff
    Address.from_integer(address, 4)
  end

  def from_6to4(_address), do: {:error, "Not a 6to4 address"}

  @doc """
  Determine if an IP address is a teredo connection.

  ## Examples

      iex> ~i(2001::)
      ...> |> IP.Address.is_teredo?()
      true
  """
  @spec is_teredo?(t) :: boolean
  def is_teredo?(%Address{address: address, version: 6})
  when (address >>> 96) == 0x20010000, do: true

  def is_teredo?(_address), do: false

  @doc """
  Return information about a teredo connection.

  ## Examples

      iex> ~i(2001:0:4136:e378:8000:63bf:3fff:fdd2)
      ...> |> IP.Address.teredo()
      ...> |> Map.get(:server)
      #IP.Address<65.54.227.120 GLOBAL UNICAST>

      iex> ~i(2001:0:4136:e378:8000:63bf:3fff:fdd2)
      ...> |> IP.Address.teredo()
      ...> |> Map.get(:client)
      #IP.Address<63.255.253.210 GLOBAL UNICAST>

      iex> ~i(2001:0:4136:e378:8000:63bf:3fff:fdd2)
      ...> |> IP.Address.teredo()
      ...> |> Map.get(:port)
      25535
  """
  @spec teredo(t) :: {:ok, map} | {:error, term}
  def teredo(%Address{address: address, version: 6})
  when (address >>> 96) == 0x20010000 do
    server = address >>> 64 &&& ((1 <<< 32) - 1)
    client = address &&& ((1 <<< 32) - 1) &&& ((1 <<< 32) - 1)
    port   = (address >>> 32) &&& ((1 <<< 16) - 1)
    %{server: Address.from_integer!(server, 4),
      client: Address.from_integer!(client, 4),
      port:   port}
  end

  def teredo(_address), do: {:error, "Not a teredo address"}

  @doc """
  Generate an IPv6 Unique Local Address

  Note that the MAC address is just used as a source of randomness, so where you
  get it from is not important and doesn't restrict this ULA to just that system.
  See RFC4193

  ## Examples

      iex> IP.Address.generate_ula("60:f8:1d:ad:d8:90")
      #IP.Address<fd29:f1ef:86a1::>
  """
  @spec generate_ula(binary, non_neg_integer, boolean) :: \
    {:ok, t} | {:error, term}
  def generate_ula(mac, subnet_id \\ 0, locally_assigned \\ true) do
    with {:ok, address} <- ULA.generate(mac, subnet_id, locally_assigned),
         {:ok, address} <- from_integer(address, 6)
    do
      {:ok, address}
    end
  end

  defp from_bytes([a, b, c, d]) do
    (a <<< 24) + (b <<< 16) + (c <<< 8) + d
  end

  defp from_bytes([a, b, c, d, e, f, g, h]) do
    (a <<< 0x70) + (b <<< 0x60) + (c <<< 0x50) + (d <<< 0x40) +
    (e <<< 0x30) + (f <<< 0x20) + (g <<< 0x10) + h
  end
end
