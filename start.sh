#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 에러 처리 함수
error_exit() {
    echo -e "${RED}❌ 오류: $1${NC}" >&2
    exit 1
}

# 성공 메시지 함수
success_msg() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 정보 메시지 함수
info_msg() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 경고 메시지 함수
warning_msg() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo -e "${BLUE}🚀 KT 해커톤 2025 웹 프로젝트 시작하기${NC}"
echo "=================================="

# 필수 도구 확인
info_msg "필수 도구 확인 중..."

# Java 확인
if ! command -v java &> /dev/null; then
    error_exit "Java가 설치되지 않았습니다."
fi

JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 17 ]; then
    error_exit "Java 17 이상이 필요합니다. 현재 버전: $JAVA_VERSION"
fi
success_msg "Java 버전 확인 완료: $(java -version 2>&1 | head -n 1)"

# Gradle 확인 (Gradle Wrapper 사용 시 불필요하지만 확인)
if command -v gradle &> /dev/null; then
    success_msg "Gradle 확인 완료: $(gradle --version | head -n 1)"
else
    info_msg "시스템 Gradle이 없습니다. Gradle Wrapper를 사용합니다."
fi

# Node.js 확인
if ! command -v node &> /dev/null; then
    error_exit "Node.js가 설치되지 않았습니다."
fi
success_msg "Node.js 확인 완료: $(node --version)"

# npm 확인
if ! command -v npm &> /dev/null; then
    error_exit "npm이 설치되지 않았습니다."
fi
success_msg "npm 확인 완료: $(npm --version)"

echo ""

# 백엔드 시작
info_msg "Spring Boot 백엔드 시작 중..."
cd samplebe || error_exit "samplebe 디렉토리를 찾을 수 없습니다."

# Gradle 의존성 다운로드 (필요한 경우)
if [ ! -d "build" ] || [ ! -f "build/classes" ]; then
    info_msg "Gradle 의존성 다운로드 중..."
    ./gradlew build -q || error_exit "Gradle 의존성 다운로드 실패"
fi

# 백엔드 실행
./gradlew bootRun -q &
BACKEND_PID=$!
cd ..

# 백엔드 시작 대기 및 상태 확인
info_msg "백엔드 시작 대기 중..."
sleep 5

# 백엔드 상태 확인 (최대 30초 대기)
for i in {1..30}; do
    if curl -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
        success_msg "백엔드가 성공적으로 시작되었습니다!"
        break
    elif curl -s http://localhost:8080 > /dev/null 2>&1; then
        success_msg "백엔드가 성공적으로 시작되었습니다!"
        break
    else
        if [ $i -eq 30 ]; then
            warning_msg "백엔드 시작 시간이 초과되었습니다. 계속 진행합니다..."
        else
            echo -n "."
            sleep 1
        fi
    fi
done

echo ""

# 프론트엔드 시작
info_msg "React 프론트엔드 시작 중..."
cd samplefe || error_exit "samplefe 디렉토리를 찾을 수 없습니다."

# npm 의존성 설치 (필요한 경우)
if [ ! -d "node_modules" ]; then
    info_msg "npm 의존성 설치 중..."
    npm install --silent || error_exit "npm 의존성 설치 실패"
fi

# 프론트엔드 실행
npm start --silent &
FRONTEND_PID=$!
cd ..

# 프론트엔드 시작 대기
info_msg "프론트엔드 시작 대기 중..."
sleep 10

# 프론트엔드 상태 확인
for i in {1..20}; do
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        success_msg "프론트엔드가 성공적으로 시작되었습니다!"
        break
    else
        if [ $i -eq 20 ]; then
            warning_msg "프론트엔드 시작 시간이 초과되었습니다. 계속 진행합니다..."
        else
            echo -n "."
            sleep 1
        fi
    fi
done

echo ""
echo -e "${GREEN}✅ 모든 서비스가 시작되었습니다!${NC}"
echo ""
echo -e "${BLUE}🌐 접속 정보:${NC}"
echo "   프론트엔드: http://localhost:3000"
echo "   백엔드 API: http://localhost:8080"
echo "   H2 콘솔: http://localhost:8080/h2-console"
echo ""
echo -e "${BLUE}📊 H2 데이터베이스 정보:${NC}"
echo "   JDBC URL: jdbc:h2:file:./hackathon"
echo "   사용자: sa"
echo "   비밀번호: (빈 값)"
echo ""
echo -e "${YELLOW}🛑 서비스 중지하려면 Ctrl+C를 누르세요${NC}"

# 프로세스 상태 모니터링 함수
monitor_processes() {
    while true; do
        if ! kill -0 $BACKEND_PID 2>/dev/null; then
            echo -e "${RED}❌ 백엔드 프로세스가 종료되었습니다.${NC}"
            break
        fi
        if ! kill -0 $FRONTEND_PID 2>/dev/null; then
            echo -e "${RED}❌ 프론트엔드 프로세스가 종료되었습니다.${NC}"
            break
        fi
        sleep 5
    done
}

# 종료 시 정리 함수
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 서비스 중지 중...${NC}"
    
    # 백엔드 프로세스 종료
    if kill -0 $BACKEND_PID 2>/dev/null; then
        kill $BACKEND_PID
        echo -e "${BLUE}백엔드 프로세스 종료됨${NC}"
    fi
    
    # 프론트엔드 프로세스 종료
    if kill -0 $FRONTEND_PID 2>/dev/null; then
        kill $FRONTEND_PID
        echo -e "${BLUE}프론트엔드 프로세스 종료됨${NC}"
    fi
    
    # 포트 정리
    lsof -ti:8080 | xargs kill -9 2>/dev/null || true
    lsof -ti:3000 | xargs kill -9 2>/dev/null || true
    
    echo -e "${GREEN}✅ 모든 서비스가 정상적으로 종료되었습니다.${NC}"
    exit 0
}

# 시그널 핸들러 설정
trap cleanup INT TERM

# 프로세스 모니터링 시작
monitor_processes &
MONITOR_PID=$!

# 메인 프로세스 대기
wait 