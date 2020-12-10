module Impl = Day.Make (struct
  let rec two_sum_p xs target =
    match xs with
    | [] -> false
    | hd :: tl ->
        if List.exists tl ~f:(( = ) (target - hd)) then true
        else two_sum_p tl target

  let rec find_no_sum ~len xs =
    let[@warning "-8"] preamble, target :: _ = List.split_n xs len in
    if two_sum_p preamble target then find_no_sum (List.tl_exn xs) ~len
    else target

  let rec find_summing_seq ?(len = 0) ?(sum = 0) ?slice ~target xs =
    let slice = Option.value slice ~default:xs in
    match slice with
    | [] -> find_summing_seq (List.tl_exn xs) ~target
    | hd :: tl ->
        let sum = sum + hd in
        if sum = target then List.slice xs 0 len
        else if sum > target then find_summing_seq (List.tl_exn xs) ~target
        else find_summing_seq xs ~len:(len + 1) ~sum ~target ~slice:tl

  let add_min_max xs =
    let min = List.min_elt xs ~compare:Int.compare in
    let max = List.max_elt xs ~compare:Int.compare in
    Option.value_exn min + Option.value_exn max

  module Out = Int

  let day = 9

  let part1 lines = lines |> List.map ~f:int_of_string |> find_no_sum ~len:25

  let sol1 = 731031916

  let part2 lines =
    lines |> List.map ~f:int_of_string
    |> find_summing_seq ~target:sol1
    |> add_min_max

  let sol2 = 93396727

  let%test "examples" =
    let lines =
      [
        35;
        20;
        15;
        25;
        47;
        40;
        62;
        55;
        65;
        95;
        102;
        117;
        150;
        182;
        127;
        219;
        299;
        277;
        309;
        576;
      ]
    in
    find_no_sum lines ~len:5 = 127
    && find_summing_seq lines ~target:127 |> add_min_max = 62
end)
