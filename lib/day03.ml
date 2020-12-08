module Impl = Day.Make (struct
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

  module Out = Int

  let day = 3

  let part1 lines = lines |> build_grid |> traverse ~x:3 ~y:1

  let part2 lines =
    let grid = build_grid lines in
    [ (1, 1); (3, 1); (5, 1); (7, 1); (1, 2) ]
    |> List.map ~f:(fun (x, y) -> traverse grid ~x ~y)
    (* 12/03: * can be accessed as ( * ). *)
    |> List.reduce_exn ~f:(fun x y -> x * y)

  let sol1 = 276

  let sol2 = 7812180000

  let%test "examples" =
    let lines =
      [
        "..##.......";
        "#...#...#..";
        ".#....#..#.";
        "..#.#...#.#";
        ".#...##..#.";
        "..#.##.....";
        ".#.#.#....#";
        ".#........#";
        "#.##...#...";
        "#...##....#";
        ".#..#...#.#";
      ]
    in
    part1 lines = 7 && part2 lines = 336
end)
