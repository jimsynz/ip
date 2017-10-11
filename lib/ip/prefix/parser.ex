defmodule IP.Prefix.Parser do
  alias IP.{Prefix, Address}
  import IP.Prefix.Helpers

  @moduledoc false

  @doc """
  Attempts to parse a `prefix` of unknown IP version.

  This attempts to parse as IPv4 and then as IPv6. Obviously it's slower
  than parsing a specific version if you know that at call time.

  ## Examples

      iex> "192.0.2.1/25"
      ...> |> IP.Prefix.Parser.parse()
      ...> |> inspect()
      "{:ok, #IP.Prefix<192.0.2.0/25 DOCUMENTATION>}"

      iex> "2001:db8::/64"
      ...> |> IP.Prefix.Parser.parse()
      ...> |> inspect()
      "{:ok, #IP.Prefix<2001:db8::/64 DOCUMENTATION>}"
  """
  @spec parse(binary) :: Prefix.t
  def parse(prefix) do
    case parse(prefix, 4) do
      {:ok, prefix} -> {:ok, prefix}
      _ ->
        case parse(prefix, 6) do
          {:ok, prefix} -> {:ok, prefix}
          _ -> {:error, "Unable to parse IP prefix"}
        end
    end
  end

  @doc """
  Attempts to parse a `prefix` of a specific IP `version` from a string.

  ## Examples

      iex> "192.0.2.1/25"
      ...> |> IP.Prefix.Parser.parse(4)
      ...> |> inspect()
      "{:ok, #IP.Prefix<192.0.2.0/25 DOCUMENTATION>}"

      iex> "2001:db8::/64"
      ...> |> IP.Prefix.Parser.parse(6)
      ...> |> inspect()
      "{:ok, #IP.Prefix<2001:db8::/64 DOCUMENTATION>}"
  """
  @spec parse(binary, 4 | 6) :: Prefix.t
  def parse(prefix, 4 = _version) do
    with {:ok, address, mask} <- ensure_contains_slash(prefix),
         {:ok, address}       <- Address.from_string(address, 4),
         {:ok, mask}          <- parse_v4_mask(mask)
    do
      {:ok, Prefix.new(address, mask)}
    else
      _ -> {:error, "Error parsing IPv4 prefix"}
    end
  end

  def parse(prefix, 6 = _version) do
    with {:ok, address, mask} <- ensure_contains_slash(prefix),
         {:ok, address}       <- Address.from_string(address, 6),
         {:ok, mask}          <- parse_v6_mask(mask)
    do
      {:ok, Prefix.new(address, mask)}
    else
      _ -> {:error, "Error parsing IPv6 prefix"}
    end
  end

  defp ensure_contains_slash(prefix) do
    case String.split(prefix, "/") do
      [address, mask] -> {:ok, address, mask}
      _ -> {:error, "Missing \"/\" in IP prefix"}
    end
  end

  defp parse_v4_mask(mask) do
    case Address.from_string(mask, 4) do
      {:ok, address} ->
        mask = address
        |> Address.to_integer()
        |> calculate_length_from_mask()
        {:ok, mask}
      _ ->
        {:ok, String.to_integer(mask)}
    end
  rescue
    ArgumentError -> {:error, "Unable to parse IPv4 mask"}
  end

  defp parse_v6_mask(mask) do
    {:ok, String.to_integer(mask)}
  rescue
    ArgumentError -> {:error, "Unable to parse IPv6 mask"}
  end
end
