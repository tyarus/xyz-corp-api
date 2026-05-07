#!/usr/bin/env pwsh
<#
.SYNOPSIS
IaaS Implementation Verification Script
Comprehensive testing untuk semua komponen IaaS

.DESCRIPTION
Script ini melakukan testing lengkap untuk:
- Virtual Machine (Docker containers)
- Web Server (Nginx)
- Firewall/Security (Rate limiting, headers)
- Web Application (Flask)
- Monitoring (CPU/Memory metrics)

.EXAMPLE
.\verify_iaas_complete.ps1
#>

param(
    [ValidateSet('local', 'railway')]
    [string]$Environment = 'local',
    
    [string]$RailwayUrl = 'https://web-production-cb55c.up.railway.app'
)

# ============================================================================
# CONFIGURATION
# ============================================================================

$LocalUrl = "http://localhost"
$ApiHealthUrl = "$LocalUrl/api/health"
$ApiMetricsUrl = "$LocalUrl/api/metrics"
$RateLimitTestUrl = "$LocalUrl/api/projects"

# Normalize Railway URL so concatenated paths are always valid.
$RailwayUrl = $RailwayUrl.Trim()
if ($RailwayUrl) {
    $RailwayUrl = $RailwayUrl.TrimEnd('/')
}

$Colors = @{
    'Success' = 'Green'
    'Error'   = 'Red'
    'Warning' = 'Yellow'
    'Info'    = 'Cyan'
    'Header'  = 'Blue'
}

$TestResults = @{
    'Passed' = 0
    'Failed' = 0
    'Skipped' = 0
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Write-Header {
    param([string]$Text)
    Write-Host "`n" -NoNewline
    Write-Host "===================================================================" -ForegroundColor $Colors['Header']
    Write-Host "  $Text" -ForegroundColor $Colors['Header']
    Write-Host "===================================================================" -ForegroundColor $Colors['Header']
}

function Write-Subheader {
    param([string]$Text)
    Write-Host "`n$Text" -ForegroundColor $Colors['Info']
}

function Write-Success {
    param([string]$Text)
    Write-Host "  [OK] $Text" -ForegroundColor $Colors['Success']
    $script:TestResults['Passed']++
}

function Write-Failure {
    param([string]$Text)
    Write-Host "  [FAIL] $Text" -ForegroundColor $Colors['Error']
    $script:TestResults['Failed']++
}

function Write-Skip {
    param([string]$Text)
    Write-Host "  [SKIP] $Text" -ForegroundColor $Colors['Warning']
    $script:TestResults['Skipped']++
}

function Test-ApiEndpoint {
    param(
        [string]$Url,
        [string]$Description
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Get -UseBasicParsing -ErrorAction Stop -TimeoutSec 5
        
        if ($response.StatusCode -eq 200) {
            Write-Success $Description
            return $true
        } else {
            Write-Failure "$Description (HTTP $($response.StatusCode))"
            return $false
        }
    }
    catch {
        $msg = $_.Exception.Message
        Write-Failure "$Description - Error: $msg"
        return $false
    }
}

function Get-JsonResponse {
    param(
        [string]$Url
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Get -UseBasicParsing -ErrorAction Stop -TimeoutSec 5
        return $response.Content | ConvertFrom-Json
    }
    catch {
        return $null
    }
}

# ============================================================================
# SECTION 1: VIRTUAL MACHINE CONFIGURATION
# ============================================================================

function Test-VirtualMachine {
    Write-Header "1. VIRTUAL MACHINE CONFIGURATION"
    
    Write-Subheader "Checking Docker Containers Status"
    
    try {
        $containers = docker ps --format "table {{.Names}}`t{{.Status}}" | Select-Object -Skip 1
        
        if ($containers) {
            Write-Success "Docker is running"
            Write-Host "`n  Container Status:" -ForegroundColor $Colors['Info']
            $containers | ForEach-Object {
                Write-Host "    $_"
            }
        } else {
            Write-Failure "No Docker containers found"
            Write-Host "  Tip: Run 'docker-compose up -d'" -ForegroundColor $Colors['Warning']
        }
    }
    catch {
        Write-Failure "Docker not accessible"
    }
    
    Write-Subheader "Checking Container Resource Usage"
    
    try {
        $stats = docker stats --no-stream --format "table {{.Container}}`t{{.MemUsage}}" | Select-Object -Skip 1
        
        if ($stats) {
            Write-Success "Container statistics available"
            Write-Host "`n  Memory Usage:" -ForegroundColor $Colors['Info']
            $stats | ForEach-Object {
                Write-Host "    $_"
            }
        }
    }
    catch {
        Write-Skip "Docker stats not available"
    }
}

# ============================================================================
# SECTION 2: WEB SERVER SETUP (Nginx)
# ============================================================================

function Test-WebServer {
    Write-Header "2. WEB SERVER SETUP (Nginx)"
    
    Write-Subheader "Checking Nginx Container"
    
    try {
        $nginx = docker ps --filter "name=nginx" --format "{{.Names}}"
        
        if ($nginx) {
            Write-Success "Nginx container is running"
        } else {
            Write-Failure "Nginx container not found"
            return
        }
    }
    catch {
        Write-Failure "Cannot check Nginx status"
        return
    }
    
    Write-Subheader "Checking Nginx Configuration"
    
    try {
        $configTest = docker exec xyz-corp-nginx nginx -t 2>&1 | Out-String
        
        if ($configTest -match "test is successful") {
            Write-Success "Nginx configuration is valid"
        } else {
            Write-Failure "Nginx configuration has errors"
        }
    }
    catch {
        Write-Skip "Could not validate Nginx config"
    }
    
    Write-Subheader "Testing Nginx Connectivity"
    
    [void](Test-ApiEndpoint -Url $ApiHealthUrl -Description "Nginx responding on port 80")
    
    Write-Subheader "Checking Security Headers"
    
    try {
        $response = Invoke-WebRequest -Uri $LocalUrl -Method Head -UseBasicParsing -ErrorAction Stop
        $headers = $response.Headers
        
        Write-Host "`n  Security Headers:" -ForegroundColor $Colors['Info']
        if ($headers['X-Frame-Options']) {
            Write-Host "    X-Frame-Options: $($headers['X-Frame-Options'])"
        }
        if ($headers['X-Content-Type-Options']) {
            Write-Host "    X-Content-Type-Options: $($headers['X-Content-Type-Options'])"
        }
    }
    catch {
        Write-Skip "Could not retrieve headers"
    }
}

# ============================================================================
# SECTION 3: FIREWALL & SECURITY
# ============================================================================

function Test-Firewall {
    Write-Header "3. FIREWALL & SECURITY GROUP CONFIGURATION"
    
    Write-Subheader "Testing Security Headers"
    
    try {
        $response = Invoke-WebRequest -Uri $ApiHealthUrl -Method Head -UseBasicParsing -ErrorAction Stop
        $headers = $response.Headers
        
        $requiredHeaders = @(
            'X-Frame-Options',
            'X-Content-Type-Options',
            'X-XSS-Protection'
        )
        
        $headerCount = 0
        Write-Host "`n  Headers Present:" -ForegroundColor $Colors['Info']
        
        foreach ($header in $requiredHeaders) {
            if ($headers.ContainsKey($header)) {
                $headerValue = $headers[$header]
                Write-Host "    $header : $headerValue"
                $headerCount++
            }
        }
        
        if ($headerCount -eq $requiredHeaders.Count) {
            Write-Success "All security headers configured"
        } else {
            Write-Failure "Some security headers missing"
        }
    }
    catch {
        Write-Failure "Could not check security headers"
    }
    
    Write-Subheader "Testing Rate Limiting"
    
    Write-Host "`n  Testing with 50 rapid requests to /api/projects..." -ForegroundColor $Colors['Info']
    
    try {
        $rateLimitedCount = 0
        
        for ($i = 1; $i -le 50; $i++) {
            try {
                $response = Invoke-WebRequest -Uri $RateLimitTestUrl -Method Get -UseBasicParsing -ErrorAction Stop -TimeoutSec 2
                
                if ($response.StatusCode -ne 200) {
                    $rateLimitedCount++
                }
            }
            catch {
                $statusCode = $null
                if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
                    $statusCode = [int]$_.Exception.Response.StatusCode
                }
                if ($statusCode -eq 429 -or $statusCode -eq 503) {
                    $rateLimitedCount++
                }
            }
        }
        
        Write-Host "    Completed 50 requests"
        
        if ($rateLimitedCount -gt 0) {
            Write-Success "Rate limiting is active"
        } else {
            Write-Host "    [WARN] No rate limiting detected" -ForegroundColor $Colors['Warning']
        }

        # Allow rate-limit buckets to cool down before subsequent endpoint tests.
        Start-Sleep -Seconds 5
    }
    catch {
        Write-Skip "Could not complete rate limit test"
    }
}

# ============================================================================
# SECTION 4: WEB APPLICATION
# ============================================================================

function Test-WebApplication {
    Write-Header "4. DEPLOY APLIKASI WEB SEDERHANA"
    
    Write-Subheader "Testing Flask Application"
    
    Write-Host "`n  Endpoint Tests:" -ForegroundColor $Colors['Info']
    
    [void](Test-ApiEndpoint -Url $LocalUrl -Description "Root endpoint")
    [void](Test-ApiEndpoint -Url "$LocalUrl/api/health" -Description "Health endpoint")
    [void](Test-ApiEndpoint -Url "$LocalUrl/dashboard" -Description "Dashboard")
    
    Write-Subheader "Testing Health Endpoint Response"
    
    $healthData = Get-JsonResponse -Url $ApiHealthUrl
    
    if ($healthData) {
        Write-Success "Health endpoint returns valid JSON"
        Write-Host "`n  Health Status:" -ForegroundColor $Colors['Info']
        Write-Host "    Status: $($healthData.status)"
        Write-Host "    Service: $($healthData.service)"
        Write-Host "    Database: $($healthData.database)"
    }
    
    Write-Subheader "Testing API Endpoints"
    
    try {
        $projectsResponse = Invoke-WebRequest -Uri "$LocalUrl/api/projects" -Method Get -UseBasicParsing -ErrorAction Stop
        
        if ($projectsResponse.StatusCode -eq 200) {
            Write-Success "Projects endpoint accessible"
        }
    }
    catch {
        Write-Failure "Projects endpoint error"
    }
    
    Write-Subheader "Checking Database"
    
    try {
        $dbCheck = docker exec xyz-corp-api ls -lah /app/data/projects.db 2>&1 | Out-String
        
        if ($dbCheck -match "projects.db") {
            Write-Success "Database file exists"
        }
    }
    catch {
        Write-Skip "Could not verify database file"
    }
}

# ============================================================================
# SECTION 5: MONITORING
# ============================================================================

function Test-Monitoring {
    Write-Header "5. MONITORING CPU & MEMORY"
    
    Write-Subheader "Testing Metrics Endpoint"
    
    [void](Test-ApiEndpoint -Url $ApiMetricsUrl -Description "Metrics endpoint")
    
    Write-Subheader "System Metrics"
    
    $metricsData = Get-JsonResponse -Url $ApiMetricsUrl
    
    if ($metricsData) {
        Write-Success "Metrics endpoint returns valid data"
        
        Write-Host "`n  Current System Metrics:" -ForegroundColor $Colors['Info']
        
        if ($metricsData.cpu) {
            $cpuPercent = $metricsData.cpu.percent
            $cpuCount = $metricsData.cpu.count
            Write-Host "    CPU: $cpuPercent% (Cores: $cpuCount)"
        }
        
        if ($metricsData.memory) {
            $memPercent = $metricsData.memory.percent
            $memUsed = $metricsData.memory.used_mb
            $memTotal = $metricsData.memory.total_mb
            Write-Host "    Memory: $memPercent% ($memUsed MB / $memTotal MB)"
        }
        
        if ($metricsData.disk) {
            $diskPercent = $metricsData.disk.percent
            $diskUsed = $metricsData.disk.used_gb
            $diskTotal = $metricsData.disk.total_gb
            Write-Host "    Disk: $diskPercent% ($diskUsed GB / $diskTotal GB)"
        }
    }
}

# ============================================================================
# SECTION 6: RAILWAY VERIFICATION
# ============================================================================

function Test-Railway {
    if (-not $RailwayUrl) {
        Write-Host "`n  Tip: Set -RailwayUrl to your Railway app URL" -ForegroundColor $Colors['Warning']
        return
    }
    
    Write-Header "6. RAILWAY PRODUCTION VERIFICATION"
    
    $railwayMsg = "Testing Railway URL: $RailwayUrl"
    Write-Subheader $railwayMsg
    
    try {
        [void](Test-ApiEndpoint -Url "$RailwayUrl/api/health" -Description "Health on Railway")
        [void](Test-ApiEndpoint -Url "$RailwayUrl/api/metrics" -Description "Metrics on Railway")
        [void](Test-ApiEndpoint -Url "$RailwayUrl/dashboard" -Description "Dashboard on Railway")
    }
    catch {
        Write-Failure "Could not connect to Railway URL"
    }
}

# ============================================================================
# SUMMARY & FINAL REPORT
# ============================================================================

function Show-Summary {
    Write-Header "TEST SUMMARY"
    
    $Total = $TestResults['Passed'] + $TestResults['Failed'] + $TestResults['Skipped']
    $SuccessRate = if ($Total -gt 0) { [math]::Round(($TestResults['Passed'] / $Total) * 100, 2) } else { 0 }
    
    Write-Host "`n  Results:" -ForegroundColor $Colors['Info']
    Write-Host "    [PASS] $($TestResults['Passed'])" -ForegroundColor $Colors['Success']
    Write-Host "    [FAIL] $($TestResults['Failed'])" -ForegroundColor $Colors['Error']
    Write-Host "    [SKIP] $($TestResults['Skipped'])" -ForegroundColor $Colors['Warning']
    Write-Host "    Success Rate: $SuccessRate%" -ForegroundColor $Colors['Info']
    
    if ($TestResults['Failed'] -eq 0) {
        Write-Host "`n  ALL TESTS PASSED!" -ForegroundColor $Colors['Success']
    } else {
        Write-Host "`n  Some tests failed. Check output above." -ForegroundColor $Colors['Warning']
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor $Colors['Header']
Write-Host "   XYZ Corp API - IaaS Implementation Verification" -ForegroundColor $Colors['Header']
Write-Host "   Testing: VM | Web Server | Firewall | App | Monitoring" -ForegroundColor $Colors['Header']
Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor $Colors['Header']
Write-Host ""

if ($Environment -eq 'local') {
    Test-VirtualMachine
    Test-WebServer
    Test-Firewall
    Test-WebApplication
    Test-Monitoring
} elseif ($Environment -eq 'railway') {
    if (-not $RailwayUrl) {
        Write-Host 'Error: RailwayUrl parameter is required' -ForegroundColor $Colors['Error']
        exit 1
    }
    Test-Railway
}

Show-Summary

Write-Host ""
