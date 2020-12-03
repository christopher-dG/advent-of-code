open Core

open Lib

let () =
  let argv = Sys.get_argv () in
  let day = int_of_string argv.(1) in
  let f = match day with
  | 1 ->
     Day1.run
  | 2 ->
     Day2.run
  | _ ->
     raise (Invalid_argument "Unsupported day") in
  f ()
