open Core

open Lib

let () =
  let argv = Sys.get_argv () in
  let day = int_of_string argv.(1) in
  let input = argv.(2) in
  let f = match day with
  | 1 ->
     Day1.run
  | _ ->
     raise (Invalid_argument "Unsupported day") in
  f input
