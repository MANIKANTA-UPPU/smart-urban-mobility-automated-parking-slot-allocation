$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$services = @(
    @{ name = "auth-service";    path = "$root\auth-service";    cmd = "npm start" },
    @{ name = "parking-service"; path = "$root\parking-service"; cmd = "npm start" },
    @{ name = "booking-service"; path = "$root\booking-service"; cmd = "npm start" },
    @{ name = "api-gateway";     path = "$root\api-gateway";     cmd = "npm start" },
    @{ name = "frontend";        path = "$root\frontend";        cmd = "npm run dev" }
)

foreach ($svc in $services) {
    Start-Process "cmd.exe" -ArgumentList "/k", "cd /d `"$($svc.path)`" && $($svc.cmd)" -WindowStyle Normal
    Start-Sleep -Seconds 3
}

Write-Host ""
Write-Host "All 5 services launched!" -ForegroundColor Green
Write-Host ""
Write-Host "  auth-service    --> http://localhost:5001" -ForegroundColor Cyan
Write-Host "  parking-service --> http://localhost:5002" -ForegroundColor Cyan
Write-Host "  booking-service --> http://localhost:5003" -ForegroundColor Cyan
Write-Host "  api-gateway     --> http://localhost:5000" -ForegroundColor Cyan
Write-Host "  frontend        --> http://localhost:5173" -ForegroundColor Yellow
Write-Host ""
Write-Host "Open your browser at: http://localhost:5173" -ForegroundColor Green
