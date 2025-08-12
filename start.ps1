#Requires -Version 5.1

# ==== Options ====
$UseEmoji = $false   # Set to true for emoji output (requires terminal font/UTF-8 support)
$OpenBrowser = $false # Set to false to prevent auto-browser opening in CRA
$ShowMonitoring = $false # Set to true to show continuous service monitoring logs
$QuietMode = $true   # Set to false to show all startup logs

# ==== Output Utilities ====
function Out-Line($tag, $msg, $color) {
  $p = switch ($tag) {
    'INFO' { if($UseEmoji){'[INFO]'} else {'[INFO]'} }
    'OK'   { if($UseEmoji){'[ OK ]'} else {'[ OK ]'} }
    'WARN' { if($UseEmoji){'[WARN]'}  else {'[WARN]'} }
    'ERR'  { if($UseEmoji){'[ERR ]'} else {'[ERR ]'} }
  }
  Write-Host ("{0} {1}" -f $p, $msg) -ForegroundColor $color
}
function Info($m){ Out-Line INFO $m Cyan }
function Ok($m){   Out-Line OK   $m Green }
function Warn($m){ Out-Line WARN $m Yellow }
function Err($m){  Out-Line ERR  $m Red }

# ==== Header ====
$Host.UI.RawUI.WindowTitle = "KT Hackathon 2025 - Start"
Info "KT Hackathon 2025 Web Project Starting"
"=================================="

# ==== Check Required Tools ====
Info "Checking required tools..."

# Java
try {
    $javaVersion = java -version 2>&1 | Select-String "version" | Select-Object -First 1
    if ($javaVersion -match 'version "(\d+)\.') {
        $javaMajor = [int]$Matches[1]
        if ($javaMajor -lt 8) { Err "Java 8+ required. Current: $javaVersion"; exit 1 }
        Ok "Java check: $javaVersion (Major version: $javaMajor)"
    } else {
        Ok "Java check: $javaVersion"
    }
} catch {
    Err "Java is not installed or not accessible"; exit 1
}

# Gradle (optional)
if (Get-Command gradle -ErrorAction SilentlyContinue) {
  $gradleLine = (& gradle --version | Select-String -Pattern '^Gradle\s+').Line
  if ($gradleLine) { Ok "Gradle check: $gradleLine" } else { Info "Gradle CLI detected" }
} else {
  Info "System Gradle not found -> Using Gradle Wrapper"
}

# Node / npm
if (Get-Command node -ErrorAction SilentlyContinue) {
    Ok ("Node check: " + (& node --version))
} else {
    Err "Node.js is not installed."; exit 1
}

if (Get-Command npm -ErrorAction SilentlyContinue) {
    Ok ("npm check: " + (& npm --version))
} else {
    Err "npm is not installed."; exit 1
}
""

# ==== Start Backend ====
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$beDir = Join-Path $root 'samplebe'
if (-not (Test-Path $beDir)) { Err "samplebe directory not found ($beDir)"; exit 1 }

Info "Starting Spring Boot backend..."
Push-Location $beDir
try {
  if (-not (Test-Path 'build')) {
    Info "Gradle build/dependency download..."
    & .\gradlew build -q
  }
  Info "Executing: .\gradlew bootRun -q"
  $be = Start-Job -ScriptBlock { 
    Set-Location $using:beDir
    & .\gradlew bootRun -q
  } -Name "Backend"
  if ($be) {
    Info "Backend job started with ID: $($be.Id)"
  } else {
    Err "Failed to start backend job"
    exit 1
  }
} catch {
  Err "Backend execution failed: $($_.Exception.Message)"
  exit 1
} finally {
  Pop-Location
}

Info "Checking backend status..."
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
if ($beUp) { Ok "Backend startup complete" } else { if (-not $QuietMode) { Warn "Backend check timeout (continuing)" } }
""

# ==== Start Frontend ====
$feDir = Join-Path $root 'samplefe'
if (-not (Test-Path $feDir)) { Err "samplefe directory not found ($feDir)"; exit 1 }

Info "Starting React frontend..."
Push-Location $feDir
try {
  if (-not (Test-Path 'node_modules')) {
    Info "npm install..."
    & npm install --silent
  }
  if (-not $OpenBrowser) { $env:BROWSER = 'none' }
  Info "Executing: npm start"
  $fe = Start-Job -ScriptBlock { 
    Set-Location $using:feDir
    & npm start
  } -Name "Frontend"
  if ($fe) {
    Info "Frontend job started with ID: $($fe.Id)"
  } else {
    Err "Failed to start frontend job"
    exit 1
  }
} catch {
  Err "Frontend execution failed: $($_.Exception.Message)"
  exit 1
} finally {
  Pop-Location
}

Info "Checking frontend status..."
Start-Sleep -Seconds 5
$feUp = $false
foreach ($i in 1..20) {
  try {
    Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:3000" -TimeoutSec 1 | Out-Null
    $feUp = $true; break
  } catch { Start-Sleep -Milliseconds 800 }
}
if ($feUp) { Ok "Frontend startup complete" } else { if (-not $QuietMode) { Warn "Frontend check timeout (continuing)" } }

""
Ok "All services started successfully"
"Frontend: http://localhost:3000"
"Backend API: http://localhost:8080"
"H2 Console: http://localhost:8080/h2-console"
"JDBC URL: jdbc:h2:file:./hackathon  (user: sa, pwd: empty)"
""

# ==== Service Monitoring ====
Info "Services are running. Press Ctrl+C to stop all services."
if ($ShowMonitoring) {
  Info "Monitoring service status..."
} else {
  Info "Monitoring disabled. Services running in background."
}

try {
  while ($true) {
    if ($ShowMonitoring) {
      # Check backend status
      $beStatus = "Running"
      try {
        $beResponse = Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:8080/actuator/health" -TimeoutSec 2 | Out-Null
        $beStatus = "Healthy"
      } catch {
        $beStatus = "Unreachable"
      }
      
      # Check frontend status
      $feStatus = "Running"
      try {
        $feResponse = Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:3000" -TimeoutSec 2 | Out-Null
        $feStatus = "Healthy"
      } catch {
        $feStatus = "Unreachable"
      }
      
      # Display status
      $timestamp = Get-Date -Format "HH:mm:ss"
      Write-Host "[$timestamp] Backend: $beStatus | Frontend: $feStatus" -ForegroundColor Cyan
      
      # Show recent logs
      if ($be) {
        $beLogs = Receive-Job -Id $be.Id -Keep | Select-Object -Last 1
        if ($beLogs) {
          Write-Host "  Backend: $beLogs" -ForegroundColor Green
        }
      }
      
      if ($fe) {
        $feLogs = Receive-Job -Id $fe.Id -Keep | Select-Object -Last 1
        if ($feLogs) {
          Write-Host "  Frontend: $feLogs" -ForegroundColor Yellow
        }
      }
      
      Start-Sleep -Seconds 5
    } else {
      # Silent monitoring - just keep the script running
      Start-Sleep -Seconds 10
    }
  }
} catch {
  # Handle Ctrl+C
  Write-Host ""
  Warn "Received interrupt signal. Stopping services..."
} finally {
  Warn "Stopping services..."

  if ($be) {
    try { Stop-Job -Id $be.Id -Force -ErrorAction SilentlyContinue } catch {}
    Info "Backend job stopped"
  }
  if ($fe) {
    try { Stop-Job -Id $fe.Id -Force -ErrorAction SilentlyContinue } catch {}
    Info "Frontend job stopped"
  }

  foreach ($port in 8080,3000) {
    try {
      $pids = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue |
              Select-Object -ExpandProperty OwningProcess -Unique
      foreach ($pid in $pids) { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue }
    } catch {}
  }

  Ok "Normal shutdown"
}
