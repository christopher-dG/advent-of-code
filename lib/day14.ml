module Impl = Day.Make (struct
  type mask = One | Zero | X

  type instruction = Mask of mask list | Mem of int * int

  let parse_program lines =
    let parse_instruction line =
      let parse_mask str =
        str |> String.to_list_rev
        |> List.map ~f:(function [@warning "-8"]
             | '1' -> One
             | '0' -> Zero
             | 'X' -> X)
      in
      let open Re in
      match exec_opt (Pcre.regexp "mem\\[(\\d+)\\] = (\\d+)") line with
      | None ->
          let str = Group.get (exec (Pcre.regexp "mask = (.*)") line) 1 in
          Mask (parse_mask str)
      | Some groups ->
          let[@warning "-8"] [| _; address; value |] = Group.all groups in
          Mem (int_of_string address, int_of_string value)
    in
    List.map lines ~f:parse_instruction

  let store_masked_value mem mask ~address ~value =
    let masked =
      List.foldi mask ~init:0 ~f:(fun i acc m ->
          let n = Int.pow 2 i in
          match m with
          | One -> acc + n
          | Zero -> acc
          | X -> acc + Int.bit_and value n)
    in
    Map.set mem ~key:address ~data:masked

  let store_at_masked_addresses mem mask ~address ~value =
    let rec expand ?(acc = [ 0 ]) bits =
      match bits with
      | [] -> acc
      | hd :: tl ->
          let zeros = acc in
          let ones = List.map acc ~f:(fun n -> n + Int.pow 2 hd) in
          expand tl ~acc:(List.append zeros ones)
    in
    let base, floats =
      List.foldi mask ~init:(0, []) ~f:(fun i (sum, floats) m ->
          let n = Int.pow 2 i in
          match m with
          | One -> (sum + n, floats)
          | Zero -> (sum + Int.bit_and address n, floats)
          | X -> (sum, i :: floats))
    in
    List.fold (expand floats) ~init:mem ~f:(fun mem n ->
        Map.set mem ~key:(base + n) ~data:value)

  let rec run_program ?mem ?mask ~f instructions =
    let mask = Option.value mask ~default:[] in
    let mem = Option.value mem ~default:(Map.empty (module Int)) in
    match instructions with
    | [] -> Map.to_alist mem
    | Mask mask :: tl -> run_program tl ~mem ~mask ~f
    | Mem (address, value) :: tl ->
        let mem = f mem mask ~address ~value in
        run_program tl ~mem ~mask ~f

  let solution lines ~f =
    lines |> parse_program |> run_program ~f
    |> List.fold ~init:0 ~f:(fun acc (_, n) -> acc + n)

  module Out = Int

  let day = 14

  let part1 lines = solution lines ~f:store_masked_value

  let part2 lines = solution lines ~f:store_at_masked_addresses

  let sol1 = 13496669152158

  let sol2 = 3278997609887

  let%test "examples (p1)" =
    let lines =
      [
        "mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X";
        "mem[8] = 11";
        "mem[7] = 101";
        "mem[8] = 0";
      ]
    in
    part1 lines = 165

  let%test "examples (p2)" =
    let lines =
      [
        "mask = 000000000000000000000000000000X1001X";
        "mem[42] = 100";
        "mask = 00000000000000000000000000000000X0XX";
        "mem[26] = 1";
      ]
    in
    part2 lines = 208
end)
