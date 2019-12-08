defmodule AOC.Intcode do
  @moduledoc "Intcode simulator."

  use GenServer

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

  @doc "Creates a new Intcode computer."
  def new(tape) do
    {:ok, pid} = start_link(tape)
    pid
  end

  @doc "Runs the computer's tape."
  def run(pid) do
    GenServer.cast(pid, :run)
    pid
  end

  @doc "Subscribes someone to the computer's events."
  def subscribe(pid, subscribers) do
    GenServer.cast(pid, {:subscribe, subscribers})
    pid
  end

  @doc "Sends input to the computer."
  def input(pid, val) do
    GenServer.cast(pid, {:input, val})
    pid
  end

  def start_link(tape) do
    GenServer.start_link(__MODULE__, tape)
  end

  def init(tape) do
    ic = %{tape: List.to_tuple(tape), subscribers: MapSet.new(), ip: 0, inputs: [], sleeping: false}
    {:ok, ic}
  end

  def handle_cast(:run, %{tape: tape, subscribers: subscribers, ip: ip, inputs: inputs} = ic) do
    opcode =
      tape
      |> elem(ip)
      |> Integer.digits()
      |> pad()

    case opcode do
      [0, 0, 0, @stop, @stop] ->
        GenServer.cast(self(), :stop)
        {:noreply, ic}

      [0, b_mode, a_mode, 0, op] when op in [@add, @mul] ->
        a = load(tape, a_mode, ip + 1)
        b = load(tape, b_mode, ip + 2)
        dest = elem(tape, ip + 3)

        f =
          case op do
            @add -> &+/2
            @mul -> &*/2
          end

        val = f.(a, b)
        tape = store(tape, dest, val)
        GenServer.cast(self(), :run)
        {:noreply, %{ic | tape: tape, ip: ip + 4}}

      [_, _, 0, 0, @input] ->
        case inputs do
          [] ->
            {:noreply, %{ic | sleeping: true}, :hibernate}

          [val | rest] ->
            dest = elem(tape, ip + 1)
            tape = store(tape, dest, val)
            GenServer.cast(self(), :run)
            {:noreply, %{ic | tape: tape, ip: ip + 2, inputs: rest}}
        end

      [_, _, mode, 0, @output] ->
        out = load(tape, mode, ip + 1)
        Enum.each(subscribers, &send(&1, {:output, out}))
        GenServer.cast(self(), :run)
        {:noreply, %{ic | ip: ip + 2}}

      [_, branch_mode, val_mode, 0, op] when op in [@if, @unless] ->
        val = load(tape, val_mode, ip + 1)

        ip =
          if (op == @if and val != 0) or (op == @unless and val == 0) do
            load(tape, branch_mode, ip + 2)
          else
            ip + 3
          end

        GenServer.cast(self(), :run)
        {:noreply, %{ic | ip: ip}}

      [0, b_mode, a_mode, 0, op] when op in [@lt, @eq] ->
        a = load(tape, a_mode, ip + 1)
        b = load(tape, b_mode, ip + 2)
        dest = elem(tape, ip + 3)
        val = if (op == @lt and a < b) or (op == @eq and a == b), do: 1, else: 0
        tape = store(tape, dest, val)
        GenServer.cast(self(), :run)
        {:noreply, %{ic | tape: tape, ip: ip + 4}}
    end
  end

  def handle_cast({:input, val}, %{inputs: inputs, sleeping: sleeping} = ic) do
    sleeping && GenServer.cast(self(), :run)
    {:noreply, %{ic | sleeping: false, inputs: inputs ++ [val]}}
  end

  def handle_cast({:subscribe, new_subs}, %{subscribers: current_subs} = ic) do
    f = if is_list(new_subs), do: &MapSet.union/2, else: &MapSet.put/2
    {:noreply, %{ic | subscribers: f.(current_subs, new_subs)}}
  end

  def handle_cast(:stop, %{subscribers: subscribers} = ic) do
    Enum.each(subscribers, &send(&1, {:done, ic}))
    {:noreply, ic}
  end

  defp load(tape, 0, idx), do: elem(tape, elem(tape, idx))
  defp load(tape, 1, idx), do: elem(tape, idx)

  defp store(tape, idx, val), do: replace_at(tape, idx, val)

  defp pad(op) when length(op) >= 5, do: op
  defp pad(op), do: pad([0 | op])
end
