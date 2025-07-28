# KT 해커톤 2025 웹 프로젝트

KT 해커톤 2025를 위한 완전한 웹 애플리케이션입니다. React + MUI 프론트엔드와 Spring Boot 백엔드, PostgreSQL 데이터베이스로 구성되어 있습니다.

## 🚀 프로젝트 개요

- **개최명**: KT 해커톤
- **개최일**: 2025년 9월 1일 ~ 2025년 9월 3일
- **장소**: 원수 수련원
- **주최**: KT
- **주관**: KT AX Build TF
- **후원**: KT, KT Cloud, KT DS, KT M&S, KT Skylife

## 🛠 기술 스택

### 프론트엔드
- **React 18.2.0**
- **Material-UI (MUI) 5.14.20**
- **React Router DOM 6.20.1**
- **Axios 1.6.2**

### 백엔드
- **Java 17**
- **Spring Boot 3.2.0**
- **Spring Data JPA**
- **PostgreSQL 15**

### 데이터베이스
- **PostgreSQL 15** (Docker)
- **pgAdmin 4** (Docker)

## 📁 프로젝트 구조

```
sample/
├── docker-compose.yml          # PostgreSQL & pgAdmin 설정
├── samplebe/                   # Spring Boot 백엔드
│   ├── src/main/java/com/kt/hackathon/
│   │   ├── controller/         # REST API 컨트롤러
│   │   ├── service/           # 비즈니스 로직
│   │   ├── repository/        # 데이터 접근 계층
│   │   ├── entity/           # JPA 엔티티
│   │   └── dto/              # 데이터 전송 객체
│   ├── src/main/resources/
│   │   └── application.yml   # 애플리케이션 설정
│   └── pom.xml               # Maven 의존성
└── samplefe/                  # React 프론트엔드
    ├── src/
    │   ├── components/        # 재사용 가능한 컴포넌트
    │   ├── pages/            # 페이지 컴포넌트
    │   ├── App.js            # 메인 앱 컴포넌트
    │   └── index.js          # 앱 진입점
    ├── public/
    │   └── index.html        # HTML 템플릿
    └── package.json          # npm 의존성
```

## 🚀 시작하기

### 1. 데이터베이스 실행

```bash
# PostgreSQL과 pgAdmin 컨테이너 실행
docker-compose up -d
```

### 2. 백엔드 실행

```bash
# 백엔드 디렉토리로 이동
cd samplebe

# Maven으로 프로젝트 빌드 및 실행
./mvnw spring-boot:run
```

백엔드는 `http://localhost:8080`에서 실행됩니다.

### 3. 프론트엔드 실행

```bash
# 프론트엔드 디렉토리로 이동
cd samplefe

# 의존성 설치
npm install

# 개발 서버 실행
npm start
```

프론트엔드는 `http://localhost:3000`에서 실행됩니다.

## 📋 주요 기능

### 🏠 홈페이지
- 해커톤 소개 및 하이라이트
- 참가 신청 버튼
- 일정 및 장소 정보

### 📝 참가 신청
- 3단계 스텝퍼를 통한 참가 신청
- 실시간 폼 검증
- 중복 이메일/팀명 확인

### 📅 일정
- 3일간의 상세 일정 표시
- 타임라인 형태의 시각적 표현
- 참가 혜택 정보

### 👥 참가자 관리
- 참가자 목록 조회
- 검색 및 필터링 기능
- 참가자 통계 대시보드

## 🔧 API 엔드포인트

### 참가자 관리
- `POST /api/participants` - 참가자 등록
- `GET /api/participants` - 전체 참가자 조회
- `GET /api/participants/{id}` - 특정 참가자 조회
- `GET /api/participants/status/{status}` - 상태별 참가자 조회
- `PUT /api/participants/{id}/status` - 참가자 상태 변경
- `DELETE /api/participants/{id}` - 참가자 삭제

## 🗄 데이터베이스

### PostgreSQL 접속 정보
- **호스트**: localhost
- **포트**: 5432
- **데이터베이스**: kt_hackathon
- **사용자**: hackathon_user
- **비밀번호**: hackathon123!

### pgAdmin 접속 정보
- **URL**: http://localhost:5050
- **이메일**: admin@kt.com
- **비밀번호**: admin123!

## 📱 반응형 디자인

모든 페이지는 모바일, 태블릿, 데스크톱에 최적화된 반응형 디자인으로 구현되었습니다.

## 🎨 UI/UX 특징

- **Material Design**: Google의 Material Design 가이드라인 준수
- **직관적인 네비게이션**: 명확한 메뉴 구조
- **사용자 친화적 폼**: 단계별 참가 신청 프로세스
- **시각적 피드백**: 로딩 상태, 성공/오류 메시지
- **접근성**: 키보드 네비게이션 및 스크린 리더 지원

## 🔒 보안

- **입력 검증**: 프론트엔드 및 백엔드 양쪽에서 데이터 검증
- **CORS 설정**: 프론트엔드와 백엔드 간 안전한 통신
- **SQL 인젝션 방지**: JPA를 통한 안전한 데이터베이스 접근

## 📞 문의처

- **이메일**: kt-hackathon@kt.com
- **전화**: 02-1234-5678

## 📄 라이선스

© 2025 KT Corporation. All rights reserved. 