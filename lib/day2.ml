open Core
open Re
open Util

let parse_line line =
  let re = Pcre.regexp "(\\d+)-(\\d+) ([a-z]): ([a-z]+)" in
  match Group.all (exec re line) with
  | [| _; a; b; char; pass |] ->
      (int_of_string a, int_of_string b, char.[0], pass)
  | _ -> raise (Invalid_argument "Invalid line")

let is_valid_password_sled line =
  let min, max, char, pass = parse_line line in
  let count = String.count pass ~f:(Char.equal char) in
  count >= min && count <= max

let part1 lines = List.count lines ~f:is_valid_password_sled

let is_valid_password_toboggan line =
  let i, j, char, pass = parse_line line in
  let i_eq = Char.equal char pass.[i - 1] in
  let j_eq = Char.equal char pass.[j - 1] in
  not (Bool.equal i_eq j_eq)

let part2 lines = List.count lines ~f:is_valid_password_toboggan

let run () =
  let lines = read_lines "input/2.txt" in
  let sol1 = part1 lines in
  let sol2 = part2 lines in
  printf "Part 1: %d\nPart 2: %d\n" sol1 sol2
