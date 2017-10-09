defmodule IP.Prefix.InvalidPrefix do
  defexception ~w(message)a

  @moduledoc """
  An exception raised by the bang-version functions in `IP.Prefix` when the
  supplied value is invalid.
  """
end
