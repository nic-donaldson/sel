open Core
open Notty
open Notty_unix

type selection =
  | Selected
  | NotSelected

type line = (string * selection)

let string_of_line (l : line) = fst l

let read_lines ic =
  In_channel.input_lines ic |> List.map ~f:(fun l -> (l, NotSelected))

let rec select (ls : line list) (n : int) =
  match (n, ls) with
  | (_, []) -> []
  | (0, (l,_)::tl) -> (l,Selected)::tl
  | (_, (l,_)::tl) -> (l,NotSelected)::(select tl (pred n))

let selected ls = List.find ls ~f:(fun x -> match x with
    | (_,Selected) -> true
    | (_,NotSelected) -> false)

let rec next = function
  | [] -> []
  | [x] -> [x]
  | (l,Selected)::(m,_)::tl -> (l,NotSelected)::(m,Selected)::tl
  | hd::tl -> hd::(next tl)

let rec prev = function
  | [] -> []
  | [x] -> [x]
  | (l,NotSelected)::(m,Selected)::tl -> (l,Selected)::(m,NotSelected)::tl
  | hd::tl -> hd::(prev tl)

let draw lines =
  List.map lines
    ~f:(fun (l,s) -> match s with
        | Selected -> I.string A.(bg white ++ fg black) l
        | NotSelected -> I.string A.(bg black ++ fg white) l)
  |> I.vcat

let print_selected lines =
  match (selected lines) with
  | Some (l,_) -> print_endline l
  | None -> ()

let rec main_loop lines t =
  let img = draw lines in
  Term.image t img;
  match Term.event t with
  | `End | `Key (`Escape, []) | `Key (`ASCII 'q', []) -> ()
  | `Key (`Arrow `Down,_) -> main_loop (next lines) t
  | `Key (`Arrow `Up,_) -> main_loop (prev lines) t
  | `Key (`Enter,_) -> print_selected lines
  | _ -> main_loop lines t

let () =
  let lines = select (read_lines In_channel.stdin) 0 in
  let tty = Unix.openfile ~mode:[Unix.O_RDWR] "/dev/tty" in
  let t = Term.create ~input:tty ~output:Unix.stderr () in main_loop lines t
