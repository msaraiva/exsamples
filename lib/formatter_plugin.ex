defmodule Samples.FormatterPlugin do
  @behaviour Mix.Tasks.Format

  @line_break ["\n", "\r\n", "\r"]

  def features(_opts) do
    [extensions: [".ex", ".exs"]]
  end

  def format(code, opts) do
    formatted_code =
      code
      |> Code.format_string!(opts)
      |> to_string()
      |> format_samples()

    formatted_code <> "\n"
  end

  defp format_samples(code, position \\ [line: 0, column: 0]) do
    case format_first_samples_from_position(code, position) do
      :noop ->
        code

      {updated_code, position_found} ->
        format_samples(updated_code, position_found)
    end
  end

  defp format_first_samples_from_position(code, position) do
    samples_zipper =
      code
      |> Sourceror.parse_string!()
      |> Sourceror.Zipper.zip()
      |> Sourceror.Zipper.find(fn
        {:samples, meta, _} ->
          has_do? = Keyword.has_key?(meta, :do)

          is_after_position? =
            cond do
              meta[:line] > position[:line] -> true
              meta[:line] == position[:line] and meta[:column] > meta[:column] -> true
              true -> false
            end

          has_do? and is_after_position?

        _ ->
          false
      end)

    case find_samples_nodes(samples_zipper) do
      {nil, _} ->
        :noop

      {samples_node, nil} ->
        {code, Sourceror.get_start_position(samples_node)}

      {samples_node, do_node} ->
        range =
          do_node
          |> Sourceror.get_range()
          |> Map.update!(:start, fn pos -> [line: pos[:line] + 1, column: 1] end)

        content = get_code_by_range(code, range)

        samples_column = Sourceror.get_column(samples_node)
        replacement = format_table(content <> "\n", samples_column + 1)

        patch = %{
          change: replacement,
          range: range,
          preserve_indentation: false
        }

        {Sourceror.patch_string(code, [patch]), Sourceror.get_start_position(samples_node)}
    end
  end

  defp find_samples_nodes(nil) do
    {nil, nil}
  end

  defp find_samples_nodes(samples_zipper) do
    samples_node = Sourceror.Zipper.node(samples_zipper)

    do_node =
      samples_zipper
      |> Sourceror.Zipper.down()
      |> Sourceror.Zipper.rightmost()
      |> Sourceror.Zipper.down()
      |> Sourceror.Zipper.node()
      |> case do
        {{:__block__, _, [:do]}, {:__block__, _, []}} -> nil
        node -> node
      end

    {samples_node, do_node}
  end

  defp format_table(code, column_offset) do
    ast = code |> Code.string_to_quoted!(columns: true)

    {_, positions} =
      Macro.prewalk(ast, [], fn
        {:|, meta, _children} = node, acc ->
          {node, [{meta[:line], meta[:column]} | acc]}

        other, acc ->
          {other, acc}
      end)

    positions = Enum.reverse(positions)
    {rows, cols_info} = walk(code, 1, 1, positions, [], {[[]], %{}, 0})
    last_col_index = map_size(cols_info) - 1

    for row <- rows do
      Enum.map_join(row, " | ", fn
        {^last_col_index, value} ->
          align_value(value, cols_info[last_col_index], true)

        {col_index, value} ->
          offset = if col_index == 0, do: String.duplicate(" ", column_offset), else: ""
          offset <> align_value(value, cols_info[col_index], false)
      end)
    end
    |> Enum.join("\n")
  end

  defp align_value(value, cols_info, last_col?) do
    cond do
      cols_info.is_number? ->
        String.pad_leading(value, cols_info.width)

      last_col? ->
        value

      true ->
        String.pad_trailing(value, cols_info.width)
    end
  end

  defp walk("\r\n" <> rest, line, _column, positions, buffer, acc) do
    acc = acc |> add_cell(buffer) |> new_line(positions)
    walk(rest, line + 1, 1, positions, [], acc)
  end

  defp walk("\n" <> rest, line, _column, positions, buffer, acc) do
    acc = acc |> add_cell(buffer) |> new_line(positions)
    walk(rest, line + 1, 1, positions, [], acc)
  end

  defp walk(<<_::utf8, rest::binary>>, line, column, [{line, column} | positions], buffer, acc) do
    walk(rest, line, column + 1, positions, [], add_cell(acc, buffer))
  end

  defp walk(<<c::utf8, rest::binary>>, line, column, positions, buffer, acc) do
    walk(rest, line, column + 1, positions, [<<c::utf8>> | buffer], acc)
  end

  defp walk(<<>>, _line, _column, _positions, _buffer, {rows, cols_info, _col_index}) do
    {Enum.reverse(rows), cols_info}
  end

  defp add_cell({[cells | rows], cols_info, col_index}, cell) do
    value = cell |> Enum.reverse() |> to_string() |> String.trim()
    width = String.length(value)
    is_number? = is_number?(value)
    info = %{width: width, is_number?: is_number?}

    cols_info =
      Map.update(cols_info, col_index, info, fn info ->
        %{width: max(info.width, width), is_number?: info.is_number? or is_number?}
      end)

    {[[{col_index, value} | cells] | rows], cols_info, col_index + 1}
  end

  defp is_number?(value) do
    value = String.replace(value, "_", "")
    match?({_, ""}, Float.parse(value)) or match?({_, ""}, Integer.parse(value))
  end

  defp new_line({[cells | rows], cols_info, _col_index}, []) do
    {[Enum.reverse(cells) | rows], cols_info, 0}
  end

  defp new_line({[cells | rows], cols_info, _col_index}, _positions) do
    {[[] | [Enum.reverse(cells) | rows]], cols_info, 0}
  end

  defp get_code_by_range(code, range) do
    {_, text_after} = split_at(code, range.start[:line], range.start[:column])
    line = range.end[:line] - range.start[:line] + 1
    {text, _} = split_at(text_after, line, range.end[:column])
    text
  end

  defp split_at(code, line, col) do
    pos = find_position(code, line, col, {0, 1, 1})
    String.split_at(code, pos)
  end

  defp find_position(_text, line, col, {pos, line, col}) do
    pos
  end

  defp find_position(text, line, col, {pos, current_line, current_col}) do
    case String.next_grapheme(text) do
      {grapheme, rest} ->
        {new_pos, new_line, new_col} =
          if grapheme in @line_break do
            if current_line == line do
              # this is the line we're lookin for
              # but it's shorter than expected
              {pos, current_line, col}
            else
              {pos + 1, current_line + 1, 1}
            end
          else
            {pos + 1, current_line, current_col + 1}
          end

        find_position(rest, line, col, {new_pos, new_line, new_col})

      nil ->
        pos
    end
  end
end
