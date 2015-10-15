defmodule ExSamples.Mixfile do
  use Mix.Project

  def project do
    [app: :exsamples,
     version: "0.0.1",
     elixir: "~> 1.1.0",
     deps: deps]
  end

  def application do
    []
  end

  defp deps do
    []
  end
end
