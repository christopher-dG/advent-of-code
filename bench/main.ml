open Core_bench
open Lib

let () =
  Bench.make_command
    [
      Bench.Test.create ~name:"Day01p1" (fun () ->
          Day01.Impl.part1 Day01.Impl.lines);
      Bench.Test.create ~name:"Day01p2" (fun () ->
          Day01.Impl.part2 Day01.Impl.lines);
      Bench.Test.create ~name:"Day02p1" (fun () ->
          Day02.Impl.part1 Day02.Impl.lines);
      Bench.Test.create ~name:"Day02p2" (fun () ->
          Day02.Impl.part2 Day02.Impl.lines);
      Bench.Test.create ~name:"Day03p1" (fun () ->
          Day03.Impl.part1 Day03.Impl.lines);
      Bench.Test.create ~name:"Day03p2" (fun () ->
          Day03.Impl.part2 Day03.Impl.lines);
      Bench.Test.create ~name:"Day04p1" (fun () ->
          Day04.Impl.part1 Day04.Impl.lines);
      Bench.Test.create ~name:"Day04p2" (fun () ->
          Day04.Impl.part2 Day04.Impl.lines);
      Bench.Test.create ~name:"Day05p1" (fun () ->
          Day05.Impl.part1 Day05.Impl.lines);
      Bench.Test.create ~name:"Day05p2" (fun () ->
          Day05.Impl.part2 Day05.Impl.lines);
    ]
  |> Command.run
