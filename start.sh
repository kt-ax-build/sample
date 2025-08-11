#!/bin/bash

echo "🚀 KT 해커톤 2025 웹 프로젝트 시작하기"
echo "=================================="

# 백엔드 시작
echo "🔧 Spring Boot 백엔드 시작 중..."
cd samplebe
./mvnw spring-boot:run &
BACKEND_PID=$!
cd ..

# 백엔드 시작 대기
echo "⏳ 백엔드 시작 대기 중..."
sleep 15

# 프론트엔드 시작
echo "🎨 React 프론트엔드 시작 중..."
cd samplefe
npm install
npm start &
FRONTEND_PID=$!
cd ..

echo "✅ 모든 서비스가 시작되었습니다!"
echo ""
echo "🌐 접속 정보:"
echo "   프론트엔드: http://localhost:3000"
echo "   백엔드 API: http://localhost:8080"
echo "   H2 콘솔: http://localhost:8080/h2-console"
echo ""
echo "📊 H2 데이터베이스 정보:"
echo "   JDBC URL: jdbc:h2:file:./hackathon"
echo "   사용자: sa"
echo "   비밀번호: (빈 값)"
echo ""
echo "🛑 서비스 중지하려면 Ctrl+C를 누르세요"

# 종료 시 정리
trap "echo '🛑 서비스 중지 중...'; kill $BACKEND_PID $FRONTEND_PID; exit" INT

# 프로세스 대기
wait 