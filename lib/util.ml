let read_lines path = path |> In_channel.read_lines

let input_file day =
  (* TODO: This does not work if you call it from the top level as `Util.input_file`. *)
  let open Filename in
  let rec parent path n =
    if Int.equal n 0 then path else parent (dirname path) (n - 1)
  in
  let txt = concat "input" (sprintf "%d.txt" day) in
  let cwd = Unix.getcwd () in
  let this = to_absolute_exn __FILE__ ~relative_to:cwd in
  let depth = if String.contains cwd '_' then 5 else 2 in
  let root =
    if this = "//toplevel//" then parent cwd 1 else parent this depth
  in
  concat root txt
