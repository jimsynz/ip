defmodule IP.Prefix.Helpers do
  use Bitwise

  @moduledoc false

  @doc false
  def calculate_mask_from_length(length, mask_length) do
    pad  = mask_length - length - 1
    mask = n_times_reduce(length, 0, fn (i, mask) -> mask + (1 <<< i) end)
    mask <<< pad
  end

  @doc false
  def calculate_length_from_mask(mask) do
    mask
    |> Integer.digits(2)
    |> Stream.filter(fn
      1 -> true
      0 -> false
    end)
    |> Enum.count()
  end

  defp n_times_reduce(0, acc, _fun), do: acc
  defp n_times_reduce(n, acc, fun) do
    acc = fun.(n, acc)
    n_times_reduce(n - 1, acc, fun)
  end
end
