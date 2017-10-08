defimpl String.Chars, for: IP.Address do
  @moduledoc """
  Allow IP Addresses to be converted into strings.
  """

  @doc ~S"""
  Convert an `address` into a string representation.

  ## Examples

      iex> "#{IP.Address.from_string!("192.0.2.1", 4)}"
      "192.0.2.1"

      iex> "#{IP.Address.from_string!("2001:db8::1", 6)}"
      "2001:db8::1"
  """
  def to_string(address), do: IP.Address.to_string(address)
end
