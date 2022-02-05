defmodule ExSamples do
  defmacro samples([as: type], contents) do
    Samples.extract(contents, type)
  end

  defmacro samples(contents) do
    Samples.extract(contents)
  end
end
