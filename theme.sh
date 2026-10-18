#!/data/data/com.termux/files/usr/bin/bash
# THW Termux Tool v3 - Developer: thw_owner

DIR="$HOME/.thw"
mkdir -p "$DIR"

pal=(196 208 226 46 51 21 201 129)
cols=$(tput cols 2>/dev/null || echo 40)
rows=$(tput lines 2>/dev/null || echo 24)

# ---------- Always restore terminal (fixes "no input" problem) ----------
cleanup() { tput cnorm 2>/dev/null; stty sane 2>/dev/null; printf '\e[0m'; }
trap cleanup EXIT
trap 'cleanup; exit 130' INT TERM

rb() {
  local t="$1" o="${2:-0}" i out=""
  for ((i = 0; i < ${#t}; i++)); do
    out+="\e[1;38;5;${pal[$(((i + o) % ${#pal[@]}))]}m${t:$i:1}"
  done
  printf "%b\e[0m" "$out"
}
pad() { local p=$(((cols - ${#1}) / 2)); ((p < 0)) && p=0; printf "%*s" "$p" ""; }
border() {
  local ch="$1" i out=""
  for ((i = 0; i < cols; i++)); do
    out+="\e[1;38;5;${pal[$((i % ${#pal[@]}))]}m${ch}"
  done
  printf "%b\e[0m" "$out"
}
at() { printf '\e[%d;1H\e[K' "$1"; }

# ---------- Non-interactive, time-limited install ----------
install_pkgs() {
  command -v figlet >/dev/null 2>&1 && return 0
  export DEBIAN_FRONTEND=noninteractive
  timeout 90 apt-get update -y </dev/null >/dev/null 2>&1
  timeout 120 apt-get install -y -o Dpkg::Options::="--force-confnew" figlet </dev/null >/dev/null 2>&1
}

# ---------- Loading screen ----------
mid=$((rows / 2))
tput civis 2>/dev/null
clear
at $((mid - 7)); border "═"
at $((mid - 6)); pad "T H W   H A C K I N G   T E A M"; rb "T H W   H A C K I N G   T E A M"
at $((mid - 5)); border "═"

install_pkgs &
PID=$!

msgs=("Connecting to THW server" "Checking system" "Installing modules" "Building theme" "Finalizing")
p=0; ticks=0
w=$((cols - 10))
while [ "$p" -lt 100 ]; do
  ticks=$((ticks + 1))
  if kill -0 "$PID" 2>/dev/null; then
    [ "$p" -lt 92 ] && p=$((p + 1))
    sleep 0.08
    # safety: never hang more than ~3 minutes
    if [ "$ticks" -gt 2200 ]; then kill "$PID" 2>/dev/null; break; fi
  else
    p=$((p + 2)); [ "$p" -gt 100 ] && p=100
    sleep 0.02
  fi

  printf -v h '0x%04X  0x%04X  0x%04X  0x%04X' $RANDOM $RANDOM $RANDOM $RANDOM
  at $((mid - 2)); pad "$h"; printf "\e[38;5;46m%s\e[0m" "$h"

  idx=$((p * 5 / 100)); [ "$idx" -gt 4 ] && idx=4
  m="${msgs[$idx]} ..."
  at $((mid)); pad "$m"; rb "$m" "$p"

  f=$((p * w / 100)); out=""
  for ((i = 0; i < w; i++)); do
    if ((i < f)); then
      out+="\e[38;5;${pal[$((i * ${#pal[@]} / w))]}m█"
    else
      out+="\e[38;5;238m░"
    fi
  done
  at $((mid + 2)); printf "  %b\e[0m \e[1;37m%3d%%\e[0m" "$out" "$p"
done

at $((mid + 4)); pad "INSTALL COMPLETE"; rb "INSTALL COMPLETE"
sleep 1
cleanup

# ---------- Ask for the banner name ----------
clear
for ((i = 0; i < mid - 3; i++)); do echo; done
border "═"; echo
pad "ENTER YOUR BANNER NAME"; rb "ENTER YOUR BANNER NAME"; echo
border "═"; echo; echo
NAME=""
while [ -z "$NAME" ]; do
  printf "\e[1;38;5;51m  Name \e[1;37m: \e[1;38;5;226m"
  read -r NAME
  printf "\e[0m"
done
echo "${NAME:0:20}" > "$DIR/name"
[ -f "$DIR/count" ] || echo 0 > "$DIR/count"

# ---------- Banner script ----------
cat > "$DIR/banner.sh" <<'EOF'
# THW banner - Developer: thw_owner
[ -n "$THW_LOADED" ] && return 0
THW_LOADED=1

THW_PALS=(
  "196 208 226 46 51 21 201 129"
  "196 202 208 214 220 226 196 160"
  "17 21 27 33 39 45 51 87"
  "201 207 213 51 45 46 82 226"
  "22 28 34 40 46 82 118 154"
  "125 161 197 203 209 215 221 227"
  "213 219 225 159 123 87 51 45"
  "54 90 126 162 198 199 207 213"
)
THW_THEMES=7   # frame, matrix, stars, bars, wave, grid, lattice

THW_TG="https://t.me/THWHACKERX"
THW_YT="https://youtube.com/@thwhacker?si=R7_L8W-92c2WgYMA"

THW_MAT=(0 1 2 3 4 5 6 7 8 9 a b c d e f '$' '#' '@' '%' '&' '*' '+' '=' '<' '>' '/' '|' '{' '}' '[' ']')
THW_STAR=('.' '·' '✦' '✧' '*' '+')
THW_BAR=('█' '▓' '▒' '░')

# ---------- background pixel: sets BCH (char), BCOL (color), BST (1; or 2;) ----------
thw_bg() {
  local r=$1 c=$2 t g
  BCH=" "; BST="2;"; BCOL=${pal[$(((r + c + n) % plen))]}
  case $TH in
  0) # FRAME
    if ((r == 0)); then
      if ((c == 0)); then BCH="╔"; elif ((c == W - 1)); then BCH="╗"; else BCH="═"; fi; BST="1;"
    elif ((r == H - 1)); then
      if ((c == 0)); then BCH="╚"; elif ((c == W - 1)); then BCH="╝"; else BCH="═"; fi; BST="1;"
    elif ((c == 0 || c == W - 1)); then BCH="║"; BST="1;"
    elif ((RANDOM % 100 < 4)); then BCH="·"
    fi ;;
  1) # MATRIX rain
    if ((RANDOM % 100 < 38)); then
      BCH=${THW_MAT[$((RANDOM % ${#THW_MAT[@]}))]}
      BCOL=${pal[$(((c + n) % plen))]}
      ((RANDOM % 4 == 0)) && BST="1;"
    fi ;;
  2) # STARS
    if ((RANDOM % 100 < 6)); then
      BCH=${THW_STAR[$((RANDOM % ${#THW_STAR[@]}))]}
      BCOL=${pal[$((RANDOM % plen))]}
      ((RANDOM % 2)) && BST="1;"
    fi ;;
  3) # BARS (gradient top and bottom)
    if ((r < 4)); then g=$r; elif ((r >= H - 4)); then g=$((H - 1 - r)); else g=-1; fi
    BCOL=${pal[$(((c * plen / W + n) % plen))]}
    if ((g >= 0)); then BCH=${THW_BAR[$g]}; BST="1;"
    elif ((c == 0 || c == W - 1)); then BCH="┃"; BST="1;"
    fi ;;
  4) # WAVE
    t=$(((c + n) % 16)); ((t > 8)) && t=$((16 - t))
    if (((r + t / 2) % 5 == 0)); then BCH="~"; BCOL=${pal[$(((c / 3 + r + n) % plen))]}; fi ;;
  5) # GRID
    BCOL=${pal[$(((r / 4 + c / 8 + n) % plen))]}
    if ((r % 4 == 0 && c % 8 == 0)); then BCH="┼"
    elif ((r % 4 == 0)); then BCH="─"
    elif ((c % 8 == 0)); then BCH="│"
    fi ;;
  6) # LATTICE
    BCOL=${pal[$(((r / 3 + c / 3 + n) % plen))]}
    if (((r + c) % 8 == 0 && (c - r + 1000) % 8 == 0)); then BCH="╳"
    elif (((r + c) % 8 == 0)); then BCH="╱"
    elif (((c - r + 1000) % 8 == 0)); then BCH="╲"
    fi ;;
  esac
}

thw_bgrange() {  # row, from, to  -> appended to OUT
  local r=$1 c
  for ((c = $2; c < $3; c++)); do
    thw_bg "$r" "$c"
    if [ "$BCH" = " " ]; then OUT+=" "; else
      OUT+=$'\e[0;'"$BST"'38;5;'"$BCOL"'m'"$BCH"
    fi
  done
}

# ---------- panel helpers ----------
thw_rbs() {  # rainbow copy of text -> RBS
  local t="$1" o="${2:-0}" i out=""
  for ((i = 0; i < ${#t}; i++)); do
    if [ "${t:$i:1}" = " " ]; then out+=" "; else
      out+=$'\e[1;38;5;'"${pal[$(((i + o) % plen))]}m${t:$i:1}"
    fi
  done
  RBS="$out"$'\e[0m'
}

thw_pbar() {  # left, middle, right -> PNL
  local l=$1 m=$2 r=$3 j s=""
  s+=$'\e[0;1;38;5;'"${pal[$((n % plen))]}m$l"
  for ((j = 1; j < PW - 1; j++)); do
    s+=$'\e[0;1;38;5;'"${pal[$(((j + n) % plen))]}m$m"
  done
  s+=$'\e[0;1;38;5;'"${pal[$(((PW + n) % plen))]}m$r"$'\e[0m'
  PNL+=("$s")
}

thw_pline() {  # colored text, visible length -> PNL
  local c="$1" len="$2" inner=$((PW - 2)) lp rp sp1 sp2 e1 e2 k=${#PNL[@]}
  lp=$(((inner - len) / 2)); ((lp < 0)) && lp=0
  rp=$((inner - len - lp)); ((rp < 0)) && rp=0
  printf -v sp1 '%*s' "$lp" ''; printf -v sp2 '%*s' "$rp" ''
  printf -v e1 '\e[0;1;38;5;%sm║\e[0m' "${pal[$(((k + n) % plen))]}"
  printf -v e2 '\e[0;1;38;5;%sm║\e[0m' "${pal[$(((k + n + 3) % plen))]}"
  PNL+=("$e1$sp1$c$sp2$e2")
}

# ---------- block-letter font (6 rows per glyph, rows separated by |) ----------
declare -A THW_G
THW_G[A]=' █████╗ |██╔══██╗|███████║|██╔══██║|██║  ██║|╚═╝  ╚═╝'
THW_G[B]='██████╗ |██╔══██╗|██████╔╝|██╔══██╗|██████╔╝|╚═════╝ '
THW_G[C]=' ██████╗|██╔════╝|██║     |██║     |╚██████╗| ╚═════╝'
THW_G[D]='██████╗ |██╔══██╗|██║  ██║|██║  ██║|██████╔╝|╚═════╝ '
THW_G[E]='███████╗|██╔════╝|█████╗  |██╔══╝  |███████╗|╚══════╝'
THW_G[F]='███████╗|██╔════╝|█████╗  |██╔══╝  |██║     |╚═╝     '
THW_G[G]=' ██████╗ |██╔════╝ |██║  ███╗|██║   ██║|╚██████╔╝| ╚═════╝ '
THW_G[H]='██╗  ██╗|██║  ██║|███████║|██╔══██║|██║  ██║|╚═╝  ╚═╝'
THW_G[I]='██╗|██║|██║|██║|██║|╚═╝'
THW_G[J]='     ██╗|     ██║|     ██║|██   ██║|╚█████╔╝| ╚════╝ '
THW_G[K]='██╗  ██╗|██║ ██╔╝|█████╔╝ |██╔═██╗ |██║  ██╗|╚═╝  ╚═╝'
THW_G[L]='██╗     |██║     |██║     |██║     |███████╗|╚══════╝'
THW_G[M]='███╗   ███╗|████╗ ████║|██╔████╔██║|██║╚██╔╝██║|██║ ╚═╝ ██║|╚═╝     ╚═╝'
THW_G[N]='███╗   ██╗|████╗  ██║|██╔██╗ ██║|██║╚██╗██║|██║ ╚████║|╚═╝  ╚═══╝'
THW_G[O]=' ██████╗ |██╔═══██╗|██║   ██║|██║   ██║|╚██████╔╝| ╚═════╝ '
THW_G[P]='██████╗ |██╔══██╗|██████╔╝|██╔═══╝ |██║     |╚═╝     '
THW_G[Q]=' ██████╗ |██╔═══██╗|██║   ██║|██║▄▄ ██║|╚██████╔╝| ╚══▀▀═╝ '
THW_G[R]='██████╗ |██╔══██╗|██████╔╝|██╔══██╗|██║  ██║|╚═╝  ╚═╝'
THW_G[S]='███████╗|██╔════╝|███████╗|╚════██║|███████║|╚══════╝'
THW_G[T]='████████╗|╚══██╔══╝|   ██║   |   ██║   |   ██║   |   ╚═╝   '
THW_G[U]='██╗   ██╗|██║   ██║|██║   ██║|██║   ██║|╚██████╔╝| ╚═════╝ '
THW_G[V]='██╗   ██╗|██║   ██║|██║   ██║|╚██╗ ██╔╝| ╚████╔╝ |  ╚═══╝  '
THW_G[W]='██╗    ██╗|██║    ██║|██║ █╗ ██║|██║███╗██║|╚███╔███╔╝| ╚══╝╚══╝ '
THW_G[X]='██╗  ██╗|╚██╗██╔╝| ╚███╔╝ | ██╔██╗ |██╔╝ ██╗|╚═╝  ╚═╝'
THW_G[Y]='██╗   ██╗|╚██╗ ██╔╝| ╚████╔╝ |  ╚██╔╝  |   ██║   |   ╚═╝   '
THW_G[Z]='███████╗|╚══███╔╝|  ███╔╝ | ███╔╝  |███████╗|╚══════╝'
THW_G[0]=' ██████╗ |██╔═████╗|██║██╔██║|████╔╝██║|╚██████╔╝| ╚═════╝ '
THW_G[1]=' ██╗|███║|╚██║| ██║| ██║| ╚═╝'
THW_G[2]='██████╗ |╚════██╗| █████╔╝|██╔═══╝ |███████╗|╚══════╝'
THW_G[3]='██████╗ |╚════██╗| █████╔╝| ╚═══██╗|██████╔╝|╚═════╝ '
THW_G[4]='██╗  ██╗|██║  ██║|███████║|╚════██║|     ██║|     ╚═╝'
THW_G[5]='███████╗|██╔════╝|███████╗|╚════██║|███████║|╚══════╝'
THW_G[6]=' ██████╗ |██╔════╝ |███████╗ |██╔═══██╗|╚██████╔╝| ╚═════╝ '
THW_G[7]='███████╗|╚════██║|    ██╔╝|   ██╔╝ |   ██║  |   ╚═╝  '
THW_G[8]=' █████╗ |██╔══██╗|╚█████╔╝|██╔══██╗|╚█████╔╝| ╚════╝ '
THW_G[9]=' █████╗ |██╔══██╗|╚██████║| ╚═══██║| █████╔╝| ╚════╝ '
THW_G[SP]='   |   |   |   |   |   '
THW_G[DASH]='      |      |█████╗|╚════╝|      |      '
THW_G[DOT]='   |   |   |   |██╗|╚═╝'
THW_G[USC]='        |        |        |        |███████╗|╚══════╝'

# Build block letters for a name -> BR (array of 6 padded rows), BW (width)
thw_block() {
  local name="${1^^}" i ch g rows row gw k
  BR=("" "" "" "" "" ""); BW=0
  for ((i = 0; i < ${#name}; i++)); do
    ch="${name:$i:1}"
    case "$ch" in " ") ch=SP;; "-") ch=DASH;; ".") ch=DOT;; "_") ch=USC;; esac
    g="${THW_G[$ch]}"; [ -z "$g" ] && continue
    IFS='|' read -ra rows <<< "$g"
    gw=0; for row in "${rows[@]}"; do ((${#row} > gw)) && gw=${#row}; done
    for ((k = 0; k < 6; k++)); do
      row="${rows[$k]}"
      while ((${#row} < gw)); do row+=" "; done
      BR[$k]+="$row"
    done
  done
  BW=${#BR[0]}
}

# ---------- ASCII art styles (shown under the box) ----------
THW_STYLES=(skull terminal lock rocket sword)
THW_ART_skull=(
'      _______'
'   .-"       "-.'
'  /             \'
' |,  .-.   .-.  ,|'
' | )(__/   \__)( |'
' |/     /\     \|'
' (_     ^^     _)'
'  \__|IIIIII|__/'
'   | \IIIIII/ |'
'   \          /'
'    `--------`'
)
THW_ART_terminal=(
'.------------------------------.'
'| o o o                        |'
'|------------------------------|'
'| $ sudo access --thw          |'
'| [##################] 100%    |'
'| > ACCESS GRANTED_            |'
"'------------------------------'"
)
THW_ART_lock=(
'      .--------.'
'     /  .----.  \'
'    |  /      \  |'
'    |  |      |  |'
'  .-'"'"'--'"'"'------'"'"'--'"'"'-.'
'  |       __       |'
'  |      (  )      |'
'  |       ||       |'
"  '------------------'"
)
THW_ART_rocket=(
'       /\'
'      /  \'
'     |    |'
'     | () |'
'     |    |'
'    /|    |\'
'   / |    | \'
'  /__|_/\_|__\'
'     /_||_\'
'       ||'
)
THW_ART_sword=(
'       /\'
'      /  \'
'      |  |'
'      |  |'
'      |  |'
'   ___|  |___'
'  /___ \/ ___\'
'      |  |'
'      |  |'
'      \__/'
)

THW_THEME_NAMES=(frame matrix stars bars wave grid lattice)

# Left-aligned framed row
thw_pleft() {  # colored text, visible length -> PNL
  local c="$1" len="$2" inner=$((PW - 2)) lp=3 rp sp1 sp2 e1 e2 k=${#PNL[@]}
  ((len + lp > inner)) && lp=0
  rp=$((inner - len - lp)); ((rp < 0)) && rp=0
  printf -v sp1 '%*s' "$lp" ''; printf -v sp2 '%*s' "$rp" ''
  printf -v e1 '\e[0;1;38;5;%sm║\e[0m' "${pal[$(((k + n) % plen))]}"
  printf -v e2 '\e[0;1;38;5;%sm║\e[0m' "${pal[$(((k + n + 3) % plen))]}"
  PNL+=("$e1$sp1$c$sp2$e2")
}
thw_kv() {  # label value labelcolor valuecolor
  local s
  printf -v s '\e[1;38;5;%sm%-10s\e[1;37m: \e[1;38;5;%sm%s\e[0m' "$3" "$1" "$4" "$2"
  thw_pleft "$s" "$((10 + 2 + ${#2}))"
}

# ---------- main banner ----------
thw_show() {
  local dir="$HOME/.thw" name n cols rows W H PW PH T L i k r off line ch f a mw ln
  local pi last TH lastth SI lastsi pal plen w artmax sty total
  local OUT="" BCH BCOL BST RBS BW
  local PNL=() CONT=() BR=()

  name=$(cat "$dir/name" 2>/dev/null)
  [ -z "$name" ] && { thw_rename; return; }
  n=$(cat "$dir/count" 2>/dev/null || echo 0)
  last=$(cat "$dir/pal" 2>/dev/null || echo 0)
  lastth=$(cat "$dir/theme" 2>/dev/null || echo 0)
  lastsi=$(cat "$dir/style" 2>/dev/null || echo 0)

  if [ "$1" != "keep" ]; then
    n=$((n + 1)); echo "$n" > "$dir/count"
    pi=$((RANDOM % ${#THW_PALS[@]}))
    [ "$pi" -eq "$last" ] && pi=$(((pi + 1 + RANDOM % (${#THW_PALS[@]} - 1)) % ${#THW_PALS[@]}))
    TH=$((RANDOM % THW_THEMES))
    [ "$TH" -eq "$lastth" ] && TH=$(((TH + 1 + RANDOM % (THW_THEMES - 1)) % THW_THEMES))
    SI=$((RANDOM % ${#THW_STYLES[@]}))
    [ "$SI" -eq "$lastsi" ] && SI=$(((SI + 1 + RANDOM % (${#THW_STYLES[@]} - 1)) % ${#THW_STYLES[@]}))
    echo "$pi" > "$dir/pal"; echo "$TH" > "$dir/theme"; echo "$SI" > "$dir/style"
  else
    pi=$last; TH=$lastth; SI=$lastsi
  fi
  read -ra pal <<< "${THW_PALS[$pi]}"; plen=${#pal[@]}
  sty=${THW_STYLES[$SI]}

  cols=$(tput cols 2>/dev/null || echo 40)
  rows=$(tput lines 2>/dev/null || echo 24)
  W=$cols; H=$((rows - 2))
  if ((W <= 60)); then PW=$((W - 4)); else PW=56; fi
  ((PW < 30)) && PW=30
  artmax=$((PW - 4))

  # ----- big block-letter name (falls back to smaller fonts for long names) -----
  thw_block "$name"
  if ((BW > artmax || BW == 0)); then
    BR=(); BW=0
    if command -v figlet >/dev/null 2>&1; then
      for f in small mini; do
        a=$(figlet -f "$f" -w 500 "$name" </dev/null 2>/dev/null) || continue
        [ -z "$a" ] && continue
        mw=0; BR=()
        while IFS= read -r line; do BR+=("$line"); ((${#line} > mw)) && mw=${#line}; done <<< "$a"
        if ((mw <= artmax)); then BW=$mw; break; fi
        BR=(); BW=0
      done
    fi
    if ((BW == 0)); then
      a=""; for ((k = 0; k < ${#name}; k++)); do a+="${name:$k:1} "; done
      ((${#a} > artmax)) && a="${name:0:artmax}"
      BR=("$a"); BW=${#a}
    fi
  fi

  # ----- the framed panel -----
  thw_pbar "╔" "═" "╗"
  thw_pline "" 0
  r=0; off=$((RANDOM % plen))
  for line in "${BR[@]}"; do
    local o=""
    for ((k = 0; k < BW; k++)); do
      ch="${line:$k:1}"
      if [ -z "$ch" ] || [ "$ch" = " " ]; then o+=" "; else
        o+=$'\e[1;38;5;'"${pal[$(((k / 3 + r + off) % plen))]}m$ch"
      fi
    done
    thw_pline "$o"$'\e[0m' "$BW"
    r=$((r + 1))
  done
  thw_pline "" 0
  thw_pbar "╚" "═" "╝"
  PH=${#PNL[@]}
  CONT=("${PNL[@]}")

  # ----- ASCII-art style under the box (only if it fits) -----
  local -n AR="THW_ART_$sty"
  total=$((PH + 1 + ${#AR[@]}))
  if ((total <= H)); then
    local aw=0 al lp rp pad1 pad2 row col
    for line in "${AR[@]}"; do ((${#line} > aw)) && aw=${#line}; done
    CONT+=("")
    r=0
    for line in "${AR[@]}"; do
      while ((${#line} < aw)); do line+=" "; done
      lp=$(((PW - aw) / 2)); ((lp < 0)) && lp=0
      rp=$((PW - aw - lp)); ((rp < 0)) && rp=0
      printf -v pad1 '%*s' "$lp" ''; printf -v pad2 '%*s' "$rp" ''
      printf -v row '%s\e[1;38;5;%sm%s\e[0m%s' "$pad1" "${pal[$(((r + n) % plen))]}" "$line" "$pad2"
      CONT+=("$row")
      r=$((r + 1))
    done
  fi
  total=${#CONT[@]}
  T=$(((H - total) / 2)); ((T < 0)) && T=0
  L=$(((W - PW) / 2))

  # ----- compose the full screen: background + content -----
  for ((r = 0; r < H; r++)); do
    if ((r >= T && r < T + total)) && [ -n "${CONT[$((r - T))]}" ]; then
      thw_bgrange "$r" 0 "$L"
      OUT+="${CONT[$((r - T))]}"
      thw_bgrange "$r" "$((L + PW))" "$W"
    else
      thw_bgrange "$r" 0 "$W"
    fi
    OUT+=$'\e[0m\n'
  done
  clear
  printf '%s' "$OUT"
}

# ---------- links ----------
thw_open() {
  # fire and forget: returns instantly, the app opens by itself
  { am start --user 0 -a android.intent.action.VIEW -d "$1" || termux-open-url "$1"; } >/dev/null 2>&1 &
  disown 2>/dev/null
}
thw_telegram() { thw_open "$THW_TG"; }   # Ctrl+L
thw_youtube()  { thw_open "$THW_YT"; }    # Ctrl+P

# ---------- prompt: banner name + symbol (replaces the default "$") ----------
thw_ps1() {
  THW_NAME=$(cat "$HOME/.thw/name" 2>/dev/null)
  [ -z "$THW_NAME" ] && return
  PS1='\[\e[1;38;5;51m\]${THW_NAME}\[\e[1;38;5;226m\] ➤ \[\e[0m\]'
}

# ---------- change the banner name (Ctrl+N or  thwname ) ----------
thw_rename() {
  local new
  while :; do
    printf "\n\e[1;38;5;51m  Enter name: \e[1;38;5;226m"
    read -r new
    printf "\e[0m"
    new="${new:0:20}"
    if [ -n "$new" ]; then echo "$new" > "$HOME/.thw/name"; thw_ps1; break; fi
    [ -s "$HOME/.thw/name" ] && break
  done
  thw_show keep
}
thwname() { thw_rename; }

# ---------- close ALL terminal sessions at once (Ctrl+X, or  thwexit ) ----------
thw_exitall() {
  printf '\e[0m\e[2J\e[H'
  pkill -9 -x bash >/dev/null 2>&1   # kills every bash session at once
  kill -9 $$ 2>/dev/null
  exit 0
}
thwexit() { thw_exitall; }

# Runs only in a real interactive terminal. Set THW_OFF=1 to disable.
if [[ $- == *i* ]] && [ -z "$THW_OFF" ]; then
  bind -x '"\C-l": thw_telegram' 2>/dev/null
  bind -x '"\C-p": thw_youtube' 2>/dev/null
  bind -x '"\C-n": thw_rename' 2>/dev/null
  # Exit all terminals: Ctrl+X always works; Ctrl+0 works if your keyboard sends it as an escape sequence
  bind -x '"\C-x": thw_exitall' 2>/dev/null
  bind -x '"\e[27;5;48~": thw_exitall' 2>/dev/null
  bind -x '"\e[48;5u": thw_exitall' 2>/dev/null
  thw_ps1
  thw_show
fi
EOF

LINE='[ -f "$HOME/.thw/banner.sh" ] && source "$HOME/.thw/banner.sh"'
touch "$HOME/.bashrc"
for f in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
  # .bashrc always; the others only if they already exist (they can block .bashrc)
  if [ "$f" = "$HOME/.bashrc" ] || [ -f "$f" ]; then
    grep -q ".thw/banner.sh" "$f" 2>/dev/null || echo "$LINE" >> "$f"
  fi
done

# Restart the shell so the theme, Ctrl+L binding and new prompt are active right now
exec bash
