defmodule ExSamples.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_samples,
     version: "0.0.1",
     elixir: "~> 1.0.5",
     deps: deps]
  end

  def application do
    []
  end

  defp deps do
    []
  end
end
