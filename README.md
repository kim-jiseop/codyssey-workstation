# 개발 워크스테이션 구축 (Codyssey)

터미널·Docker·Git을 직접 세팅하고, **실행 결과(로그·접속·데이터 유지)로 검증한 과정**을 기록한 저장소입니다.

- 작성일: 2026. 11. 6.(금)
- 모든 명령과 전체 출력은 [`logs/`](logs/) 폴더에, 실행 스크립트는 [`scripts/`](scripts/) 폴더에 있습니다.
- 개념 정리는 [학습정리.md](학습정리.md)에 따로 적었습니다.

---

## 1) 프로젝트 개요

| 목표 | 이 저장소에서 한 일 |
|---|---|
| 터미널로 작업 디렉토리·권한 정리 | WSL 우분투에서 생성·복사·이동·삭제, `chmod` 전/후 비교 |
| Docker 설치·점검·운영 | Docker Desktop + WSL2 설치, `info`/`images`/`ps`/`logs`/`stats` |
| Dockerfile로 웹 서버 컨테이너화 | `nginx:1.27-alpine` 기반 커스텀 이미지 `my-web:1.0` |
| 포트 매핑 접속 확인 | 같은 이미지를 8080·8081 두 포트로 실행해 접속 |
| 바인드 마운트·볼륨 검증 | 호스트 파일 수정 즉시 반영 / 컨테이너 삭제 후 데이터 유지 |
| Git·GitHub 연동 | 사용자 정보·기본 브랜치 설정, 공개 저장소 생성·푸시 |

## 2) 실행 환경

| 항목 | 값 |
|---|---|
| OS | Windows 11 Home (+ WSL2 Ubuntu) |
| 셸 / 터미널 | Git Bash(윈도우), bash 5.3(WSL 우분투) |
| Docker | Docker Desktop 4.98.0 / Engine 29.9.2 (WSL2 백엔드, linux/x86_64) |
| WSL | 3.0.3.0 |
| Git | 2.55.0.windows.5 (윈도우), 2.53.0 (WSL) |

> **다른 PC에서 재현할 때**: 서울캠퍼스 맥은 Docker Desktop 대신 **OrbStack**을 실행하면 같은 `docker` 명령을 쓸 수 있습니다.
> 윈도우는 WSL2가 먼저 있어야 합니다(→ [트러블슈팅 1](#트러블슈팅-1-docker-엔진에-연결되지-않음)).

## 3) 수행 체크리스트

- [x] 터미널 기본 조작 및 폴더 구성 → [로그](logs/01_터미널_조작.log)
- [x] 권한 변경 실습(파일·디렉토리) → [로그](logs/02_권한_실습.log)
- [x] Docker 설치/점검 → [로그](logs/04_도커_점검.log)
- [x] 이미지·컨테이너 기본 운영, hello-world 실행 → [로그](logs/05_도커_기본운영.log)
- [x] ubuntu 컨테이너 진입, attach/exec 비교 → [로그](logs/06_우분투_컨테이너.log)
- [x] Dockerfile 커스텀 이미지 빌드/실행 → [로그](logs/07_웹서버_포트매핑.log)
- [x] 포트 매핑 접속(8080, 8081) → [로그](logs/07_웹서버_포트매핑.log)
- [ ] 포트 매핑 브라우저 접속 화면(주소창 포함) → `docs/images/` 에 첨부 예정
- [x] 바인드 마운트 반영 → [로그](logs/08_바인드마운트.log)
- [x] 볼륨 영속성 → [로그](logs/09_볼륨_영속성.log)
- [x] Git 설정 + GitHub 저장소 연동
- [ ] VSCode GitHub 로그인 화면 → `docs/images/` 에 첨부 예정
- [x] 트러블슈팅 3건 (WSL 미설치 / 윈도우 디스크 권한 / 헬스체크 IPv6)

## 4) 저장소 구조

```
.
├── README.md              # 이 문서(기술 문서)
├── 학습정리.md             # 개념 정리
├── app/                   # 웹 서버 소스
│   ├── Dockerfile
│   ├── nginx/default.conf # /health 주소를 추가한 NGINX 설정
│   └── site/index.html    # 정적 페이지
├── scripts/               # 실습을 그대로 다시 돌리는 스크립트
│   ├── 01_터미널_권한.sh
│   ├── 02_윈도우디스크_권한확인.sh
│   └── 03_도커_실습.sh
└── logs/                  # 스크립트가 남긴 명령+출력
```

## 5) 재현 방법

```bash
git clone https://github.com/kim-jiseop/codyssey-workstation.git
cd codyssey-workstation

# 터미널·권한 실습 (리눅스/WSL/맥 터미널)
bash scripts/01_터미널_권한.sh

# Docker 실습 (Docker 엔진이 켜진 상태에서, 윈도우는 Git Bash)
bash scripts/03_도커_실습.sh
```

스크립트는 `$ 명령` 을 먼저 찍고 바로 실행하므로, 로그에 **명령과 출력이 함께** 남습니다.
다시 실행하면 이전 실습 컨테이너·볼륨을 지우고 처음부터 진행합니다.

---

## 6) 수행 로그 (발췌)

### 6-1. 터미널 기본 조작

```
$ pwd
/home/gogosing
$ mkdir -p ~/codyssey/practice
$ cd ~/codyssey/practice
$ touch empty.txt                      # 빈 파일 생성
$ echo "hello codyssey" > memo.txt
$ mkdir docs
$ ls -la
drwxr-xr-x 3 gogosing gogosing 4096 Nov  6 01:26 .
drwxr-xr-x 3 gogosing gogosing 4096 Nov  6 01:26 ..
drwxr-xr-x 2 gogosing gogosing 4096 Nov  6 01:26 docs
-rw-r--r-- 1 gogosing gogosing    0 Nov  6 01:26 empty.txt
-rw-r--r-- 1 gogosing gogosing   15 Nov  6 01:26 memo.txt
$ cat memo.txt                         # 내용 확인
hello codyssey
$ cp memo.txt docs/memo_copy.txt                         # 복사
$ mv docs/memo_copy.txt docs/memo_renamed.txt            # 이름 변경
$ mv empty.txt docs/                                     # 이동
$ echo ".secret_note" > .hidden_file
$ ls                                   # 숨김 파일 안 보임
docs
memo.txt
$ ls -a                                # 숨김 파일까지 보임
.
..
.hidden_file
docs
memo.txt
$ rm docs/empty.txt                    # 파일 삭제
$ cd docs && pwd
/home/gogosing/codyssey/practice/docs
$ cat ../memo.txt                      # 상대 경로
hello codyssey
$ cat ~/codyssey/practice/memo.txt     # 절대 경로(~ = /home/gogosing)
hello codyssey
$ rm -r trash                          # 디렉토리 통째로 삭제
```

### 6-2. 권한 변경 (파일 1개 + 디렉토리 1개)

| 대상 | 변경 전 | 명령 | 변경 후 |
|---|---|---|---|
| `perm_file.txt` | `-rw-r--r--` 644 | `chmod 600` | `-rw-------` 600 |
| `perm_file.txt` | 600 | `chmod 755` | `-rwxr-xr-x` 755 |
| `perm_dir/` | `drwxr-xr-x` 755 | `chmod 700` | `drwx------` 700 |
| `perm_dir/` | 700 | `chmod go+rx` | `drwxr-xr-x` 755 |

```
$ stat -c "%A %a %n" perm_file.txt perm_dir
-rw-r--r-- 644 perm_file.txt
drwxr-xr-x 755 perm_dir
$ chmod 600 perm_file.txt
$ stat -c "%A %a %n" perm_file.txt
-rw------- 600 perm_file.txt
$ chmod 700 perm_dir
$ stat -c "%A %a %n" perm_dir
drwx------ 700 perm_dir

# x(실행) 권한의 효과
$ chmod 644 hello.sh && ./hello.sh
./hello.sh: Permission denied          # (로그에는 앞에 스크립트 이름·줄 번호가 붙어 있음)
$ chmod 755 hello.sh && ./hello.sh
script ran

# 디렉토리의 x = "안으로 들어갈 수 있는 권한"
$ chmod 644 perm_dir && cd perm_dir
cd: perm_dir: Permission denied
$ chmod 755 perm_dir && cd perm_dir && pwd
/home/gogosing/codyssey/practice/perm_dir
```

### 6-3. Docker 설치·점검

```
$ docker --version
Docker version 29.9.2, build a82e528

$ docker info            # 전체 출력: logs/04_도커_점검.log
Client:
 Version:    29.9.2
 Context:    desktop-linux
Server:
 Server Version: 29.9.2
 Storage Driver: overlayfs
 Cgroup Version: 2
 ...
```
`Server:` 항목이 오류 없이 나오면 데몬(뒤에서 컨테이너를 돌리는 엔진)이 동작 중이라는 뜻입니다.

### 6-4. 기본 운영 명령

```
$ docker pull ubuntu:24.04
$ docker pull nginx:1.27-alpine
$ docker images
IMAGE                ID             DISK USAGE   CONTENT SIZE
hello-world:latest   c567b231f656       25.9kB         9.49kB
nginx:1.27-alpine    65645c7bb6a0       74.5MB         21.9MB
ubuntu:24.04         fe81560990fa        119MB         31.7MB

$ docker run --name hello-test hello-world
Hello from Docker!
This message shows that your installation appears to be working correctly.

$ docker ps                 # 실행 중인 것만 → 비어 있음
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
$ docker ps -a              # 멈춘 것까지
c722e7f2e5fc   hello-world   "/hello"   2 seconds ago   Exited (0) 1 second ago   hello-test

$ docker stats --no-stream my-web-8080 my-web-8081
NAME          CPU %     MEM USAGE / LIMIT     MEM %     PIDS
my-web-8080   0.00%     16.47MiB / 7.504GiB   0.21%     19
my-web-8081   0.00%     15.94MiB / 7.504GiB   0.21%     19
```

### 6-5. ubuntu 컨테이너와 attach / exec 차이

```
$ docker run --rm ubuntu:24.04 bash -c "ls / && echo hello from ubuntu && cat /etc/os-release | head -2"
bin  boot  dev  etc  home  lib ...
hello from ubuntu
PRETTY_NAME="Ubuntu 24.04.5 LTS"

# exec: 새 프로세스로 들어갔다 나옴 → 컨테이너는 계속 실행
$ docker run -dit --name ubuntu-exec ubuntu:24.04 bash
$ docker exec ubuntu-exec bash -c "echo inside exec && ls /home && exit"
inside exec
ubuntu
$ docker ps --filter name=ubuntu-exec --format "{{.Names}}: {{.Status}}"
ubuntu-exec: Up 1 second

# attach: 메인 프로세스(bash)에 붙어서 exit → 컨테이너 종료
$ docker run -di --name ubuntu-attach ubuntu:24.04 bash
$ echo "echo inside attach; exit" | docker attach ubuntu-attach
$ docker ps -a --filter name=ubuntu-attach --format "{{.Names}}: {{.Status}}"
ubuntu-attach: Exited (0) Less than a second ago

$ docker stop ubuntu-exec
$ docker ps -a --filter name=ubuntu --format "{{.Names}}: {{.Status}}"
ubuntu-attach: Exited (0) 4 seconds ago
ubuntu-exec: Exited (137) Less than a second ago
```

| | `docker exec` | `docker attach` |
|---|---|---|
| 무엇에 연결? | 컨테이너 안에 **새 프로세스**를 하나 더 띄움 | 이미 돌고 있는 **메인 프로세스(PID 1)** 에 연결 |
| `exit` 하면? | 그 새 프로세스만 끝남 → **컨테이너 유지** | 메인 프로세스가 끝남 → **컨테이너 종료** |
| 끝내지 않고 빠져나오기 | 그냥 `exit` | `Ctrl+P` → `Ctrl+Q` (`-it`로 실행한 경우) |
| 쓰임새 | 운영 중 점검·디버깅 | 메인 프로세스 출력 직접 보기 |

> 관찰 메모: 스크립트(비대화형)로 attach 했을 때 `exit` 는 전달되어 컨테이너가 `Exited (0)` 이 됐지만,
> `echo inside attach` 의 출력은 로그에 찍히지 않았습니다. 원인은 확인하지 못했습니다.
> 대화형(`docker run -it ...` → `docker attach`)으로 직접 해 보면 출력이 보입니다.

### 6-6. Dockerfile 커스텀 이미지 — 방식 (A) 웹 서버 베이스 + 콘텐츠·설정 교체

**선택한 베이스**: 공식 이미지 `nginx:1.27-alpine` (가볍고, 웹 서버가 이미 들어 있음)

[`app/Dockerfile`](app/Dockerfile)

```dockerfile
FROM nginx:1.27-alpine
LABEL org.opencontainers.image.title="my-web" \
      org.opencontainers.image.description="Codyssey 워크스테이션 미션용 정적 웹 서버"
ENV APP_ENV=dev
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY site/ /usr/share/nginx/html/
EXPOSE 80
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/health || exit 1
```

| 커스텀 포인트 | 목적 | 확인 결과 |
|---|---|---|
| `LABEL` | 이미지가 무엇인지 메타데이터로 설명 | `docker inspect` 에 title·description 표시 |
| `ENV APP_ENV=dev` | 실행 모드를 코드 밖 설정으로 분리 | `docker exec ... printenv APP_ENV` → `dev` |
| `COPY default.conf` | 기본 설정 교체, `/health` 주소 추가 | `curl /health` → `ok` |
| `COPY site/` | 기본 첫 화면을 내 페이지로 교체 | `curl /` → `Hello, Codyssey!` |
| `EXPOSE 80` | 컨테이너가 쓰는 포트를 문서로 표시 | `-p 호스트:80` 으로 연결 |
| `HEALTHCHECK` | 컨테이너가 정말 응답하는지 Docker가 주기 점검 | `docker ps` 상태에 `(healthy)` 표시 ([트러블슈팅 3](#트러블슈팅-3-헬스체크가-unhealthy-로-나옴)) |

```
$ docker build -t my-web:1.0 ./app
#6 [2/3] COPY nginx/default.conf /etc/nginx/conf.d/default.conf
#7 [3/3] COPY site/ /usr/share/nginx/html/
#8 naming to docker.io/library/my-web:1.0 done

$ docker images my-web
IMAGE        ID             DISK USAGE   CONTENT SIZE
my-web:1.0   37eeac9e698e       73.6MB           21MB
```

### 6-7. 포트 매핑 (같은 이미지, 두 포트)

```
$ docker run -d -p 8080:80 --name my-web-8080 my-web:1.0
$ docker run -d -p 8081:80 --name my-web-8081 my-web:1.0
$ docker ps --filter name=my-web --format "{{.Names}}\t{{.Ports}}"
my-web-8081   0.0.0.0:8081->80/tcp
my-web-8080   0.0.0.0:8080->80/tcp

$ curl -s http://localhost:8080 | grep "<h1>"
  <h1>Hello, Codyssey!</h1>
$ curl -s http://localhost:8081 | grep "<h1>"
  <h1>Hello, Codyssey!</h1>
$ curl -s http://localhost:8080/health
ok
$ curl -sI http://localhost:8080 | head -1
HTTP/1.1 200 OK

$ docker logs my-web-8080 2>&1 | tail -2
172.17.0.1 - - [05/Nov/2026:16:31:36 +0000] "GET / HTTP/1.1" 200 603 "-" "curl/8.21.0" "-"
172.17.0.1 - - [05/Nov/2026:16:31:36 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.21.0" "-"

$ docker ps --filter name=my-web --format "{{.Names}}: {{.Status}}"
my-web-8081: Up 7 seconds (healthy)
my-web-8080: Up 8 seconds (healthy)
```

**브라우저 접속 화면**: _(첨부 예정 — `docs/images/port-8080.png`, `docs/images/port-8081.png`)_

### 6-8. 바인드 마운트 — 호스트 변경이 즉시 반영

```
$ cat bind-demo/index.html
<h1>BEFORE: bind mount</h1>
$ docker run -d -p 8082:80 --name bind-test -v "<프로젝트경로>/bind-demo:/usr/share/nginx/html" nginx:1.27-alpine

# 변경 전
$ curl -s http://localhost:8082
<h1>BEFORE: bind mount</h1>

# 호스트에서 파일만 수정 (컨테이너 재시작·재빌드 없음)
$ echo "<h1>AFTER: changed on host</h1>" > bind-demo/index.html

# 변경 후
$ curl -s http://localhost:8082
<h1>AFTER: changed on host</h1>
$ docker exec bind-test cat /usr/share/nginx/html/index.html
<h1>AFTER: changed on host</h1>
```

### 6-9. Docker 볼륨 — 컨테이너를 지워도 데이터 유지

```
$ docker volume create mydata
$ docker run -d --name vol-test -v mydata:/data ubuntu:24.04 sleep infinity
$ docker exec vol-test bash -c "echo hi-volume > /data/hello.txt && cat /data/hello.txt"
hi-volume

# 컨테이너 삭제
$ docker rm -f vol-test
$ docker ps -a --filter name=vol-test --format "{{.Names}}"
(출력 없음 = 삭제됨)

# 새 컨테이너에 같은 볼륨 연결
$ docker run -d --name vol-test2 -v mydata:/data ubuntu:24.04 sleep infinity
$ docker exec vol-test2 cat /data/hello.txt
hi-volume

$ docker volume inspect mydata
"Mountpoint": "/var/lib/docker/volumes/mydata/_data"
```

### 6-10. Git 설정 및 GitHub 연동

```
$ git config --global user.name "kim-jiseop"
$ git config --global user.email "<GitHub noreply 주소>"
$ git config --global init.defaultBranch main
$ git config --list --global
user.name=kim-jiseop
user.email=***+kim-jiseop@users.noreply.github.com
init.defaultbranch=main
core.quotepath=false

$ git init
$ gh repo create codyssey-workstation --public --source . --remote origin --push
https://github.com/kim-jiseop/codyssey-workstation
$ git remote -v
origin  https://github.com/kim-jiseop/codyssey-workstation.git (fetch)
origin  https://github.com/kim-jiseop/codyssey-workstation.git (push)
```

- 이메일은 실제 주소 대신 GitHub이 주는 **noreply 주소**를 써서 공개 저장소에 개인 이메일이 남지 않게 했습니다.
- **VSCode GitHub 로그인 화면**: _(첨부 예정 — `docs/images/vscode-github.png`)_

---

## 7) 트러블슈팅

### 트러블슈팅 1. Docker 엔진에 연결되지 않음

- **문제**: Docker Desktop 4.98.0 설치 후 `docker info` 의 Server 부분에서 오류
  ```
  failed to connect to the docker API at npipe:////./pipe/docker_engine; ...
  open //./pipe/docker_engine: The system cannot find the file specified.
  ```
- **원인 가설**
  1. 설치 직후라 터미널이 새 PATH를 모름
  2. Docker Desktop 앱이 실행되지 않아 엔진이 꺼져 있음
  3. 엔진이 돌아갈 리눅스 환경(WSL2)이 없음
- **확인**
  - `docker --version` → `Docker version 29.9.2` 출력, 클라이언트는 정상 (가설 1은 PATH 추가로 해결)
  - Docker Desktop 실행 후에도 같은 오류 → 가설 2 아님
  - `wsl -l -v` → "Linux용 Windows 하위 시스템 설치되어 있지 않습니다"
  - Docker 백엔드 로그(`%LOCALAPPDATA%\Docker\log\host\com.docker.backend.exe.log`)
    ```
    engine linux/wsl failed to start: checking preconditions: checking WSL version: wsl is not installed
    ```
- **해결**: 관리자 권한 PowerShell에서 `wsl --install` 실행 후 재부팅 (Docker 오류 창의 안내와 동일)
- **해결 확인**
  ```
  $ wsl -l -v
    NAME              STATE           VERSION
  * Ubuntu            Stopped         2
    docker-desktop    Running         2

  $ docker info --format '{{.ServerVersion}} | {{.OperatingSystem}} | {{.OSType}}/{{.Architecture}}'
  29.9.2 | Docker Desktop | linux/x86_64

  $ docker run --rm hello-world
  Hello from Docker!
  ```
- **배운 점**: 윈도우의 Docker 엔진은 리눅스 위에서 돌아가므로, 윈도우 Home에서는 WSL2가 먼저 있어야 한다.

### 트러블슈팅 2. 윈도우 디스크에서는 `chmod` 가 먹지 않음

- **문제**: WSL에서 프로젝트 폴더(`/mnt/c/...`)의 파일에 `chmod 600` 을 해도 권한이 `777` 그대로
- **원인 가설**: `/mnt/c` 는 윈도우 NTFS 디스크를 빌려 붙인 것이라, 리눅스 권한 정보를 저장할 곳이 없다
- **확인** ([로그](logs/03_윈도우디스크_권한.log))
  ```
  # 윈도우 디스크
  $ stat -c "%A %a %n" ntfs_test.txt
  -rwxrwxrwx 777 ntfs_test.txt
  $ chmod 600 ntfs_test.txt
  $ stat -c "%A %a %n" ntfs_test.txt
  -rwxrwxrwx 777 ntfs_test.txt          ← 바뀌지 않음
  $ mount | grep " /mnt/c "
  C:\ on /mnt/c type 9p (rw,noatime,aname=drvfs;...)   ← 옵션에 metadata 없음

  # 리눅스 디스크(~)
  $ chmod 600 ext4_test.txt
  $ stat -c "%A %a %n" ext4_test.txt
  -rw------- 600 ext4_test.txt          ← 정상 반영
  ```
- **해결/대안**: 권한 실습은 리눅스 디스크(`~/codyssey/practice`)에서 수행했다.
  윈도우 디스크에서도 권한을 쓰려면 `/etc/wsl.conf` 에 `[automount] options = "metadata"` 를 넣고 WSL을 다시 시작하는 방법이 있다(이번에는 적용하지 않음).
- **배운 점**: 권한은 파일 자체가 아니라 **파일 시스템이 저장**하는 정보다. 같은 리눅스 명령이라도 어느 디스크 위에 있느냐에 따라 결과가 다르다.

### 트러블슈팅 3. 헬스체크가 unhealthy 로 나옴

- **문제**: 바깥에서 `curl http://localhost:8080/health` 는 `ok` 인데, `docker ps` 상태는 `(unhealthy)`
  ```
  my-web-8080: Up 2 minutes (unhealthy)
  ```
- **원인 가설**
  1. `/health` 설정이 잘못됨
  2. 컨테이너 안에 `wget` 이 없음
  3. 컨테이너 **안**에서 부르는 주소가 바깥과 다르게 해석됨
- **확인**
  ```
  $ docker inspect --format '{{json .State.Health}}' my-web-8080
  ... "FailingStreak":5 ... "Output":"wget: can't connect to remote host: Connection refused"
      → wget 은 있음(가설 2 아님), 연결 자체가 거부됨

  $ docker exec my-web-8080 sh -c 'wget -qO- http://localhost/health'
  wget: can't connect to remote host: Connection refused
  $ docker exec my-web-8080 sh -c 'wget -qO- http://127.0.0.1/health'
  ok                                      → 설정은 정상(가설 1 아님)

  $ docker exec my-web-8080 grep localhost /etc/hosts
  127.0.0.1   localhost
  ::1         localhost ip6-localhost ip6-loopback
  ```
  컨테이너 안의 `localhost` 가 IPv6 주소(`::1`)로 먼저 연결되는데,
  NGINX 설정은 `listen 80;` 으로 **IPv4만** 듣고 있어서 거부됨 → 가설 3
- **해결**: 헬스체크 주소를 `http://127.0.0.1/health` 로 바꾸고 다시 빌드
  ```
  $ docker ps --filter name=my-web --format "{{.Names}}: {{.Status}}"
  my-web-8081: Up 7 seconds (healthy)
  my-web-8080: Up 8 seconds (healthy)
  ```
  (다른 방법: `default.conf` 에 `listen [::]:80;` 을 추가해 IPv6도 듣게 하기)
- **배운 점**: "바깥에서 접속된다"와 "컨테이너 안에서 접속된다"는 다른 문제다. 헬스체크는 **컨테이너 안**에서 실행된다.

---

## 8) 보안·개인정보

- 토큰·비밀번호는 문서·로그·스크린샷에 넣지 않았습니다. GitHub 인증은 `gh` 로그인(키링 저장)으로 처리했습니다.
- 커밋 이메일은 noreply 주소를 사용했습니다.
- `.gitignore` 로 `.env`, `*.pem`, `*.key` 같은 비밀값 파일과 교육기관 배포 PDF를 제외했습니다.
- 로그 전체를 `token`, `password`, `gho_` 등으로 검색해 노출이 없는 것을 확인했습니다.
- `docker info` 에 나오는 `http.docker.internal:3128` 프록시는 Docker Desktop 내부 기본값으로 민감정보가 아닙니다.
