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
    |> Enum.count(&(is_double?(&1) and is_increasing?(&1)))
  end

  @doc """
      iex> AOC.Day4.part2
      757
  """
  def part2(inp \\ default()) do
    inp
    |> Enum.map(&Integer.digits/1)
    |> Enum.count(&(is_double?(&1, :strict) and is_increasing?(&1)))
  end

  defp is_double?(digits), do: length(Enum.uniq(digits)) != length(digits)

  defp is_double?(digits, :strict) do
    digits
    |> Enum.uniq()
    |> Enum.any?(fn d -> Enum.count(digits, &(d == &1)) == 2 end)
  end

  defp is_increasing?(digits), do: Enum.sort(digits) == digits
end
