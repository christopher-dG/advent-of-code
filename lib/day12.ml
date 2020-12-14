(* Today's code kinda sucks *)
module Impl = Day.Make (struct
  let parse_instructions lines =
    List.map lines ~f:(fun line ->
        (line.[0], String.drop_prefix line 1 |> int_of_string))

  let do_move (x, y) (dir, n) =
    match[@warning "-8"] dir with
    | 'E' -> (x + n, y)
    | 'W' -> (x - n, y)
    | 'N' -> (x, y + n)
    | 'S' -> (x, y - n)

  let change_direction cur (dir, n) =
    let scalar = if Char.equal dir 'L' then -1 else 1 in
    let order = [| 'N'; 'E'; 'S'; 'W' |] in
    let idx, _ = Array.findi_exn order ~f:(fun _ d -> Char.equal d cur) in
    order.((idx + 4 + (scalar * n / 90)) mod 4)

  let run_instruction_1 (dir, (x, y)) (move, n) =
    match[@warning "-8"] move with
    | 'E' | 'W' | 'N' | 'S' -> (dir, do_move (x, y) (move, n))
    | 'F' -> (dir, do_move (x, y) (dir, n))
    | 'L' | 'R' -> (change_direction dir (move, n), (x, y))

  let run_route_1 instructions =
    List.fold instructions ~init:('E', (0, 0)) ~f:run_instruction_1

  let rotate_waypoint (x, y) (dir, n) =
    if n = 180 then (-x, -y)
    else
      let rotate_once (x, y) =
        if x >= 0 && y >= 0 then (y, -x)
        else if x >= 0 then (y, -x)
        else if x < 0 && y < 0 then (y, -x)
        else (y, -x)
      in
      let n = n / 90 in
      let n = if Char.equal dir 'R' then n else n + 2 in
      List.fold (List.range 0 n) ~init:(x, y) ~f:(fun pos _ -> rotate_once pos)

  let run_instruction_2 (ship, (way_x, way_y)) (move, n) =
    match[@warning "-8"] move with
    | 'E' | 'W' | 'N' | 'S' -> (ship, do_move (way_x, way_y) (move, n))
    | 'F' ->
        let ship = do_move ship ('E', n * way_x) in
        let ship = do_move ship ('N', n * way_y) in
        (ship, (way_x, way_y))
    | 'L' | 'R' -> (ship, rotate_waypoint (way_x, way_y) (move, n))

  let run_route_2 instructions =
    List.fold instructions ~init:((0, 0), (10, 1)) ~f:run_instruction_2

  module Out = Int

  let day = 12

  let part1 lines =
    let _, (ew, ns) = lines |> parse_instructions |> run_route_1 in
    abs ew + abs ns

  let part2 lines =
    let (ew, ns), _ = lines |> parse_instructions |> run_route_2 in
    abs ew + abs ns

  let sol1 = 2057

  let sol2 = 71504

  let%test "examples" =
    let lines = [ "F10"; "N3"; "F7"; "R90"; "F11" ] in
    part1 lines = 25 && part2 lines = 286
end)
