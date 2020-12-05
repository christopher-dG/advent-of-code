(* TODO: Is there a way to bind this to the root Day01 module? *)
module Impl = Day.Make (struct
  let rec two_sum_product xs target set =
    (* 12/05: match[@warning "-8"] can be used to skip exhaustiveness checks. *)
    match xs with
    | [] -> raise (Invalid_argument "No solution")
    | hd :: tl ->
        let comp = target - hd in
        if Set.exists set ~f:(( = ) comp) then hd * comp
        else two_sum_product tl target set

  let three_sum_table xs =
    let tbl = Hashtbl.create (module Int) in
    let idxs = List.mapi xs ~f:(fun i x -> (i, x)) in
    let _ =
      idxs
      |> List.cartesian_product idxs
      |> List.filter ~f:(fun ((i, _), (j, _)) -> not (i = j))
      (* 12/04: `List.iter` should be used for side effects. *)
      |> List.map ~f:(fun ((i, a), (j, b)) ->
             Hashtbl.add tbl ~key:(a + b) ~data:(i, j))
    in
    tbl

  let rec three_sum_idxs xs target tbl =
    match xs with
    | [] -> raise (Invalid_argument "No solution")
    | (i, x) :: tl -> (
        let comp = target - x in
        match Hashtbl.find tbl comp with
        | Some (j, k) ->
            if i = j || i = k then three_sum_idxs tl target tbl else (i, j, k)
        | None -> three_sum_idxs tl target tbl )

  let three_sum_product xs i j k =
    let arr = Array.of_list xs in
    arr.(i) * arr.(j) * arr.(k)

  let part1 lines =
    let xs = List.map lines ~f:int_of_string in
    let set = Set.of_list (module Int) xs in
    two_sum_product xs 2020 set

  let part2 lines =
    let xs = List.map lines ~f:int_of_string in
    let tbl = three_sum_table xs in
    let with_idx = List.mapi xs ~f:(fun i x -> (i, x)) in
    let i, j, k = three_sum_idxs with_idx 2020 tbl in
    three_sum_product xs i j k

  module Out = Int

  let day = 1

  let sol1 = 545379

  let sol2 = 257778836

  let%test "examples" =
    let lines = [ "1721"; "979"; "366"; "299"; "675"; "1456" ] in
    part1 lines = 514579 && part2 lines = 241861950
end)
