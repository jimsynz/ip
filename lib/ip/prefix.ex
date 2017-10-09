defmodule IP.Prefix do
  alias IP.{Prefix, Address}
  defstruct ~w(address mask)a
  use Bitwise

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

      iex> IP.Prefix.new(IP.Address.from_string!("192.0.2.1"), 24)
      #IP.Prefix<192.0.2.0/24>

      iex> IP.Prefix.new(IP.Address.from_string!("2001:db8::1"), 64)
      #IP.Prefix<2001:db8::/64>
  """
  @spec new(Address.t, ipv4_prefix_length | ipv6_prefix_length) :: t
  def new(%Address{address: address, version: 4}, length) when length > 0 and length <= 32 do
    mask = calculate_mask_from_length(length, 32)
    %Prefix{address: Address.from_integer!(address &&& mask, 4), mask: mask}
  end

  def new(%Address{address: address, version: 6}, length) when length > 0 and length <= 128 do
    mask = calculate_mask_from_length(length, 128)
    %Prefix{address: Address.from_integer!(address &&& mask, 6), mask: mask}
  end

  @doc """
  Returns the bit-length of the prefix.

  ## Example

      iex> IP.Address.from_string!("192.0.2.1")
      ...> |> IP.Address.to_prefix(24)
      ...> |> IP.Prefix.length()
      24
  """
  @spec length(t) :: ipv4_prefix_length | ipv6_prefix_length
  def length(%Prefix{mask: mask}), do: calculate_length_from_mask(mask)

  @doc """
  Returns the calculated mask of the prefix.

  ## Example

      iex> IP.Address.from_string!("192.0.2.1")
      ...> |> IP.Address.to_prefix(24)
      ...> |> IP.Prefix.mask()
      0b11111111111111111111111100000000
  """
  @spec mask(t) :: non_neg_integer
  def mask(%Prefix{mask: mask}), do: mask

  @doc """
  Returns the first address in the prefix.

  ## Examples

      iex> IP.Address.from_string!("192.0.2.128")
      ...> |> IP.Address.to_prefix(24)
      ...> |> IP.Prefix.first()
      #IP.Address<192.0.2.0>

      iex> IP.Address.from_string!("2001:db8::128")
      ...> |> IP.Address.to_prefix(64)
      ...> |> IP.Prefix.first()
      #IP.Address<2001:db8::>
  """
  @spec first(t) :: Address.t
  def first(%Prefix{address: %Address{address: address, version: version}, mask: mask}) do
    Address.from_integer!(address &&& mask, version)
  end

  @doc """
  Returns the last address in the prefix.

  ## Examples

      iex> IP.Address.from_string!("192.0.2.128")
      ...> |> IP.Address.to_prefix(24)
      ...> |> IP.Prefix.last()
      #IP.Address<192.0.2.255>

      iex> IP.Address.from_string!("2001:db8::128")
      ...> |> IP.Address.to_prefix(64)
      ...> |> IP.Prefix.last()
      #IP.Address<2001:db8::ffff:ffff:ffff:ffff>
  """
  def last(%Prefix{address: %Address{address: address, version: 4}, mask: mask}) do
    Address.from_integer!((address &&& mask) + (~~~mask &&& @ipv4_mask), 4)
  end

  def last(%Prefix{address: %Address{address: address, version: 6}, mask: mask}) do
    address = (address &&& mask) + (~~~mask &&& @ipv6_mask)
    Address.from_integer!(address, 6)
  end

  def contains?(%Prefix{address: %Address{address: addr0, version: 4}, mask: mask}, %Address{address: addr1, version: 4})
  when (addr0 &&& mask) <= addr1
   and ((addr0 &&& mask) + (~~~(mask) &&& @ipv4_mask)) >= addr1
  do
    true
  end

  def contains?(%Prefix{address: %Address{address: addr0, version: 6}, mask: mask},
                %Address{address: addr1, version: 6})
  when (addr0 &&& mask) <= addr1
   and ((addr0 &&& mask) + (~~~(mask) &&& @ipv6_mask)) >= addr1
  do
    true
  end

  def contains?(_prefix, _address), do: false

  defp calculate_mask_from_length(length, mask_length) do
    pad = mask_length - length
    0..(length - 1)
    |> Enum.reduce(0, fn (i, mask) -> mask + (1 <<< i + pad) end)
  end

  defp calculate_length_from_mask(mask) do
    mask
    |> Integer.digits(2)
    |> Stream.filter(fn
      1 -> true
      0 -> false
    end)
    |> Enum.count()
  end
end
