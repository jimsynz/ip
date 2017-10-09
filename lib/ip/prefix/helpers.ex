defmodule IP.Prefix.Helpers do
  use Bitwise

  @moduledoc false

  @doc false
  def calculate_mask_from_length(length, mask_length) do
    pad = mask_length - length
    0..(length - 1)
    |> Enum.reduce(0, fn (i, mask) -> mask + (1 <<< i + pad) end)
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
end
