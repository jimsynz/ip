defmodule IP.Prefix.Parser do
  alias IP.{Address, Prefix}
  import Bitwise
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
      "{:ok, #IP.Prefix<192.0.2.0/25 Documentation (TEST-NET-1), GLOBAL, RESERVED>}"

      iex> "2001:db8::/64"
      ...> |> IP.Prefix.Parser.parse()
      ...> |> inspect()
      "{:ok, #IP.Prefix<2001:db8::/64 Documentation, GLOBAL, RESERVED>}"
  """
  @spec parse(binary) :: {:ok, Prefix.t()} | {:error, term}
  def parse(prefix) do
    case parse(prefix, 4) do
      {:ok, prefix} ->
        {:ok, prefix}

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
      "{:ok, #IP.Prefix<192.0.2.0/25 Documentation (TEST-NET-1), GLOBAL, RESERVED>}"

      iex> "2001:db8::/64"
      ...> |> IP.Prefix.Parser.parse(6)
      ...> |> inspect()
      "{:ok, #IP.Prefix<2001:db8::/64 Documentation, GLOBAL, RESERVED>}"
  """
  @spec parse(binary, Address.version()) :: {:ok, Prefix.t()} | {:error, term}
  def parse(prefix, 4 = _version) do
    with {:ok, address, mask} <- ensure_contains_slash(prefix),
         {:ok, address} <- Address.from_string(address, 4),
         {:ok, mask} <- parse_v4_mask(mask) do
      {:ok, Prefix.new(address, mask)}
    else
      _ -> {:error, "Error parsing IPv4 prefix"}
    end
  end

  def parse(prefix, 6 = _version) do
    with {:ok, address, mask} <- ensure_contains_slash(prefix),
         {:ok, address} <- Address.from_string(address, 6),
         {:ok, mask} <- parse_v6_mask(mask) do
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

  defguardp is_int_to(i, high) when is_integer(i) and i >= 0 and i <= high

  defp parse_v4_mask(mask) do
    mask
    |> String.split(".")
    |> Enum.map(&String.to_integer/1)
    |> case do
      [length] when is_int_to(length, 32) ->
        {:ok, length}

      [255, 255, 255, quad] when is_int_to(quad, 255) ->
        {:ok, calculate_length_from_mask(4_294_967_040 + quad)}

      [255, 255, quad, 0] when is_int_to(quad, 255) ->
        {:ok, calculate_length_from_mask(4_294_901_760 + (quad <<< 8))}

      [255, quad, 0, 0] when is_int_to(quad, 255) ->
        {:ok, calculate_length_from_mask(4_278_190_080 + (quad <<< 16))}

      [quad, 0, 0, 0] when is_int_to(quad, 255) ->
        {:ok, calculate_length_from_mask(quad <<< 24)}

      _ ->
        {:error, "Unable to parse IPv4 mask"}
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
