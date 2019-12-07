defmodule AOC.Day2 do
  use AOC

  @add 1
  @mul 2
  @stop 99

  defp default, do: input(",", &String.to_integer/1)

  @doc """
      iex> AOC.Day2.part1
      3562672
  """
  def part1(inp \\ default()) do
    simulate(inp, 12, 2)
  end

  @doc """
      iex> AOC.Day2.part2
      {19690720, 8250}
  """
  def part2(inp \\ default()) do
    # I'm not sure how to programmatically prove this, but:
    # - 0, 0 outputs 797870
    # - Incrementing the noun increases the outout by 230400
    # - Incrementing the verb increments the output
    noun = 82
    verb = 50
    {simulate(inp, noun, verb), 100 * noun + verb}
  end

  def simulate(inp, noun, verb) when is_list(inp) do
    inp
    |> replace_at(1, noun)
    |> replace_at(2, verb)
    |> List.to_tuple()
    |> simulate(0, {})
  end

  def simulate(tape, idx, state) do
    case {elem(tape, idx), state} do
      {@stop, {}} ->
        elem(tape, 0)

      {@add, {}} ->
        simulate(tape, idx + 1, {&+/2})

      {@mul, {}} ->
        simulate(tape, idx + 1, {&*/2})

      {a, {op}} ->
        simulate(tape, idx + 1, {op, a})

      {b, {op, a}} ->
        simulate(tape, idx + 1, {op, a, b})

      {dest, {op, a, b}} ->
        val = op.(elem(tape, a), elem(tape, b))
        tape = replace_at(tape, dest, val)
        simulate(tape, idx + 1, {})
    end
  end
end
