defmodule AOC.Day3 do
  use AOC

  @up 85
  @left 76
  @right 82

  defp default, do: input("\n", fn line -> String.split(line, ",") end)

  @doc """
      iex> AOC.Day3.part1
      1195
  """
  def part1(inp \\ default()) do
    [a, b] =
      Enum.map(inp, fn path ->
        path
        |> traverse_path()
        |> MapSet.new()
      end)

    MapSet.intersection(a, b)
    |> MapSet.to_list()
    |> Enum.map(fn {a, b} -> abs(a) + abs(b) end)
    |> Enum.min()
  end

  @doc """
      iex> AOC.Day3.part2
      91518
  """
  def part2(inp \\ default()) do
    [a, b] = Enum.map(inp, &traverse_path/1)

    MapSet.intersection(MapSet.new(a), MapSet.new(b))
    |> Enum.map(fn coord ->
      a_idx = Enum.find_index(a, &(&1 == coord))
      b_idx = Enum.find_index(b, &(&1 == coord))
      a_idx + b_idx + 2
    end)
    |> Enum.min()
  end

  defp traverse_path(path) do
    Enum.reduce(path, {{0, 0}, []}, fn <<direction, amount::binary>>, acc ->
      amount = String.to_integer(amount)
      process_move(acc, direction, amount)
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  defp process_move({pos, history}, direction, amount) do
    axis = if direction in [@left, @right], do: 0, else: 1
    scalar = if direction in [@left, @up], do: -1, else: 1
    start = elem(pos, axis) + scalar
    stop = elem(pos, axis) + scalar * amount

    new_pos = replace_at(pos, axis, stop)

    new_history =
      Enum.reduce(start..stop, history, fn idx, acc ->
        [replace_at(pos, axis, idx) | acc]
      end)

    {new_pos, new_history}
  end
end
