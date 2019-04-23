defmodule IP.Mixfile do
  use Mix.Project

  @description """
  Represtations and tools for IP addresses and networks.
  """
  @version "1.1.0"

  def project do
    [
      app: :ip,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      description: @description
    ]
  end

  def package do
    [
      maintainers: ["James Harton <james@automat.nz>"],
      licenses: ["MIT"],
      links: %{
        "Source" => "https://gitlab.com/jimsy/ip"
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev},
      {:credo, "~> 1.0", only: ~w(dev test)a, runtime: false},
      {:dialyxir, "~> 0.5", only: ~w(dev test)a, runtime: false}
    ]
  end
end
