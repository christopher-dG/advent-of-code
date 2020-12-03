open Core

let read_lines path = path |> In_channel.read_lines

let read_ints path = path |> read_lines |> List.map ~f:int_of_string
