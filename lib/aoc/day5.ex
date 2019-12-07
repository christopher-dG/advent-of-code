defmodule AOC.Day5 do
  use AOC

  alias AOC.Intcode

  defp default, do: input(",", &String.to_integer/1)

  @doc """
      iex> AOC.Day5.part1
      15314507
  """
  def part1(inp \\ default()) do
    Intcode.simulate(inp, [1])
    |> Map.get(:outputs)
    |> hd()
  end

  @doc """
      iex> AOC.Day5.part2
      0
  """
  def part2(inp \\ default()) do
    Intcode.simulate(inp, [5])
    |> Map.get(:outputs)
    |> hd()
  end
end
