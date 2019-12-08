defmodule AOC.Day5 do
  use AOC

  alias AOC.Intcode

  defp default, do: input(",", &String.to_integer/1)

  @doc """
      iex> AOC.Day5.part1
      15314507
  """
  def part1(inp \\ default()), do: run(inp, 1)

  @doc """
      iex> AOC.Day5.part2
      652726
  """
  def part2(inp \\ default()), do: run(inp, 5)

  def run(tape, inp) do
    tape
    |> Intcode.new()
    |> Intcode.subscribe(self())
    |> Intcode.input(inp)
    |> Intcode.run()

    last_output()
  end

  defp last_output(default \\ nil) do
    receive do
      {:done, _ic} -> default
      {:output, out} -> last_output(out)
    end
  end
end
