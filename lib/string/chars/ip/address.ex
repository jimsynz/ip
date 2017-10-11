defimpl String.Chars, for: IP.Address do
  @moduledoc """
  Allow IP Addresses to be converted into strings.
  """

  @doc ~S"""
  Convert an `address` into a string representation.

  ## Examples

      iex> "#{~i(192.0.2.1)}"
      "192.0.2.1"

      iex> "#{~i(2001:db8::1)}"
      "2001:db8::1"
  """
  def to_string(address), do: IP.Address.to_string(address)
end
