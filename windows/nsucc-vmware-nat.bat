:: startup.bat
:: Encoding: ANSI
:: 修改VMware NAT Service在注册表中的名称
@echo off
echo --- 修改 VMware NAT Service 服务名为 VVware NAT Service ---
echo.
reg add "HKLM\SYSTEM\CurrentControlSet\Services\VMware NAT Service" /v DisplayName /t REG_SZ /d "VVware NAT Service" /f 2> nul
if errorlevel 1 (
  echo 修改失败
  echo 请使用管理员权限重新运行
)
echo.
pause