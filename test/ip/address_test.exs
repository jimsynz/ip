defmodule IPAddressTest do
  use ExUnit.Case
  doctest IP.Address, except: [generate_ula: 3]
end
