defmodule IP.Prefix do
  alias IP.{Prefix, Address}
  defstruct ~w(address length)a

  @moduledoc """
  Defines an IP prefix, otherwise known as a subnet.
  """

  @type t :: %Prefix{}
  @type ipv4_prefix_length :: 0..32
  @type ipv6_prefix_length :: 0..128

  @doc """
  Create an IP prefix from an `IP.Address` and `length`.

  ## Examples

      iex> IP.Prefix.new(IP.Address.from_string!("192.0.2.1", 4), 32)
      %IP.Prefix{address: %IP.Address{address: 3221225985, version: 4}, length: 32}

      iex> IP.Prefix.new(IP.Address.from_string!("2001:db8::1", 6), 128)
      %IP.Prefix{address: %IP.Address{address: 42540766411282592856903984951653826561, version: 6}, length: 128}
  """
  @spec new(Address.t, ipv4_prefix_length | ipv6_prefix_length) :: t
  def new(%Address{version: 4} = address, length) when length > 0 and length <= 32 do
    %Prefix{address: address, length: length}
  end

  def new(%Address{version: 6} = address, length) when length > 0 and length <= 128 do
    %Prefix{address: address, length: length}
  end
end
