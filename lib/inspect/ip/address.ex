defimpl Inspect, for: IP.Address do
  alias IP.{Address, Scope}
  import Inspect.Algebra

  @moduledoc """
  Implement the `Inspect` protocol for `IP.Address`
  """

  @doc """
  Inpect an `address`.

  ## Examples

      iex> IP.Address.from_string!("192.0.2.1", 4)
      #IP.Address<192.0.2.1 DOCUMENTATION>

      iex> IP.Address.from_string!("2001:db8::1", 6)
      #IP.Address<2001:db8::1 DOCUMENTATION>
  """
  @spec inspect(Address.t, list) :: binary
  def inspect(address, _opts) do
    scope = Scope.address_scope(address)
    concat ["#IP.Address<#{address} #{scope}>"]
  end
end
