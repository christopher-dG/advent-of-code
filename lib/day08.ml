module Impl = Day.Make (struct
  type instruction = NoOp of int | Acc of int | Jump of int

  let parse_instructions lines =
    let parse_instruction line =
      let[@warning "-8"] [ instruction; arg ] = String.split line ~on:' ' in
      match[@warning "-8"] instruction with
      | "nop" -> NoOp (int_of_string arg)
      | "acc" -> Acc (int_of_string arg)
      | "jmp" -> Jump (int_of_string arg)
    in
    lines |> List.map ~f:parse_instruction |> Array.of_list

  let rec simulate ?(acc = 0) ?(pc = 0) ?(seen = Set.empty (module Int))
      instructions =
    if Set.mem seen pc then (acc, false)
    else if pc = Array.length instructions then (acc, true)
    else
      let seen = Set.add seen pc in
      match instructions.(pc) with
      | NoOp _ -> simulate ~acc ~pc:(pc + 1) ~seen instructions
      | Acc n -> simulate ~acc:(acc + n) ~pc:(pc + 1) ~seen instructions
      | Jump n -> simulate ~acc ~pc:(pc + n) ~seen instructions

  let with_replaced instructions i =
    let instruction = instructions.(i) in
    let () =
      match instruction with
      | NoOp n -> instructions.(i) <- Jump n
      | Jump _ -> instructions.(i) <- NoOp 0
      | _ -> ()
    in
    let result = simulate instructions in
    let () = instructions.(i) <- instruction in
    match result with n, true -> Some n | _ -> None

  module Out = Int

  let day = 8

  let part1 lines =
    let n, _ = lines |> parse_instructions |> simulate in
    n

  let part2 lines =
    let instructions = parse_instructions lines in
    let n =
      List.range 0 (Array.length instructions)
      |> List.find_map ~f:(with_replaced instructions)
    in
    Option.value_exn n

  let sol1 = 1614

  let sol2 = 1260

  let%test "examples" =
    let lines =
      "nop +0\nacc +1\njmp +4\nacc +3\njmp -3\nacc -99\nacc +1\njmp -4\nacc +6"
      |> String.split ~on:'\n'
    in
    part1 lines = 5 && part2 lines = 8
end)
