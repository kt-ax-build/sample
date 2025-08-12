@echo off
setlocal enabledelayedexpansion

REM 에러 처리 함수
:error_exit
echo [ERROR] ❌ 오류: %~1
exit /b 1

REM 성공 메시지 함수
:success_msg
echo [SUCCESS] ✅ %~1
goto :eof

REM 정보 메시지 함수
:info_msg
echo [INFO] ℹ️  %~1
goto :eof

REM 경고 메시지 함수
:warning_msg
echo [WARNING] ⚠️  %~1
goto :eof

echo [INFO] 🚀 KT 해커톤 2025 웹 프로젝트 시작하기
echo ==================================

REM 필수 도구 확인
call :info_msg "필수 도구 확인 중..."

REM Java 확인
java -version >nul 2>&1
if errorlevel 1 (
    call :error_exit "Java가 설치되지 않았습니다."
)

for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    set "JAVA_VERSION=%%i"
    set "JAVA_VERSION=!JAVA_VERSION:"=!"
    for /f "tokens=1 delims=." %%j in ("!JAVA_VERSION!") do set "JAVA_MAJOR=%%j"
)

if !JAVA_MAJOR! lss 17 (
    call :error_exit "Java 17 이상이 필요합니다. 현재 버전: !JAVA_MAJOR!"
)
for /f "tokens=*" %%i in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    call :success_msg "Java 버전 확인 완료: %%i"
)

REM Gradle 확인 (Gradle Wrapper 사용 시 불필요하지만 확인)
gradle --version >nul 2>&1
if errorlevel 1 (
    call :info_msg "시스템 Gradle이 없습니다. Gradle Wrapper를 사용합니다."
) else (
    for /f "tokens=*" %%i in ('gradle --version ^| findstr /i "gradle"') do (
        call :success_msg "Gradle 확인 완료: %%i"
    )
)

REM Node.js 확인
node --version >nul 2>&1
if errorlevel 1 (
    call :error_exit "Node.js가 설치되지 않았습니다."
)
for /f "tokens=*" %%i in ('node --version') do (
    call :success_msg "Node.js 확인 완료: %%i"
)

REM npm 확인
npm --version >nul 2>&1
if errorlevel 1 (
    call :error_exit "npm이 설치되지 않았습니다."
)
for /f "tokens=*" %%i in ('npm --version') do (
    call :success_msg "npm 확인 완료: %%i"
)

echo.

REM 백엔드 시작
call :info_msg "Spring Boot 백엔드 시작 중..."
cd samplebe
if errorlevel 1 (
    call :error_exit "samplebe 디렉토리를 찾을 수 없습니다."
)

REM Gradle 의존성 다운로드 (필요한 경우)
if not exist "build" (
    call :info_msg "Gradle 의존성 다운로드 중..."
    call gradlew.bat build -q
    if errorlevel 1 (
        call :error_exit "Gradle 의존성 다운로드 실패"
    )
)

REM 백엔드 실행
start /b gradlew.bat bootRun -q
set "BACKEND_PID=%ERRORLEVEL%"
cd ..

REM 백엔드 시작 대기 및 상태 확인
call :info_msg "백엔드 시작 대기 중..."
timeout /t 5 /nobreak >nul

REM 백엔드 상태 확인 (최대 30초 대기)
set "BACKEND_STARTED=false"
for /l %%i in (1,1,30) do (
    powershell -Command "try { Invoke-WebRequest -Uri 'http://localhost:8080/actuator/health' -UseBasicParsing -TimeoutSec 1 | Out-Null; exit 0 } catch { exit 1 }" >nul 2>&1
    if not errorlevel 1 (
        call :success_msg "백엔드가 성공적으로 시작되었습니다!"
        set "BACKEND_STARTED=true"
        goto :backend_check_done
    )
    powershell -Command "try { Invoke-WebRequest -Uri 'http://localhost:8080' -UseBasicParsing -TimeoutSec 1 | Out-Null; exit 0 } catch { exit 1 }" >nul 2>&1
    if not errorlevel 1 (
        call :success_msg "백엔드가 성공적으로 시작되었습니다!"
        set "BACKEND_STARTED=true"
        goto :backend_check_done
    )
    if %%i equ 30 (
        call :warning_msg "백엔드 시작 시간이 초과되었습니다. 계속 진행합니다..."
    ) else (
        <nul set /p=.
        timeout /t 1 /nobreak >nul
    )
)
:backend_check_done

echo.

REM 프론트엔드 시작
call :info_msg "React 프론트엔드 시작 중..."
cd samplefe
if errorlevel 1 (
    call :error_exit "samplefe 디렉토리를 찾을 수 없습니다."
)

REM npm 의존성 설치 (필요한 경우)
if not exist "node_modules" (
    call :info_msg "npm 의존성 설치 중..."
    call npm install --silent
    if errorlevel 1 (
        call :error_exit "npm 의존성 설치 실패"
    )
)

REM 프론트엔드 실행
start /b npm start --silent
set "FRONTEND_PID=%ERRORLEVEL%"
cd ..

REM 프론트엔드 시작 대기
call :info_msg "프론트엔드 시작 대기 중..."
timeout /t 10 /nobreak >nul

REM 프론트엔드 상태 확인
set "FRONTEND_STARTED=false"
for /l %%i in (1,1,20) do (
    powershell -Command "try { Invoke-WebRequest -Uri 'http://localhost:3000' -UseBasicParsing -TimeoutSec 1 | Out-Null; exit 0 } catch { exit 1 }" >nul 2>&1
    if not errorlevel 1 (
        call :success_msg "프론트엔드가 성공적으로 시작되었습니다!"
        set "FRONTEND_STARTED=true"
        goto :frontend_check_done
    )
    if %%i equ 20 (
        call :warning_msg "프론트엔드 시작 시간이 초과되었습니다. 계속 진행합니다..."
    ) else (
        <nul set /p=.
        timeout /t 1 /nobreak >nul
    )
)
:frontend_check_done

echo.
echo [SUCCESS] ✅ 모든 서비스가 시작되었습니다!
echo.
echo [INFO] 🌐 접속 정보:
echo    프론트엔드: http://localhost:3000
echo    백엔드 API: http://localhost:8080
echo    H2 콘솔: http://localhost:8080/h2-console
echo.
echo [INFO] 📊 H2 데이터베이스 정보:
echo    JDBC URL: jdbc:h2:file:./hackathon
echo    사용자: sa
echo    비밀번호: (빈 값)
echo.
echo [WARNING] 🛑 서비스 중지하려면 Ctrl+C를 누르세요

REM 프로세스 상태 모니터링
:monitor_loop
timeout /t 5 /nobreak >nul

REM 백엔드 프로세스 확인
tasklist /FI "IMAGENAME eq java.exe" /FI "WINDOWTITLE eq *gradle*" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] ❌ 백엔드 프로세스가 종료되었습니다.
    goto :cleanup
)

REM 프론트엔드 프로세스 확인
tasklist /FI "IMAGENAME eq node.exe" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] ❌ 프론트엔드 프로세스가 종료되었습니다.
    goto :cleanup
)

goto :monitor_loop

REM 종료 시 정리 함수
:cleanup
echo.
echo [WARNING] 🛑 서비스 중지 중...

REM 백엔드 프로세스 종료
taskkill /F /IM java.exe /FI "WINDOWTITLE eq *gradle*" >nul 2>&1
if not errorlevel 1 (
    echo [INFO] 백엔드 프로세스 종료됨
)

REM 프론트엔드 프로세스 종료
taskkill /F /IM node.exe >nul 2>&1
if not errorlevel 1 (
    echo [INFO] 프론트엔드 프로세스 종료됨
)

REM 포트 정리
for /f "tokens=5" %%i in ('netstat -ano ^| findstr :8080') do (
    taskkill /F /PID %%i >nul 2>&1
)
for /f "tokens=5" %%i in ('netstat -ano ^| findstr :3000') do (
    taskkill /F /PID %%i >nul 2>&1
)

echo [SUCCESS] ✅ 모든 서비스가 정상적으로 종료되었습니다.
pause
exit /b 0
