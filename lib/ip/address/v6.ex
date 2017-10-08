defmodule IP.Address.V6 do
  use Bitwise

  @moduledoc """
  Helper module for working with IPv6 address strings.
  """

  @doc """
  Expand a compressed address.

  ## Examples

      iex> "2001:db8::1"
      ...> |> IP.Address.V6.expand()
      "2001:0db8:0000:0000:0000:0000:0000:0001"

      iex> "2001:0db8:0000:0000:0000:0000:0000:0001"
      ...> |> IP.Address.V6.expand()
      "2001:0db8:0000:0000:0000:0000:0000:0001"
  """
  @spec expand(binary) :: {:ok, binary} | {:error, term}
  def expand(address) do
    address
    |> expand_to_ints()
    |> Enum.map(fn (i) ->
      i
      |> Integer.to_string(16)
      |> String.pad_leading(4, "0")
    end)
    |> Enum.join(":")
    |> String.downcase()
  end

  @doc """
  Compress an IPv6 address

  ## Examples

      iex> "2001:0db8:0000:0000:0000:0000:0000:0001"
      ...> |> IP.Address.V6.compress()
      "2001:db8::1"

      iex> "2001:db8::1"
      ...> |> IP.Address.V6.compress()
      "2001:db8::1"
  """
  @spec compress(binary) :: binary
  def compress(address) do
    address = address
      |> expand_to_ints()
      |> Enum.map(&Integer.to_string(&1, 16))
      |> Enum.join(":")
      |> String.downcase()
    Regex.replace(~r/\b(?:0+:){2,}/, address, ":")
  end

  @doc """
  Convert an IPv6 into a 128 bit integer

  ## Examples

      iex> "2001:0db8:0000:0000:0000:0000:0000:0001"
      ...> |> IP.Address.V6.to_integer()
      42540766411282592856903984951653826561

      iex> "2001:db8::1"
      ...> |> IP.Address.V6.to_integer()
      42540766411282592856903984951653826561
  """
  def to_integer(address) do
    address
    |> expand_to_ints()
    |> reduce_ints(0)
  end

  defp reduce_ints([], addr), do: addr
  defp reduce_ints([next | remaining] = all, addr) do
    left_shift_size = (length(all) - 1) * 16
    addr = addr + (next <<< left_shift_size)
    reduce_ints(remaining, addr)
  end

  defp expand_to_ints(address) do
    case String.split(address, "::") do
      [head, tail] ->
        head = decolonify(head)
        tail = decolonify(tail)
        pad(head, tail)
      [head] -> decolonify(head)
    end
  end

  defp decolonify(chunk) do
    chunk
    |> String.split(":")
    |> Enum.map(&String.to_integer(&1, 16))
  end

  defp pad(head, []) when length(head) == 8, do: head
  defp pad([], tail) when length(tail) == 8, do: tail
  defp pad(head, tail) when length(head) + length(tail) < 8 do
    head_len = length(head)
    tail_len = length(head)
    pad_len  = 8 - (head_len + tail_len)
    pad      = Enum.map(0..pad_len, fn (_) -> 0 end)
    head ++ pad ++ tail
  end
end
