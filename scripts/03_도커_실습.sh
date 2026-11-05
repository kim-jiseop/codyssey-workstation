#!/usr/bin/env bash
# Docker 점검·운영·웹 서버·바인드 마운트·볼륨 실습을 실행하고 단계별 로그를 남긴다.
# 실행: 윈도우 Git Bash 에서  bash scripts/03_도커_실습.sh
#      (리눅스/맥이라면 그대로 실행 가능. HOST_DIR 줄만 $(pwd) 로 동작)
set -u
export MSYS_NO_PATHCONV=1   # Git Bash 가 /usr/... 같은 경로를 윈도우 경로로 바꾸지 않도록

PROJECT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$PROJECT/logs"
mkdir -p "$LOG_DIR"
cd "$PROJECT" || exit 1

# Docker 에 넘길 호스트 경로(Git Bash 는 윈도우 형식이 필요)
HOST_DIR="$( (pwd -W 2>/dev/null) || pwd )"

run() { echo "\$ $*"; eval "$@"; echo; }

# 다시 실행해도 같은 결과가 나오도록 이전 실습 흔적 정리
cleanup() {
  docker rm -f hello-test ubuntu-attach ubuntu-exec my-web-8080 my-web-8081 \
               bind-test vol-test vol-test2 >/dev/null 2>&1
  docker volume rm mydata >/dev/null 2>&1
  rm -rf "$PROJECT/bind-demo"
}

check() {
  run 'docker --version'
  run 'docker info'
}

basics() {
  run 'docker pull ubuntu:24.04'
  run 'docker pull nginx:1.27-alpine'
  run 'docker images'
  run 'docker run --name hello-test hello-world'
  run 'docker ps'
  run 'docker ps -a'
  run 'docker logs hello-test'
}

ubuntu() {
  echo "# 1) 일회성 실행: 명령이 끝나면 컨테이너도 끝남"
  run 'docker run --rm ubuntu:24.04 bash -c "ls / && echo hello from ubuntu && cat /etc/os-release | head -2"'

  echo "# 2) exec: 실행 중인 컨테이너에 '새 프로세스'로 들어감 -> 나와도 컨테이너는 계속 실행"
  run 'docker run -dit --name ubuntu-exec ubuntu:24.04 bash'
  run 'docker exec ubuntu-exec bash -c "echo inside exec && ls /home && exit"'
  run 'docker ps --filter name=ubuntu-exec --format "{{.Names}}: {{.Status}}"'

  echo "# 3) attach: 컨테이너의 '메인 프로세스(PID 1)'에 붙음 -> exit 하면 컨테이너가 멈춤"
  run 'docker run -di --name ubuntu-attach ubuntu:24.04 bash'
  run 'echo "echo inside attach; exit" | docker attach ubuntu-attach'
  run 'docker ps -a --filter name=ubuntu-attach --format "{{.Names}}: {{.Status}}"'

  echo "# 4) 중지 후 상태 확인"
  run 'docker stop ubuntu-exec'
  run 'docker ps -a --filter name=ubuntu --format "{{.Names}}: {{.Status}}"'
}

web() {
  docker rm -f my-web-8080 my-web-8081 >/dev/null 2>&1
  run 'docker build -t my-web:1.0 ./app'
  run 'docker images my-web'
  run 'docker run -d -p 8080:80 --name my-web-8080 my-web:1.0'
  run 'docker run -d -p 8081:80 --name my-web-8081 my-web:1.0'
  sleep 2
  run 'docker ps --filter name=my-web --format "{{.Names}}\t{{.Ports}}\t{{.Status}}"'
  run 'curl -s http://localhost:8080 | grep -E "<h1>|my-web"'
  run 'curl -s http://localhost:8081 | grep -E "<h1>|my-web"'
  run 'curl -s http://localhost:8080/health'
  run 'curl -sI http://localhost:8080 | head -1'
  run 'docker exec my-web-8080 printenv APP_ENV'
  run 'docker inspect --format "{{json .Config.Labels}}" my-web:1.0'
  run 'docker logs my-web-8080 2>&1 | tail -5'
  run 'docker stats --no-stream my-web-8080 my-web-8081'
  # 헬스체크 결과가 나올 때까지 최대 40초 기다림
  for _ in $(seq 20); do
    [ "$(docker inspect -f '{{.State.Health.Status}}' my-web-8080)" != "starting" ] && break
    sleep 2
  done
  run 'docker ps --filter name=my-web --format "{{.Names}}: {{.Status}}"'
}

bind() {
  mkdir -p "$PROJECT/bind-demo"
  echo "<h1>BEFORE: bind mount</h1>" > "$PROJECT/bind-demo/index.html"
  run 'cat bind-demo/index.html'
  run "docker run -d -p 8082:80 --name bind-test -v \"$HOST_DIR/bind-demo:/usr/share/nginx/html\" nginx:1.27-alpine"
  sleep 2
  echo "# 변경 전"
  run 'curl -s http://localhost:8082'
  echo "# 호스트에서 파일만 고침(컨테이너는 그대로)"
  run 'echo "<h1>AFTER: changed on host</h1>" > bind-demo/index.html'
  echo "# 변경 후"
  run 'curl -s http://localhost:8082'
  run 'docker exec bind-test cat /usr/share/nginx/html/index.html'
}

volume() {
  run 'docker volume create mydata'
  run 'docker volume ls --filter name=mydata'
  run 'docker run -d --name vol-test -v mydata:/data ubuntu:24.04 sleep infinity'
  run 'docker exec vol-test bash -c "echo hi-volume > /data/hello.txt && cat /data/hello.txt"'
  echo "# 컨테이너 삭제"
  run 'docker rm -f vol-test'
  run 'docker ps -a --filter name=vol-test --format "{{.Names}}"'
  echo "# 새 컨테이너에 같은 볼륨 연결"
  run 'docker run -d --name vol-test2 -v mydata:/data ubuntu:24.04 sleep infinity'
  run 'docker exec vol-test2 cat /data/hello.txt'
  run 'docker volume inspect mydata'
}

# 인자 없이 실행하면 전체, 단계 이름을 주면 그 단계만 (예: bash scripts/03_도커_실습.sh web)
if [ $# -eq 0 ]; then
  set -- check basics ubuntu web bind volume
  cleanup
fi
for stage in "$@"; do
  case "$stage" in
    check)  check  > "$LOG_DIR/04_도커_점검.log"        2>&1 ;;
    basics) basics > "$LOG_DIR/05_도커_기본운영.log"     2>&1 ;;
    ubuntu) ubuntu > "$LOG_DIR/06_우분투_컨테이너.log"   2>&1 ;;
    web)    web    > "$LOG_DIR/07_웹서버_포트매핑.log"   2>&1 ;;
    bind)   bind   > "$LOG_DIR/08_바인드마운트.log"      2>&1 ;;
    volume) volume > "$LOG_DIR/09_볼륨_영속성.log"       2>&1 ;;
    *) echo "알 수 없는 단계: $stage" >&2 ;;
  esac
done
echo "로그 저장: $LOG_DIR"
