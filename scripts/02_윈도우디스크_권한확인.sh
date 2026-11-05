#!/usr/bin/env bash
# 윈도우 디스크(/mnt/c)와 리눅스 디스크(~)에서 chmod 결과가 어떻게 다른지 비교한다.
# 실행: WSL 우분투에서  bash scripts/02_윈도우디스크_권한확인.sh
set -u
run() { echo "\$ $*"; eval "$@"; echo; }

PROJECT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT" || exit 1

{
  echo "# 1) 윈도우 디스크 위의 파일"
  run 'pwd'
  run 'touch ntfs_test.txt'
  run 'stat -c "%A %a %n" ntfs_test.txt'
  run 'chmod 600 ntfs_test.txt'
  run 'stat -c "%A %a %n" ntfs_test.txt'
  run 'mount | grep " /mnt/c "'
  rm -f ntfs_test.txt

  echo "# 2) 리눅스 디스크 위의 파일"
  run 'cd ~ && touch ext4_test.txt'
  run 'stat -c "%A %a %n" ext4_test.txt'
  run 'chmod 600 ext4_test.txt'
  run 'stat -c "%A %a %n" ext4_test.txt'
  rm -f ~/ext4_test.txt
} > "$PROJECT/logs/03_윈도우디스크_권한.log" 2>&1
cat "$PROJECT/logs/03_윈도우디스크_권한.log"
