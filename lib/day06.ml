module Impl = Day.Make (struct
  let rec split_groups ?(acc = []) ?(cur = []) lines =
    let string_set s = s |> String.to_list |> Set.of_list (module Char) in
    match lines with
    | [] -> cur :: acc
    | "" :: tl -> split_groups ~acc:(cur :: acc) ~cur:[] tl
    | hd :: tl -> split_groups ~acc ~cur:(string_set hd :: cur) tl

  let solution lines ~f =
    lines |> split_groups
    |> List.map ~f:(fun sets -> sets |> List.reduce_exn ~f |> Set.length)
    |> List.reduce_exn ~f:( + )

  module Out = Int

  let day = 6

  let part1 lines = solution lines ~f:Set.union

  let part2 lines = solution lines ~f:Set.inter

  let sol1 = 6748

  let sol2 = 3445

  let%test "examples" =
    let lines =
      [
        "abc";
        "";
        "a";
        "b";
        "c";
        "";
        "ab";
        "ac";
        "";
        "a";
        "a";
        "a";
        "a";
        "";
        "b";
      ]
    in
    part1 lines = 11 && part2 lines = 6
end)
