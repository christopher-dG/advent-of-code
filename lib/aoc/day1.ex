defmodule AOC.Day1 do
  use AOC

  defp default, do: input("\n", &String.to_integer/1)

  @doc """
      iex> AOC.Day1.part1
      3426455
  """
  def part1(inp \\ default()), do: Enum.reduce(inp, 0, &(fuel_required(&1) + &2))

  @doc """
      iex> AOC.Day1.part2
      5136807
  """
  def part2(inp \\ default()), do: Enum.reduce(inp, 0, &(fuel_required(&1, :recursive) + &2))

  defp fuel_required(mass), do: floor(mass / 3) - 2

  defp fuel_required(mass, acc \\ 0, :recursive) do
    case fuel_required(mass) do
      n when n > 0 -> fuel_required(n, acc + n, :recursive)
      _n -> acc
    end
  end
end
