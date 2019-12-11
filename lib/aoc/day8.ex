defmodule AOC.Day8 do
  use AOC

  defp default, do: input("", &String.to_integer/1)

  @width 25
  @height 6

  @black 0
  @white 1
  @transparent 2

  @doc """
      iex> AOC.Day8.part1
      2500
  """
  def part1(inp \\ default()) do
    {_z, o, t} =
      inp
      # Partition the input into layers.
      |> Enum.chunk_every(@width * @height)
      # Count the pixel values of each layer.
      |> Enum.map(fn layer ->
        Enum.reduce(layer, {0, 0, 0}, fn digit, {z, o, t} ->
          case digit do
            0 -> {z + 1, o, t}
            1 -> {z, o + 1, t}
            2 -> {z, o, t + 1}
          end
        end)
      end)
      # Minimize by the zero count.
      |> Enum.min_by(fn {z, _o, _t} -> z end)

    o * t
  end

  @doc ~S"""
      iex> AOC.Day8.part2 |> String.split("\n")
      [" ▆▆  ▆   ▆▆  ▆  ▆▆  ▆  ▆ ",
       "▆  ▆ ▆   ▆▆  ▆ ▆  ▆ ▆  ▆ ",
       "▆     ▆ ▆ ▆  ▆ ▆  ▆ ▆▆▆▆ ",
       "▆      ▆  ▆  ▆ ▆▆▆▆ ▆  ▆ ",
       "▆  ▆   ▆  ▆  ▆ ▆  ▆ ▆  ▆ ",
       " ▆▆    ▆   ▆▆  ▆  ▆ ▆  ▆ "]
  """
  def part2(inp \\ default()) do
    inp
    |> Enum.with_index()
    # Layer the pixels by modding the index by the layer length.
    # The pixels look like [last_layer, ..., first_layer].
    |> Enum.reduce(%{}, fn {pixel, idx}, acc ->
      Map.update(acc, rem(idx, @width * @height), [pixel], &[pixel | &1])
    end)
    # Sort by index.
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn {_idx, pixel} ->
      pixel
      # Reverse to get the first layer first.
      |> Enum.reverse()
      |> Enum.find(&(&1 != @transparent))
      |> case do
        @white -> "▆"
        @black -> " "
      end
    end)
    # Split into rows, and join into one string.
    |> Enum.chunk_every(@width)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
  end
end
