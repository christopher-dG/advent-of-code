open Core
open Re
open Util

let parse_line line =
  let re = Pcre.regexp "(\\d+)-(\\d+) ([a-z]): ([a-z]+)" in
  let[@warning "-8"] [| _; a; b; char; pass |] = Group.all (exec re line) in
  (int_of_string a, int_of_string b, char.[0], pass)

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

let%test "examples" =
  let lines = [ "1-3 a: abcde"; "1-3 b: cdefg"; "2-9 c: ccccccccc" ] in
  part1 lines = 2 && part2 lines = 1

let%test "input" =
  let lines = read_lines "../input/2.txt" in
  part1 lines = 556 && part2 lines = 605
