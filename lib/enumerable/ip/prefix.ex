defimpl Enumerable, for: IP.Prefix do
  alias IP.{Prefix, Address}

  @moduledoc """
  Implements `Enumerable` for `IP.Prefix`, allowing consumers to iterate
  through all addresses in a prefix.
  """

  @doc """
  Returns the number of addresses within the `prefix`.

  ## Examples

      iex> ~i(192.0.2.128/25)
      ...> |> Enum.count()
      128

      iex> ~i(2001:db8::/121)
      ...> |> Enum.count()
      128
  """
  @spec count(Prefix.t()) :: {:ok, non_neg_integer} | {:error, module}
  def count(prefix), do: {:ok, Prefix.space(prefix)}

  @doc """
  Returns whether an `address` is contained by the `prefix`.

  ## Examples

      iex> ~i(192.0.2.128/25)
      ...> |> Enum.member?(~i(192.0.2.250))
      true
  """
  @spec member?(Prefix.t(), Address.t()) :: {:ok, boolean} | {:error, module}
  def member?(prefix, %Address{} = address), do: {:ok, Prefix.contains_address?(prefix, address)}

  @doc """
  Allows the reduction of `prefix` into a colection of addresses.

  ## Examples

      iex> ~i(192.0.2.128/29)
      ...> |> Stream.filter(fn a -> rem(IP.Address.to_integer(a), 2) == 0 end)
      ...> |> Enum.map(fn a -> IP.Address.to_string(a) end)
      ["192.0.2.128", "192.0.2.130", "192.0.2.132", "192.0.2.134"]
  """
  @spec reduce(Prefix.t(), Enumerable.acc(), Enumerable.reducer()) :: Enumerable.result()

  def reduce(%Prefix{} = prefix, {:cont, acc}, fun) do
    first =
      prefix
      |> Prefix.first()
      |> Address.to_integer()

    last =
      prefix
      |> Prefix.last()
      |> Address.to_integer()

    do_reduce({prefix, first, last}, {:cont, acc}, fun)
  end

  defp do_reduce(_, {:halt, acc}, _fun), do: {:halted, acc}

  defp do_reduce({prefix, pos, last}, {:suspend, acc}, fun),
    do: {:suspended, acc, &do_reduce({prefix, pos, last}, &1, fun)}

  defp do_reduce(
         {%Prefix{address: %Address{version: version}} = prefix, pos, last},
         {:cont, acc},
         fun
       ) do
    case pos do
      ^last ->
        {:done, acc}

      pos ->
        next = Address.from_integer!(pos, version)
        do_reduce({prefix, pos + 1, last}, fun.(next, acc), fun)
    end
  end

  def slice(_), do: {:error, __MODULE__}
end
