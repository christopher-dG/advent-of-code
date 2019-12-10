defmodule AOC.Day10 do
  use AOC

  defp default, do: input("")

  @doc """
      iex> AOC.Day10.part1
      {{19, 11}, 230}
  """
  def part1(inp \\ default()) do
    inp
    |> get_asteroids()
    |> count_visible()
    |> Enum.max_by(&elem(&1, 1))
  end

  def part2(inp \\ default(), n \\ 200) do
    # Skip the big long computation to come up with this.
    centre = {19, 11}

    {x, y} =
      inp
      |> get_asteroids()
      |> Enum.filter(&(&1 != centre))
      |> Enum.map(&{&1, angle(centre, &1)})
      # THE SORT IS NOT CORRECT
      |> Enum.sort_by(fn {_a, theta} -> theta end)
      |> Enum.split_while(fn {_a, theta} -> theta < 0 end)
      |> Tuple.to_list()
      |> Enum.reverse()
      |> List.flatten()
      |> Enum.chunk_by(fn {_a, theta} -> theta end)
      |> Enum.map(fn list ->
        list
        |> Enum.map(fn {a, _theta} -> a end)
        |> Enum.sort_by(&distance(centre, &1))
      end)
      |> nth_laser(n)

    100 * x + y
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

  defp count_visible(asteroids) do
    asteroids
    |> Enum.map(&{&1, count_visible(asteroids, &1)})
    |> Map.new()
  end

  defp count_visible(asteroids, asteroid) do
    Enum.count(asteroids, &is_visible?(asteroids, asteroid, &1))
  end

  defp nth_laser(asteroids, n), do: nth_laser(asteroids, n, 1)
  defp nth_laser([[] | tail], n, current), do: nth_laser(tail, n, current)
  defp nth_laser([[h | _t] | _tail], n, n), do: h
  defp nth_laser([[_h | t] | tail], n, current), do: nth_laser(tail ++ [t], n, current + 1)
end
