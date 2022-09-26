defmodule IP.Prefix.Helpers do
  import Bitwise

  @moduledoc false

  @doc false
  def calculate_mask_from_length(length, mask_length) do
    pad = mask_length - length - 1
    mask = n_times_reduce(length, 0, fn i, mask -> mask + (1 <<< i) end)
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

  defmacro lowest_address(addr, mask) do
    quote do
      unquote(addr) &&& unquote(mask)
    end
  end

  defmacro highest_address(addr, mask, 4) do
    quote do
      (unquote(addr) &&& unquote(mask)) + (bnot(unquote(mask)) &&& 0xFFFFFFFF)
    end
  end

  defmacro highest_address(addr, mask, 6) do
    quote do
      (unquote(addr) &&& unquote(mask)) +
        (bnot(unquote(mask)) &&& 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
    end
  end
end
