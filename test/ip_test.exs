defmodule IPTest do
  use ExUnit.Case
  doctest IP

  test "greets the world" do
    assert IP.hello() == :world
  end
end
