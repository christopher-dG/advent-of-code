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

      # Set up the subscriptions as described by the input map.
      Enum.each(subscriptions, fn {subscriber, subscribees} ->
        subscribees =
          Enum.map(subscribees, fn subscribee ->
            # If an integer i was passed, it means "computer i".
            # Otherwise we assume it's a pid.
            cond do
              is_integer(subscribee) -> Enum.at(pids, subscribee)
              is_pid(subscribee) -> subscribee
            end
          end)

        Intcode.subscribe(Enum.at(pids, subscriber), subscribees)
      end)

      # Give each computer its phase input.
      pids
      |> Enum.zip(phases)
      |> Enum.each(fn {pid, phase} -> Intcode.input(pid, phase) end)

      # The first computer gets 0 as a second input.
      # The other computers will receive inputs from their subscribee's outputs.
      pids
      |> hd()
      |> Intcode.input(0)

      Enum.each(pids, &Intcode.run/1)

      # This assumes that self() was somewhere in the subscription map.
      Intcode.last_output()
    end)
    |> Enum.max()
  end
end
