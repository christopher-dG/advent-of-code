module Impl = Day.Make (struct
  let parse_bag bag =
    let open Re in
    let re = Pcre.regexp "(\\d+) (.*) bags?" in
    let[@warning "-8"] [| _; n; colour |] = Group.all (exec re bag) in
    (colour, int_of_string n)

  let rec parse_rules ?(acc = Hashtbl.create (module String)) lines =
    match lines with
    | [] -> acc
    | hd :: tl ->
        let open Re in
        let re = Pcre.regexp "(.*) bags contain (.*)\\." in
        let[@warning "-8"] [| _; bag; others |] = Group.all (exec re hd) in
        let others =
          if String.equal others "no other bags" then []
          else
            others |> String.split ~on:',' |> List.map ~f:String.strip
            |> List.map ~f:parse_bag
        in
        let () = Hashtbl.set acc ~key:bag ~data:others in
        parse_rules tl ~acc

  let rec contains_bag rules bag target =
    Hashtbl.find_exn rules bag
    |> List.exists ~f:(fun (b, _) ->
           String.equal b target || contains_bag rules b target)

  let rec count_contents rules bag =
    Hashtbl.find_exn rules bag
    |> List.fold ~init:0 ~f:(fun acc (b, n) ->
           acc + n + (n * count_contents rules b))

  module Out = Int

  let day = 7

  let part1 lines =
    let rules = parse_rules lines in
    Hashtbl.keys rules
    |> List.count ~f:(fun b -> contains_bag rules b "shiny gold")

  let part2 lines =
    let rules = parse_rules lines in
    count_contents rules "shiny gold"

  let sol1 = 185

  let sol2 = 89084

  let%test "examples (1)" =
    let lines =
      [
        "light red bags contain 1 bright white bag, 2 muted yellow bags.";
        "dark orange bags contain 3 bright white bags, 4 muted yellow bags.";
        "bright white bags contain 1 shiny gold bag.";
        "muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.";
        "shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.";
        "dark olive bags contain 3 faded blue bags, 4 dotted black bags.";
        "vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.";
        "faded blue bags contain no other bags.";
        "dotted black bags contain no other bags.";
      ]
    in
    part1 lines = 4 && part2 lines = 32

  let%test "examples (2)" =
    let lines =
      [
        "shiny gold bags contain 2 dark red bags.";
        "dark red bags contain 2 dark orange bags.";
        "dark orange bags contain 2 dark yellow bags.";
        "dark yellow bags contain 2 dark green bags.";
        "dark green bags contain 2 dark blue bags.";
        "dark blue bags contain 2 dark violet bags.";
        "dark violet bags contain no other bags.";
      ]
    in
    part2 lines = 126
end)
