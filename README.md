# IP

[![pipeline status](https://gitlab.com/jimsy/ip/badges/main/pipeline.svg)](https://gitlab.com/jimsy/ip/commits/main)
[![Hex.pm](https://img.shields.io/hexpm/v/ip.svg)](https://hex.pm/packages/ip)
[![Hippocratic License HL3-FULL](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-FULL&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/full.html)

IP, IP, Ooray! Simple IP Address representations.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ip` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ip, "~> 2.0.0"}
  ]
end
```

## Usage

`ip` provides representations for IP addresses and subnets for Elixir with a bunch of helpful stuff tacked on the side.

    iex> ~i(192.0.2.1)
    #IP.Address<192.0.2.1 DOCUMENTATION>

    iex> ~i(2001:db8::)
    #IP.Address<2001:db8:: DOCUMENTATION>

    iex> outside = ~i(2001:db8::/64)
    ...> inside  = IP.Prefix.eui_64!(outside, "60:f8:1d:ad:d8:90")
    ...> IP.Prefix.contains_address?(outside, inside)
    true

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ip](https://hexdocs.pm/ip).

## License

This software is licensed under the terms of the
[HL3-FULL](https://firstdonoharm.dev), see the `LICENSE.md` file included with
this package for the terms.

This license actively proscribes this software being used by and for some
industries, countries and activities.  If your usage of this software doesn't
comply with the terms of this license, then [contact me](mailto:james@harton.nz)
with the details of your use-case to organise the purchase of a license - the
cost of which may include a donation to a suitable charity or NGO.
