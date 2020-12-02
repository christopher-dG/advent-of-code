open Core
open Printf

open Util

let rec two_sum_product xs target set =
  match xs with
  | [] ->
     raise (Invalid_argument "No solution")
  | hd :: tl ->
     let comp = target - hd in
     if Set.exists set ~f:((=) comp) then
       hd * comp
     else
       two_sum_product tl target set

let part1 xs target =
  let set = Set.of_list (module Int) xs in
  two_sum_product xs target set

let three_sum_table xs =
  let tbl = Hashtbl.create (module Int) in
  let idxs = List.mapi xs ~f:(fun i x -> (i, x)) in
  let _ =
    idxs
    |> List.cartesian_product idxs
    |> List.filter ~f:(fun ((i, _), (j, _)) -> not (i = j))
    |> List.map ~f:(fun ((i, a), (j, b)) -> Hashtbl.add tbl ~key:(a + b) ~data:(i, j)) in
  tbl

let rec three_sum_idxs xs target tbl =
  match xs with
  | [] ->
     raise (Invalid_argument "No solution")
  | (i, x) :: tl ->
     let comp = target - x in
     match Hashtbl.find tbl comp with
     | Some (j, k) ->
        if i = j || i = k then
          three_sum_idxs tl target tbl
        else
          (i, j, k)
     | None -> three_sum_idxs tl target tbl

let three_sum_product xs i j k =
  let arr = Array.of_list xs in
  arr.(i) * arr.(j) * arr.(k)

let part2 xs target =
  let tbl = three_sum_table xs in
  let with_idx = List.mapi xs ~f:(fun i x -> (i, x)) in
  let (i, j, k) = three_sum_idxs with_idx target tbl in
  three_sum_product xs i j k

let run path =
  let xs = read_ints path in
  let sol1 = part1 xs 2020 in
  let sol2 = part2 xs 2020 in
  printf "Part 1: %d\nPart 2: %d\n" sol1 sol2

let%test "part 1 (example)" = part1 [1721; 979; 366; 299; 675; 1456] 2020 = 514579
let%test "part 1 (input)" = part1 (read_ints "../input/1.txt") 2020 = 545379
let%test "part 2 (example)" = part2 [1721; 979; 366; 299; 675; 1456] 2020 = 241861950
let%test "part 2 (input)" = part2 (read_ints "../input/1.txt") 2020 = 257778836
