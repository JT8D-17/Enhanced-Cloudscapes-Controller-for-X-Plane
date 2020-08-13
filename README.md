# Enhanced Cloudscapes Controller
FlyWithLua-based user interface to control the "Enhanced Cloudscapes" plugin for X-Plane 11  

Status: Under heavy development.

&nbsp;

## Requirements

- [X-Plane 11](https://www.x-plane.com/)
- [FlyWithLuaNG](https://forums.x-plane.org/index.php?/files/file/38445-flywithlua-ng-next-generation-edition-for-x-plane-11-win-lin-mac/)
- [ "Enhanced Cloudscapes" plugin](https://forums.x-plane.org/index.php?/files/file/65005-enhanced-cloudscapes/)

&nbsp;

## Installation

Copy the "Scripts" and "Modules" folders into
 X-Plane 11/Resources/plugins/FlyWithLua/

&nbsp;

## Usage

Quick & dirty. Who's got time for more anyway?

### 1. First start/_"Preferences"_ screen

1. In X-Plane:   
"Plugins" menu --> "FlyWithLua" --> "FlyWithLua Macros"    
--> "Enchanced Cloudscapes Controller: Toogle Window"
2. "ECC Preferences" button: 
	- The "Main Menu" button leads back to the start screen
	- "Notification display time" controls the time, during which notifications in the notification area below the main window content is displayed
	- Enabling _"Toggle Window by key"_ provides a Controller-specific override for a hotkey to toggle window visibility ("u" by default). Find a key number and set it in the input field. Alternatively, leave this diabled and set the hotkey key in X-Plane's keyboard options
	- Enabling _"Autosave changes"_ saves all   __Controller window__ settings immediately to a preferences file when changed, including window size and position
	- Enabling _"Autoload on Start"_ autoloads all __Controller window settings and the cloud preset__ upon script start (when starting an X-Plane session)
	-  The _"Save Preferences"_, _"Load Preferences"_ and _"Delete Preference File"_ buttons are self-explanatory and __only affect the Controller window preference file, not the cloud preset__
	- __Note:__ Window size is saved automatically
3. Save your changes.

### 2. The Cloud Controller area


&nbsp;

## License

Enhanced Cloudscapes Controller is licensed under the European Union Public License v1.2 (see _EUPL-1.2-license.txt_). Compatible licenses (e.g. GPLv3) are listed  in the section "Appendix" in the license file.
