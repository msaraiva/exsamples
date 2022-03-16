defmodule Samples do
  def extract(contents, type) do
    contents
    |> extract_table_parts
    |> (fn {vars, _type, keyword_lists} -> {vars, type, keyword_lists} end).()
    |> process_table_parts
  end

  def extract(contents) do
    contents
    |> extract_table_parts
    |> process_table_parts
  end

  defp extract_table_parts(contents) do
    {vars, type, fields, fields_values} =
      contents
      |> normalize_contents
      |> contents_to_table
      |> slice_table

    keyword_lists = zip_fields_and_values(fields, fields_values)
    {vars, type, keyword_lists}
  end

  defp process_table_parts({[], type, keyword_lists}) do
    to_typed_list(keyword_lists, type)
  end

  defp process_table_parts({vars, type, keyword_lists}) do
    to_assignments(vars, type, keyword_lists)
  end

  defp slice_table(table) do
    [header | rows] = extract_header_rows(table)
    {type, fields} = extract_type_and_fields(header)
    {vars, fields_values} = extract_vars_and_fields_values(type, rows)

    {vars, type, fields, fields_values}
  end

  defp to_assignments(vars, type, keyword_lists) do
    vars
    |> Enum.zip(keyword_lists)
    |> Enum.map(fn {var_name, value} ->
      var = Macro.var(var_name, nil)

      quote do
        unquote(var) = unquote(replace_value(type, value))
      end
    end)
  end

  defp to_typed_list(contents, nil) do
    to_typed_list(contents, {:%{}, [], []})
  end

  defp to_typed_list(contents, type) do
    Enum.map(contents, fn item ->
      replace_value(type, item)
    end)
  end

  defp extract_header_rows([]), do: [[nil]]
  defp extract_header_rows(table), do: table

  def extract_type_and_fields([type = {atom, _, []} | fields]) when atom == :%{} do
    {type, fields}
  end

  def extract_type_and_fields([{:__aliases__, _, [_]} = type | fields]) do
    {type, fields}
  end

  def extract_type_and_fields(fields = [{field, [_], _} | _]) when is_atom(field) do
    {nil, Enum.map(fields, fn {field, [_], _} -> field end)}
  end

  def extract_type_and_fields(fields = [field | _]) when is_atom(field) do
    {nil, fields}
  end

  def extract_type_and_fields(fields = [field | _]) when is_binary(field) do
    {nil, fields}
  end

  def extract_type_and_fields([type | fields]) do
    {type, fields}
  end

  def extract_vars_and_fields_values(nil, rows) do
    {[], rows}
  end

  def extract_vars_and_fields_values(_type, rows) do
    rows
    |> Enum.map(fn [{var, [line: _line], _} | fields_values] -> {var, fields_values} end)
    |> :lists.unzip()
  end

  defp zip_fields_and_values(fields, rows) do
    Enum.map(rows, fn row ->
      Enum.zip(fields, row)
    end)
  end

  # As structs by module name
  defp replace_value({:__aliases__, [counter: _, line: _], [module]}, value) do
    {:%, [], [{:__aliases__, [], [module]}, {:%{}, [], value}]}
  end

  defp replace_value({:__aliases__, [line: _], [module]}, value) do
    {:%, [], [{:__aliases__, [], [module]}, {:%{}, [], value}]}
  end

  # As structs
  defp replace_value({:%, meta, [lhs, {:%{}, _, _value}]}, value) do
    {:%, meta, [lhs, {:%{}, [], value}]}
  end

  # As maps
  defp replace_value({:%{}, meta, []}, value) do
    {:%{}, meta, value}
  end

  # As keyword list
  defp replace_value([], value) do
    value
  end

  defp contents_to_table(contents) do
    case contents do
      [do: nil] -> []
      nil -> []
      _ -> extract_rows(contents)
    end
  end

  defp extract_rows(contents) do
    contents |> Enum.map(&extract_row(&1))
  end

  defp extract_row([row]) do
    row |> extract_row
  end

  defp extract_row(row) do
    row |> extract_cells([]) |> Enum.reverse()
  end

  defp extract_cells({:|, _, [lhs, rhs]}, values) do
    rhs |> extract_cells([lhs | values])
  end

  defp extract_cells(value, values) do
    [value | values]
  end

  defp normalize_contents(contents) do
    case contents do
      [do: {:__block__, _, code}] -> code
      [do: code] -> [code]
    end
  end
end
