defmodule AOC.Utils do
  @moduledoc "Random convenience functions."

  @doc "Replace a value at in index in some collection."
  def replace_at(list, idx, x) when is_list(list), do: List.replace_at(list, idx, x)

  def replace_at(tuple, idx, x) when is_tuple(tuple) do
    tuple
    |> Tuple.delete_at(idx)
    |> Tuple.insert_at(idx, x)
  end
end
