defmodule AOC.Intcode do
  @moduledoc "Intcode simulator."

  import AOC.Utils

  @add 1
  @mul 2
  @stop 99

  def simulate(tape, noun, verb) when is_list(tape) do
    tape
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
