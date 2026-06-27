@echo off
REM ============================================
REM RASHA Super App - Generate Self-Signed SSL Certs (Windows)
REM ============================================
REM Usage:
REM   scripts\generate-ssl-certs.bat
REM
REM This generates self-signed certificates for local HTTPS development.
REM The certificates are valid for 10 years and cover:
REM   - rasha.local
REM   - *.rasha.local
REM   - localhost
REM   - 127.0.0.1
REM
REM Requires: OpenSSL (installed via Git for Windows, Win32 OpenSSL, or similar)
REM ============================================
setlocal enabledelayedexpansion

set CERT_DIR=certs
set DAYS=3650
set SUBJECT=/C=ID/ST=Jakarta/L=Jakarta/O=RASHA/OU=Development/CN=rasha.local

REM Check if OpenSSL is available
where openssl >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] OpenSSL is not installed or not found in PATH.
    echo.
    echo Install OpenSSL from one of these sources:
    echo   - Git for Windows: https://gitforwindows.org/
    echo   - Win32/Win64 OpenSSL: https://slproweb.com/products/Win32OpenSSL.html
    echo   - Or install via winget: winget install OpenSSL
    endlocal
    exit /b 1
)

@echo ^>^> Generating self-signed SSL certificates...

REM Warn if certs already exist
if exist "%CERT_DIR%\rasha.crt" (
    echo [WARNING] Certificates already exist in %CERT_DIR%\. Overwriting...
)

REM Create certs directory if it doesn't exist
if not exist "%CERT_DIR%" mkdir "%CERT_DIR%"

REM Generate CA key and certificate
@echo ^>^> Creating CA key and certificate...
openssl genrsa -out "%CERT_DIR%\rasha-ca.key" 2048 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to generate CA key.
    endlocal
    exit /b 1
)

openssl req -x509 -new -nodes -key "%CERT_DIR%\rasha-ca.key" -sha256 -days %DAYS% -out "%CERT_DIR%\rasha-ca.crt" -subj "%SUBJECT%" 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to generate CA certificate.
    endlocal
    exit /b 1
)

REM Generate server key
@echo ^>^> Creating server key...
openssl genrsa -out "%CERT_DIR%\rasha.key" 2048 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to generate server key.
    endlocal
    exit /b 1
)

REM Create SAN config file
@echo ^>^> Creating SAN configuration...
(
echo [req]
echo default_bits = 2048
echo prompt = no
echo default_md = sha256
echo distinguished_name = dn
echo req_extensions = v3_req
echo.
echo [dn]
echo C = ID
echo ST = Jakarta
echo L = Jakarta
echo O = RASHA
echo OU = Development
echo CN = rasha.local
echo.
echo [v3_req]
echo subjectAltName = @alt_names
echo.
echo [alt_names]
echo DNS.1 = rasha.local
echo DNS.2 = *.rasha.local
echo DNS.3 = localhost
echo DNS.4 = crm.rasha.local
echo DNS.5 = dynform.rasha.local
echo DNS.6 = erp.rasha.local
echo DNS.7 = api.rasha.local
echo IP.1 = 127.0.0.1
echo IP.2 = ::1
) > "%CERT_DIR%\san.cnf"

REM Generate CSR with SAN
@echo ^>^> Creating CSR...
openssl req -new -key "%CERT_DIR%\rasha.key" -out "%CERT_DIR%\rasha.csr" -config "%CERT_DIR%\san.cnf" 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to generate CSR.
    endlocal
    exit /b 1
)

REM Create v3 extensions config
@echo ^>^> Creating v3 extensions configuration...
(
echo authorityKeyIdentifier=keyid,issuer
echo basicConstraints=CA:FALSE
echo keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
echo extendedKeyUsage = serverAuth
echo subjectAltName = @alt_names
echo.
echo [alt_names]
echo DNS.1 = rasha.local
echo DNS.2 = *.rasha.local
echo DNS.3 = localhost
echo DNS.4 = crm.rasha.local
echo DNS.5 = dynform.rasha.local
echo DNS.6 = erp.rasha.local
echo DNS.7 = api.rasha.local
echo IP.1 = 127.0.0.1
echo IP.2 = ::1
) > "%CERT_DIR%\v3_ext.cnf"

REM Sign the certificate
@echo ^>^> Signing server certificate with CA...
openssl x509 -req -in "%CERT_DIR%\rasha.csr" -CA "%CERT_DIR%\rasha-ca.crt" -CAkey "%CERT_DIR%\rasha-ca.key" -CAcreateserial -out "%CERT_DIR%\rasha.crt" -days %DAYS% -sha256 -extfile "%CERT_DIR%\v3_ext.cnf" 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to sign server certificate.
    endlocal
    exit /b 1
)

REM Clean up temporary files
@echo ^>^> Cleaning up temporary files...
if exist "%CERT_DIR%\rasha.csr" del /q "%CERT_DIR%\rasha.csr"
if exist "%CERT_DIR%\san.cnf" del /q "%CERT_DIR%\san.cnf"
if exist "%CERT_DIR%\v3_ext.cnf" del /q "%CERT_DIR%\v3_ext.cnf"
if exist "%CERT_DIR%\rasha-ca.srl" del /q "%CERT_DIR%\rasha-ca.srl"

echo.
echo ^>^> SSL certificates generated in %CERT_DIR%\!
echo    - rasha.key    (server private key)
echo    - rasha.crt    (server certificate)
echo    - rasha-ca.crt (CA certificate)
echo.
echo ^>^> Install the CA certificate in your browser:
echo    Windows: Double-click rasha-ca.crt -^> Install Certificate -^> Local Machine -^> Trusted Root Certification Authorities
echo.
echo ^>^> Done!

endlocal
