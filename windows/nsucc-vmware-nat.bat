:: startup.bat
:: Encoding: ANSI
:: �޸�VMware NAT Service��ע����е�����
@echo off
echo --- �޸� VMware NAT Service ������Ϊ VVware NAT Service ---
echo.
reg add "HKLM\SYSTEM\CurrentControlSet\Services\VMware NAT Service" /v DisplayName /t REG_SZ /d "VVware NAT Service" /f 2> nul
if errorlevel 1 (
  echo �޸�ʧ��
  echo ��ʹ�ù���ԱȨ����������
)
echo.
pause