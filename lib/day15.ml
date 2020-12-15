module Impl = Day.Make (struct
  let init_game numbers ~turns =
    List.foldi numbers
      ~init:(Array.init (turns + 1) ~f:(fun _ -> []), 0)
      ~f:(fun i (acc, _) n ->
        let () = acc.(n) <- (i + 1) :: acc.(n) in
        (acc, n))

  let rec play_game ?turn ~turns (acc, last) =
    let turn =
      match turn with Some turn -> turn | None -> List.hd_exn acc.(last) + 1
    in
    let n = match acc.(last) with a :: b :: _ -> a - b | _ -> 0 in
    if turn = turns then n
    else
      let () = acc.(n) <- turn :: acc.(n) in
      play_game (acc, n) ~turns ~turn:(turn + 1)

  let solution lines turns =
    lines |> List.hd_exn |> String.split ~on:',' |> List.map ~f:int_of_string
    |> init_game ~turns |> play_game ~turns

  module Out = Int

  let day = 15

  let part1 lines = solution lines 2020

  let part2 lines = solution lines 30000000

  let sol1 = 412

  let sol2 = 243

  (* let%test "examples" = true *)
end)
