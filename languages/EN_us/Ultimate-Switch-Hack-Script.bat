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
title Loading %this_script_version% - Shadow256 Ultimate Switch Hack Script %ushs_version%
goto:eof

:admin_error
echo The script is in a folder witch needs admin write authorisation to be written. Reload the script with a right click and select "launch as administrator".
goto:eof

:display_utf8_instructions
echo Before continuing, verify the setting explained below cause the script could have some problems if the setting isn't set correctly.
echo Make a right click on the title bar or use the shortcut "alt+space" and select "properties".
echo Goto the "fonts" tab, select the "Lucida Console" font and click on "OK" button.
echo.
echo If everything is well configured, the script should work correctly.
echo If the script close just after this, the font selected is not compatible with UTF-8 encoding.
goto:eof