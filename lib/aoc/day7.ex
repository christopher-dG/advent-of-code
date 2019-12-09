defmodule AOC.Day7 do
  use AOC

  alias AOC.Intcode

  defp default, do: input(",", &String.to_integer/1)

  @doc """
      iex> AOC.Day7.part1
      368584
  """
  def part1(inp \\ default()) do
    subscriptions = %{0 => [1], 1 => [2], 2 => [3], 3 => [4], 4 => [self()]}
    run(inp, 0..4, subscriptions)
  end

  @doc """
      iex> AOC.Day7.part2
      35993240
  """
  def part2(inp \\ default()) do
    subscriptions = %{0 => [1], 1 => [2], 2 => [3], 3 => [4], 4 => [0, self()]}
    run(inp, 5..9, subscriptions)
  end

  defp run(tape, range, subscriptions) do
    range
    |> Combination.permutate()
    |> Enum.map(fn phases ->
      pids = Enum.map(phases, fn _p -> Intcode.new(tape) end)

      Enum.each(subscriptions, fn {subscriber, subscribees} ->
        subscribees =
          Enum.map(subscribees, fn subscribee ->
            cond do
              is_integer(subscribee) -> Enum.at(pids, subscribee)
              is_pid(subscribee) -> subscribee
            end
          end)

        Intcode.subscribe(Enum.at(pids, subscriber), subscribees)
      end)

      pids
      |> Enum.zip(phases)
      |> Enum.each(fn {pid, phase} -> Intcode.input(pid, phase) end)

      pids
      |> hd()
      |> Intcode.input(0)

      Enum.each(pids, &Intcode.run/1)

      Intcode.last_output()
    end)
    |> Enum.max()
  end
end
