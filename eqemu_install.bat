@echo off
REM if not "%1" == "max" start /MAX cmd /c %0 max & exit/b

goto check_Permissions

:check_Permissions
    echo Administrative permissions required. Detecting permissions...	
    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Success: Administrative permissions confirmed.
		
		GOTO :MAIN
    ) else (
        echo Failed: Run eqemu_install.bat as Administrator Right click - Run as Administrator
		pause
		exit
    )

pause

:MAIN

cd "%~dp0" 

echo #########################################################
echo #::: EverQuest Emulator Modular Installer
echo #::: Installer Author: Akkadius
echo #:::
echo #::: EQEmulator Server Software is developed and maintained 
echo #:::	by the EQEmulator Developement team
echo #:::
echo #::: Everquest is a registered trademark of Daybreak Game Company LLC.
echo #::: EQEmulator is not associated or affiliated in any way with Daybreak Game Company LLC.
echo #########################################################

SET has_winrar=0
SET has_perl=0
SET has_mysql=0

IF EXIST "%ProgramFiles(x86)%\WinRAR" (
	SET has_winrar=1
	REM echo WinRAR Exists... 32-Bit
)
IF EXIST "%ProgramFiles%\WinRAR" (
	SET has_winrar=1
	REM echo WinRAR Exists... 64-Bit
)
IF %has_winrar% == 0 (
	echo Installing WinRAR...
	WinRARSetup.exe /S
	pause
)

echo :
echo #########################################################
echo #::: To be installed:
echo #########################################################
echo - Server running folder - Will be installed to the folder you ran this script
echo - MariaDB (MySQL) - Database engine
echo - Heidi SQL (Comes with MariaDB)
echo - Perl 5.12.3 :: Scripting language for quest engines
echo - LUA Configured :: Scripting language for quest engines
echo - Latest PEQ Database
echo - Latest PEQ Quests
echo - Latest Plugins repository
echo - Automatically added Firewall rules
echo - Maps (Latest V2) formats are loaded
echo - New Path files are loaded
echo - Optimized server binaries
echo #########################################################

IF NOT EXIST "C:\Perl\bin" (
	GOTO :INSTALL_PERL
)

IF NOT EXIST "C:\Program Files\MariaDB 10.0" (
	GOTO :INSTALL_MARIADB
)

IF NOT EXIST "eqemu_update.pl" (
	perl -MLWP::UserAgent -e "require LWP::UserAgent;  my $ua = LWP::UserAgent->new; $ua->timeout(10); $ua->env_proxy; my $response = $ua->get('https://raw.githubusercontent.com/EQEmu/Server/master/utils/scripts/eqemu_update.pl'); if ($response->is_success){ open(FILE, '> eqemu_update.pl'); print FILE $response->decoded_content; close(FILE); }
)
IF NOT EXIST "eqemu_config.xml" (
	perl -MLWP::UserAgent -e "require LWP::UserAgent;  my $ua = LWP::UserAgent->new; $ua->timeout(10); $ua->env_proxy; my $response = $ua->get('https://raw.githubusercontent.com/Akkadius/EQEmuInstall/master/eqemu_config.xml'); if ($response->is_success){ open(FILE, '> eqemu_config.xml'); print FILE $response->decoded_content; close(FILE); }
)

perl eqemu_update.pl installer

REM netsh advfirewall firewall add rule name="EQEmu World (9000) TCP" dir=in action=allow protocol=TCP localport=9000
REM netsh advfirewall firewall add rule name="EQEmu Zones (7000-7500) TCP" dir=in action=allow protocol=TCP localport=7000-7500
REM netsh advfirewall firewall add rule name="EQEmu World (9000) UDP" dir=in action=allow protocol=UDP localport=9000
REM netsh advfirewall firewall add rule name="EQEmu Zones (7000-7500) UDP" dir=in action=allow protocol=UDP localport=7000-7500


pause

GOTO :EXIT

:INSTALL_PERL
	echo Installing Perl... LOADING... PLEASE WAIT...
	msiexec /i ActivePerl-5.12.3.1204-MSWin32-x86-294330.msi PERL_PATH="Yes" /q
	"C:\Program Files (x86)\WinRAR\unrar" x -o- Perl.rar C:\
	del ActivePerl-5.12.3.1204-MSWin32-x86-294330.msi
	del Perl.rar
	
	GOTO :MAIN
	
:INSTALL_MARIADB
	echo Installing MariaDB (Root Password: eqemu) LOADING... PLEASE WAIT...
	msiexec /i mariadb-10.0.21-winx64.msi SERVICENAME=MySQL PORT=3306 PASSWORD=eqemu /qn
	setx path "%path%;C:\Program Files\MariaDB 10.0\bin"
	del mariadb-10.0.21-winx64.msi
	
	GOTO :MAIN
	
:EXIT
	exit