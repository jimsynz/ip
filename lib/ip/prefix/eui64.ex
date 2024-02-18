defmodule IP.Prefix.EUI64 do
  import Bitwise

  @moduledoc false

  @doc """
  Parse a mac address into an integer.

  ## Examples

      iex> "60:f8:1d:ad:d8:90"
      ...> |> IP.Prefix.EUI64.eui_portion()
      {:ok, 7131482995267852432}
  """
  @spec eui_portion(binary) :: {:ok, non_neg_integer} | {:error, term}
  def eui_portion(mac) do
    with {:ok, mac} <- remove_non_digits(mac),
         {:ok, mac} <- hex_to_int(mac),
         {:ok, head, tail} <- split_mac(mac),
         {:ok, eui} <- generate_eui(head, tail) do
      {:ok, eui}
    else
      {:error, _} = e -> e
    end
  end

  defp remove_non_digits(mac) do
    {:ok, Regex.replace(~r/[^0-9a-f]/i, mac, "")}
  end

  defp split_mac(mac) when is_integer(mac) and mac >= 0 and mac <= 0xFFFFFFFFFFFF do
    head = mac >>> 24
    tail = mac &&& 0xFFFFFF
    {:ok, head, tail}
  end

  defp generate_eui(head, tail) do
    address = (head <<< 40) + (0xFFFE <<< 24) + tail
    address = Bitwise.bxor(address, 0x0200000000000000)
    {:ok, address}
  end

  defp hex_to_int(mac) do
    {:ok, String.to_integer(mac, 16)}
  rescue
    ArgumentError -> {:error, "Unable to parse MAC address"}
  end
end
