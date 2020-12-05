open Core
open Core_bench
open Lib

let inputs =
  let days = List.range 1 6 in
  let read_lines day = Util.read_lines (Util.input_file day) in
  let inputs = List.map days ~f:read_lines in
  Array.of_list ([] :: inputs)

let () =
  Bench.make_command
    [
      Bench.Test.create ~name:"Day01p1" (fun () -> Day01.part1 inputs.(1));
      Bench.Test.create ~name:"Day01p2" (fun () -> Day01.part2 inputs.(1));
      Bench.Test.create ~name:"Day02p1" (fun () -> Day02.part1 inputs.(2));
      Bench.Test.create ~name:"Day02p2" (fun () -> Day02.part2 inputs.(2));
      Bench.Test.create ~name:"Day03p1" (fun () -> Day03.part1 inputs.(3));
      Bench.Test.create ~name:"Day03p2" (fun () -> Day03.part2 inputs.(3));
      Bench.Test.create ~name:"Day04p1" (fun () -> Day04.part1 inputs.(4));
      Bench.Test.create ~name:"Day04p2" (fun () -> Day04.part2 inputs.(4));
      Bench.Test.create ~name:"Day05p1" (fun () -> Day05.part1 inputs.(5));
      Bench.Test.create ~name:"Day05p2" (fun () -> Day05.part2 inputs.(5));
    ]
  |> Command.run
