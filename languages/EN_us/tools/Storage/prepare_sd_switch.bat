set lng_label_exist=0
%ushs_base_path%tools\gnuwin32\bin\grep.exe -c -E "^:%~1$" <"%~0" >"%ushs_base_path%temp_lng_var.txt"
set /p lng_label_exist=<"%ushs_base_path%temp_lng_var.txt"
del /q "%ushs_base_path%temp_lng_var.txt"
IF "%lng_label_exist%"=="0" (
	call "!associed_language_script:%language_path%=languages\FR_fr!" "%~1"
	goto:eof
) else (
	goto:%~1
)

:display_title
title SD preparing %this_script_version% - Shadow256 Ultimate Switch Hack Script %ushs_version%
goto:eof

:intro
echo This script will prepare a SD card with files that used by the hack ^(CFWs, homebrews, modules...^).
echo During the script, the admin's rights could be asked.
echo.
echo Be careful: If you decide to format the SD, all datas on it will be lost so save the importants datas before doing that.
echo Be careful: Choose the good letter for your SD because no verification could be done to verify that point.
goto:eof

:disk_not_finded_error
	echo No compatible disk found. Please insert a compatible disk and relaunch the script.
goto:eof

:disk_list_begin
echo Disks list:
goto:eof

:disk_choice
set /p volume_letter=Enter the volume letter that you want to use or enter "0" to go back to previous menu: 
goto:eof

:disk_choice_empty_error
echo The volume letter couldn't be empty.
goto:eof

:disk_choice_char_error
echo Unauthorised char in volume letter.
goto:eof

:disk_choice_not_exist_error
echo This volume doesn't exist.
goto:eof

:disk_choice_not_in_list_error
echo This volume letter is not in the list.
goto:eof

:disk_format_choice
set /p format_choice=Do you want to format the SD ^(volume "%volume_letter%"^)? ^(%lng_yes_choice%/%lng_no_choice%^):
goto:eof

:disk_format_type_choice
echo What format type do you want to do:
echo 1: EXFAT ^(the Switch must have the EXFAT drivers installed to support it^)?
echo 2: FAT32 ^(limited to  4 GO maximum file size^)?
echo All other choices: Cancel formating.
echo.
set /p format_type=Make your choice: 
goto:eof

:disk_formating_begin
echo Formating...
goto:eof

:disk_formating_error
echo An error occured during formating, the script will be stoped.
goto:eof

:disk_formating_success
echo Formating success.
goto:eof

:disk_formating_fat32_not_admin_error
echo You don't have accepted the admin rights ask, formating step is canceled.
goto:eof

:disk_formating_fat32_disk_used_error
echo The formating has not been done.
echo Try to properly eject your volume, insert it and retry to execute the script imediatly.
echo You could also try to close all the explorer's windows just before formating, sometimes it fix the problem.
echo.
echo The script will end now.
goto:eof

:disk_formating_fat32_disk_not_exist_error
echo The volume that you want to format doesn't exist, maybe you have ejected or disconected the volume during this script.
echo.
echo The script will end now.
goto:eof

:disk_formating_fat32_unknown_error
echo An unknown error occured during formating operation.
echo.
echo The script will end now.
goto:eof

:disk_formating_fat32_canceled_info
echo The formating has been canceled by the user.
goto:eof

:general_profile_select_begin
echo Select the general profile:
goto:eof

:general_profile_select_atmosphere_and_sxos_recommanded_profile_display
echo !count_default_profile!: Atmosphere + SXOS + Memloader profile recommanded, doesn't contain the nogc patches and just update the files on the SD so this profile is not always adapted.
goto:eof

:general_profile_select_atmosphere_recommanded_profile_display
echo !count_default_profile!: Atmosphere profile recommanded, doesn't contain the nogc patches and just update the files on the SD so this profile is not always adapted.
goto:eof

:general_profile_select_sxos_recommanded_profile_display
echo !count_default_profile!: Profile  SXOS profile recommanded, just update the files on the SD so this profile is not always adapted.
goto:eof

:general_profile_choice
echo 0: Open the general profiles management.
echo E: End the script without preparing the SD.
echo All other choices: Prepare the SD manualy.
echo.
set /p general_profile=Make your choice: 
goto:eof

:confirm_copy_choice
set /p confirm_copy=Do you confirm this? ^(%lng_yes_choice%/%lng_no_choice%^): 
goto:eof

:canceled
echo Operation canceled.
goto:eof

:bad_choice
echo This choice doesn't exist.
goto:eof

:before_copy_error
echo SD preparation canceled because an unknown error occured, verify that you have not remove a profile used in the general ofle that you have chosen.
echo If the problem persist, please try to make the profile again.
goto:eof

:copying_begin
echo Copying...
goto:eof

:copying_end
echo Copy ended.
echo.
set /p prepare_another_sd=Do you want to restart the SD preparation from the beginning? ^(%lng_yes_choice%/%lng_no_choice%^): 
goto:eof

:config_nes_classic_choice
echo Warning, it seems that no configuration of the Nes Classic Edition emulator has taken place previously, so it will be unusable as this point.
echo You can configure the emulator via the "other functions" of the script and then redo the preparation of the SD or choose to configure it immediately.
set /p config_nes_classic=Do you want to launch the emulator configuration script? ^(%lng_yes_choice%/%lng_no_choice%^): 
goto:eof

:config_nes_classic_error
echo It seems that the configuration of the Nes Classic Edition emulator has failed, so it will not be copied.
goto:eof

:config_snes_classic_choice
echo Warning, it seems that no configuration of the Snes Classic Edition emulator has taken place previously, so it will be unusable as this point.
echo You can configure the emulator via the "other functions" of the script and then redo the preparation of the SD or choose to configure it immediately.
set /p config_snes_classic=Do you want to launch the emulator configuration script? ^(%lng_yes_choice%/%lng_no_choice%^): 
goto:eof

:config_snes_classic_error
echo It seems that the configuration of the Snes Classic Edition emulator has failed, so it will not be copied.
goto:eof

:retroarch_not_exist_error
echo RetroArch couldn't be installed cause it is not finded, use the update manager   when it is asked during the SD preparation.
goto:eof

:sxos_force_disable_stealth_mode_for_uLaunch
rem echo To use the uLaunch module with SX OS, the Stealth Mode of SX OS has been disabled, please don't connect to internet without a protection like  Incognito and/or 90dns configured.
echo The uLaunch module isn't officialy compatible with SX OS for now, the module will not be copied for this CFW.
goto:eof