::Script by Shadow256
IF EXIST "tools\storage\functions\ini_scripts.bat" (
	call tools\storage\functions\ini_scripts.bat
) else (
	@echo off
	chcp 65001 >nul
	IF EXIST "%~0.version" (
	set /p this_script_version=<"%~0.version"
) else (
	set this_script_version=1.00.00
)
)
Setlocal enabledelayedexpansion
set base_script_path="%~dp0\..\.."
set folders_url_project_base=https://github.com/shadow2560/Ultimate-Switch-Hack-Script/trunk
set files_url_project_base=https://raw.githubusercontent.com/shadow2560/Ultimate-Switch-Hack-Script/master
IF NOT EXIST "tools\gnuwin32\bin\wc.exe" (
	ping /n 2 www.github.com >nul 2>&1
	IF !errorlevel! NEQ 0 (
		echo Dependancy error, you have to connect to internet, script will close.
		pause
		exit
	) else (
		copy nul "continue_update.txt" >nul
		echo Updating Gnuwin32 dependancies...
		"tools\gitget\SVN\svn.exe" export %folders_url_project_base%/tools/gnuwin32 tools\gnuwin32 --force >nul
	)
)
IF NOT EXIST "tools\aria2\aria2c.exe" (
	ping /n 2 www.github.com >nul 2>&1
	IF !errorlevel! NEQ 0 (
		echo Dependancy error, you have to connect to internet, script will close.
		pause
		exit
	) else (
		copy nul "continue_update.txt" >nul
		echo Updating Aria2 dependancies...
		"tools\gitget\SVN\svn.exe" export %folders_url_project_base%/tools/aria2 tools\aria2 --force >nul
	)
)
IF NOT EXIST "languages\FR_fr" (
	copy nul "continue_update.txt" >nul
	echo Initializing french language...
	set temp_language_path=languages\FR_fr
	call :initialize_language
)
IF "%temp_language_path%"=="" (
	IF EXIST "languages\FR_fr\language_general_config.bat" call "languages\FR_fr\language_general_config.bat"
	IF "!language_path!"=="" (
		copy nul "continue_update.txt" >nul
		echo Initializing first language...
		set temp_language_path=languages\FR_fr
		rmdir /s /q "templogs" 2>nul
		call :initialize_language
	)
)
IF EXIST "templogs" (
	del /q "templogs" 2>nul
	rmdir /s /q "templogs" 2>nul
)
mkdir "templogs"
IF "%~2"=="language_init" (
	rmdir /s /q "templogs" 2>nul
	call :initialize_language
)
echo é >nul
set this_script_full_path=%~0
IF "%ushs_base_path%"=="" (
	cd >templogs\tempvar.txt
	set /p ushs_base_path=<templogs\tempvar.txt
	set ushs_base_path=!ushs_base_path!\
)
set associed_language_script=%language_path%\!this_script_full_path:%ushs_base_path%=!
set associed_language_script=%ushs_base_path%%associed_language_script%
IF NOT EXIST "%associed_language_script%" (
	set associed_language_script=languages\FR_fr\!this_script_full_path:%ushs_base_path%=!
	set associed_language_script=%ushs_base_path%!associed_language_script!
	echo Associed language file not found, use the update manager to install the file. French language will be tryed.
	pause
)
IF NOT EXIST "%associed_language_script%" (
	echo Language error, please use the update manager to update the script. The script will force the initialization of the language.
	pause
rmdir /s /q "templogs" 2>nul
		call :initialize_language
)
IF "%~1"=="retroarch_update" (
	call :retroarch_update
	goto:end_script
)
call "%associed_language_script%" "display_title"
IF "%lng_yes_choice%"=="" (
	IF "%language_custom%"=="0" (
		ping /n 2 www.github.com >nul 2>&1
		IF !errorlevel! EQU 0 (
			call :verif_file_version "%language_path%\language_general_config.bat"
			IF "!update_finded!"=="Y" (
				copy nul "continue_update.txt" >nul
				"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -d "templogs" -o "language_general_config.bat" "%files_url_project_base%/%language_path:\=/%/language_general_config.bat"
				IF !errorlevel! EQU 0 (
					move "templogs\language_general_config.bat" "%language_path%\language_general_config.bat" >nul
					"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -d "templogs" -o "language_general_config.bat.version" "%files_url_project_base%/%language_path:\=/%/language_general_config.bat.version"
					IF !errorlevel! EQU 0 (
						move "templogs\language_general_config.bat.version" "%language_path%\language_general_config.bat.version" >nul
						rmdir /s /q templogs
						call "%associed_language_script%" "language_config_update_info"
						pause
						start /i "" "%windir%\system32\cmd.exe" /c call "Ultimate-Switch-Hack-Script.bat"
						IF /i "%language_echo%"=="on" pause
						exit
					)
				)
			)
		) else (
			call "%associed_language_script%" "no_internet_connection_error"
			pause
			goto:end_script
		)
	)
)
IF EXIST "continue_update.txt" (
	set auto_update=O
	goto:begin_update
)
IF  "%~2"=="force" (
	set auto_update=O
	goto:begin_update
)
IF EXIST "failed_updates\*.failed" (
	set auto_update=O
	goto:begin_update
)
:verif_auto_update_ini
IF EXIST "%language_path%\script_general_config.bat\*.*" (
	rmdir /s /q "%language_path%\script_general_config.bat"
)
IF not EXIST "%language_path%\script_general_config.bat" copy nul "%language_path%\script_general_config.bat" >nul
tools\gnuwin32\bin\grep.exe -n "set auto_update=" <"%language_path%\script_general_config.bat" >templogs\tempvar.txt
set /p temp_auto_update_line=<templogs\tempvar.txt
IF NOT "%temp_auto_update_line%"=="" (
	echo %temp_auto_update_line%|"tools\gnuwin32\bin\cut.exe" -d : -f 1 >templogs\tempvar.txt
	set /p auto_update_file_param_line=<templogs\tempvar.txt
	echo %temp_auto_update_line%|"tools\gnuwin32\bin\cut.exe" -d = -f 2 >templogs\tempvar.txt
	set /p ini_auto_update=<templogs\tempvar.txt
)
set temp_auto_update_line=
:initialize_auto_update
IF "%ini_auto_update%"=="" (
	call "%associed_language_script%" "autoupdate_choice"
) else IF /i "%ini_auto_update%"=="O" (
	set auto_update=O
) else IF /i "%ini_auto_update%"=="N" (
	set auto_update=N
) else (
	call "%associed_language_script%" "autoupdate_bad_value_error"
	"tools\gnuwin32\bin\sed.exe" %auto_update_file_param_line%d "%language_path%\script_general_config.bat">"%language_path%\script_general_config2.bat"
	del /q "%language_path%\script_general_config.bat"
	ren "%language_path%\script_general_config2.bat" "script_general_config.bat"
	set ini_auto_update=
	goto:initialize_auto_update
)
IF NOT "%auto_update%"=="" (
	set auto_update=%auto_update:~0,1%
) else (
	call "%associed_language_script%" "autoupdate_empty_value_error"
	goto:initialize_auto_update
)
call :o/n/t/j_choice "auto_update"
IF /i "%auto_update%"=="J" (
	IF NOT "%auto_update_file_param_line%"=="" (
		"tools\gnuwin32\bin\sed.exe" '%auto_update_file_param_line% d' "%language_path%\script_general_config.bat">"%language_path%\script_general_config2.bat"
		del /q "%language_path%\script_general_config.bat"
		ren "%language_path%\script_general_config2.bat" "script_general_config.bat"
	)
	echo set auto_update=N>>"%language_path%\script_general_config.bat"
	set auto_update=N
)
IF /i "%auto_update%"=="T" (
	IF NOT "%auto_update_file_param_line%"=="" (
		"tools\gnuwin32\bin\sed.exe" '%auto_update_file_param_line% d' "%language_path%\script_general_config.bat">"%language_path%\script_general_config2.bat"
		del /q "%language_path%\script_general_config.bat"
		ren "%language_path%\script_general_config2.bat" "script_general_config.bat"
	)
	echo set auto_update=O>>"%language_path%\script_general_config.bat"
	set auto_update=O
)
IF /i "%auto_update%"=="N" (
	goto:end_script
) else IF /i "%auto_update%"=="O" (
	goto:begin_update
) else (
	call "%associed_language_script%" "autoupdate_choice_not_permited_error"
	goto:initialize_auto_update
)
:begin_update
echo :::::::::::::::::::::::::::::::::::::
echo ::Shadow256 Ultimate Switch Hack Script %ushs_version% updater::
echo.
IF NOT EXIST "failed_updates\*.failed" (
	rmdir /s /q "failed_updates" 2>nul
)
mkdir "failed_updates" >nul
:new_script_install
IF "%~1"=="update_all" goto:skip_new_script_install
IF "%~1"=="general_content_update" goto:skip_new_script_install
IF "%~2"=="force" (
	IF NOT "%verified_internet_connexion%"=="Y" (
		ping /n 2 www.github.com >nul 2>&1
	) else (
		set errorlevel=0
	)
	IF !errorlevel! NEQ 0 (
		call "%associed_language_script%" "no_internet_connection_error"
		call "%associed_language_script%" "no_internet_connection_for_new_installation_error"
		pause
		goto:end_script
	)
	set verified_internet_connexion=Y
	call :verif_file_version "tools\Storage\update_manager.bat"
	IF "!update_finded!"=="Y" (
		call :verif_file_version "tools\Storage\update_manager_updater.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
		call :verif_file_version "languages\FR_fr\tools\Storage\update_manager_updater.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
		IF NOT "%language_path%"=="languages\FR_fr" (
			IF "%language_custom%"=="0" (
				call :verif_file_version "%language_path%\tools\Storage\update_manager_updater.bat"
				IF "!update_finded!"=="Y" (
					call :update_file
				)
			)
		)
		call "%associed_language_script%" "update_manager_updater_update"
		pause
		call :update_manager_update_special_script
	)
	set new_install_choice=
	call "%associed_language_script%" "new_installation_choice"
	IF NOT "!new_install_choice!"=="" set new_install_choice=!new_install_choice:~0,1!
	call :o/n_choice "new_install_choice"
	IF /i NOT "!new_install_choice!"=="o" (
		IF EXIST templogs (
			rmdir /s /q templogs
		)
		IF NOT EXIST "failed_updates\*.failed" (
			rmdir /s /q failed_updates
		)
		exit
	)
)
:skip_new_script_install
IF NOT "%verified_internet_connexion%"=="Y" (
	ping /n 2 www.github.com >nul 2>&1
) else (
	set errorlevel=0
)
IF %errorlevel% NEQ 0 (
	call "%associed_language_script%" "no_internet_connection_error"
	IF /i "%new_install_choice%"=="o" (
		call "%associed_language_script%" "no_internet_connection_for_new_installation_error"
		pause
		IF EXIST templogs (
			rmdir /s /q templogs
		)
		IF NOT EXIST "failed_updates\*.failed" (
			rmdir /s /q failed_updates
		)
		exit
	)
	pause
	goto:end_script
)
set verified_internet_connexion=Y
:failed_updates_verification
IF NOT EXIST "failed_updates\*.failed" goto:skip_failed_updates_verification
IF EXIST "failed_updates\update_manager.bat.file.failed" (
	call :verif_file_version "tools\Storage\update_manager_updater.bat"
	IF "!update_finded!"=="Y" (
		call :update_file
	)
	call :verif_file_version "languages\FR_fr\tools\Storage\update_manager_updater.bat"
	IF "!update_finded!"=="Y" (
		call :update_file
	)
	IF NOT "%language_path%"=="languages\FR_fr" (
		IF "%language_custom%"=="0" (
			call :verif_file_version "%language_path%\tools\Storage\update_manager_updater.bat"
			IF "!update_finded!"=="Y" (
				call :update_file
			)
		)
	)
	call "%associed_language_script%" "update_manager_updater_update"
	pause
	call :update_manager_update_special_script
)
for %%f in (failed_updates\*.failed) do (
	call :update_failed_content "%%f"
)
:skip_failed_updates_verification
:start_verif_update
:update_manager_update
call :verif_file_version "tools\Storage\update_manager.bat"
IF "!update_finded!"=="Y" (
	call :verif_file_version "tools\Storage\update_manager_updater.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
	call :verif_file_version "languages\FR_fr\tools\Storage\update_manager_updater.bat"
	IF "!update_finded!"=="Y" (
		call :update_file
	)
	IF NOT "%language_path%"=="languages\FR_fr" (
		IF "%language_custom%"=="0" (
			call :verif_file_version "%language_path%\tools\Storage\update_manager_updater.bat"
			IF "!update_finded!"=="Y" (
				call :update_file
			)
		)
	)
	call "%associed_language_script%" "update_manager_updater_update"
	pause
	call :update_manager_update_special_script
)
IF "%~1"=="" (
		IF EXIST "continue_update.txt" del /q "continue_update.txt"
		goto:end_script
) else (
	copy nul "continue_update.txt" >nul
	call "%associed_language_script%" "begin_update"
	call :verif_file_version "tools\version.txt"
	IF "!update_finded!"=="Y" (
		call :update_file
		IF "%ushs_version%"=="1.00.00" (
			set restart_needed=Y
			call "%associed_language_script%" "script_version_not_initialized_info"
		)
	)
	call :verif_file_version "tools\general_update_version.txt"
	IF "!update_finded!"=="Y" (
		set restart_needed=Y
		call :general_content_update
	) else (
		call :verif_file_version "%language_path%\tools\general_update_version.txt"
		IF "!update_finded!"=="Y" (
			set restart_needed=Y
			call :general_content_update
		)
	)
	IF "%language_custom%"=="0" (
		call :verif_folder_version "%language_path%\doc"
		IF "!update_finded!"=="Y" (
			call :update_folder
		)
		call :verif_file_version "%language_path%\language_general_config.bat"
		IF "!update_finded!"=="Y" (
			"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -d "templogs" -o "language_general_config.bat" "%files_url_project_base%/%language_path:\=/%/language_general_config.bat"
			IF !errorlevel! EQU 0 (
				move "templogs\language_general_config.bat" "%language_path%\language_general_config.bat" >nul
				"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -d "templogs" -o "language_general_config.bat.version" "%files_url_project_base%/%language_path:\=/%/language_general_config.bat.version"
				IF !errorlevel! EQU 0 (
					move "templogs\language_general_config.bat.version" "%language_path%\language_general_config.bat.version" >nul
					call "%associed_language_script%" "language_config_update_info"
					set restart_needed=Y
				)
			)
		)
	)
	IF EXIST "continue_update.txt" del /q "continue_update.txt"
	IF "%~1"=="general_content_update" goto:clean_files
	call :%~1
)
:clean_files
call :del_old_or_unused_files
IF "%restart_needed%"=="Y" (
	call "%associed_language_script%" "end_update_restart_needed"
	pause
	rmdir /s /q templogs
	start /i "" "%windir%\system32\cmd.exe" /c call "Ultimate-Switch-Hack-Script.bat"
	IF /i "%language_echo%"=="on" pause
	exit
) else (
	call "%associed_language_script%" "end_update"
	pause
)
goto:end_script

rem Specific scripts instructions must be added here

:update_all
call "%associed_language_script%" "update_all_begin"
call "%associed_language_script%" "languages_update_begin"
"tools\gitget\SVN\svn.exe" export %folders_url_project_base%/languages languages --force >nul
call "%associed_language_script%" "languages_update_end"
call :update_about.bat
call :update_android_installer.bat
call :update_biskey_dump.bat
call :update_convert_BOTW.bat
call :update_convert_game_to_nsp.bat
call :update_donate.bat
call :update_extract_cert.bat
call :update_game_saves_unpack.bat
call :update_install_drivers.bat
call :update_install_nsp_network.bat
call :update_install_nsp_USB.bat
call :update_language_selector.bat
call :update_launch_emuGUIibo.bat
call :update_launch_hid-mitm_compagnon.bat
call :update_launch_linux.bat
call :update_launch_switch_lan_play_server.bat
call :update_merge_games.bat
call :update_modchips_management.bat
call :update_nand_toolbox.bat
call :update_netplay.bat
call :update_nsZip.bat
call :update_pegaswitch.bat
call :update_preload_NSC_Builder.bat
call :update_prepare_sd_switch.bat
call :update_prepare_update_on_sd.bat
call :update_renxpack.bat
call :update_serial_checker.bat
call :update_split_games.bat
call :update_test_keys.bat
call :update_toolbox.bat
call :update_update_shofel2.bat
call :update_verify_nsp.bat
call :update_NES_Injector
call :update_SNES_Injector
call :retroarch_update
call "%associed_language_script%" "update_all_end"
exit /b

:update_starting_script
call :verif_file_version "Ultimate-Switch-Hack-Script.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\Ultimate-Switch-Hack-Script.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\Ultimate-Switch-Hack-Script.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_about.bat
call :verif_file_version "tools\Storage\about.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\about.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\about.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_android_installer.bat
call :verif_file_version "tools\Storage\android_installer.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\android_installer.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\android_installer.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\android_apps"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_biskey_dump.bat
call :verif_file_version "tools\Storage\biskey_dump.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\biskey_dump.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\biskey_dump.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\biskeydump"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\TegraRcmSmash"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_cheats_profiles_management.bat
call :verif_file_version "tools\Storage\cheats_profiles_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\cheats_profiles_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\cheats_profiles_management.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\sd_switch\cheats"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_convert_BOTW.bat
call :verif_file_version "tools\Storage\convert_BOTW.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\convert_BOTW.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\convert_BOTW.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\BOTW_saveconv"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_convert_game_to_nsp.bat
call :verif_file_version "tools\Storage\convert_game_to_nsp.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\convert_game_to_nsp.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\convert_game_to_nsp.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\Hactool_based_programs"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_create_update.bat
call :verif_file_version "tools\Storage\create_update.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\create_update.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\create_update.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\Hactool_based_programs"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\python3_scripts\Keys_management"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_donate.bat
call :verif_file_version "tools\Storage\donate.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\donate.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\donate.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_emulators_pack_profiles_management.bat
call :verif_file_version "tools\Storage\emulators_pack_profiles_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\emulators_pack_profiles_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\emulators_pack_profiles_management.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
tools\gnuwin32\bin\grep.exe -c "" <"tools\default_configs\Lists\emulators.list" > templogs\tempvar.txt
set /p count_emulators=<templogs\tempvar.txt
set /a temp_count=1
:listing_emulators
IF %temp_count% GTR %count_emulators% goto:skip_listing_emulators
"tools\gnuwin32\bin\sed.exe" -n %temp_count%p "tools\default_configs\Lists\emulators.list" >templogs\tempvar.txt
set /p temp_emulator=<templogs\tempvar.txt
IF "%temp_emulator%"=="RetroArch" goto:skip_emulators_special_files
call :verif_folder_version "tools\sd_switch\emulators\pack\%temp_emulator%"
IF "!update_finded!"=="Y" (
	call :update_folder
)
:skip_emulators_special_files
set /a temp_count+=1
goto:listing_emulators
:skip_listing_emulators
exit /b

:update_emummc_profiles_management.bat
call :verif_file_version "tools\Storage\emummc_profiles_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\emummc_profiles_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\emummc_profiles_management.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_emunand_partition_file_create.bat
call :verif_file_version "tools\Storage\emunand_partition_file_create.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\emunand_partition_file_create.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\emunand_partition_file_create.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_extract_cert.bat
call :verif_file_version "tools\Storage\extract_cert.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\extract_cert.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\extract_cert.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\openssl"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\python2_scripts\CertNXtractionPack"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\python3_scripts\Cert_extraction"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_extract_nand_files_from_emunand_partition_file.bat
call :verif_file_version "tools\Storage\extract_nand_files_from_emunand_partition_file.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\extract_nand_files_from_emunand_partition_file.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\extract_nand_files_from_emunand_partition_file.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_game_saves_unpack.bat
call :verif_file_version "tools\Storage\game_saves_unpack.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\game_saves_unpack.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\game_saves_unpack.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\Hactool_based_programs"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_install_drivers.bat
call :verif_file_version "tools\Storage\install_drivers.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\install_drivers.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\install_drivers.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\drivers"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\TegraRcmSmash"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_install_nsp_network.bat
call :verif_file_version "tools\Storage\install_nsp_network.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\install_nsp_network.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\install_nsp_network.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\python3_scripts\remote_NSP"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_install_nsp_USB.bat
call :verif_file_version "tools\Storage\install_nsp_USB.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\install_nsp_USB.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\install_nsp_USB.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\Goldtree"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_language_selector.bat
call :verif_file_version "tools\Storage\language_selector.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\language_selector.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\language_selector.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_launch_emuGUIibo.bat
call :verif_file_version "tools\Storage\launch_emuGUIibo.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\launch_emuGUIibo.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\launch_emuGUIibo.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\emuGUIibo"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_launch_hid-mitm_compagnon.bat
call :verif_file_version "tools\Storage\launch_hid-mitm_compagnon.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\launch_hid-mitm_compagnon.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\launch_hid-mitm_compagnon.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\Hid-mitm_compagnon"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_launch_linux.bat
call :verif_file_version "tools\Storage\launch_linux.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\launch_linux.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\launch_linux.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\linux_kernels"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\shofel2"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\TegraRcmSmash"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_launch_payload.bat
call :verif_file_version "tools\Storage\launch_payload.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\launch_payload.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\launch_payload.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "Payloads"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\TegraRcmSmash"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_launch_switch_lan_play_server.bat
call :verif_file_version "tools\Storage\launch_switch_lan_play_server.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\launch_switch_lan_play_server.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\launch_switch_lan_play_server.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\Node.js_programs"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_menu.bat
call :verif_file_version "tools\Storage\menu.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\menu.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\menu.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_merge_game.bat
call :verif_file_version "tools\Storage\merge_games.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\merge_games.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\merge_games.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_mixed_pack_profiles_management.bat
call :verif_file_version "tools\Storage\mixed_pack_profiles_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\mixed_pack_profiles_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\mixed_pack_profiles_management.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\sd_switch\mixed\base"
IF "!update_finded!"=="Y" (
	call :update_folder
)
tools\gnuwin32\bin\grep.exe -c "" <"tools\default_configs\Lists\homebrews.list" > templogs\tempvar.txt
set /p count_homebrews=<templogs\tempvar.txt
set /a temp_count=1
:listing_homebrews
IF %temp_count% GTR %count_homebrews% goto:skip_listing_homebrews
"tools\gnuwin32\bin\sed.exe" -n %temp_count%p "tools\default_configs\Lists\homebrews.list" >templogs\tempvar.txt
set /p temp_homebrew=<templogs\tempvar.txt
call :verif_folder_version "tools\sd_switch\mixed\modular\%temp_homebrew%"
IF "!update_finded!"=="Y" (
	call :update_folder
)
set /a temp_count+=1
goto:listing_homebrews
:skip_listing_homebrews
exit /b

:update_modchips_management.bat
call :verif_file_version "tools\Storage\modchips_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\modchips_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\modchips_management.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\Switchboot"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :update_launch_payload.bat
exit /b

:update_modules_profiles_management.bat
call :verif_file_version "tools\Storage\modules_profiles_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\modules_profiles_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\modules_profiles_management.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
tools\gnuwin32\bin\grep.exe -c "" <"tools\default_configs\Lists\modules.list" > templogs\tempvar.txt
set /p count_modules=<templogs\tempvar.txt
set /a temp_count=1
:listing_modules
IF %temp_count% GTR %count_modules% goto:skip_listing_modules
"tools\gnuwin32\bin\sed.exe" -n %temp_count%p "tools\default_configs\Lists\modules.list" >templogs\tempvar.txt
set /p temp_module=<templogs\tempvar.txt
call :verif_folder_version "tools\sd_switch\modules\pack\%temp_module%"
IF "!update_finded!"=="Y" (
	call :update_folder
)
set /a temp_count+=1
goto:listing_modules
:skip_listing_modules
exit /b

:update_mount_discs.bat
call :verif_file_version "tools\Storage\mount_discs.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\mount_discs.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\mount_discs.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\HacDiskMount"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\memloader"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\TegraRcmSmash"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_nand_joiner.bat
call :verif_file_version "tools\Storage\nand_joiner.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\nand_joiner.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\nand_joiner.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_nand_spliter.bat
call :verif_file_version "tools\Storage\nand_spliter.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\nand_spliter.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\nand_spliter.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_nand_toolbox.bat
call :verif_file_version "tools\Storage\nand_toolbox.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\nand_toolbox.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\nand_toolbox.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\NxNandManager"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :update_emunand_partition_file_create.bat
call :update_extract_nand_files_from_emunand_partition_file.bat
call :update_mount_discs.bat
call :update_nand_joiner.bat
call :update_nand_spliter.bat
call :update_ninfs.bat
IF EXIST "tools\Storage\nand_firmware_detect.bat" del /q "tools\Storage\nand_firmware_detect.bat" >nul
IF EXIST "tools\Storage\nand_firmware_detect.bat.version" del /q "tools\Storage\nand_firmware_detect.bat.version" >nul
IF EXIST "%language_path%\tools\Storage\nand_firmware_detect.bat" del /q "%language_path%\tools\Storage\nand_firmware_detect.bat"
IF EXIST "%language_path%\tools\Storage\nand_firmware_detect.bat.version" del /q "%language_path%\tools\Storage\nand_firmware_detect.bat.version"
IF EXIST "tools\python3_scripts\FVI" rmdir /s /q "tools\python3_scripts\FVI"
exit /b

:update_netplay.bat
call :verif_file_version "tools\Storage\netplay.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\netplay.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\netplay.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\netplay"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_ninfs.bat
call :verif_file_version "tools\Storage\ninfs.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\ninfs.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\ninfs.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\ninfs"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_nsZip.bat
call :verif_file_version "tools\Storage\nsZip.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\nsZip.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\nsZip.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\nsZip"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_ocasional_functions_menu.bat
call :verif_file_version "tools\Storage\ocasional_functions_menu.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\ocasional_functions_menu.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\ocasional_functions_menu.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_others_functions_menu.bat
call :verif_file_version "tools\Storage\others_functions_menu.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\others_functions_menu.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\others_functions_menu.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_pegaswitch.bat
call :verif_file_version "tools\Storage\pegaswitch.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\pegaswitch.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\pegaswitch.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\sd_switch\pegaswitch"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\Node.js_programs"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "Payloads"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_preload_NSC_Builder.bat
call :verif_file_version "tools\Storage\preload_NSC_Builder.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\preload_NSC_Builder.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\preload_NSC_Builder.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\NSC_Builder"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_prepare_sd_switch.bat
call :verif_file_version "tools\Storage\prepare_sd_switch.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\prepare_sd_switch.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\prepare_sd_switch.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\fat32format"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\sd_switch\atmosphere"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\sd_switch\atmosphere_patches_nogc"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\sd_switch\payloads"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\sd_switch\reinx"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\sd_switch\sxos"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "Payloads"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\Switchboot"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :update_cheats_profiles_management.bat
call :update_emulators_pack_profiles_management.bat
call :update_emummc_profiles_management.bat
call :update_mixed_pack_profiles_management.bat
call :update_modules_profiles_management.bat
call :update_prepare_sd_switch_profiles_management.bat
call :verif_file_version "tools\sd_switch\version.txt"
IF "!update_finded!"=="Y" (
	call :update_file
)
exit /b

:update_prepare_sd_switch_files_questions.bat
call :verif_file_version "tools\Storage\prepare_sd_switch_files_questions.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\prepare_sd_switch_files_questions.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\prepare_sd_switch_files_questions.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_prepare_sd_switch_infos.bat
call :verif_file_version "tools\Storage\prepare_sd_switch_infos.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\prepare_sd_switch_infos.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\prepare_sd_switch_infos.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_prepare_sd_switch_profiles_management.bat
call :verif_file_version "tools\Storage\prepare_sd_switch_profiles_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\prepare_sd_switch_profiles_management.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\prepare_sd_switch_profiles_management.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :update_prepare_sd_switch_files_questions.bat
call :update_prepare_sd_switch_infos.bat
exit /b

:update_prepare_update_on_sd.bat
call :verif_file_version "tools\Storage\prepare_update_on_sd.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\prepare_update_on_sd.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\prepare_update_on_sd.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\sd_switch\mixed\modular\ChoiDuJourNX"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :update_create_update.bat
exit /b

:update_renxpack.bat
call :verif_file_version "tools\Storage\renxpack.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\renxpack.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\renxpack.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\Hactool_based_programs"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_restore_configs.bat
call :verif_file_version "tools\Storage\restore_configs.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\restore_configs.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\restore_configs.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_restore_default.bat
call :verif_file_version "tools\Storage\restore_default.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\restore_default.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\restore_default.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_save_configs.bat
call :verif_file_version "tools\Storage\save_configs.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\save_configs.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\save_configs.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_serial_checker.bat
call :verif_file_version "tools\Storage\serial_checker.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\serial_checker.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\serial_checker.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\python3_scripts\ssnc"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_settings_menu.bat
call :verif_file_version "tools\Storage\settings_menu.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\settings_menu.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\settings_menu.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:update_split_games.bat
call :verif_file_version "tools\Storage\split_games.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\split_games.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\split_games.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\python3_scripts\splitNSP"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\XCI-Cutter"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_test_keys.bat
call :verif_file_version "tools\Storage\test_keys.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\test_keys.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\test_keys.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\python3_scripts\Keys_management"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_toolbox.bat
call :verif_file_version "tools\Storage\toolbox.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\toolbox.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\toolbox.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\toolbox"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\emuGUIibo"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\Goldtree"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\GuiFormat"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\HacDiskMount"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\Hactool_based_programs"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\H2testw"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\XCI-Cutter"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_update_shofel2.bat
call :verif_file_version "tools\Storage\update_shofel2.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\update_shofel2.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\update_shofel2.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\shofel2"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_verify_nsp.bat
call :verif_file_version "tools\Storage\verify_nsp.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\Storage\verify_nsp.bat"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\verify_nsp.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :verif_folder_version "tools\Hactool_based_programs"
IF "!update_finded!"=="Y" (
	call :update_folder
)
exit /b

:update_NES_Injector
call :verif_folder_version "tools\NES_Injector"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "languages\FR_fr\tools\NES_Injector"
IF "!update_finded!"=="Y" (
	call :update_folder
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\NES_Injector\NES_Injector.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
exit /b

:update_SNES_Injector
call :verif_folder_version "tools\SNES_Injector"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "languages\FR_fr\tools\SNES_Injector"
IF "!update_finded!"=="Y" (
	call :update_folder
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\SNES_Injector\SNES_Injector.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
exit /b

:general_content_update
call "%associed_language_script%" "update_basic_elements_begin"
call :verif_file_version "languages\FR_fr\tools\Storage\update_manager.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
call :verif_file_version "languages\FR_fr\tools\Storage\update_manager_updater.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\Storage\update_manager.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
		call :verif_file_version "%language_path%\tools\Storage\update_manager_updater.bat"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call :update_starting_script
call :update_about.bat
call :update_language_selector.bat
call :update_menu.bat
call :update_ocasional_functions_menu.bat
call :update_others_functions_menu.bat
call :update_settings_menu.bat
call :update_restore_configs.bat
call :update_restore_default.bat
call :update_save_configs.bat
call :update_donate.bat
call :verif_folder_version "tools\7zip"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\aria2"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\default_configs"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\gitget"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\gnuwin32"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\megatools"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_folder_version "tools\Storage\functions"
IF "!update_finded!"=="Y" (
	call :update_folder
)
call :verif_file_version "tools\general_update_version.txt"
IF "!update_finded!"=="Y" (
	call :update_file
)
call :verif_file_version "languages\FR_fr\tools\general_update_version.txt"
IF "!update_finded!"=="Y" (
	call :update_file
)
IF NOT "%language_path%"=="languages\FR_fr" (
	IF "%language_custom%"=="0" (
		call :verif_file_version "%language_path%\tools\general_update_version.txt"
		IF "!update_finded!"=="Y" (
			call :update_file
		)
	)
)
call "%associed_language_script%" "update_basic_elements_end"
exit /b

rem End of specific scripts instructions

:verif_file_version
set temp_file_path=%~1
set temp_file_slash_path=%temp_file_path:\=/%
call :test_write_access file "%~dp1"
set script_version=0
IF "%temp_file_path%"=="tools\sd_switch\version.txt" (
	IF EXIST "%temp_file_path%" (
		set /p script_version=<"%temp_file_path%"
	) else (
		set script_version=0
	)
	"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -d "templogs" -o "version.txt" "%files_url_project_base%/%temp_file_slash_path%"
) else IF "%temp_file_path%"=="tools\general_update_version.txt" (
	IF EXIST "%temp_file_path%" (
		set /p script_version=<"%temp_file_path%"
	) else (
		set script_version=0
	)
	"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -d "templogs" -o "version.txt" "%files_url_project_base%/%temp_file_slash_path%"
) else IF "%temp_file_path%"=="languages\FR_fr\tools\general_update_version.txt" (
	IF EXIST "%temp_file_path%" (
		set /p script_version=<"%temp_file_path%"
	) else (
		set script_version=0
	)
	"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -d "templogs" -o "version.txt" "%files_url_project_base%/%temp_file_slash_path%"
) else IF "%temp_file_path%"=="%language_path%\tools\general_update_version.txt" (
	IF EXIST "%temp_file_path%" (
		set /p script_version=<"%temp_file_path%"
	) else (
		set script_version=0
	)
	"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -d "templogs" -o "version.txt" "%files_url_project_base%/%temp_file_slash_path%"
) else IF "%temp_file_path%"=="tools\version.txt" (
	IF EXIST "%temp_file_path%" (
		set /p script_version=<"%temp_file_path%"
	) else (
		set script_version=0
	)
	"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -d "templogs" -o "version.txt" "%files_url_project_base%/%temp_file_slash_path%"
) else (
	IF EXIST "%~1.version" set /p script_version=<"%~1.version"
	"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -d "templogs" -o "version.txt" "%files_url_project_base%/%temp_file_slash_path%.version"
)
set /p script_version_verif=<"templogs\version.txt"
rem echo %temp_file_path% : va=%script_version%, vm=%script_version_verif%
rem echo %temp_file_slash_path%
rem pause
call :compare_version
exit /b

:verif_folder_version
set temp_folder_path=%~1
set temp_folder_slash_path=%temp_folder_path:\=/%
call :test_write_access folder "%~1"
set script_version=0
IF EXIST "%~1\folder_version.txt" set /p script_version=<"%~1\folder_version.txt"
"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -d "templogs" -o "version.txt" "%files_url_project_base%/%temp_folder_slash_path%/folder_version.txt"
set /p script_version_verif=<"templogs\version.txt"
rem echo %temp_folder_path% : va=%script_version%, vm=%script_version_verif%
rem echo %temp_folder_slash_path%
rem pause
call :compare_version
exit /b

:update_file
echo %temp_file_path%>"failed_updates\%temp_file_path:\=;%.file.failed"
"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -o "%temp_file_path%" "%files_url_project_base%/%temp_file_slash_path%"
IF %errorlevel% NEQ 0 (
	call "%associed_language_script%" "update_file_error"
	IF EXIST templogs (
		rmdir /s /q templogs
	)
	pause
	exit
)
:file.version_download
IF "%temp_file_path%"=="tools\sd_switch\version.txt" goto:skip_file.version_download
IF "%temp_file_path%"=="tools\general_update_version.txt" goto:skip_file.version_download
IF "%temp_file_path%"=="languages\FR_fr\tools\general_update_version.txt" goto:skip_file.version_download
IF "%temp_file_path%"=="%language_path%\tools\general_update_version.txt" goto:skip_file.version_download
IF "%temp_file_path%"=="tools\version.txt" goto:skip_file.version_download
"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -o "%temp_file_path%.version" "%files_url_project_base%/%temp_file_slash_path%.version"
IF %errorlevel% NEQ 0 (
	call "%associed_language_script%" "update_file.version_error"
	IF EXIST templogs (
		rmdir /s /q templogs
	)
	pause
	exit
)
:skip_file.version_download
del /q "failed_updates\%temp_file_path:\=;%.file.failed"
call "%associed_language_script%" "update_file_success"
exit /b

:update_folder
echo %temp_folder_path%>"failed_updates\%temp_folder_path:\=;%.fold.failed"
IF "%temp_folder_path%"=="tools\gitget" (
	"tools\gitget\SVN\svn.exe" export %folders_url_project_base%/%temp_folder_slash_path% templogs\gitget --force >nul
	IF !errorlevel! NEQ 0 (
		call "%associed_language_script%" "update_folder_error"
		IF EXIST templogs (
			rmdir /s /q templogs
		)
		pause
		exit
	) else (
		rmdir /s /q "%temp_folder_path%"
		move "templogs\gitget" "%temp_folder_path%"
		exit /b
	)
)
IF "%temp_folder_path%"=="tools\Hactool_based_programs" (
	mkdir templogs\tempsave
	copy /V "tools\Hactool_based_programs\keys.txt" "templogs\tempsave\keys.txt" >nul 2>&1
copy /V "tools\Hactool_based_programs\keys.dat" "templogs\tempsave\keys.dat" >nul 2>&1
)
IF "%temp_folder_path%"=="tools\megatools" (
	mkdir templogs\tempsave
	copy /V "tools\megatools\mega.ini" "templogs\tempsave\mega.ini" >nul 2>&1
)
IF "%temp_folder_path%"=="tools\netplay" (
	mkdir templogs\tempsave
	copy /v "tools\netplay\servers_list.txt" "templogs\tempsave\servers_list.txt" >nul 2>&1
)
IF "%temp_folder_path%"=="tools\NSC_Builder" (
	mkdir templogs\tempsave
	copy /V "tools\NSC_Builder\keys.txt" "templogs\tempsave\keys.txt" >nul 2>&1
)
IF "%temp_folder_path%"=="tools\toolbox" (
	mkdir templogs\tempsave
	%windir%\System32\Robocopy.exe tools\toolbox templogs\tempsave /e >nul 2>&1
	del /q templogs\tempsave\default_tools.txt
	del /q templogs\tempsave\folder_version.txt
)
rmdir /s /q "%temp_folder_path%"
"tools\gitget\SVN\svn.exe" export %folders_url_project_base%/%temp_folder_slash_path% %temp_folder_path% --force >nul
set temp_folder_download_error=%errorlevel%
IF "%temp_folder_path%"=="tools\Hactool_based_programs" (
		move "templogs\tempsave" "%temp_folder_path%"
)
IF "%temp_folder_path%"=="tools\megatools" (
		move "templogs\tempsave" "%temp_folder_path%"
)
IF "%temp_folder_path%"=="tools\netplay" (
		move "templogs\tempsave" "%temp_folder_path%"
)
IF "%temp_folder_path%"=="tools\NSC_Builder" (
		move "templogs\tempsave" "%temp_folder_path%"
)
IF "%temp_folder_path%"=="tools\toolbox" (
		move "templogs\tempsave" "%temp_folder_path%"
)
IF %temp_folder_download_error% NEQ 0 (
	call "%associed_language_script%" "update_folder_error"
	IF EXIST templogs (
		rmdir /s /q templogs
	)
	pause
	exit
)
del /q "failed_updates\%temp_folder_path:\=;%.fold.failed"
call "%associed_language_script%" "update_folder_success"
exit /b

:compare_version
set update_finded=
IF "%script_version_verif%"=="" goto:end_compare_version
IF "%script_version%"=="" (
	IF NOT "%script_version_verif%"=="" (
		set update_finded=Y
		exit /b
	) else (
		exit /b
	)
)
echo %script_version_verif%|"tools\gnuwin32\bin\grep.exe" -o "\."|"tools\gnuwin32\bin\wc.exe" -l >templogs\tempvar.txt
set /p count_script_version_verif_cols=<templogs\tempvar.txt
set /a count_script_version_verif_cols+=1
echo %script_version%|"tools\gnuwin32\bin\grep.exe" -o "\."|"tools\gnuwin32\bin\wc.exe" -l >templogs\tempvar.txt
set /p count_script_version_cols=<templogs\tempvar.txt
set /a count_script_version_cols+=1
IF %count_script_version_verif_cols% EQU 1 (
	IF %count_script_version_cols% EQU 1 (
		IF %script_version_verif% GTR %script_version% (
			set update_finded=Y
			exit /b
		) else (
			exit /b
		)
	)
)
for /l %%i in (1,1,%count_script_version_verif_cols%) do (
	echo %script_version_verif%|"tools\gnuwin32\bin\grep.exe" ""|"tools\gnuwin32\bin\cut.exe" -d . -f %%i >templogs\tempvar.txt
	set /p temp_script_version_verif=<templogs\tempvar.txt
	echo %script_version%|"tools\gnuwin32\bin\grep.exe" ""|"tools\gnuwin32\bin\cut.exe" -d . -f %%i >templogs\tempvar.txt
	set /p temp_script_version=<templogs\tempvar.txt
	IF !temp_script_version_verif! GTR !temp_script_version! (
		set update_finded=Y
		exit /b
	)
)

:test_write_access
IF "%~1"=="folder" (
	mkdir "%~2\test"
) else (
	mkdir "%~dp2\test"
)
IF %errorlevel% NEQ 0 (
	call "%associed_language_script%" "write_access_test_error"
	goto:end_script
)
IF "%~1"=="folder" (
	rmdir /s /q "%~2\test"
) else (
	rmdir /s /q "%~dp2\test"
)
exit /b

:update_failed_content
set /p temp_failed_update_path=<"%~1"
set temp_failed_file=%~1
IF "%temp_failed_file:~-11,4%"=="file" (
	set temp_file_path=%temp_failed_update_path%
	set temp_file_slash_path=%temp_failed_update_path:\=/%
	call :update_file
)
IF "%temp_failed_file:~-11,4%"=="fold" (
	set temp_folder_path=%temp_failed_update_path%
	set temp_folder_slash_path=%temp_failed_update_path:\=/%
	call :update_folder
)
exit /b

:update_manager_update_special_script
IF EXIST templogs (
	rmdir /s /q templogs
)
IF NOT EXIST "failed_updates\*.failed" (
	rmdir /s /q failed_updates
)
endlocal
::start /i "" "%windir%\system32\cmd.exe" /c call "tools\Storage\update_manager_updater.bat"
::IF /i "%language_echo%"=="on" pause
call "tools\Storage\update_manager_updater.bat"
exit
exit /b

:initialize_language
ping /n 2 www.github.com >nul 2>&1
IF %errorlevel% NEQ 0 (
	echo No internet connection and the language is not initialized, script will close.
	pause
	exit /b 500
)
copy nul "continue_update.txt" >nul
IF NOT EXIST "tools\default_configs\Lists\languages.list" (
	"tools\gitget\SVN\svn.exe" export %folders_url_project_base%/tools/default_configs/Lists tools\default_configs\Lists --force >nul
)
"tools\gitget\SVN\svn.exe" export %folders_url_project_base%/%temp_language_path:\=/% %temp_language_path% --force >nul
IF NOT "%temp_language_path%"=="languages\FR_fr" (
	"tools\gitget\SVN\svn.exe" export %folders_url_project_base%/languages/FR_fr languages\FR_fr --force >nul
)
echo Language initialized, script will restart.
pause
start /i "" "%windir%\system32\cmd.exe" /c call "Ultimate-Switch-Hack-Script.bat"
IF /i "%language_echo%"=="on" pause
exit
exit /b

:del_old_or_unused_files
call "%associed_language_script%" "del_hold_files_begin"
IF EXIST "tools\Storage\verif_update.ini" del /q "tools\Storage\verif_update.ini"
IF EXIST "DOC\*.*" rmdir /s /q "DOC"
IF EXIST "tools\sd_switch\mixed\modular\DZ" rmdir /s /q "tools\sd_switch\mixed\modular\DZ"
IF EXIST "tools\sd_switch\mixed\modular\Zerotwoxci" rmdir /s /q "tools\sd_switch\mixed\modular\Zerotwoxci"
IF EXIST "tools\sd_switch\modules\pack\Sys-Netcheat" rmdir /s /q "tools\sd_switch\modules\pack\Sys-Netcheat"
call "%associed_language_script%" "del_hold_files_end"
exit /b

:o/n_choice
IF /i "!%~1!"=="%lng_yes_choice%" (
	set %~1=o
) else IF /i "!%~1!"=="%lng_no_choice%" (
	set %~1=n
)
exit /b

:o/n/t/j_choice
IF /i "!%~1!"=="%lng_yes_choice%" (
	set %~1=o
) else IF /i "!%~1!"=="%lng_no_choice%" (
	set %~1=n
) else IF /i "!%~1!"=="%lng_always_choice%" (
	set %~1=t
) else IF /i "!%~1!"=="%lng_never_choice%" (
	set %~1=j
)
exit /b

:retroarch_update
IF NOT EXIST "failed_updates" mkdir "failed_updates" >nul
set errorlevel=0
ping /n 2 www.github.com >nul 2>&1
IF %errorlevel% NEQ 0 (
	call "%associed_language_script%" "retroarch_no_internet_connection"
	pause
	exit /b 500
)
ping /n 2 buildbot.libretro.com >nul 2>&1
IF %errorlevel% NEQ 0 (
	call "%associed_language_script%" "retroarch_no_internet_connection"
	pause
	exit /b 500
)
call :verif_folder_version "tools\sd_switch\emulators\pack\RetroArch"
IF NOT EXIST "tools\sd_switch\emulators\pack\RetroArch\RetroArch.7z" (
	set update_finded=Y
)
IF "!update_finded!"=="Y" (
	call "%associed_language_script%" "retroarch_updating"
	call :update_folder
	call "%associed_language_script%" "retroarch_updating"
	set /p retroarch_file_slash_path=<"tools\sd_switch\emulators\pack\RetroArch\download_adress.txt"
	set retroarch_file_path=tools\sd_switch\emulators\pack\RetroArch\RetroArch.7z
	"tools\aria2\aria2c.exe" -m 0 --auto-save-interval=0 --file-allocation=none --allow-overwrite=true --continue=false --auto-file-renaming=false --quiet=true --summary-interval=0 --remove-control-file=true --always-resume=false --save-not-found=false --keep-unfinished-download-result=false -o "!retroarch_file_path!" !retroarch_file_slash_path!
	call "%associed_language_script%" "retroarch_end_updating"
)
exit /b

:end_script
IF EXIST templogs (
	rmdir /s /q templogs
)
IF NOT EXIST "failed_updates\*.failed" (
	rmdir /s /q failed_updates
)
IF "%~1"=="retroarch_update" goto:skip_ending_cls
cls
:skip_ending_cls
endlocal