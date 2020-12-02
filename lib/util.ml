open Core

let read_input path =
  path
  |> In_channel.read_lines

let read_ints path =
  path
  |> read_input
  |> List.map ~f:int_of_string
