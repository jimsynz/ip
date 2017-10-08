defmodule IP.Address.Helpers do
  @moduledoc """
  Helpful macros related to IP addresses.
  """

  @doc """
  Guard clause macro for "between 0 and 0xffffffff"
  """
  defmacro valid_ipv4_integer?(n) do
    quote do
      is_integer(unquote(n)) and unquote(n) >= 0 and unquote(n) <= 0xffffffff
    end
  end

  @doc """
  Guard clause macro for "between 0 and 0xffffffffffffffffffffffffffffffff"
  """
  defmacro valid_ipv6_integer?(n) do
    quote do
      is_integer(unquote(n))
      and unquote(n) >= 0
      and unquote(n) <= 0xffffffffffffffffffffffffffffffff
    end
  end

  @doc """
  Guard clause macro for "4 or 6"
  """
  defmacro valid_ip_version?(4), do: quote do: true
  defmacro valid_ip_version?(6), do: quote do: true
  defmacro valid_ip_version?(_), do: quote do: false

  @doc """
  Guard clause macro for "between 0 and 0xff"
  """
  defmacro valid_byte?(n) do
    quote do
      is_integer(unquote(n)) and unquote(n) >= 0 and unquote(n) <= 0xff
    end
  end
end
