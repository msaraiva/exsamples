defmodule ExSamples do

  defmacro __using__(_opts) do 
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro vars(contents) do
    contents |> Samples.do_vars
  end

  defmacro list_of(contents) do
    contents |> Samples.do_list_of
  end
  
end