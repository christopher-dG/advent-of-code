module Impl = Day.Make (struct
  let rec split_batch_rec lines cur acc =
    match lines with
    | [] -> cur :: acc
    | "" :: tl -> split_batch_rec tl "" (cur :: acc)
    | hd :: tl -> split_batch_rec tl (cur ^ " " ^ hd) acc

  let split_batch lines = split_batch_rec lines "" []

  let split_passport passport =
    passport |> String.split ~on:' ' |> List.map ~f:String.strip
    |> List.filter ~f:(fun s -> not (String.is_empty s))
    |> List.map ~f:(fun s ->
           let[@warning "-8"] [ a; b ] = String.split s ~on:':' in
           (a, b))

  let is_valid_passport_lazy passport =
    let required =
      Set.of_list
        (module String)
        [ "byr"; "iyr"; "eyr"; "hgt"; "hcl"; "ecl"; "pid" ]
    in
    let fields = passport |> split_passport |> List.map ~f:(fun (a, _) -> a) in
    let fields = Set.of_list (module String) fields in
    Set.is_subset required ~of_:fields

  let is_between value min max =
    let int = int_of_string value in
    int >= min && int <= max

  let is_between_years value min max =
    String.length value = 4 && is_between value min max

  let regex_matches value pattern =
    let open Re in
    let re = Pcre.regexp pattern in
    execp re value

  let validate_height value =
    let open Re in
    let re = Pcre.regexp "^(\\d+)(cm|in)$" in
    match exec_opt re value with
    | None -> false
    | Some m -> (
        let[@warning "-8"] [| _; n; unit |] = Group.all m in
        match[@warning "-8"] unit with
        | "cm" -> is_between n 150 193
        | "in" -> is_between n 59 76 )

  let validate_eye_colour value =
    List.mem
      [ "amb"; "blu"; "brn"; "gry"; "grn"; "hzl"; "oth" ]
      value ~equal:String.equal

  let validate_field (key, value) =
    match key with
    | "byr" -> is_between_years value 1920 2002
    | "iyr" -> is_between_years value 2010 2020
    | "eyr" -> is_between_years value 2020 2030
    | "hgt" -> validate_height value
    | "hcl" -> regex_matches value "^#[0-9a-f]{6}$"
    | "ecl" -> validate_eye_colour value
    | "pid" -> regex_matches value "^\\d{9}$"
    | _ -> true

  let is_valid_passport_strict passport =
    if is_valid_passport_lazy passport then
      passport |> split_passport |> List.for_all ~f:validate_field
    else false

  module Out = Int

  let day = 4

  let part1 lines = lines |> split_batch |> List.count ~f:is_valid_passport_lazy

  let part2 lines =
    lines |> split_batch |> List.count ~f:is_valid_passport_strict

  let sol1 = 260

  let sol2 = 153

  let%test "examples (part 1)" =
    let lines =
      "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd\n\
       byr:1937 iyr:2017 cid:147 hgt:183cm\n\n\
       iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884\n\
       hcl:#cfa07d byr:1929\n\n\
       hcl:#ae17e1 iyr:2013\n\
       eyr:2024\n\
       ecl:brn pid:760753108 byr:1931\n\
       hgt:179cm\n\n\
       hcl:#cfa07d eyr:2025 pid:166559648\n\
       iyr:2011 ecl:brn hgt:59in" |> String.split ~on:'\n'
    in
    part1 lines = 2

  let%test "examples (part 2-1)" =
    let lines =
      "eyr:1972 cid:100\n\
       hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926\n\n\
       iyr:2019\n\
       hcl:#602927 eyr:1967 hgt:170cm\n\
       ecl:grn pid:012533040 byr:1946\n\n\
       hcl:dab227 iyr:2012\n\
       ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277\n\n\
       hgt:59cm ecl:zzz\n\
       eyr:2038 hcl:74454a iyr:2023\n\
       pid:3556412378 byr:2007" |> String.split ~on:'\n'
    in
    part2 lines = 0

  let%test "examples (part 2-2)" =
    let lines =
      "pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980\n\
       hcl:#623a2f\n\n\
       eyr:2029 ecl:blu cid:129 byr:1989\n\
       iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm\n\n\
       hcl:#888785\n\
       hgt:164cm byr:2001 iyr:2015 cid:88\n\
       pid:545766238 ecl:hzl\n\
       eyr:2022\n\n\
       iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719"
      |> String.split ~on:'\n'
    in
    part2 lines = 4
end)
