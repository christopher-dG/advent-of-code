defmodule AOC do
  defmacro __using__(_) do
    quote do
      @day __MODULE__
           |> to_string()
           |> String.replace(~r/.+?([0-9]+)$/, "\\1")

      @file Path.join([__DIR__, "..", "..", "input", @day]) <> ".txt"
      @input File.read!(@file) |> String.trim()

      def input, do: @input
      def input(splitter), do: String.split(input(), splitter, trim: true)
      def input(splitter, parser), do: Enum.map(input(splitter), parser)

      import AOC.Utils
    end
  end
end
