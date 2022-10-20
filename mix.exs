defmodule ExSamples.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exsamples,
      version: "0.1.0",
      elixir: "~> 1.13 and >= 1.13.2",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:sourceror, "~> 0.9"}
    ]
  end

  defp description do
    """
    Initializes lists of maps, structs or keyword lists using tabular data in Elixir.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Marlus Saraiva"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/msaraiva/exsamples"}
    ]
  end
end
