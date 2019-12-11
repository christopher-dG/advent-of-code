defmodule AOC.Day11 do
  use AOC

  @black 0
  @white 1

  @up 0
  @right 1
  @down 2
  @left 3

  @turn_left 0
  @turn_right 1

  alias AOC.Intcode

  defp default, do: input(",", &String.to_integer/1)

  @doc """
      iex> AOC.Day11.part1
      2252
  """
  def part1(inp \\ default()) do
    inp
    |> start_program()
    |> poll_robot(@black)
    |> elem(1)
    |> MapSet.size()
  end

  @doc ~S"""
      iex> AOC.Day11.part2 |> String.split("\n")
      ["  ▆▆   ▆▆   ▆▆  ▆    ▆▆▆   ▆▆    ▆▆ ▆▆▆▆   ",
       " ▆  ▆ ▆  ▆ ▆  ▆ ▆    ▆  ▆ ▆  ▆    ▆ ▆      ",
       " ▆  ▆ ▆    ▆  ▆ ▆    ▆  ▆ ▆       ▆ ▆▆▆    ",
       " ▆▆▆▆ ▆ ▆▆ ▆▆▆▆ ▆    ▆▆▆  ▆ ▆▆    ▆ ▆      ",
       " ▆  ▆ ▆  ▆ ▆  ▆ ▆    ▆ ▆  ▆  ▆ ▆  ▆ ▆      ",
       " ▆  ▆  ▆▆▆ ▆  ▆ ▆▆▆▆ ▆  ▆  ▆▆▆  ▆▆  ▆▆▆▆   "]
  """
  def part2(inp \\ default()) do
    {grid, _path} =
      inp
      |> start_program()
      |> poll_robot(@white)

    keys = Map.keys(grid)
    {max_x, _y} = Enum.max_by(keys, &(elem(&1, 0)))
    {_x, max_y} = Enum.max_by(keys, &(elem(&1, 1)))
    {max_x, max_y}

    Enum.map(0..max_y, fn y ->
      Enum.reduce(0..max_x, "", fn x, acc ->
        char =
          case Map.get(grid, {x, y}, @black) do
            @white -> "▆"
            @black -> " "
          end

        [acc, [char]]
      end)
    end)
    |> Enum.join("\n")
  end

  defp start_program(tape) do
    tape
    |> Intcode.new()
    |> Intcode.subscribe(self())
    |> Intcode.run()
  end

  defp poll_robot(pid, start_colour) do
    Intcode.input(pid, start_colour)
    poll_robot(pid, %{{0, 0} => start_colour}, {0, 0, @up}, MapSet.new())
  end

  defp poll_robot(pid, grid, {x, y, direction}, path) do
    case get_output() do
      {:ok, colour} ->
        grid = Map.put(grid, {x, y}, colour)
        path = MapSet.put(path, {x, y})

        turn =
          case get_output() do
            {:ok, @turn_left} -> -1
            {:ok, @turn_right} -> 1
          end

        direction = Integer.mod(direction + turn, 4)

        {x, y} =
          case direction do
            @up -> {x, y - 1}
            @right -> {x + 1, y}
            @down -> {x, y + 1}
            @left -> {x - 1, y}
          end

        colour = Map.get(grid, {x, y}, @black)
        Intcode.input(pid, colour)

        poll_robot(pid, grid, {x, y, direction}, path)

      :done ->
        {grid, path}
    end
  end

  defp get_output() do
    receive do
      {:output, n} -> {:ok, n}
      :done -> :done
    end
  end
end
