@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem =========================
rem 출력 설정
rem =========================
set "USE_COLOR=0"   rem 0=단색(권장), 1=색상(PowerShell Write-Host)
set "USE_EMOJI=0"   rem 0=이모지 안씀, 1=이모지 시도(UTF-8 + 지원 폰트 필요)
set "PS=powershell -NoProfile -ExecutionPolicy Bypass -Command"

:mk_prefix
set "P_INFO=[INFO]"
set "P_OK=[ OK ]"
set "P_WARN=[WARN]"
set "P_ERR=[ERR ]"
if "%USE_EMOJI%"=="1" (
  set "P_INFO=ℹ️ [INFO]"
  set "P_OK=✅ [ OK ]"
  set "P_WARN=⚠️ [WARN]"
  set "P_ERR=❌ [ERR ]"
)
exit /b

call :mk_prefix

:echo_info
if "%USE_COLOR%"=="1" (%PS% "Write-Host '%P_INFO% ' -NoNewline -ForegroundColor Cyan; Write-Host ($args -join ' ')" %* & exit /b)
echo %P_INFO% %*
exit /b

:echo_ok
if "%USE_COLOR%"=="1" (%PS% "Write-Host '%P_OK%  ' -NoNewline -ForegroundColor Green; Write-Host ($args -join ' ')" %* & exit /b)
echo %P_OK%  %*
exit /b

:echo_warn
if "%USE_COLOR%"=="1" (%PS% "Write-Host '%P_WARN% ' -NoNewline -ForegroundColor Yellow; Write-Host ($args -join ' ')" %* & exit /b)
echo %P_WARN% %*
exit /b

:echo_err
if "%USE_COLOR%"=="1" (%PS% "Write-Host '%P_ERR%  ' -NoNewline -ForegroundColor Red; Write-Host ($args -join ' ')" %* 1>&2 & exit /b)
>&2 echo %P_ERR%  %*
exit /b

:die
call :echo_err %*
exit /b 1


rem =========================
rem 헤더
rem =========================
%PS% "$host.UI.RawUI.WindowTitle='KT 해커톤 2025 웹 프로젝트 시작기'"
call :echo_info "🚀 KT 해커톤 2025 웹 프로젝트 시작하기"
echo ==================================


rem =========================
rem 필수 도구 확인
rem =========================
call :echo_info "필수 도구 확인 중..."

where java >NUL 2>&1 || call :die "Java가 설치되지 않았습니다."
for /f "usebackq tokens=* delims=" %%v in (`powershell -NoProfile -Command "(java -version) 2>&1 | Select-String -Pattern '""(\d+)\.' | ForEach-Object { if($_.Matches.Count -gt 0){$_.Matches[0].Groups[1].Value} }"`) do set "JAVA_MAJOR=%%v"
if "%JAVA_MAJOR%"=="" call :die "Java 버전을 확인할 수 없습니다."
if %JAVA_MAJOR% LSS 17 call :die "Java 17 이상이 필요합니다. 현재 주요 버전: %JAVA_MAJOR%"
for /f "usebackq tokens=* delims=" %%l in (`powershell -NoProfile -Command "(java -version) 2>&1 | Select-Object -First 1"`) do set "JAVA_LINE=%%l"
call :echo_ok "Java 버전 확인 완료: %JAVA_LINE%"

where gradle >NUL 2>&1 ^
  && for /f "usebackq tokens=* delims=" %%g in (`gradle --version ^| findstr /r /c:"Gradle "`) do call :echo_ok "Gradle 확인 완료: %%g" ^
  || call :echo_info "시스템 Gradle이 없습니다. Gradle Wrapper를 사용합니다."

where node >NUL 2>&1 || call :die "Node.js가 설치되지 않았습니다."
for /f "usebackq tokens=* delims=" %%n in (`node --version`) do call :echo_ok "Node.js 확인 완료: %%n"

where npm >NUL 2>&1 || call :die "npm이 설치되지 않았습니다."
for /f "usebackq tokens=* delims=" %%m in (`npm --version`) do call :echo_ok "npm 확인 완료: %%m"

echo.


rem =========================
rem 백엔드 시작
rem =========================
call :echo_info "Spring Boot 백엔드 시작 중..."
if not exist "samplebe" call :die "samplebe 디렉토리를 찾을 수 없습니다."
pushd samplebe

if not exist "build" (
  call :echo_info "Gradle 의존성 다운로드/빌드 중..."
  call .\gradlew build -q || (popd & call :die "Gradle 빌드 실패")
)

%PS% "$p = Start-Process -FilePath '.\gradlew' -ArgumentList @('bootRun','-q') -WorkingDirectory (Get-Location) -PassThru; [IO.File]::WriteAllText('..\BACKEND_PID.txt', $p.Id)"
if errorlevel 1 (popd & call :die "백엔드 실행 실패")
popd

call :echo_info "백엔드 시작 대기 중..."
timeout /t 5 >NUL

set "HEALTH_OK=0"
for /l %%i in (1,1,30) do (
  curl -s http://localhost:8080/actuator/health >NUL 2>&1 && set "HEALTH_OK=1" && goto :backend_ok
  curl -s http://localhost:8080 >NUL 2>&1 && set "HEALTH_OK=1" && goto :backend_ok
  if "%%i"=="30" (
    call :echo_warn "백엔드 시작 시간이 초과되었습니다. 계속 진행합니다..."
  ) else (
    <NUL set /p .=.
    timeout /t 1 >NUL
  )
)
:backend_ok
if "%HEALTH_OK%"=="1" call :echo_ok "백엔드가 성공적으로 시작되었습니다!"
echo.


rem =========================
rem 프론트엔드 시작
rem =========================
call :echo_info "React 프론트엔드 시작 중..."
if not exist "samplefe" call :die "samplefe 디렉토리를 찾을 수 없습니다."
pushd samplefe

if not exist "node_modules" (
  call :echo_info "npm 의존성 설치 중..."
  call npm install --silent || (popd & call :die "npm 의존성 설치 실패")
)

%PS% "$p = Start-Process -FilePath 'npm' -ArgumentList @('start','--silent') -WorkingDirectory (Get-Location) -PassThru; [IO.File]::WriteAllText('..\FRONTEND_PID.txt', $p.Id)"
if errorlevel 1 (popd & call :die "프론트엔드 실행 실패")
popd

call :echo_info "프론트엔드 시작 대기 중..."
timeout /t 10 >NUL

set "FE_OK=0"
for /l %%i in (1,1,20) do (
  curl -s http://localhost:3000 >NUL 2>&1 && set "FE_OK=1" && goto :frontend_ok
  if "%%i"=="20" (
    call :echo_warn "프론트엔드 시작 시간이 초과되었습니다. 계속 진행합니다..."
  ) else (
    <NUL set /p .=.
    timeout /t 1 >NUL
  )
)
:frontend_ok
if "%FE_OK%"=="1" call :echo_ok "프론트엔드가 성공적으로 시작되었습니다!"

echo.
call :echo_ok "모든 서비스가 시작되었습니다!"
echo.
echo 프론트엔드: http://localhost:3000
echo 백엔드 API: http://localhost:8080
echo H2 콘솔  : http://localhost:8080/h2-console
echo JDBC URL : jdbc:h2:file:./hackathon
echo 사용자   : sa
echo 비밀번호 : (빈 값)
echo.
call :echo_warn "서비스 중지하려면 아무 키나 누르세요"

for /f "usebackq tokens=* delims=" %%p in (`type BACKEND_PID.txt 2^>NUL`) do set "BACKEND_PID=%%p"
for /f "usebackq tokens=* delims=" %%p in (`type FRONTEND_PID.txt 2^>NUL`) do set "FRONTEND_PID=%%p"

pause >NUL

rem =========================
rem 종료 처리
rem =========================
echo.
call :echo_warn "서비스 중지 중..."

if defined BACKEND_PID (
  taskkill /PID %BACKEND_PID% /T /F >NUL 2>&1
  call :echo_info "백엔드 프로세스 종료됨"
)

if defined FRONTEND_PID (
  taskkill /PID %FRONTEND_PID% /T /F >NUL 2>&1
  call :echo_info "프론트엔드 프로세스 종료됨"
)

for /f "tokens=5" %%p in ('netstat -ano ^| findstr /r ":8080 .*LISTENING"') do taskkill /PID %%p /F >NUL 2>&1
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /r ":3000 .*LISTENING"') do taskkill /PID %%p /F >NUL 2>&1

del /q BACKEND_PID.txt 2>NUL
del /q FRONTEND_PID.txt 2>NUL

call :echo_ok "모든 서비스가 정상적으로 종료되었습니다."
exit /b 0
