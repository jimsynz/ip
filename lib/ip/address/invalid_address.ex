defmodule IP.Address.InvalidAddress do
  defexception ~w(message)a

  @moduledoc """
  An exception raised by the bang-version functions in `IP.Address` when the
  supplied value is invalid.
  """
end
