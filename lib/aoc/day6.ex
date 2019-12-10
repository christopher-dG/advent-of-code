defmodule AOC.Day6 do
  use AOC

  @com "COM"
  @san "SAN"
  @you "YOU"

  defp default, do: input("\n", fn line -> String.split(line, ")") end)

  @doc """
  iex> AOC.Day6.part1
  308790
  """
  def part1(inp \\ default()) do
    inp
    |> build_graph(:directed)
    |> degrees(@com)
    |> Map.values()
    |> Enum.sum()
  end

  @doc """
  iex> AOC.Day6.part2
  472
  """
  def part2(inp \\ default()) do
    graph = build_graph(inp, :undirected)
    intersection = MapSet.intersection(graph[@san], graph[@you])

    if Enum.empty?(intersection) do
      degree =
        graph
        |> degrees(@san)
        |> Map.get(@you)

      degree - 2
    else
      intersection
      |> MapSet.to_list()
      |> hd()
    end
  end

  defp build_graph(orbits, :directed) do
    Enum.reduce(orbits, %{}, fn [orbitee, orbiter], acc ->
      Map.update(acc, orbitee, [orbiter], fn edges -> [orbiter | edges] end)
    end)
  end

  defp build_graph(orbits, :undirected) do
    Enum.reduce(orbits, %{}, fn [orbitee, orbiter], acc ->
      acc
      |> Map.update(orbitee, MapSet.new([orbiter]), &MapSet.put(&1, orbiter))
      |> Map.update(orbiter, MapSet.new([orbitee]), &MapSet.put(&1, orbitee))
    end)
  end

  def degrees(graph, center), do: degrees(graph, %{center => 0}, center)

  def degrees(graph, acc, orbitee) do
    case Map.get(graph, orbitee) do
      nil ->
        acc

      orbiters ->
        orbiters
        |> Enum.map(fn orbiter ->
          if Map.has_key?(acc, orbiter) do
            acc
          else
            acc = Map.put(acc, orbiter, acc[orbitee] + 1)
            degrees(graph, acc, orbiter)
          end
        end)
        |> Enum.reduce(&Map.merge/2)
    end
  end
end
