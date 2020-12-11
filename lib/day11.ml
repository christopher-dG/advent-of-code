module Impl = Day.Make (struct
  type space = Floor | Empty | Occupied

  let parse_row row =
    row |> String.to_array
    |> Array.map ~f:(function [@warning "-8"]
         | '.' -> Floor
         | 'L' -> Empty
         | '#' -> Occupied)

  let is_occupied floor (i, j) =
    if i >= 0 && i < Array.length floor && j >= 0 && j < Array.length floor.(0)
    then
      match floor.(i).(j) with
      | Occupied -> Some true
      | Empty -> Some false
      | Floor -> None
    else Some false

  let adjacent =
    [ (-1, -1); (-1, 0); (-1, 1); (0, -1); (0, 1); (1, -1); (1, 0); (1, 1) ]

  let count_adjacent floor (i, j) =
    List.count adjacent ~f:(fun (di, dj) ->
        is_occupied floor (i + di, j + dj) |> Option.value ~default:false)

  let count_visible floor (i, j) =
    let rec can_see_occupied floor (i, j) ~di ~dj =
      let i, j = (i + di, j + dj) in
      match is_occupied floor (i, j) with
      | None -> can_see_occupied floor (i, j) ~di ~dj
      | Some true -> true
      | Some false -> false
    in
    List.count adjacent ~f:(fun (di, dj) ->
        can_see_occupied floor (i, j) ~di ~dj)

  let rec simulate ~count ~threshold floor =
    let next_state floor (i, j) =
      let count = count floor (i, j) in
      match floor.(i).(j) with
      | Occupied -> if count >= threshold then Empty else Occupied
      | Empty -> if count = 0 then Occupied else Empty
      | Floor -> Floor
    in
    let next =
      Array.mapi floor ~f:(fun i row ->
          Array.mapi row ~f:(fun j _ -> next_state floor (i, j)))
    in
    if Array.equal (Array.equal phys_equal) floor next then floor
    else simulate next ~count ~threshold

  let solution lines ~count ~threshold =
    lines
    |> Array.of_list_map ~f:parse_row
    |> simulate ~count ~threshold
    |> Array.fold ~init:0 ~f:(fun acc row ->
           acc + Array.count row ~f:(phys_equal Occupied))

  module Out = Int

  let day = 11

  let part1 lines = solution lines ~count:count_adjacent ~threshold:4

  let part2 lines = solution lines ~count:count_visible ~threshold:5

  let sol1 = 2334

  let sol2 = 2100

  let%test "examples" =
    let lines =
      [
        "L.LL.LL.LL";
        "LLLLLLL.LL";
        "L.L.L..L..";
        "LLLL.LL.LL";
        "L.LL.LL.LL";
        "L.LLLLL.LL";
        "..L.L.....";
        "LLLLLLLLLL";
        "L.LLLLLL.L";
        "L.LLLLL.LL";
      ]
    in
    part1 lines = 37 && part2 lines = 26
end)
