@echo off
echo Starting Smart Urban Mobility - All Services...
echo.

powershell -Command "Start-Process cmd -ArgumentList '/k cd /d \"c:\Users\Bindu\Desktop\PS011  Smart Urban Mobility & Automated Parking Slot Allocation\auth-service\" && npm start' -WindowStyle Normal"
timeout /t 3 /nobreak >nul

powershell -Command "Start-Process cmd -ArgumentList '/k cd /d \"c:\Users\Bindu\Desktop\PS011  Smart Urban Mobility & Automated Parking Slot Allocation\parking-service\" && npm start' -WindowStyle Normal"
timeout /t 3 /nobreak >nul

powershell -Command "Start-Process cmd -ArgumentList '/k cd /d \"c:\Users\Bindu\Desktop\PS011  Smart Urban Mobility & Automated Parking Slot Allocation\booking-service\" && npm start' -WindowStyle Normal"
timeout /t 3 /nobreak >nul

powershell -Command "Start-Process cmd -ArgumentList '/k cd /d \"c:\Users\Bindu\Desktop\PS011  Smart Urban Mobility & Automated Parking Slot Allocation\api-gateway\" && npm start' -WindowStyle Normal"
timeout /t 3 /nobreak >nul

powershell -Command "Start-Process cmd -ArgumentList '/k cd /d \"c:\Users\Bindu\Desktop\PS011  Smart Urban Mobility & Automated Parking Slot Allocation\frontend\" && npm run dev' -WindowStyle Normal"

echo.
echo All 5 services launched!
echo.
echo   auth-service    --^> http://localhost:5001
echo   parking-service --^> http://localhost:5002
echo   booking-service --^> http://localhost:5003
echo   api-gateway     --^> http://localhost:5000
echo   frontend        --^> http://localhost:5173
echo.
echo Open browser at: http://localhost:5173
echo.
pause
