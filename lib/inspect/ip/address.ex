defimpl Inspect, for: IP.Address do
  alias IP.{Address, Scope}
  import Inspect.Algebra

  @moduledoc """
  Implement the `Inspect` protocol for `IP.Address`
  """

  @doc """
  Inspect an `address`.

  ## Examples

      iex> ~i(192.0.2.1)
      #IP.Address<192.0.2.1 Documentation (TEST-NET-1), GLOBAL, RESERVED>

      iex> ~i(2001:db8::1)
      #IP.Address<2001:db8::1 Documentation, GLOBAL, RESERVED>
  """
  @spec inspect(Address.t(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def inspect(address, _opts) do
    scope = Scope.address_scope(address)
    concat(["#IP.Address<#{address} #{scope}>"])
  end
end
