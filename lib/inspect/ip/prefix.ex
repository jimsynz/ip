defimpl Inspect, for: IP.Prefix do
  alias IP.Prefix
  import Inspect.Algebra

  @moduledoc """
  Implement the `Inspect` protocol for `IP.Prefix`
  """

  @doc """
  Inspect a `prefix`.

  ## Examples

      iex> IP.Address.from_string!("192.0.2.1", 4)
      ...> |> IP.Address.to_prefix(32)
      #IP.Prefix<192.0.2.1/32>
  """
  @spec inspect(Prefix.t, list) :: binary
  def inspect(%Prefix{} = prefix, _opts) do
    concat ["#IP.Prefix<#{prefix}>"]
  end
end
