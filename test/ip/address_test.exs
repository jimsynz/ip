defmodule IPAddressTest do
  use ExUnit.Case
  import IP.Sigil
  doctest IP.Address, except: [generate_ula: 3]
end
