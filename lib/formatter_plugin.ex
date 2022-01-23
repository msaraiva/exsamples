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
    {rows, widths} = walk(code, 1, 1, positions, [], {[[]], %{}, 0})
    last_col_index = map_size(widths) - 1

    for row <- rows do
      Enum.map_join(row, " | ", fn
        {^last_col_index, value} ->
          value

        {col_index, value} ->
          offset = if col_index == 0, do: String.duplicate(" ", column_offset), else: ""
          offset <> String.pad_trailing(value, widths[col_index])
      end)
    end
    |> Enum.join("\n")
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

  defp walk(<<>>, _line, _column, _positions, _buffer, {rows, widths, _col_index}) do
    {Enum.reverse(rows), widths}
  end

  defp add_cell({[cells | rows], widths, col_index}, cell) do
    value = cell |> Enum.reverse() |> to_string() |> String.trim()
    width = String.length(value)
    widths = Map.update(widths, col_index, width, &max(&1, width))
    {[[{col_index, value} | cells] | rows], widths, col_index + 1}
  end

  defp new_line({[cells | rows], widths, _col_index}, []) do
    {[Enum.reverse(cells) | rows], widths, 0}
  end

  defp new_line({[cells | rows], widths, _col_index}, _positions) do
    {[[] | [Enum.reverse(cells) | rows]], widths, 0}
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
