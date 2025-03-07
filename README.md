# IP

[![Build Status](https://drone.harton.dev/api/badges/james/ip/status.svg)](https://drone.harton.dev/james/ip)
[![Hex.pm](https://img.shields.io/hexpm/v/ip.svg)](https://hex.pm/packages/ip)
[![Hippocratic License HL3-FULL](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-FULL&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/full.html)

IP, IP, Ooray! Simple IP Address representations.

## Installation

IP is available on [Hex](https://hex.pm/packages/ip) the package can be
installed by adding `ip` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ip, "~> 2.0.3"}
  ]
end
```

## Documentation

Documentation for the latest release is available on
[Hexdocs](https://hexdocs.pm/ip) and for the `main` branch on
[docs.harton.nz](https://docs.harton.nz/james/ip).

## Usage

`ip` provides representations for IP addresses and subnets for Elixir with a bunch of helpful stuff tacked on the side.

    iex> ~i(192.0.2.1)
    #IP.Address<192.0.2.1 Documentation (TEST-NET-1), GLOBAL, RESERVED>

    iex> ~i(2001:db8::)
    #IP.Address<2001:db8:: Documentation, GLOBAL, RESERVED>

    iex> outside = ~i(2001:db8::/64)
    ...> inside  = IP.Prefix.eui_64!(outside, "60:f8:1d:ad:d8:90")
    ...> IP.Prefix.contains_address?(outside, inside)
    true

## Github Mirror

This repository is mirrored [on Github](https://github.com/jimsynz/ip)
from it's primary location [on my Forgejo instance](https://harton.dev/james/ip).
Feel free to raise issues and open PRs on Github.

## License

This software is licensed under the terms of the
[HL3-FULL](https://firstdonoharm.dev), see the `LICENSE.md` file included with
this package for the terms.

This license actively proscribes this software being used by and for some
industries, countries and activities. If your usage of this software doesn't
comply with the terms of this license, then [contact me](mailto:james@harton.nz)
with the details of your use-case to organise the purchase of a license - the
cost of which may include a donation to a suitable charity or NGO.
