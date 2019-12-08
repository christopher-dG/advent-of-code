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

  @doc "Gets the last output, assuming you've subscribed to exactly one computer."
  def last_output(default \\ nil) do
    receive do
      {:done, _ic} -> default
      {:output, out} -> last_output(out)
    end
  end

  def start_link(tape), do: GenServer.start_link(__MODULE__, tape)

  def init(tape) do
    ic = %{
      tape: List.to_tuple(tape),
      subscribers: MapSet.new(),
      ip: 0,
      inputs: [],
      state: :stopped
    }

    {:ok, ic}
  end

  def handle_cast(:run, ic), do: {:noreply, ic, {:continue, :run}}

  def handle_cast({:input, val}, %{inputs: inputs, state: state} = ic) do
    reply = {:noreply, %{ic | state: :waking, inputs: inputs ++ [val]}}
    if state === :sleeping, do: Tuple.insert_at(reply, 2, {:continue, :run}), else: reply
  end

  def handle_cast({:subscribe, new_subs}, %{subscribers: current_subs} = ic) do
    subs =
      if is_list(new_subs) do
        MapSet.union(current_subs, MapSet.new(new_subs))
      else
        MapSet.put(current_subs, new_subs)
      end

    {:noreply, %{ic | subscribers: subs}}
  end

  def handle_info({:output, val}, ic), do: handle_cast({:input, val}, ic)

  def handle_info({:done, ic}, _ic), do: {:noreply, ic}

  def handle_continue(:run, ic), do: simulate(ic)

  def handle_continue(:stop, %{subscribers: subscribers} = ic) do
    Enum.each(subscribers, &send(&1, {:done, ic}))
    {:noreply, ic}
  end

  defp simulate(%{tape: tape, subscribers: subscribers, ip: ip, inputs: inputs} = ic) do
    ic = %{ic | state: :running}

    opcode =
      tape
      |> elem(ip)
      |> Integer.digits()
      |> pad()

    case opcode do
      [0, 0, 0, @stop, @stop] ->
        {:noreply, %{ic | state: :stopped}, {:continue, :stop}}

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
        {:noreply, %{ic | tape: tape, ip: ip + 4}, {:continue, :run}}

      [_, _, 0, 0, @input] ->
        case inputs do
          [] ->
            {:noreply, %{ic | state: :sleeping}, :hibernate}

          [val | rest] ->
            dest = elem(tape, ip + 1)
            tape = store(tape, dest, val)
            {:noreply, %{ic | tape: tape, ip: ip + 2, inputs: rest}, {:continue, :run}}
        end

      [_, _, mode, 0, @output] ->
        out = load(tape, mode, ip + 1)
        Enum.each(subscribers, &send(&1, {:output, out}))
        {:noreply, %{ic | ip: ip + 2}, {:continue, :run}}

      [_, branch_mode, val_mode, 0, op] when op in [@if, @unless] ->
        val = load(tape, val_mode, ip + 1)

        ip =
          if (op == @if and val != 0) or (op == @unless and val == 0) do
            load(tape, branch_mode, ip + 2)
          else
            ip + 3
          end

        {:noreply, %{ic | ip: ip}, {:continue, :run}}

      [0, b_mode, a_mode, 0, op] when op in [@lt, @eq] ->
        a = load(tape, a_mode, ip + 1)
        b = load(tape, b_mode, ip + 2)
        dest = elem(tape, ip + 3)
        val = if (op == @lt and a < b) or (op == @eq and a == b), do: 1, else: 0
        tape = store(tape, dest, val)
        {:noreply, %{ic | tape: tape, ip: ip + 4}, {:continue, :run}}
    end
  end

  defp load(tape, 0, idx), do: elem(tape, elem(tape, idx))
  defp load(tape, 1, idx), do: elem(tape, idx)

  defp store(tape, idx, val), do: replace_at(tape, idx, val)

  defp pad(op) when length(op) >= 5, do: op
  defp pad(op), do: pad([0 | op])
end
