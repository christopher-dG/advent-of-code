(* module Impl = Day.Make (struct *)
let parse_input lines =
  let parse_rule line =
    let open Re in
    let[@warning "-8"] [| _; name; a1; b1; a2; b2 |] =
      Group.all (exec (Pcre.regexp "(.*): (\\d+)-(\\d+) or (\\d+)-(\\d+)") line)
    in
    ( name,
      (int_of_string a1, int_of_string b1),
      (int_of_string a2, int_of_string b2) )
  in
  let parse_ticket line =
    line |> String.split ~on:',' |> List.map ~f:int_of_string
  in
  let[@warning "-8"] ( rules,
                       ""
                       :: "your ticket:"
                          :: mine :: "" :: "nearby tickets:" :: nearby ) =
    List.split_while lines ~f:(fun line -> not (String.equal line ""))
  in
  let rules = List.map rules ~f:parse_rule in
  let mine = parse_ticket mine in
  let nearby = List.map nearby ~f:parse_ticket in
  (rules, mine, nearby)

let invalid_fields rules ticket =
  List.filter ticket ~f:(fun n ->
      List.for_all rules ~f:(fun (_, (a1, b1), (a2, b2)) ->
          (n < a1 || n > b1) && (n < a2 || n > b2)))

let invalids_sum rules tickets =
  List.fold tickets ~init:0 ~f:(fun acc ticket ->
      acc + (invalid_fields rules ticket |> List.fold ~init:0 ~f:( + )))

module Out = Int

let day = 16

let part1 lines =
  let rules, _, nearby = parse_input lines in
  invalids_sum rules nearby

let part2 _lines = 2

let sol1 = 1

let sol2 = 2

(* let%test "examples" = true *)
(* end) *)
