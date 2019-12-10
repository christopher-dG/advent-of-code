defmodule AOC.Day10 do
  use AOC

  defp default, do: input("")

  @doc """
      iex> AOC.Day10.part1
      230
  """
  def part1(inp \\ default()) do
    inp
    |> get_asteroids()
    |> count_visible()
    |> Enum.max_by(&elem(&1, 1))
    |> elem(1)
  end

  def part2(inp \\ default()) do
    inp
  end

  defp count_visible(asteroids) do
    asteroids
    |> Enum.map(&{&1, count_visible(asteroids, &1)})
    |> Map.new()
  end

  defp count_visible(asteroids, asteroid) do
    Enum.count(asteroids, &is_visible?(asteroids, asteroid, &1))
  end

  defp get_asteroids(chars) do
    Enum.reduce(chars, {MapSet.new(), 0, 0}, fn ch, {acc, x, y} ->
      case ch do
        "#" -> {MapSet.put(acc, {x, y}), x + 1, y}
        "." -> {acc, x + 1, y}
        "\n" -> {acc, 0, y + 1}
      end
    end)
    |> elem(0)
  end

  defp angle({x1, y1}, {x2, y2}), do: :math.atan2(y2 - y1, x2 - x1) * 180 / :math.pi()

  defp distance({x1, y1}, {x2, y2}), do: :math.sqrt(:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2))

  defp is_visible?(_asteroids, a, a), do: false

  defp is_visible?(asteroids, a, b) do
    theta = angle(a, b)

    visible_asteroid =
      asteroids
      |> Enum.filter(&(angle(a, &1) == theta and &1 != a))
      |> Enum.min_by(&distance(a, &1), fn -> {-1, -1} end)

    visible_asteroid == b
  end
end
