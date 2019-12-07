defmodule AOCTest do
  use ExUnit.Case

  Enum.each(1..25, fn day ->
    try do
      Module.safe_concat(AOC, "Day#{day}")
    rescue
      _e -> :noop
    else
      mod -> doctest mod
    end
  end)
end
