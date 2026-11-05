# 베이스: 공식 NGINX 이미지(가벼운 alpine 판)
FROM nginx:1.27-alpine

# 이미지 설명(누가 봐도 어떤 이미지인지 알 수 있게)
LABEL org.opencontainers.image.title="my-web" \
      org.opencontainers.image.description="Codyssey 워크스테이션 미션용 정적 웹 서버"

# 실행 모드를 환경 변수로 표시
ENV APP_ENV=dev

# 기본 설정을 내 설정으로 교체(/health 주소 추가)
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# 기본 첫 화면을 내 페이지로 교체
COPY site/ /usr/share/nginx/html/

# 컨테이너 안에서 쓰는 포트(문서 역할)
EXPOSE 80

# 10초마다 /health 를 불러 살아 있는지 확인
# localhost 는 IPv6(::1)로 먼저 연결돼 IPv4 로만 듣는 nginx 에 닿지 않으므로 127.0.0.1 을 쓴다
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/health || exit 1
