defmodule AOC.Day4 do
  use AOC

  defp default do
    [start, stop] = input("-", &String.to_integer/1)
    start..stop
  end

  @doc """
      iex> AOC.Day4.part1
      1169
  """
  def part1(inp \\ default()) do
    inp
    |> Enum.map(&Integer.digits/1)
    |> Enum.count(&(double?(&1) and increasing?(&1)))
  end

  @doc """
      iex> AOC.Day4.part2
      757
  """
  def part2(inp \\ default()) do
    inp
    |> Enum.map(&Integer.digits/1)
    |> Enum.count(&(double?(&1, :strict) and increasing?(&1)))
  end

  defp double?(digits), do: length(Enum.uniq(digits)) != length(digits)

  defp double?(digits, :strict) do
    digits
    |> Enum.uniq()
    |> Enum.any?(fn d -> Enum.count(digits, &(d == &1)) == 2 end)
  end

  defp increasing?(digits), do: Enum.sort(digits) == digits
end
