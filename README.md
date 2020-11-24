# Enhanced Cloudscapes Controller
FlyWithLua-based user interface to control the "Enhanced Cloudscapes" plugin for X-Plane 11. Offers real-time editing and persistence for plugin datarefs.

&nbsp;

<a name="toc"></a>
## Table of Contents
1. [Requirements](#requirements)
2. [Installation](#install)
3. [Uninstallation](#uninstall)
4. [First Start](#first)
5. [User Interface](#UI)
	1. [Cloud Controller window](#controller)
	2. [User Interface settings](#settings)
6. [Known Issues](#issues)
7. [License](#license)

&nbsp;

<a name="requirements"></a>
##1 - Requirements

- [X-Plane 11](https://www.x-plane.com/) (11.41 or higher)
- [FlyWithLuaNG](https://forums.x-plane.org/index.php?/files/file/38445-flywithlua-ng-next-generation-edition-for-x-plane-11-win-lin-mac/) (2.7.28 or higher)
- [ "Enhanced Cloudscapes" plugin](https://forums.x-plane.org/index.php?/files/file/65005-enhanced-cloudscapes/) (2020.11.24 or newer)

&nbsp;
[Back to table of contents](#toc)

<a name="install"></a>
##2 - Installation

Copy the "Scripts" and "Modules" folders into _"X-Plane 11/Resources/plugins/FlyWithLua/"_

&nbsp;
[Back to table of contents](#toc)

<a name="uninstall"></a>
##3 - Uninstallation

- Delete _EnhCloudsController.lua_ from _"X-Plane 11/Resources/plugins/FlyWithLua/Scripts"_
- Delete _"EnhCloudsController"_ from _"X-Plane 11/Resources/plugins/FlyWithLua/Modules"_

&nbsp;
[Back to table of contents](#toc)

<a name="first"></a>
##4 - First start

Enhanced Clouds Controller must be started manually until the _"Autosave"_ option in the _"UI Settings"_ window has been enabled.   
After that, the visibility status of the window will be remembered and applied during each script start (or reload).

Start ECC...   

1.  ...from X-Plane's _"Plugins"_ menu with
 _"Enhanced Cloudscapes"_ --> _"Open Controller Window"_
or
_"FlyWithLua"_ --> _"FlyWithLua Macros"_ --> _"Enchanced Cloudscapes Controller: Toggle Window"_
2. ...by assigning a keyboard shortcut for 
_"Enhanced Cloudscapes Controller/Window/Toggle Window"_
in X-Plane's keyboard settings window:


&nbsp;
[Back to table of contents](#toc)

<a name="UI"></a>
##5 - User Interface

General hints:   
	- After having typed a value into any text/number input box, click anywhere in the Controller's window to leave it, otherwise it will keep focus, eating up all keyboard inputs (see "Known Issues" section below).   
	- Undesired values in text/number input boxes that were just entered can be discarded  by pressing the "ESC" key.  
	- Window size is saved when the "Autosave" option is activated in the _"ECC UI Settings"_ window
 
<a name="controller"></a>
###5.1 - Cloud Controller window

**5.1.1 -  Navigation**
	- The arrow buttons flip from parameter group to parameter group. The group assignment for each parameter chan be changed in its advanced settings

**5.1.2 - Value manipulation**
	- Use the slider or float (decimal) number input elements to change a parameter's value. Input value range is limited though.
	- _"Reset"_ will reset the parameter to the default value, which is obtained from each dataref at script start (also see "Known Issues" section below).
	- If you need more input options, check the "Advanced Settings" checkbox at the botton of each page
	
**5.1.3 - Advanced settings**
	- Advanced options uniformly apply to all values of a parameter array
	- The displayed parameter title is stated in a text input box and can therefore be edited
	- _"Switch Display To [Numerical/Percentage]"_ toggles between a numerical (float) and percentage format for the parameter's value
	- _"Lower/Upper Raw Value Limit"_ can be used to narrow or broaden the available range for input values. Will also affect values displayed as a percentage. The _"Reset"_ button resets each limiter value to the one defined in the LUA file. Use with caution, may break the plugin.
	- _"Display Precision"_ accepts integer (i.e. whole number) inputs and controls the decimals displayed in the control elements for the parameter. Will auto-reset to "1" (percentage) and "6" (numerical) when the  _"Switch Display To [Numerical/Percentage]"_ button is pressed.
	- _"Display In Group"_ controls the group assignment for the parameter and accepts integer (whole number) values. Can be used to move the parameter to any present or new group and offers a way to reorder the groups to one's liking. Applying changes requires pressing the _"Apply"_ button.

**5.1.4 - Loading/Saving**
	- The _"Load/Save Preset"_ buttons control file input/output and write the current parameter values to disk
	- If _"Autoload"_ has been enabled in the _"ECC UI Settings"_ menu, values are automatically loaded upon script start.
	
**5.1.5 - Preset file location**
	- The path to the preset file is:   
	 _"FlyWithLua/Modules/EnhCloudsController/EC_Preset.cfg"_ .  
	Altering this requires editing the script source and is therefore not recommended.

[Back to table of contents](#toc)
<a name="settings"></a>
### 5.2 - User Interface Settings

**5.2.1 - Navigation**
	- The menu can be accessed with the _"ECC UI Settings"_ button.
	- The _"Back"_ button leads back to the start screen.

**5.2.2 - Notification settings**
	- "Notification display time" accepts integer (i.e. whole number) values and controls the time in seconds, for which notifications in the notification area below the main window content is displayed

**5.2.3 - Window hotkey control**
	- _"[Enable/Disable] Window Toggling by Hotkey"_ toggles the hotkey activation mode for the main window, independent of which key was set for this in X-Plane's keyboard settings 
	- The "Keyboard Key Code" field accepts integer (whole number) values and determines the key that will toggle the ECC window's visibility. The default keycode is 85, i.e. "u".
	- A key (combination) to toggle the Window may always be set in X-Plane's keyboard settings (_"Enhanced Cloudscapes Controller"_ section).
	
**5.2.4 - Autosave/Autoload**
	- _"[Enable/Disable] Autosave"_ saves all   __Controller window__ settings immediately to file when activated, including window size and position and will then autosave when another setting has been changed. Does not affect the plugin parameters!
	- _"[Enable/Disable] Autoload"_ autoloads all __Controller window settings and the cloud preset__ upon script start (when starting an X-Plane session).  
This option may also be toggled from the _"Plugins"_ --> _"Enhanced Cloudscapes"_ --> _"Autoload Settings"_ menu item.

**5.2.5 - Manual UI settings file management**
	-  The _"Save UI Settings"_, _"Load UI Settings"_ and _"Delete UI Settings"_ buttons are self-explanatory and __only affect the Controller settings file, not the cloud preset__
	
**5.2.6 - UI settings file location**
	- The path to the settings file is:   
	 _"FlyWithLua/Modules/EnhCloudsController/UI_Prefs.cfg"_  
	Altering this requires editing the script source and is therefore not recommended.

&nbsp;
[Back to table of contents](#toc)

<a name="issues"></a>
##6 - Known issues

- Altering a plugin parameter and reloading the Lua script will set that parameter as default.   
Workaround: Restart X-Plane so that the plugin will be reset
- Input boxes will not let go of focus upon pressing "Enter".  
This is an Imgui limitation.   
- The main _"Enhanced Cloudscapes"_ menu item in the "Plugins" menu will not be removed if you reload all Lua script files in FlyWithLua.

&nbsp;
<a name="license"></a>
[Back to table of contents](#toc)

##7 - License

Enhanced Cloudscapes Controller is licensed under the European Union Public License v1.2 (see _EUPL-1.2-license.txt_). Compatible licenses (e.g. GPLv3) are listed  in the section "Appendix" in the license file.
