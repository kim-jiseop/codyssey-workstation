#!/usr/bin/env bash
# 터미널 기본 조작과 권한 실습을 실행하고, 명령과 출력을 함께 남긴다.
# 실행: WSL 우분투에서  bash scripts/01_터미널_권한.sh
set -u

LOG_DIR="$(cd "$(dirname "$0")/.." && pwd)/logs"
mkdir -p "$LOG_DIR"

# 명령을 "$ 명령" 형태로 보여 준 뒤 실행한다.
run() { echo "\$ $*"; eval "$@"; echo; }

terminal() {
  cd ~ || exit 1
  rm -rf ~/codyssey/practice   # 다시 실행해도 같은 결과가 나오도록 초기화
  run 'pwd'
  run 'mkdir -p ~/codyssey/practice'
  run 'cd ~/codyssey/practice'
  run 'pwd'
  run 'ls -la'
  run 'touch empty.txt'
  run 'echo "hello codyssey" > memo.txt'
  run 'mkdir docs'
  run 'ls -la'
  run 'cat memo.txt'
  run 'cp memo.txt docs/memo_copy.txt'
  run 'mv docs/memo_copy.txt docs/memo_renamed.txt'
  run 'mv empty.txt docs/'
  run 'ls -la docs'
  run 'echo ".secret_note" > .hidden_file'
  run 'ls'
  run 'ls -a'
  run 'rm docs/empty.txt'
  run 'ls -la docs'
  run 'cd docs'
  run 'pwd'
  run 'cat ../memo.txt'
  run 'cat ~/codyssey/practice/memo.txt'
  run 'cd ..'
  run 'mkdir -p trash/sub && touch trash/sub/a.txt'
  run 'rm -r trash'
  run 'ls -la'
}

permission() {
  cd ~/codyssey/practice || exit 1
  run 'touch perm_file.txt && mkdir -p perm_dir'
  echo "# 변경 전"
  run 'ls -l perm_file.txt'
  run 'ls -ld perm_dir'
  run 'stat -c "%A %a %n" perm_file.txt perm_dir'
  echo "# 변경: 파일 644 -> 600 -> 755, 디렉토리 755 -> 700"
  run 'chmod 600 perm_file.txt'
  run 'stat -c "%A %a %n" perm_file.txt'
  run 'chmod 755 perm_file.txt'
  run 'stat -c "%A %a %n" perm_file.txt'
  run 'chmod 700 perm_dir'
  run 'stat -c "%A %a %n" perm_dir'
  echo "# 기호 방식: 그룹·기타에 읽기+실행 다시 주기"
  run 'chmod go+rx perm_dir'
  run 'stat -c "%A %a %n" perm_dir'
  echo "# 실행 권한(x)의 효과 확인"
  run 'printf "#!/bin/bash\necho script ran\n" > hello.sh'
  run 'chmod 644 hello.sh && ./hello.sh'
  run 'chmod 755 hello.sh && ./hello.sh'
  echo "# 디렉토리에서 x가 없으면 안으로 들어갈 수 없음"
  run 'chmod 644 perm_dir && cd perm_dir'
  run 'chmod 755 perm_dir && cd perm_dir && pwd && cd ..'
}

terminal   > "$LOG_DIR/01_터미널_조작.log"   2>&1
permission > "$LOG_DIR/02_권한_실습.log"     2>&1
echo "로그 저장: $LOG_DIR"
