defmodule AOC.Intcode do
  @moduledoc "Intcode simulator."

  import AOC.Utils

  @add 1
  @mul 2
  @input 3
  @output 4
  @if 5
  @unless 6
  @lt 7
  @eq 8
  @stop 9

  def simulate(tape, inputs) when is_list(tape) and is_list(inputs) do
    program = %{tape: List.to_tuple(tape), ip: 0, inputs: inputs, outputs: []}
    simulate(program)
  end

  def simulate(tape, noun, verb) when is_list(tape) and is_integer(noun) and is_integer(verb) do
    tape
    |> replace_at(1, noun)
    |> replace_at(2, verb)
    |> simulate()
  end

  def simulate(tape) when is_list(tape), do: simulate(tape, [])

  def simulate(%{tape: tape, ip: ip, inputs: inputs, outputs: outputs} = program) do
    opcode =
      tape
      |> elem(ip)
      |> Integer.digits()
      |> pad()

    case opcode do
      [0, 0, 0, @stop, @stop] ->
        program

      [0, b_mode, a_mode, 0, op] when op in [@add, @mul] ->
        a = load(tape, a_mode, elem(tape, ip + 1))
        b = load(tape, b_mode, elem(tape, ip + 2))
        dest = elem(tape, ip + 3)

        f =
          case op do
            @add -> &+/2
            @mul -> &*/2
          end

        val = f.(a, b)
        tape = store(tape, dest, val)
        simulate(%{program | tape: tape, ip: ip + 4})

      [_, _, 0, 0, @input] ->
        dest = elem(tape, ip + 1)
        [inp | inputs] = inputs
        tape = store(tape, dest, inp)
        simulate(%{program | tape: tape, ip: ip + 2, inputs: inputs})

      [_, _, mode, 0, @output] ->
        src = elem(tape, ip + 1)
        out = load(tape, mode, src)
        outputs = [out | outputs]
        simulate(%{program | ip: ip + 2, outputs: outputs})

      [_, jump_mode, branch_mode, 0, op] when op in [@if, @unless] ->
        branch = load(tape, branch_mode, ip + 1)

        if (op == @if and branch) || (op == @unless and !branch) do
          jump = load(tape, jump_mode, ip + 2)
          simulate(%{program | ip: jump})
        else
          simulate(%{program | ip: ip + 3})
        end

      [0, b_mode, a_mode, 0, op] when op in [@lt, @eq] ->
        a = load(tape, a_mode, ip + 1)
        b = load(tape, b_mode, ip + 2)
        dest = elem(tape, ip + 3)
        val = if (op == @lt and a < b) || (op == @eq and a == b), do: 1, else: 0
        tape = store(tape, dest, val)
        simulate(%{program | tape: tape, ip: ip + 4})
    end
  end

  defp load(tape, 0, idx), do: elem(tape, idx)
  defp load(_tape, 1, val), do: val

  defp store(tape, idx, val), do: replace_at(tape, idx, val)

  defp pad(op) when length(op) == 5, do: op
  defp pad(op) when length(op) == 4, do: [0 | op]
  defp pad(op) when length(op) == 3, do: [0, 0 | op]
  defp pad(op) when length(op) == 2, do: [0, 0, 0 | op]
  defp pad(op) when length(op) == 1, do: [0, 0, 0, 0 | op]
end
