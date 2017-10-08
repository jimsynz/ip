defimpl Inspect, for: IP.Address do
  @moduledoc """
  Implement the `Inspect` protocol for `IP.Address`
  """
  alias IP.Address
  import Inspect.Algebra

  @doc """
  Inpect an `address`.

  # Examples

      iex> IP.Address.from_string!("192.0.2.1", 4)
      #IP.Address<192.0.2.1>

      iex> IP.Address.from_string!("2001:db8::1", 6)
      #IP.Address<2001:db8::1>
  """
  @spec inspect(Address.t, list) :: binary
  def inspect(address, _opts) do
    concat ["#IP.Address<#{address}>"]
  end
end
