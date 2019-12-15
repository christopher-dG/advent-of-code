defmodule AOC.Day12 do
  use AOC

  defp default, do: input("\n", &parse_line/1)

  defp parse_line(line) do
    ~r/^<x=(.+), y=(.+), z=(.+)>$/
    |> Regex.run(line, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  @doc """
      iex> AOC.Day12.part1
      12644
  """
  def part1(inp \\ default()) do
    1..1000
    |> Enum.reduce(initial_state(inp), fn _t, moons -> simulate_motion(moons) end)
    |> calculate_energy()
  end

  @doc """
      iex> AOC.Day12.part2
      290314621566528
  """
  def part2(inp \\ default()) do
    moons = initial_state(inp)
    x = cycle_length(moons, 0)
    y = cycle_length(moons, 1)
    z = cycle_length(moons, 2)
    lcm(x, y, z)
  end

  defp initial_state(moons) do
    moons
    |> Enum.with_index()
    |> Enum.map(fn {coords, i} -> {i, coords, {0, 0, 0}} end)
  end

  defp apply_gravity(moons) do
    moons
    |> Combination.combine(2)
    |> Enum.reduce(moons, fn [a, b], moons ->
      {idx_a, {pos_x_a, pos_y_a, pos_z_a}, _vel_a} = a
      {idx_b, {pos_x_b, pos_y_b, pos_z_b}, _vel_b} = b
      a_x_delta = delta(pos_x_a, pos_x_b)
      a_y_delta = delta(pos_y_a, pos_y_b)
      a_z_delta = delta(pos_z_a, pos_z_b)

      moons
      |> List.update_at(idx_a, fn {idx, pos, {vel_x, vel_y, vel_z}} ->
        {idx, pos, {vel_x + a_x_delta, vel_y + a_y_delta, vel_z + a_z_delta}}
      end)
      |> List.update_at(idx_b, fn {idx, pos, {vel_x, vel_y, vel_z}} ->
        {idx, pos, {vel_x - a_x_delta, vel_y - a_y_delta, vel_z - a_z_delta}}
      end)
    end)
  end

  defp delta(x, y) when x > y, do: -1
  defp delta(x, y) when x < y, do: 1
  defp delta(_x, _y), do: 0

  defp apply_velocity(moons) when is_list(moons), do: Enum.map(moons, &apply_velocity/1)

  defp apply_velocity({idx, {pos_x, pos_y, pos_z}, {vel_x, vel_y, vel_z} = vel}) do
    {idx, {pos_x + vel_x, pos_y + vel_y, pos_z + vel_z}, vel}
  end

  defp simulate_motion(moons) do
    moons
    |> apply_gravity()
    |> apply_velocity()
  end

  defp calculate_energy(moons) when is_list(moons) do
    moons
    |> Enum.map(&calculate_energy/1)
    |> Enum.sum()
  end

  defp calculate_energy({_dx, {pos_x, pos_y, pos_z}, {vel_x, vel_y, vel_z}}) do
    potential = abs(pos_x) + abs(pos_y) + abs(pos_z)
    kinetic = abs(vel_x) + abs(vel_y) + abs(vel_z)
    potential * kinetic
  end

  defp pick_index(moons, idx) do
    Enum.map(moons, fn {_i, p, v} -> {elem(p, idx), elem(v, idx)} end)
  end

  defp cycle_length(moons, idx) do
    moons
    |> simulate_motion()
    |> cycle_length(idx, pick_index(moons, idx), 1)
  end

  defp cycle_length(moons, idx, target, n) do
    if pick_index(moons, idx) == target do
      n
    else
      moons
      |> simulate_motion()
      |> cycle_length(idx, target, n + 1)
    end
  end

  defp lcm(a, b, c), do: lcm(lcm(a, b), c)
  defp lcm(a, b), do: round(a * b / Integer.gcd(a, b))
end
