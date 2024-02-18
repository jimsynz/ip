defimpl Inspect, for: IP.Prefix do
  alias IP.{Prefix, Scope}
  import Inspect.Algebra

  @moduledoc """
  Implement the `Inspect` protocol for `IP.Prefix`
  """

  @doc """
  Inspect a `prefix`.

  ## Examples

      iex> ~i(192.0.2.1)
      ...> |> IP.Address.to_prefix(32)
      #IP.Prefix<192.0.2.1/32 DOCUMENTATION>
  """
  @spec inspect(Prefix.t(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def inspect(%Prefix{} = prefix, _opts) do
    scope = Scope.prefix_scope(prefix)
    concat(["#IP.Prefix<#{prefix} #{scope}>"])
  end
end
