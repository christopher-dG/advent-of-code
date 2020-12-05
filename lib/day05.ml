open Util

let rec bin_partition ?min ?max chars =
  let min = Option.value min ~default:0 in
  let max = Option.value max ~default:(Int.pow 2 (String.length chars) - 1) in
  if String.is_empty chars then min
  else
    let hd = chars.[0] in
    let tl = String.slice chars 1 (String.length chars) in
    let delta =
      int_of_float (Float.round_up (float_of_int (max - min)) /. 2.0)
    in
    match[@warning "-8"] hd with
    | 'F' | 'L' -> bin_partition ~min ~max:(max - delta - 1) tl
    | 'B' | 'R' -> bin_partition ~min:(min + delta + 1) ~max tl

let seat_id pass =
  let row = bin_partition (String.slice pass 0 7) in
  let col = bin_partition (String.slice pass 7 10) in
  (row * 8) + col

let part1 lines =
  let id = lines |> List.map ~f:seat_id |> List.max_elt ~compare:Int.compare in
  Option.value_exn id

let[@warning "-8"] rec find_hole_in_range = function
  | x :: y :: _ when x <> y - 1 -> x + 1
  | _ :: tl -> find_hole_in_range tl

let part2 lines =
  lines |> List.map ~f:seat_id
  |> List.sort ~compare:Int.compare
  |> find_hole_in_range

let run () =
  let lines = read_lines (input_file 5) in
  let sol1 = part1 lines in
  let sol2 = part2 lines in
  printf "Part 1: %d\nPart 2: %d\n" sol1 sol2

let%test "examples" =
  seat_id "FBFBBFFRLR" = 357
  && seat_id "BFFFBBFRRR" = 567
  && seat_id "FFFBBBFRRR" = 119
  && seat_id "BBFFBBFRLL" = 820

let%test "input" =
  let lines = read_lines (input_file 5) in
  part1 lines = 978 && part2 lines = 727
