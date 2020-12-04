open Core
open Util

let build_grid lines =
  lines |> Array.of_list
  |> Array.map ~f:(fun line ->
         line |> String.to_array |> Array.map ~f:(Char.equal '#'))

let rec traverse_rec grid ~x ~y ~xd ~yd ~trees =
  if y >= Array.length grid then trees
  else
    let row = grid.(y) in
    let loc = row.(x mod Array.length row) in
    let trees = if loc then trees + 1 else trees in
    traverse_rec grid ~x:(x + xd) ~y:(y + yd) ~xd ~yd ~trees

let traverse grid ~x ~y = traverse_rec grid ~x:0 ~y:0 ~trees:0 ~xd:x ~yd:y

let part1 lines = lines |> build_grid |> traverse ~x:3 ~y:1

let part2 lines =
  let grid = build_grid lines in
  [ (1, 1); (3, 1); (5, 1); (7, 1); (1, 2) ]
  |> List.map ~f:(fun (x, y) -> traverse grid ~x ~y)
  |> List.reduce_exn ~f:(fun x y -> x * y)

let run () =
  let lines = read_lines (input_file 3) in
  let sol1 = part1 lines in
  let sol2 = part2 lines in
  printf "Part 1: %d\nPart 2: %d\n" sol1 sol2

let%test "examples" =
  let lines =
    "..##.......\n\
     #...#...#..\n\
     .#....#..#.\n\
     ..#.#...#.#\n\
     .#...##..#.\n\
     ..#.##.....\n\
     .#.#.#....#\n\
     .#........#\n\
     #.##...#...\n\
     #...##....#\n\
     .#..#...#.#" |> String.strip |> String.split ~on:'\n'
  in
  part1 lines = 7 && part2 lines = 336

let%test "input" =
  let lines = read_lines (input_file 3) in
  part1 lines = 276 && part2 lines = 7812180000
