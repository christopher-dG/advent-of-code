defmodule AOC.Day9 do
  use AOC

  alias AOC.Intcode

  defp default, do: input(",", &String.to_integer/1)

  @doc """
      iex> AOC.Day9.part1
      3454977209
  """
  def part1(inp \\ default()), do: run(inp, 1)

  @doc """
      iex> AOC.Day9.part2
      50120
  """
  def part2(inp \\ default()), do: run(inp, 2)

  defp run(tape, inp) do
    tape
    |> Intcode.new()
    |> Intcode.subscribe(self())
    |> Intcode.input(inp)
    |> Intcode.run()

    Intcode.last_output()
  end
end
