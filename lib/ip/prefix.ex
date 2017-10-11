defmodule IP.Prefix do
  alias IP.{Prefix, Address}
  alias IP.Prefix.{Parser, InvalidPrefix, Helpers, EUI64}
  defstruct ~w(address mask)a
  use Bitwise
  import Helpers

  @moduledoc """
  Defines an IP prefix, otherwise known as a subnet.
  """

  @type t :: %Prefix{}
  @type ipv4_prefix_length :: 0..32
  @type ipv6_prefix_length :: 0..128

  @ipv4_mask 0xffffffff
  @ipv6_mask 0xffffffffffffffffffffffffffffffff

  @doc """
  Create an IP prefix from an `IP.Address` and `length`.

  ## Examples

      iex> IP.Prefix.new(~i(192.0.2.1), 24)
      #IP.Prefix<192.0.2.0/24 DOCUMENTATION>

      iex> IP.Prefix.new(~i(2001:db8::1), 64)
      #IP.Prefix<2001:db8::/64 DOCUMENTATION>
  """
  @spec new(Address.t, ipv4_prefix_length | ipv6_prefix_length) :: t
  def new(%Address{address: address, version: 4}, length) when length >= 0 and length <= 32 do
    mask = calculate_mask_from_length(length, 32)
    %Prefix{address: Address.from_integer!(address, 4), mask: mask}
  end

  def new(%Address{address: address, version: 6}, length) when length >= 0 and length <= 128 do
    mask = calculate_mask_from_length(length, 128)
    %Prefix{address: Address.from_integer!(address, 6), mask: mask}
  end

  @doc """
  Create a prefix by attempting to parse a string of unknown version.

  Calling `from_string/2` is faster if you know the IP version of the prefix.

  ## Examples

      iex> "192.0.2.1/24"
      ...> |> IP.Prefix.from_string()
      ...> |> inspect()
      "{:ok, #IP.Prefix<192.0.2.0/24 DOCUMENTATION>}"

      iex> "192.0.2.1/255.255.255.0"
      ...> |> IP.Prefix.from_string()
      ...> |> inspect()
      "{:ok, #IP.Prefix<192.0.2.0/24 DOCUMENTATION>}"

      iex> "2001:db8::/64"
      ...> |> IP.Prefix.from_string()
      ...> |> inspect()
      "{:ok, #IP.Prefix<2001:db8::/64 DOCUMENTATION>}"
  """
  @spec from_string(binary) :: {:ok, t} | {:error, term}
  def from_string(prefix), do: Parser.parse(prefix)

  @doc """
  Create a prefix by attempting to parse a string of specified IP version.

  ## Examples

      iex> "192.0.2.1/24"
      ...> |> IP.Prefix.from_string(4)
      ...> |> inspect()
      "{:ok, #IP.Prefix<192.0.2.0/24 DOCUMENTATION>}"

      iex> "192.0.2.1/255.255.255.0"
      ...> |> IP.Prefix.from_string(4)
      ...> |> inspect()
      "{:ok, #IP.Prefix<192.0.2.0/24 DOCUMENTATION>}"

      iex> "2001:db8::/64"
      ...> |> IP.Prefix.from_string(4)
      {:error, "Error parsing IPv4 prefix"}
  """
  @spec from_string(binary, 4 | 6) :: {:ok, t} | {:error, term}
  def from_string(prefix, version), do: Parser.parse(prefix, version)

  @doc """
  Create a prefix by attempting to parse a string of unknown version.

  Calling `from_string!/2` is faster if you know the IP version of the prefix.

  ## Examples

      iex> "192.0.2.1/24"
      ...> |> IP.Prefix.from_string!()
      #IP.Prefix<192.0.2.0/24 DOCUMENTATION>

      iex> "192.0.2.1/255.255.255.0"
      ...> |> IP.Prefix.from_string!()
      #IP.Prefix<192.0.2.0/24 DOCUMENTATION>

      iex> "2001:db8::/64"
      ...> |> IP.Prefix.from_string!()
      #IP.Prefix<2001:db8::/64 DOCUMENTATION>
  """
  @spec from_string!(binary) :: t
  def from_string!(prefix) do
    case from_string(prefix) do
      {:ok, prefix} -> prefix
      {:error, msg} -> raise(InvalidPrefix, message: msg)
    end
  end

  @doc """
  Create a prefix by attempting to parse a string of specified IP version.

  ## Examples

      iex> "192.0.2.1/24"
      ...> |> IP.Prefix.from_string!(4)
      #IP.Prefix<192.0.2.0/24 DOCUMENTATION>

      iex> "192.0.2.1/255.255.255.0"
      ...> |> IP.Prefix.from_string!(4)
      #IP.Prefix<192.0.2.0/24 DOCUMENTATION>
  """
  @spec from_string!(binary, 4 | 6) :: t
  def from_string!(prefix, version) do
    case from_string(prefix, version) do
      {:ok, prefix} -> prefix
      {:error, msg} -> raise(InvalidPrefix, message: msg)
    end
  end

  @doc """
  Returns the bit-length of the prefix.

  ## Example

      iex> ~i(192.0.2.1/24)
      ...> |> IP.Prefix.length()
      24
  """
  @spec length(t) :: ipv4_prefix_length | ipv6_prefix_length
  def length(%Prefix{mask: mask}), do: calculate_length_from_mask(mask)

  @doc """
  Alter the bit-`length` of the `prefix`.

  ## Example

      iex> ~i(192.0.2.0/24)
      ...> |> IP.Prefix.length(25)
      #IP.Prefix<192.0.2.0/25 DOCUMENTATION>
  """
  @spec length(t, ipv4_prefix_length | ipv6_prefix_length) :: t
  def length(%Prefix{address: %Address{version: 4}} = prefix, length)
  when is_number(length) and length >= 0 and length <= 32
  do
    %{prefix | mask: calculate_mask_from_length(length, 32)}
  end

  def length(%Prefix{address: %Address{version: 6}} = prefix, length)
  when is_number(length) and length >= 0 and length <= 128
  do
    %{prefix | mask: calculate_mask_from_length(length, 128)}
  end

  @doc """
  Returns the calculated mask of the prefix.

  ## Example

      iex> ~i(192.0.2.1/24)
      ...> |> IP.Prefix.mask()
      0b11111111111111111111111100000000
  """
  @spec mask(t) :: non_neg_integer
  def mask(%Prefix{mask: mask}), do: mask

  @doc """
  Returns an old-fashioned subnet mask for IPv4 prefixes.

  ## Example

      iex> ~i(192.0.2.0/24)
      ...> |> IP.Prefix.subnet_mask()
      #IP.Address<255.255.255.0 RESERVED>
  """
  @spec subnet_mask(t) :: binary
  def subnet_mask(%Prefix{mask: mask, address: %Address{version: 4}}) do
    mask
    |> Address.from_integer!(4)
  end

  @doc """
  Returns an "cisco style" wildcard mask for IPv4 prefixes.

  ## Example

      iex> ~i(192.0.2.0/24)
      ...> |> IP.Prefix.wildcard_mask()
      #IP.Address<0.0.0.255 CURRENT NETWORK>
  """
  @spec wildcard_mask(t) :: binary
  def wildcard_mask(%Prefix{mask: mask, address: %Address{version: 4}}) do
    mask
    |> bnot()
    |> band(@ipv4_mask)
    |> Address.from_integer!(4)
  end

  @doc """
  Returns the first address in the prefix.

  ## Examples

      iex> ~i(192.0.2.128/24)
      ...> |> IP.Prefix.first()
      #IP.Address<192.0.2.0 DOCUMENTATION>

      iex> ~i(2001:db8::128/64)
      ...> |> IP.Prefix.first()
      #IP.Address<2001:db8:: DOCUMENTATION>
  """
  @spec first(t) :: Address.t
  def first(%Prefix{address: %Address{address: address, version: version}, mask: mask}) do
    Address.from_integer!(lowest_address(address, mask), version)
  end

  @doc """
  Returns the last address in the prefix.

  ## Examples

      iex> ~i(192.0.2.128/24)
      ...> |> IP.Prefix.last()
      #IP.Address<192.0.2.255 DOCUMENTATION>

      iex> ~i(2001:db8::128/64)
      ...> |> IP.Prefix.last()
      #IP.Address<2001:db8::ffff:ffff:ffff:ffff DOCUMENTATION>
  """
  def last(%Prefix{address: %Address{address: address, version: 4}, mask: mask}) do
    Address.from_integer!(highest_address(address, mask, 4), 4)
  end

  def last(%Prefix{address: %Address{address: address, version: 6}, mask: mask}) do
    Address.from_integer!(highest_address(address, mask, 6), 6)
  end

  @doc """
  Returns `true` or `false` depending on whether the supplied `address` is
  contained within `prefix`.

  ## Examples

      iex> ~i(192.0.2.0/24)
      ...> |> IP.Prefix.contains_address?(~i(192.0.2.127))
      true

      iex> ~i(192.0.2.0/24)
      ...> |> IP.Prefix.contains_address?(~i(198.51.100.1))
      false

      iex> ~i(2001:db8::/64)
      ...> |> IP.Prefix.contains_address?(~i(2001:db8::1))
      true

      iex> ~i(2001:db8::/64)
      ...> |> IP.Prefix.contains_address?(~i(2001:db8:1::1))
      false

      iex> outside = ~i(2001:db8::/64)
      ...> inside  = IP.Prefix.eui_64!(outside, "60:f8:1d:ad:d8:90")
      ...> IP.Prefix.contains_address?(outside, inside)
      true

  """
  def contains_address?(%Prefix{address: %Address{address: addr0, version: 4}, mask: mask} = _prefix,
                        %Address{address: addr1, version: 4} = _address)
  when lowest_address(addr0, mask) <= addr1
   and highest_address(addr0, mask, 4) >= addr1
  do
    true
  end

  def contains_address?(%Prefix{address: %Address{address: addr0, version: 6}, mask: mask} = _prefix,
                        %Address{address: addr1, version: 6} = _address)
  when lowest_address(addr0, mask) <= addr1
   and highest_address(addr0, mask, 6) >= addr1
  do
    true
  end

  def contains_address?(_prefix, _address), do: false

  @doc """
  Returns `true` or `false` depending on whether the supplied `inside` is
  completely contained by `outside`.

  ## Examples

      iex> outside = ~i(192.0.2.0/24)
      ...> inside  = ~i(192.0.2.128/25)
      ...> IP.Prefix.contains_prefix?(outside, inside)
      true

      iex> outside = ~i(192.0.2.128/25)
      ...> inside  = ~i(192.0.2.0/24)
      ...> IP.Prefix.contains_prefix?(outside, inside)
      false

      iex> outside = ~i(2001:db8::/64)
      ...> inside  = ~i(2001:db8::/128)
      ...> IP.Prefix.contains_prefix?(outside, inside)
      true

      iex> outside = ~i(2001:db8::/128)
      ...> inside  = ~i(2001:db8::/64)
      ...> IP.Prefix.contains_prefix?(outside, inside)
      false

  """
  @spec contains_prefix?(t, t) :: true | false
  def contains_prefix?(%Prefix{address: %Address{address: oaddr, version: 4}, mask: omask} = _outside,
                       %Prefix{address: %Address{address: iaddr, version: 4}, mask: imask} = _inside)
  when lowest_address(oaddr, omask) <= lowest_address(iaddr, imask)
   and highest_address(oaddr, omask, 4) >= highest_address(iaddr, imask, 4)
  do
    true
  end

  def contains_prefix?(%Prefix{address: %Address{address: oaddr, version: 6}, mask: omask} = _outside,
                       %Prefix{address: %Address{address: iaddr, version: 6}, mask: imask} = _inside)
  when lowest_address(oaddr, omask) <= lowest_address(iaddr, imask)
   and highest_address(oaddr, omask, 6) >= highest_address(iaddr, imask, 6)
  do
    true
  end

  def contains_prefix?(_outside, _inside), do: false

  @doc """
  Generate an EUI-64 host address within the specifed IPv6 `prefix`.

  EUI-64 addresses can only be generated for 64 bit long IPv6 prefixes.

  ## Examples

      iex> ~i(2001:db8::/64)
      ...> |> IP.Prefix.eui_64("60:f8:1d:ad:d8:90")
      ...> |> inspect()
      "{:ok, #IP.Address<2001:db8::62f8:1dff:fead:d890 DOCUMENTATION>}"
  """
  @spec eui_64(t, binary) :: Address.t
  def eui_64(%Prefix{address: %Address{version: 6},
                     mask: 0xffffffffffffffff0000000000000000} = prefix, mac)
  do
    with {:ok, eui_portion} <- EUI64.eui_portion(mac),
         address            <- Prefix.first(prefix),
         address            <- Address.to_integer(address),
         address            <- address + eui_portion,
         {:ok, address}     <- Address.from_integer(address, 6)
    do
      {:ok, address}
    end
  end

  @doc """
  Generate an EUI-64 host address within the specifed IPv6 `prefix`.

  EUI-64 addresses can only be generated for 64 bit long IPv6 prefixes.

  ## Examples

      iex> ~i(2001:db8::/64)
      ...> |> IP.Prefix.eui_64!("60:f8:1d:ad:d8:90")
      #IP.Address<2001:db8::62f8:1dff:fead:d890 DOCUMENTATION>
  """
  @spec eui_64!(t, binary) :: Address.t
  def eui_64!(prefix, mac) do
    case eui_64(prefix, mac) do
      {:ok, address} -> address
      {:error, msg} -> raise(InvalidPrefix, msg)
    end
  end

  @doc """
  Return the address space within this address.

  ## Examples

      iex> ~i(192.0.2.0/24)
      ...> |> IP.Prefix.space()
      256

      iex> ~i(2001:db8::/64)
      ...> |> IP.Prefix.space()
      18446744073709551616
  """
  @spec space(t) :: non_neg_integer
  def space(%Prefix{address: %Address{address: address, version: 4}, mask: mask}) do
    first = address &&& mask
    last  = first + (~~~mask &&& @ipv4_mask)
    last - first + 1
  end

  def space(%Prefix{address: %Address{address: address, version: 6}, mask: mask}) do
    first = address &&& mask
    last  = first + (~~~mask &&& @ipv6_mask)
    last - first + 1
  end

  @doc """
  Return the usable IP address space within this address.

  ## Examples

      iex> ~i(192.0.2.0/24)
      ...> |> IP.Prefix.usable()
      254

      iex> ~i(2001:db8::/64)
      ...> |> IP.Prefix.usable()
      18446744073709551616
  """
  @spec usable(t) :: non_neg_integer
  def usable(%Prefix{address: %Address{version: 4}} = prefix) do
    space = prefix
      |> Prefix.space()
    space - 2
  end

  def usable(%Prefix{address: %Address{version: 6}} = prefix) do
    Prefix.space(prefix)
  end
end
