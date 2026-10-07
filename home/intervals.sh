# shellcheck shell=bash
# Entraînement à l'oreille sur les sons de "intervalles audio" : un dossier par
# mode (01 montant, 02 descendant, 03 harmonique), un fichier par nombre de
# demi-tons, chaque piste finissant par la réponse parlée.
#   intervals            → progression par niveaux, reprend au niveau sauvegardé
#   intervals -n N       → progression à partir du niveau N
#   intervals all|1|2|3  → mode libre : tous les dossiers ou un seul, Entrée pour révéler
#
# Une session de progression : présentation des intervalles du niveau, puis
# blocs de 20 questions mélangées (on tape le nombre de demi-tons). 18/20
# valide le niveau ; sinon ~1 min d'écoute sans répondre avant le bloc suivant
# (alterner exercice et simple exposition fait mieux progresser que l'exercice
# seul, cf. Little, Cheng & Wright 2019).

root="${INTERVALS_DIR:-$HOME/Downloads/intervalles audio}"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/intervals"
state_file="$state_dir/level"

block_size=20
pass_score=18
exposure_size=16

# Niveau = modes|intervalles en demi-tons. Chaque niveau ne change qu'une chose,
# un intervalle ou un mode. Les paires de même nom (2m/2M, 3m/3M, 6m/6M, 7m/7M),
# les plus confondues, arrivent tard et séparément.
levels=(
  "asc|1 12"
  "asc|1 6 12"
  "asc desc|1 6 12"
  "asc desc|1 6 7 12"
  "asc desc harm|1 6 7 12"
  "asc desc harm|1 4 6 7 12"
  "asc desc harm|1 4 6 7 10 12"
  "asc desc harm|1 4 5 6 7 10 12"
  "asc desc harm|1 2 4 5 6 7 10 12"
  "asc desc harm|1 2 4 5 6 7 9 10 12"
  "asc desc harm|1 2 3 4 5 6 7 9 10 12"
  "asc desc harm|1 2 3 4 5 6 7 9 10 11 12"
  "asc desc harm|1 2 3 4 5 6 7 8 9 10 11 12"
)

short_names=("" 2m 2M 3m 3M 4te T 5te 6m 6M 7m 7M 8ve)
long_names=("" "seconde mineure" "seconde majeure" "tierce mineure" "tierce majeure"
  "quarte juste" "triton" "quinte juste" "sixte mineure" "sixte majeure"
  "septième mineure" "septième majeure" "octave")
declare -A mode_prefix=([asc]=01 [desc]=02 [harm]=03)
declare -A mode_symbol=([asc]="↑" [desc]="↓" [harm]="harm")
declare -A mode_path

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

die() {
  echo "$*" >&2
  exit 1
}

# Les fichiers enchaînent intervalle puis réponse parlée (début ~3,4 s au plus
# tôt) : on extrait les 3 premières secondes avec un fondu, afplay -t n'étant
# pas assez précis pour couper avant la voix.
trim() { # mp3 wav
  ffmpeg -loglevel error -y -i "$1" -t 3 -af afade=t=out:st=2.8:d=0.2 "$2"
}

in_list() { # valeur liste…
  local needle=$1 item
  shift
  for item in "$@"; do
    [ "$item" = "$needle" ] && return 0
  done
  return 1
}

# --- Mode libre ---------------------------------------------------------------

free_mode() { # all|1|2|3
  local filter=$1 dirs sounds sound key clip="$workdir/clip.wav"

  if [ "$filter" = "all" ]; then
    dirs=("$root")
  else
    mapfile -t dirs < <(find "$root" -mindepth 1 -maxdepth 1 -type d -name "$(printf '%02d' "$filter") *")
    if [ "${#dirs[@]}" -eq 0 ]; then
      echo "Aucun dossier '$filter' dans $root :" >&2
      find "$root" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort >&2
      exit 1
    fi
  fi

  mapfile -t sounds < <(find "${dirs[@]}" -type f -name '*.mp3')
  [ "${#sounds[@]}" -gt 0 ] || die "Aucun mp3 trouvé dans ${dirs[*]}"

  echo "${#sounds[@]} sons · Entrée : réponse · r : réécouter · q : quitter"
  while true; do
    sound=$(printf '%s\n' "${sounds[@]}" | shuf -n 1)
    trim "$sound" "$clip"
    while true; do
      /usr/bin/afplay "$clip"
      read -rp "? " key
      case "$key" in
        r) continue ;;
        q) exit 0 ;;
        *) break ;;
      esac
    done
    echo "→ $(basename "$(dirname "$sound")") / $(basename "$sound" .mp3)"
    while true; do
      /usr/bin/afplay "$clip"
      read -rp "Entrée : suivant · r : réécouter · q : quitter " key
      case "$key" in
        r) continue ;;
        q) exit 0 ;;
        *) break ;;
      esac
    done
    echo
  done
}

# --- Progression --------------------------------------------------------------

saved_level() {
  if [ -f "$state_file" ]; then cat "$state_file"; else echo 1; fi
}

# Ne retient que le niveau le plus avancé : réviser un ancien niveau avec -n
# n'écrase pas la progression.
save_progress() { # niveau
  if [ "$1" -gt "$(saved_level)" ]; then
    mkdir -p "$state_dir"
    echo "$1" >"$state_file"
  fi
}

print_levels() {
  local i spec modes intervals n names symbols
  for i in "${!levels[@]}"; do
    spec=${levels[$i]}
    read -ra modes <<<"${spec%%|*}"
    read -ra intervals <<<"${spec#*|}"
    names=()
    for n in "${intervals[@]}"; do names+=("${short_names[$n]}"); done
    symbols=$(mode_symbols "${modes[@]}")
    # Padding à la main : printf compte les octets et ↑ ↓ en font trois.
    printf '%2d  %s%*s%s\n' $((i + 1)) "$symbols" $((11 - ${#symbols})) "" "${names[*]}"
  done
}

mode_symbols() { # modes…
  local mode symbols=()
  for mode in "$@"; do symbols+=("${mode_symbol[$mode]}"); done
  echo "${symbols[*]}"
}

label() { # mode demi-tons
  echo "${mode_symbol[$1]} ${short_names[$2]} (${long_names[$2]})"
}

resolve_mode_paths() {
  local mode found
  for mode in "${!mode_prefix[@]}"; do
    mapfile -t found < <(find "$root" -mindepth 1 -maxdepth 1 -type d -name "${mode_prefix[$mode]} *")
    [ "${#found[@]}" -eq 1 ] || die "Dossier '${mode_prefix[$mode]} …' introuvable dans $root"
    mode_path[$mode]=${found[0]}
  done
}

# Remplit level_modes, level_intervals et level_pairs ("mode demi-tons").
load_level() { # niveau
  local spec=${levels[$(($1 - 1))]} mode n
  read -ra level_modes <<<"${spec%%|*}"
  read -ra level_intervals <<<"${spec#*|}"
  level_pairs=()
  for mode in "${level_modes[@]}"; do
    for n in "${level_intervals[@]}"; do level_pairs+=("$mode $n"); done
  done
}

# Charge le niveau, repère ce qui est nouveau par rapport au précédent et
# extrait d'avance tous les clips du niveau.
start_level() { # niveau
  local previous=() pair mode n mp3 names=()
  if [ "$1" -gt 1 ]; then
    load_level $(($1 - 1))
    previous=("${level_pairs[@]}")
  fi
  load_level "$1"

  fresh_pairs=()
  for pair in "${level_pairs[@]}"; do
    in_list "$pair" "${previous[@]}" || fresh_pairs+=("$pair")
  done

  for pair in "${level_pairs[@]}"; do
    read -r mode n <<<"$pair"
    [ -f "$workdir/$mode-$n.wav" ] && continue
    mapfile -t mp3 < <(find "${mode_path[$mode]}" -maxdepth 1 -type f -name "$(printf '%02d' "$n") *.mp3")
    [ "${#mp3[@]}" -eq 1 ] || die "Son introuvable : $(label "$mode" "$n") dans ${mode_path[$mode]}"
    trim "${mp3[0]}" "$workdir/$mode-$n.wav"
  done

  choices=""
  for n in "${level_intervals[@]}"; do
    choices+="$n=${short_names[$n]} "
    names+=("${short_names[$n]}")
  done

  echo
  echo "Niveau $1/${#levels[@]} : $(mode_symbols "${level_modes[@]}") · ${names[*]}"
}

play() { # mode demi-tons
  /usr/bin/afplay "$workdir/$1-$2.wav"
}

listen() { # "mode demi-tons"
  local mode n
  read -r mode n <<<"$1"
  echo "  $(label "$mode" "$n")"
  play "$mode" "$n"
  sleep 0.4
}

present() {
  local n pair
  echo "Présentation :"
  for n in "${level_intervals[@]}"; do listen "${level_modes[0]} $n"; done
  echo "Nouveau :"
  for pair in "${fresh_pairs[@]}"; do
    listen "$pair"
    listen "$pair"
  done
}

# Joue la question jusqu'à une réponse valide, dans la variable answer.
ask() { # mode demi-tons invite
  local key
  while true; do
    play "$1" "$2"
    while true; do
      read -rp "$3 $choices? " key
      case "$key" in
        r) break ;;
        q) exit 0 ;;
        *)
          if in_list "$key" "${level_intervals[@]}"; then
            answer=$key
            return
          fi
          echo "  Tape le nombre de demi-tons parmi : ${level_intervals[*]}"
          ;;
      esac
    done
  done
}

# Après une erreur : bonne réponse puis réponse donnée, dans le même mode.
compare() { # mode bonne_réponse réponse_donnée
  local key
  while true; do
    echo "    bonne réponse : $(label "$1" "$2")"
    play "$1" "$2"
    sleep 0.4
    echo "    ta réponse    : $(label "$1" "$3")"
    play "$1" "$3"
    read -rp "  Entrée : suivant · r : réécouter les deux · q : quitter " key
    case "$key" in
      r) continue ;;
      q) exit 0 ;;
      *) return ;;
    esac
  done
}

quiz_block() { # → score
  local i mode n
  score=0
  echo "Bloc de $block_size : tape le nombre de demi-tons · r : réécouter · q : quitter"
  for ((i = 1; i <= block_size; i++)); do
    read -r mode n <<<"${level_pairs[RANDOM % ${#level_pairs[@]}]}"
    ask "$mode" "$n" "[$i/$block_size]"
    if [ "$answer" = "$n" ]; then
      score=$((score + 1))
      echo "  ✓ $(label "$mode" "$n")"
      sleep 0.6
    else
      echo "  ✗ $(label "$mode" "$n"), pas ${short_names[$answer]}"
      compare "$mode" "$n" "$answer"
    fi
  done
}

expose() {
  local i
  for ((i = 0; i < exposure_size; i++)); do
    listen "${level_pairs[RANDOM % ${#level_pairs[@]}]}"
  done
}

progression() { # niveau
  local level=$1 key
  resolve_mode_paths
  while true; do
    start_level "$level"
    present
    while true; do
      quiz_block
      if [ "$score" -ge "$pass_score" ]; then
        echo "Niveau $level validé ($score/$block_size)"
        save_progress $((level + 1))
        if [ "$level" -eq "${#levels[@]}" ]; then
          echo "Tous les niveaux sont validés. Pour réviser : intervals -n N, ou mode libre : intervals all"
          exit 0
        fi
        read -rp "Entrée : niveau suivant · q : quitter " key
        [ "$key" = "q" ] && exit 0
        level=$((level + 1))
        break
      fi
      echo "$score/$block_size, il en faut $pass_score. Écoute sans répondre :"
      expose
      read -rp "Entrée : nouveau bloc · q : quitter " key
      [ "$key" = "q" ] && exit 0
    done
  done
}

case "${1:-}" in
  "")
    level=$(saved_level)
    [ "$level" -le "${#levels[@]}" ] || level=${#levels[@]}
    progression "$level"
    ;;
  -n)
    level=${2:-}
    if ! [[ "$level" =~ ^[0-9]+$ ]] || [ "$level" -lt 1 ] || [ "$level" -gt "${#levels[@]}" ]; then
      echo "Usage : intervals -n N, avec N parmi :" >&2
      print_levels >&2
      exit 1
    fi
    progression "$level"
    ;;
  *)
    free_mode "$1"
    ;;
esac
