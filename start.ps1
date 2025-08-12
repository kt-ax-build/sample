#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

# ==== 옵션 ====
$UseEmoji = $false   # true로 바꾸면 이모지 출력(터미널 폰트/UTF-8 필요)
$OpenBrowser = $false # CRA 등에서 자동 브라우저 열림을 막고 싶으면 false 유지

# ==== 출력 유틸 ====
function Out-Line($tag, $msg, $color) {
  $p = switch ($tag) {
    'INFO' { if($UseEmoji){'ℹ'} else {'[INFO]'} }
    'OK'   { if($UseEmoji){'✅'} else {'[ OK ]'} }
    'WARN' { if($UseEmoji){'⚠'}  else {'[WARN]'} }
    'ERR'  { if($UseEmoji){'❌'} else {'[ERR ]'} }
  }
  Write-Host ("{0} {1}" -f $p, $msg) -ForegroundColor $color
}
function Info($m){ Out-Line INFO $m Cyan }
function Ok($m){   Out-Line OK   $m Green }
function Warn($m){ Out-Line WARN $m Yellow }
function Err($m){  Out-Line ERR  $m Red }

# ==== 헤더 ====
$Host.UI.RawUI.WindowTitle = "KT 해커톤 2025 - Start"
Info "KT 해커톤 2025 웹 프로젝트 시작"
"=================================="

# ==== 필수 도구 확인 ====
Info "필수 도구 확인 중..."

# Java
$javaLine = (& java -version 2>&1 | Select-Object -First 1)
if (-not $javaLine) { Err "Java가 설치되지 않았습니다."; exit 1 }
if ($javaLine -notmatch '\"(\d+)\.') { Err "Java 버전을 확인할 수 없습니다. ($javaLine)"; exit 1 }
$javaMajor = [int]$Matches[1]
if ($javaMajor -lt 17) { Err "Java 17 이상 필요. 현재: $javaLine"; exit 1 }
Ok "Java 확인: $javaLine"

# Gradle(옵션)
if (Get-Command gradle -ErrorAction SilentlyContinue) {
  $gradleLine = (& gradle --version | Select-String -Pattern '^Gradle\s+').Line
  if ($gradleLine) { Ok "Gradle 확인: $gradleLine" } else { Info "Gradle CLI 감지됨" }
} else {
  Info "시스템 Gradle 없음 → Gradle Wrapper 사용"
}

# Node / npm
(Get-Command node -ErrorAction SilentlyContinue)  | Out-Null
if (-not $?) { Err "Node.js가 설치되지 않았습니다."; exit 1 }
Ok ("Node 확인: " + (& node --version))

(Get-Command npm -ErrorAction SilentlyContinue) | Out-Null
if (-not $?) { Err "npm이 설치되지 않았습니다."; exit 1 }
Ok ("npm 확인: " + (& npm --version))
""

# ==== 백엔드 시작 ====
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$beDir = Join-Path $root 'samplebe'
if (-not (Test-Path $beDir)) { Err "samplebe 디렉토리를 찾을 수 없습니다. ($beDir)"; exit 1 }

Info "Spring Boot 백엔드 시작 중..."
Push-Location $beDir
try {
  if (-not (Test-Path 'build')) {
    Info "Gradle 빌드/의존성 다운로드..."
    & .\gradlew build -q
  }
  $be = Start-Process -FilePath ".\gradlew" -ArgumentList @('bootRun','-q') -PassThru
} catch {
  Pop-Location
  Err "백엔드 실행 실패: $($_.Exception.Message)"
  exit 1
}
Pop-Location

Info "백엔드 상태 확인 중..."
Start-Sleep -Seconds 3
$beUp = $false
foreach ($i in 1..30) {
  try {
    Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:8080/actuator/health" -TimeoutSec 1 | Out-Null
    $beUp = $true; break
  } catch {
    try {
      Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:8080" -TimeoutSec 1 | Out-Null
      $beUp = $true; break
    } catch { Start-Sleep -Milliseconds 800 }
  }
}
if ($beUp) { Ok "백엔드 기동 완료" } else { Warn "백엔드 확인 타임아웃(계속 진행)" }
""

# ==== 프론트엔드 시작 ====
$feDir = Join-Path $root 'samplefe'
if (-not (Test-Path $feDir)) { Err "samplefe 디렉토리를 찾을 수 없습니다. ($feDir)"; exit 1 }

Info "React 프론트엔드 시작 중..."
Push-Location $feDir
try {
  if (-not (Test-Path 'node_modules')) {
    Info "npm install..."
    & npm install --silent
  }
  if (-not $OpenBrowser) { $env:BROWSER = 'none' }
  $fe = Start-Process -FilePath "npm" -ArgumentList @('start','--silent') -PassThru
} catch {
  Pop-Location
  Err "프론트엔드 실행 실패: $($_.Exception.Message)"
  exit 1
}
Pop-Location

Info "프론트엔드 상태 확인 중..."
Start-Sleep -Seconds 5
$feUp = $false
foreach ($i in 1..20) {
  try {
    Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:3000" -TimeoutSec 1 | Out-Null
    $feUp = $true; break
  } catch { Start-Sleep -Milliseconds 800 }
}
if ($feUp) { Ok "프론트엔드 기동 완료" } else { Warn "프론트엔드 확인 타임아웃(계속 진행)" }

""
Ok "모든 서비스 시작 완료"
"프론트엔드: http://localhost:3000"
"백엔드 API: http://localhost:8080"
"H2 콘솔  : http://localhost:8080/h2-console"
"JDBC URL : jdbc:h2:file:./hackathon  (user: sa, pwd: empty)"
""

# ==== 종료/정리 ====
try {
  Warn "종료하려면 Enter 키를 누르세요"
  [void][System.Console]::ReadLine()
} finally {
  Warn "서비스 중지 중..."

  if ($be -and -not $be.HasExited) {
    try { Stop-Process -Id $be.Id -Force -ErrorAction SilentlyContinue } catch {}
    Info "백엔드 프로세스 종료"
  }
  if ($fe -and -not $fe.HasExited) {
    try { Stop-Process -Id $fe.Id -Force -ErrorAction SilentlyContinue } catch {}
    Info "프론트엔드 프로세스 종료"
  }

  foreach ($port in 8080,3000) {
    try {
      $pids = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue |
              Select-Object -ExpandProperty OwningProcess -Unique
      foreach ($pid in $pids) { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue }
    } catch {}
  }

  Ok "정상 종료"
}
