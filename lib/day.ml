(* TODO: How to put signatures in an interface file? *)
module type Day = sig
  module Out : sig
    type t

    val equal : t -> t -> bool
  end

  val day : int

  val part1 : string list -> Out.t

  val part2 : string list -> Out.t

  val sol1 : Out.t

  val sol2 : Out.t
end

module Make (D : Day) = struct
  let lines =
    let rec find_input_file dir =
      let open Filename in
      let git = concat dir ".git" in
      let inputs = concat dir "input" in
      if Sys.is_directory_exn git then concat inputs (sprintf "%d.txt" D.day)
      else find_input_file (dirname dir)
    in
    Unix.getcwd () |> find_input_file |> In_channel.read_lines

  let part1 = D.part1

  let part2 = D.part2

  let%test "input" =
    let ( = ) = D.Out.equal in
    D.part1 lines = D.sol1 && D.part2 lines = D.sol2
end
