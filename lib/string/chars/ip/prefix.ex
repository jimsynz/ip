defimpl String.Chars, for: IP.Prefix do
  alias IP.Prefix
  @moduledoc """
  Implements `String.Chars` for `IP.Prefix`.
  """

  @doc ~S"""
  Convert a `prefix` into a string representation.

  ## Examples

      iex> address = IP.Address.from_string!("192.0.2.1", 4)
      ...> prefix = IP.Prefix.new(address, 32)
      ...> "#{prefix}"
      "192.0.2.1/32"
  """
  def to_string(%Prefix{address: address} = prefix) do
    length = Prefix.length(prefix)
    "#{address}/#{length}"
  end
end
