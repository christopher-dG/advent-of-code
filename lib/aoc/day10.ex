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

  @doc """
      iex> AOC.Day10.part2
      {{12, 5}, 1205}
  """
  def part2(inp \\ default()) do
    # Skip the big long computation to come up with this.
    centre = {19, 11}

    {x, y} =
      inp
      |> get_asteroids()
      |> Enum.filter(&(&1 != centre))
      |> sort_for_laser(centre)
      |> nth_laser(200)

    {{x, y}, 100 * x + y}
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

    # An asteroid b is visible to a if there are no asteroids closer to a than b
    # whose angle, relative to a, is the same as that of b.
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

  defp quadrant(theta) when theta < -90, do: 3
  defp quadrant(theta) when theta < 0, do: 0
  defp quadrant(theta) when theta < 90, do: 1
  defp quadrant(theta) when theta <= 180, do: 2

  defp sort_for_laser(asteroids, centre) do
    # [{x1, y1}, ...]
    asteroids
    # [{{x1, y1}, theta1}, ...]
    |> Enum.map(&{&1, angle(centre, &1)})
    # Split the asteroids into four quadrants (lists),
    # where the + is our centre:
    #  -------
    # | 3 | 0 |
    # |---+---|
    # | 2 | 1 |
    #  -------
    # [[{{x1, y1}, theta1, ...}], (3 more)]
    |> Enum.reduce(List.duplicate([], 4), fn {_a, theta} = tuple, quadrants ->
      List.update_at(quadrants, quadrant(theta), &[tuple | &1])
    end)
    # Sort each quadrant by angle, then flatten.
    # [{{x1, y1}, theta1}, {{x2, y2}, theta2}], where the sequence of thetas
    # "goes in a circle".
    |> Enum.map(fn asteroids ->
      Enum.sort_by(asteroids, fn {_a, theta} -> theta end)
    end)
    |> List.flatten()
    # Group asteroids with the same angle (that are in line with each other),
    # then discard the angle and sort by distance from the centre asteroid.
    # [[{x1, y1}, {x2, y2}], [{x3, y3}], ...]
    |> Enum.chunk_by(fn {_a, theta} -> theta end)
    |> Enum.map(fn list ->
      list
      |> Enum.map(fn {a, _theta} -> a end)
      |> Enum.sort_by(&distance(centre, &1))
    end)
  end

  # Entrypoing: Add an accumulator.
  defp nth_laser(asteroids, n), do: nth_laser(asteroids, n, 1)
  # If a line of asteroids is exhausted, discard the empty list and continue.
  defp nth_laser([[] | tail], n, current), do: nth_laser(tail, n, current)
  # If the accumulator has reached the desired count, return that asteroid.
  defp nth_laser([[h | _t] | _tail], n, n), do: h
  # Otherwise, discard the asteroid and put the rest of the line at the back.
  defp nth_laser([[_h | t] | tail], n, current), do: nth_laser(tail ++ [t], n, current + 1)
end
