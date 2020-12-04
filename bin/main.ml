open Lib

let () =
  let argv = Sys.get_argv () in
  let day = int_of_string argv.(1) in
  let f =
    match day with
    | 1 -> Day01.run
    | 2 -> Day02.run
    | 3 -> Day03.run
    | 4 -> Day04.run
    | _ -> raise (Invalid_argument "Unsupported day")
  in
  f ()
