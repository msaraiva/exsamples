defmodule ExSamples.Mixfile do
  use Mix.Project

  def project do
    [app: :exsamples,
     version: "0.1.0",
     elixir: "~> 1.1",
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    []
  end

  defp deps do
    []
  end

  defp description do
    """
    Initializes lists of maps, structs or keyword lists using tabular data in Elixir.
    """
  end

  defp package do
    [files: ["lib", "priv", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Marlus Saraiva"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/msaraiva/exsamples"}]
  end
end
