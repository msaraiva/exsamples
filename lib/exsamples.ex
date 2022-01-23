defmodule ExSamples do
  defmacro samples([as: type], contents) do
    contents |> Samples.extract(type)
  end

  defmacro samples(contents) do
    contents |> Samples.extract()
  end
end
