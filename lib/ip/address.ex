defmodule IP.Address do
  alias __MODULE__
  alias IP.Address.{InvalidAddress, V6, Helpers}
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
    address = address
      |> String.split(".")
      |> Enum.map(&String.to_integer(&1))
      |> from_bytes()

    {:ok, %Address{version: 4, address: address}}
  end

  def from_string(address, 6) when is_binary(address) do
    address = address
      |> V6.to_integer()
      {:ok, %Address{version: 6, address: address}}
  end

  def from_string(_address, 4), do: {:error, "Cannot parse IPv4 address"}
  def from_string(_address, 6), do: {:error, "Cannot parse IPv6 address"}
  def from_string(_address, version), do: {:error, "No such IP version #{inspect version}"}

  @doc """
  Convert a string representation into an IP address of specified versionor raise an
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

  defp from_bytes([a, b, c, d]) do
    (a <<< 24) + (b <<< 16) + (c <<< 8) + d
  end
end
