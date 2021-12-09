defmodule IP.Mixfile do
  use Mix.Project

  @description """
  Represtations and tools for IP addresses and networks.
  """
  @version "1.1.1"

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
      {:credo, "~> 1.6", only: ~w[dev test]a, runtime: false},
      {:earmark, ">= 0.2.1", only: ~w[dev test]a},
      {:ex_doc, ">= 0.26.0", only: ~w[dev test]a},
      {:git_ops, "~> 2.3", only: ~w[dev test]a, runtime: false}
    ]
  end
end
