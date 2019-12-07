defmodule AOC.Day6 do
  use AOC

  @com "COM"

  defp default, do: input("\n", fn line -> String.split(line, ")") end)

  @doc """
      iex> AOC.Day6.part1
      308790
  """
  def part1(inp \\ default()) do
    inp
    |> build_graph()
    |> degrees(@com)
    |> Map.values()
    |> Enum.sum()
  end

  def part2(inp \\ default()) do
    inp
  end

  defp build_graph(orbits) do
    Enum.reduce(orbits, %{}, fn [orbitee, orbiter], acc ->
      Map.update(acc, orbitee, [orbiter], fn orbiters -> [orbiter | orbiters] end)
    end)
  end

  defp degrees(graph, center), do: degrees(graph, %{center => 0}, center)

  defp degrees(graph, acc, orbitee) do
    case Map.get(graph, orbitee) do
      nil ->
        acc

      orbiters ->
        orbiters
        |> Enum.map(fn orbiter ->
          acc = Map.put(acc, orbiter, acc[orbitee] + 1)
          degrees(graph, acc, orbiter)
        end)
        |> Enum.reduce(&Map.merge/2)
    end
  end
end
