
# OFFLINE-INSTALL

## 1. 정의
- 해당 프로젝트는 기존에 소프트웨어 설치를 간단하게 하는 토이 프로젝트 입니다.
- RedHat 8 기준으로 구성하였다.

## 2. 소프트웨어
- mysql  5.7
- Redis
- Haproxy
- RabbitMQ
- Nginx
- docker-ce
- openjdk 11

## 3. 스크립트 실행 순서
1. install.sh -> S?W install 스크립트
2. install-nvm.sh -> Node instaLl 스크립트
3. configure.sh -> 소프트웨어 설정 스크립트

## 4. 특이사항
- 현재 해당 repo에는 소프트웨어 설치에 필요한 rpm 파일은 제외하였습니다. (용량이 커서 github에 못올림)