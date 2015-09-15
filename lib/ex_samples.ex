defmodule ExSamples do

  defmacro __using__(_opts) do 
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro samples(contents) do
    contents |> Samples.extract
  end
  
end