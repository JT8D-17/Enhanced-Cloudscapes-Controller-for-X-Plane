# Enhanced Cloudscapes Controller
FlyWithLua-based user interface to control the "Enhanced Cloudscapes" plugin for X-Plane 11. Offers real-time editing, presets and persistence for plugin datarefs.

&nbsp;

<a name="toc"></a>
## Table of Contents
1. [Requirements](#requirements)
2. [Installation](#install)
3. [Uninstallation](#uninstall)
4. [First Start](#first)
5. [User Interface](#UI)
	1. [Main Menu](#controller)
	2. [Cloud Settings Menu](#controller)
	3. [UI Settings Menu](#uisettings)
6. [Known Issues](#issues)
7. [License](#license)

&nbsp;

<a name="requirements"></a>
## 1 - Requirements

[X-Plane 11](https://www.x-plane.com/) (11.41 or higher)   
[FlyWithLuaNG](https://forums.x-plane.org/index.php?/files/file/38445-flywithlua-ng-next-generation-edition-for-x-plane-11-win-lin-mac/) (2.7.28 or higher)   
[ "Enhanced Cloudscapes" plugin](https://forums.x-plane.org/index.php?/files/file/65005-enhanced-cloudscapes/) (2020.11.24 or newer)


[Back to table of contents](#toc)

&nbsp;

<a name="install"></a>
## 2 - Installation

Copy the "Scripts" and "Modules" folders into _"X-Plane 11/Resources/plugins/FlyWithLua/"_

[Back to table of contents](#toc)

&nbsp;

<a name="uninstall"></a>
## 3 - Uninstallation

- Delete _EC_Controller.lua_ from _"X-Plane 11/Resources/plugins/FlyWithLua/Scripts"_
- Delete the _"EC_Controller"_ folder from _"X-Plane 11/Resources/plugins/FlyWithLua/Modules"_

[Back to table of contents](#toc)

&nbsp;

<a name="first"></a>
## 4 - First start

Enhanced Clouds Controller must be started manually until the _"Autosave"_ option in the _"UI Settings"_ window has been enabled.   
After that, the visibility status of the window will be remembered and applied during each script start (or reload).

Start ECC...   
...from X-Plane's _"Plugins"_ menu with  _"Enhanced Cloudscapes"_ --> _"Open Controller Window"_.    
or    
...from X-Plane's _"Plugins"_ menu with _"FlyWithLua"_ --> _"FlyWithLua Macros"_ --> _"Enhanced Cloudscapes Controller: Toggle Window"_.    
or    
...by assigning a keyboard shortcut for 
_"Enhanced Cloudscapes Controller/Window/Toggle Window"_
in X-Plane's keyboard settings window.

Once the window is open, go into the _"UI Settings"_ menu and enable Autosaving and Autoloading (see section 5.3.4).

After that, feel free to try the included presets or attempt to create your own. See section 5.2 for descriptions of UI element functionality.

[Back to table of contents](#toc)

&nbsp;

<a name="UI"></a>
## 5 - User Interface

General hints:

After having typed a value into any text/number input box, click anywhere in the Controller's window to leave it, otherwise it will keep focus, eating up all keyboard inputs (see "Known Issues" section below).   
Undesired values in text/number input boxes that were just entered can be discarded  by pressing the "ESC" key.  
Window size is saved when the "Autosave" option is activated in the _"ECC UI Settings"_ window.    
The EC Controller window will automatically open upon X-Plane session start if both the "Autosave" and "Autoload" option have been activated in the _"UI Settings"_ menu (see section 5.3.3 below).   
Some UI elements have tooltips.

[Back to table of contents](#toc)

&nbsp;

<a name="mainmenu"></a>
### 5.1 - Main Menu

Click the _"Cloud Settings"_ or _"UI Settings"_ button to enter the respective menu. Each of these menus offers a _"Main Menu"_ button to immediately return.
 
 [Back to table of contents](#toc)
 
 &nbsp;
 
<a name="controller"></a>
### 5.2 - Cloud Settings Menu

**5.2.1 - Presets**

The latest release of EC Controller features support for multiple presets, which are stored in `FlyWithLua/Modules/EC_Controller` and __must__ be prefixed with "EC_Preset", e.g. `EC_Preset_HighDetail.cfg`.    
Scanning for presets is performed at script start, but in case a manual rescan is required, there is a _"Rescan"_ button in the UI.

Pessing the _"Save"_ button activates a file name input box (with a character limit of 30!) and a _"OK"_ and _"Cancel"_ button.    
Pressing _"OK"_ will write the current preset to file with the specified file name. __If a preset with the same file name is already present, it will be overwritten without asking for confirmation!__  The preset list for the selector will be refreshed after saving is complete. Pressing _"Cancel"_ returns to the preset selector.

A preset that is picked from the selector dropdown box (except _"New Preset"_) is immediately loaded and its file name (without the file extension) is stored in `ActivePreset.cfg`.    
When the _"Autoload"_ function from the _"UI Settings"_ or plugin menu has been activated, `ActivePreset.cfg` is read at EC Controller start and the preset matching the filename stored in it is being loaded if the corresponding preset file can be found (otherwise default values will be used).

&nbsp;

**5.2.2 -  Subpage navigation**

The arrow buttons flip from parameter group to parameter group. The group assignment for each parameter can be changed in its advanced settings

&nbsp;

**5.2.3 - Value manipulation**

Use the slider or float (decimal) number input elements to change a parameter's value. Note that input value range is limited.    
 _"Reset"_ will reset the parameter to the default value, which is obtained from each dataref at script start (also see "Known Issues" section below).    
If you need more input options, check the "Advanced Settings" checkbox.

&nbsp;
	
**5.2.4 - Advanced settings**

Advanced options uniformly apply to all values of a parameter array.   
The displayed parameter title is stated in a text input box and can therefore be edited.   
_"Switch Display To [Numerical/Percentage]"_ toggles between a numerical (float) and percentage format for the parameter's value.   
_"Lower/Upper Raw Value Limit"_ can be used to narrow or broaden the available range for input values. Will also affect values displayed as a percentage. The _"Reset"_ button resets each limiter value to the one defined in the LUA file. Use this with caution as it may break the plugin.   
_"Display Precision"_ accepts integer (i.e. whole number) inputs and controls the decimals displayed in the control elements for the parameter. It will auto-reset to "1" (percentage) and "6" (numerical) when the  _"Switch Display To [Numerical/Percentage]"_ button is pressed.   
_"Display In Group"_ controls the group assignment for the parameter and accepts integer (whole number) values. This can be used to move the parameter to any present or new group and offers a way to reorder the groups to one's liking. Applying any changes that were made to advanced parameters requires pressing the _"Apply"_ button.

[Back to table of contents](#toc)

&nbsp;

<a name="uisettings"></a>
### 5.3 - UI Settings Menu

**5.3.1 - Notification settings**

"Notification display time" accepts integer (i.e. whole number) values and controls the time in seconds, for which notifications in the notification area below the main window content is displayed.

&nbsp;


**5.3.2 - Window hotkey control**

 _"[Enable/Disable] Window Toggling by Hotkey"_ toggles the hotkey activation mode for the main window, independent of which key was set for this in X-Plane's keyboard settings.    
The "Keyboard Key Code" field accepts integer (whole number) values and determines the key that will toggle the ECC window's visibility. The default keycode is 85, i.e. "u".    
A key (combination) to toggle the Window may always be set in X-Plane's keyboard settings (_"Enhanced Cloudscapes Controller"_ section).
	
&nbsp;
	
**5.3.3 - Autosave/Autoload**

 _"[Enable/Disable] Autosave"_ saves __EC Controller's UI settings__ settings immediately to file when activated, including window size and position and will then autosave when another setting has been changed. Does not affect the plugin parameters!    
 _"[Enable/Disable] Autoload"_ autoloads all __Controller window settings and the cloud preset__ upon script start (when starting an X-Plane session). This option may also be toggled from the _"Plugins"_ --> _"Enhanced Cloudscapes"_ --> _"Autoload Settings"_ menu item.

&nbsp;

**5.3.4 - Manual UI settings file management**

The _"Save UI Settings"_, _"Load UI Settings"_ and _"Delete UI Settings"_ buttons are self-explanatory and __only affect EC Controller's UI settings file, not the currently active cloud preset__

&nbsp;
	
**5.3.5 - UI settings file location**

The path to the settings file is: `FlyWithLua/Modules/EC_Controller/UI_Prefs.cfg`. Altering it requires editing the script source and is therefore not recommended.    

[Back to table of contents](#toc)

&nbsp;

<a name="issues"></a>
## 6 - Known issues

- If you reload all FlyWithLua scripts, an empty "Enhanced Cloudscapes" menu may be left over in the plugins menu or the "FlyWithLua" menu may disappear. In both cases, restart X-Plane.
- Altering a plugin parameter and reloading the Lua script will set that parameter as default.   
Workaround: Restart X-Plane so that the plugin will be reset
- Input boxes will not let go of focus upon pressing "Enter".  
This is an Imgui limitation. Click anywhere into the window (except for another input field) to unfocus.   

[Back to table of contents](#toc)


&nbsp;

<a name="license"></a>
## 7 - License

Enhanced Cloudscapes Controller is licensed under the European Union Public License v1.2 (see _EUPL-1.2-license.txt_). Compatible licenses (e.g. GPLv3) are listed  in the section "Appendix" in the license file.


[Back to table of contents](#toc)