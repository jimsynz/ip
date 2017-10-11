# IP

[![pipeline status](https://gitlab.com/jimsy/ip/badges/master/pipeline.svg)](https://gitlab.com/jimsy/ip/commits/master)
[![Hex.pm](https://img.shields.io/hexpm/v/ip.svg)](https://hex.pm/packages/ip)

IP, IP, Ooray! Simple IP Address representations.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ip` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ip, "~> 0.1.0"}
  ]
end
```

## Usage

`ip` provides representations for IP addresses and subnets for Elixir with a bunch of helpful stuff tacked on the side.

    iex> "192.0.2.1"
    ...> |> IP.Address.from_string!
    #IP.Address<192.0.2.1 DOCUMENTATION>

    iex> "2001:db8::"
    ...> |> IP.Address.from_string!
    #IP.Address<2001:db8:: DOCUMENTATION>

    iex> outside = IP.Prefix.from_string!("2001:db8::/64")
    ...> inside  = IP.Prefix.eui_64!(outside, "60:f8:1d:ad:d8:90")
    ...> IP.Prefix.contains_address?(outside, inside)
    true

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ip](https://hexdocs.pm/ip).

