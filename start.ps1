# start.ps1
# PowerShell 5.1+ 권장. Cursor 하단 PowerShell 터미널에서 실행:  .\start.ps1
# 정책 오류 시: Set-ExecutionPolicy -Scope Process Bypass

$ErrorActionPreference = 'Stop'

# ========== 출력 유틸(ASCII 태그) ==========
function W-Info([string]$msg){ Write-Host ("[INFO] {0}" -f $msg) -ForegroundColor Cyan }
function W-Ok  ([string]$msg){ Write-Host ("[ OK ] {0}" -f $msg) -ForegroundColor Green }
function W-Warn([string]$msg){ Write-Host ("[WARN] {0}" -f $msg) -ForegroundColor Yellow }
function W-Err ([string]$msg){ Write-Host ("[ERR ] {0}" -f $msg) -ForegroundColor Red }

# ========== HTTP 헬퍼(버전 무관 타임아웃) ==========
function Test-HttpOk([string]$url, [int]$timeoutMs = 1000) {
  try {
    $handler = New-Object System.Net.Http.HttpClientHandler
    $client  = New-Object System.Net.Http.HttpClient($handler)
    $client.Timeout = [TimeSpan]::FromMilliseconds($timeoutMs)
    $resp = $client.GetAsync($url).GetAwaiter().GetResult()
    return $resp.IsSuccessStatusCode
  } catch { return $false } finally {
    if ($client) { $client.Dispose() }
    if ($handler) { $handler.Dispose() }
  }
}

# ========== 헤더/경로 ==========
try { $Host.UI.RawUI.WindowTitle = "KT 해커톤 2025 - Start" } catch {}
W-Info "KT 해커톤 2025 웹 프로젝트 시작"
"=================================="

$Root  = Split-Path -Parent $MyInvocation.MyCommand.Path
$BeDir = Join-Path $Root 'samplebe'
$FeDir = Join-Path $Root 'samplefe'

# ========== 필수 도구 확인 ==========
W-Info "필수 도구 확인 중..."

# Java
$javaLine = (& java -version 2>&1 | Select-Object -First 1)
if (-not $javaLine) { W-Err "Java가 설치되지 않았습니다."; exit 1 }
if ($javaLine -notmatch '\"(\d+)\.') { W-Err "Java 버전을 확인할 수 없습니다. ($javaLine)"; exit 1 }
$javaMajor = [int]$Matches[1]
if ($javaMajor -lt 17) { W-Err ("Java 17 이상 필요. 현재: {0}" -f $javaLine); exit 1 }
W-Ok ("Java 확인: {0}" -f $javaLine)

# Gradle(옵션)
if (Get-Command gradle -ErrorAction SilentlyContinue) {
  $gradleLine = (& gradle --version | Select-String -Pattern '^Gradle\s+').Line
  if ($gradleLine) { W-Ok ("Gradle 확인: {0}" -f $gradleLine) } else { W-Info "Gradle CLI 감지됨" }
} else {
  W-Info "시스템 Gradle 없음 → Gradle Wrapper 사용"
}

# Node / npm
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { W-Err "Node.js가 설치되지 않았습니다."; exit 1 }
W-Ok ("Node 확인: {0}" -f (& node --version))
if (-not (Get-Command npm  -ErrorAction SilentlyContinue)) { W-Err "npm이 설치되지 않았습니다."; exit 1 }
W-Ok ("npm 확인: {0}" -f (& npm --version))
""

# ========== 실행(백엔드 → 프론트엔드) ==========
$be = $null
$fe = $null

try {
  # --- 백엔드 ---
  if (-not (Test-Path $BeDir)) { W-Err ("samplebe 디렉토리를 찾을 수 없습니다. ({0})" -f $BeDir); exit 1 }
  W-Info "Spring Boot 백엔드 시작 중..."
  Push-Location $BeDir
  try {
    if (-not (Test-Path 'build')) {
      W-Info "Gradle 빌드/의존성 다운로드..."
      & .\gradlew build -q
    }
    $be = Start-Process -FilePath ".\gradlew" -ArgumentList @('bootRun','-q') -PassThru
  } catch {
    throw "백엔드 실행 실패: $($_.Exception.Message)"
  } finally {
    Pop-Location
  }

  W-Info "백엔드 상태 확인 중..."
  Start-Sleep -Seconds 3
  $beUp = $false
  foreach ($i in 1..30) {
    if ( Test-HttpOk "http://localhost:8080/actuator/health" -timeoutMs 1000 `
      -or Test-HttpOk "http://localhost:8080" -timeoutMs 1000) { $beUp = $true; break }
    Start-Sleep -Milliseconds 800
  }
  if ($beUp) { W-Ok "백엔드 기동 완료" } else { W-Warn "백엔드 확인 타임아웃(계속 진행)" }
  ""

  # --- 프론트엔드 ---
  if (-not (Test-Path $FeDir)) { W-Err ("samplefe 디렉토리를 찾을 수 없습니다. ({0})" -f $FeDir); exit 1 }
  W-Info "React 프론트엔드 시작 중..."
  Push-Location $FeDir
  try {
    if (-not (Test-Path 'node_modules')) {
      W-Info "npm install..."
      & npm install --silent
    }
    $env:BROWSER = 'none'   # CRA 자동 브라우저 오픈 방지
    $fe = Start-Process -FilePath "npm" -ArgumentList @('start','--silent') -PassThru
  } catch {
    throw "프론트엔드 실행 실패: $($_.Exception.Message)"
  } finally {
    Pop-Location
  }

  W-Info "프론트엔드 상태 확인 중..."
  Start-Sleep -Seconds 5
  $feUp = $false
  foreach ($i in 1..20) {
    if (Test-HttpOk "http://localhost:3000" -timeoutMs 1000) { $feUp = $true; break }
    Start-Sleep -Milliseconds 800
  }
  if ($feUp) { W-Ok "프론트엔드 기동 완료" } else { W-Warn "프론트엔드 확인 타임아웃(계속 진행)" }

  ""
  W-Ok "모든 서비스 시작 완료"
  "프론트엔드: http://localhost:3000"
  "백엔드 API: http://localhost:8080"
  "H2 콘솔  : http://localhost:8080/h2-console"
  "JDBC URL : jdbc:h2:file:./hackathon  (user: sa, pwd: empty)"
  ""

  W-Warn "종료하려면 Enter 키를 누르세요"
  [void][System.Console]::ReadLine()
}
catch {
  W-Err $_
}
finally {
  W-Warn "서비스 중지 중..."

  if ($be -and -not $be.HasExited) {
    try { Stop-Process -Id $be.Id -Force -ErrorAction SilentlyContinue } catch {}
    W-Info "백엔드 프로세스 종료"
  }
  if ($fe -and -not $fe.HasExited) {
    try { Stop-Process -Id $fe.Id -Force -ErrorAction SilentlyContinue } catch {}
    W-Info "프론트엔드 프로세스 종료"
  }

  foreach ($port in 8080,3000) {
    try {
      $pids = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue |
              Select-Object -ExpandProperty OwningProcess -Unique
      foreach ($pid in $pids) {
        try { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue } catch {}
      }
    } catch {}
  }

  W-Ok "정상 종료"
}
