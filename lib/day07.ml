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
    let bags = Hashtbl.find_exn rules bag in
    if List.exists bags ~f:(fun (b, _) -> String.equal b target) then true
    else List.exists bags ~f:(fun (b, _) -> contains_bag rules b target)

  let rec count_contents rules bag =
    let contents = Hashtbl.find_exn rules bag in
    let acc = ref 0 in
    let () =
      List.iter contents ~f:(fun (b, n) ->
          acc := !acc + n + (n * count_contents rules b))
    in
    !acc

  module Out = Int

  let day = 7

  let part1 lines =
    let rules = parse_rules lines in
    let bags = Hashtbl.keys rules in
    List.count bags ~f:(fun b -> contains_bag rules b "shiny gold")

  let part2 lines =
    let rules = parse_rules lines in
    count_contents rules "shiny gold"

  let sol1 = 185

  let sol2 = 89084
end)
