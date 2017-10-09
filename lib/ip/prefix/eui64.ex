defmodule IP.Prefix.EUI64 do
  use Bitwise

  @moduledoc """
  Handles functions related to EUI64 addresses.
  """

  @doc """
  Parse a mac address into an integer.

  ## Examples

      iex> "60:f8:1d:ad:d8:90"
      ...> |> IP.Prefix.EUI64.eui_portion()
      {:ok, 7131482995267852432}
  """
  @spec eui_portion(binary) :: {:ok, non_neg_integer} | {:error, term}
  def eui_portion(mac) do
    with {:ok, mac}        <- remove_non_digits(mac),
         {:ok, mac}        <- hex_to_int(mac),
         {:ok, head, tail} <- split_mac(mac),
         {:ok, eui}        <- generate_eui(head, tail)
    do
      {:ok, eui}
    else
      {:error, _} = e -> e
    end
  end

  defp remove_non_digits(mac) do
    {:ok, Regex.replace(~r/[^0-9a-f]/i, mac, "")}
  end

  defp split_mac(mac) when is_integer(mac) and mac >= 0 and mac <= 0xffffffffffff do
    head = mac >>> 24
    tail = mac &&& 0xffffff
    {:ok, head, tail}
  end

  def generate_eui(head, tail) do
    address = (head <<< 40) + (0xfffe <<< 24) + tail
    address = address ^^^ 0x0200000000000000
    {:ok, address}
  end

  def hex_to_int(mac) do
    {:ok, String.to_integer(mac, 16)}
  rescue
    ArgumentError -> {:error, "Unable to parse MAC address"}
  end
end
