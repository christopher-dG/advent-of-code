module Impl = Day.Make (struct
  let rec count_diffs ?acc xs =
    match acc with
    | None ->
        0 :: xs |> List.sort ~compare:Int.compare |> count_diffs ~acc:((0, 0), 0)
    | Some ((ones, threes), cur) -> (
        match xs with
        | [] -> (ones, threes + 1)
        | hd :: tl ->
            let ones, threes =
              match[@warning "-8"] hd - cur with
              | 0 -> (ones, threes)
              | 1 -> (ones + 1, threes)
              | 3 -> (ones, threes + 1)
            in
            count_diffs tl ~acc:((ones, threes), hd) )

  let rec count_chains ?(cache = Map.empty (module Int)) ?idx xs =
    let len = List.length xs in
    let idx, xs =
      match idx with
      | Some i -> (i, xs)
      | None -> (len, List.sort (0 :: xs) ~compare:Int.compare)
    in
    match Map.find cache idx with
    | Some n -> n
    | None ->
        let n =
          match List.slice xs idx len with
          | [] | [ _ ] | [ _; _ ] -> 1
          | [ a; _; c ] -> if c - a <= 3 then 2 else 1
          | xs ->
              let steps =
                match[@warning "-8"] xs with
                | hd :: _ :: b :: _ when b - hd > 3 -> 1
                | hd :: _ :: _ :: c :: _ when c - hd > 3 -> 2
                | hd :: _ :: _ :: c :: _ when c - hd = 3 -> 3
              in
              List.range 0 steps
              |> List.fold ~init:0 ~f:(fun acc i ->
                     acc + Map.find_exn cache (idx + i + 1))
        in
        if idx = 0 then n
        else
          let cache = Map.set cache ~key:idx ~data:n in
          count_chains xs ~cache ~idx:(idx - 1)

  module Out = Int

  let day = 10

  let part1 lines =
    lines |> List.map ~f:int_of_string |> count_diffs |> fun (ones, threes) ->
    ones * threes

  let part2 lines = lines |> List.map ~f:int_of_string |> count_chains

  let sol1 = 2030

  let sol2 = 42313823813632

  let%test "examples (short)" =
    let lines =
      [ "16"; "10"; "15"; "5"; "1"; "11"; "7"; "19"; "6"; "12"; "4" ]
    in
    part1 lines = 35 && part2 lines = 8

  let%test "examples (long)" =
    let lines =
      [
        "28";
        "33";
        "18";
        "42";
        "31";
        "14";
        "46";
        "20";
        "48";
        "47";
        "24";
        "23";
        "49";
        "45";
        "19";
        "38";
        "39";
        "11";
        "1";
        "32";
        "25";
        "35";
        "8";
        "17";
        "7";
        "9";
        "4";
        "2";
        "34";
        "10";
        "3";
      ]
    in
    part1 lines = 220 && part2 lines = 19208
end)
