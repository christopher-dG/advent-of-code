module Impl = Day.Make (struct
  let rec bin_partition ?(min = 0) ?max chars =
    (* FYI: This is a lot faster if you just use some bit shifts. *)
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

  let[@warning "-8"] rec find_hole_in_range = function
    | x :: y :: _ when x <> y - 1 -> x + 1
    | _ :: tl -> find_hole_in_range tl

  module Out = Int

  let day = 5

  let part1 lines =
    let id =
      lines |> List.map ~f:seat_id |> List.max_elt ~compare:Int.compare
    in
    Option.value_exn id

  let part2 lines =
    lines |> List.map ~f:seat_id
    |> List.sort ~compare:Int.compare
    |> find_hole_in_range

  let sol1 = 978

  let sol2 = 727

  let%test "examples" =
    seat_id "FBFBBFFRLR" = 357
    && seat_id "BFFFBBFRRR" = 567
    && seat_id "FFFBBBFRRR" = 119
    && seat_id "BBFFBBFRLL" = 820
end)
