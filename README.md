# MSFS 2020 WorldMapFilters

## Introduction
This simple Powershell script is used to setup the WorldMapFilters for MSFS 2020. The behaviour of this script is similar to that for the `FSLTL Traffic Injector`. The user is prompted to enter specific values for each filter, which are then saved into the XML-File of the WorldMapFilters.

## Folder Structure
* _backup:_ Here you can find a WorldMapFilters-File with everything set to `ON`. You can of course replace that with your own file.
* _WorldMapFilters.ps1:_ This is the main script used to set and save the filters.
* _WorldMapFilters.log:_ This is a log file to provide the developer with information about errors. If you encounter any errors or think that the script is not working as expected, please provide me this log file for further investigation.

## Explanation
The script starts by finding out whether your MSFS 2020 is a _Steam_ or _MS Store_ version.
In any case, it will lookup the config file with the name _UserCfg.opt_. This UserConfig file contains information about the location of your _Packages_ folder.
After that, it will determine the location of your _WorldMapFilters.xml_ file which contains all the filter settings for the world map in MSFS 2020.
The user then is prompted with a couple of "questions" about which filters to set up.

## Usage
* `>>> IMPORTANT <<<` If you installed MSFS to a custom location, you need to update the path in the script before you run it. There are two variables where that path is saved: `$steamCfgPath` and `$windowsStoreCfgPath`. Put your custom path **inside the quotes** but without overwriting `\UserCfg.opt`, save it and you are good to go.
* Make sure to backup your original _WorldMapFilters.xml_ file. The location of that file depends on your MSFS version and is shown in the output of the script. You can always hit `CTRL+C` to cancel the operation.
* Download the zip file found in the releases section and unzip it to a location of your discretion
* Right click the file _WorldMapFilters.ps1_ and `Run with PowerShell`
* The user is now prompted to type either `1` to turn the filter setting `ON` or `0` to turn it `OFF`
* You can always skip a filter by just hitting `ENTER`

## Limitations
* The script expects you to have MSFS 2020 installed to it's default location. The actual location depends on whether you have the _MS Store_ or _Steam_ edition. If you installed MSFS to a custom location, you would need to change the paths accordingly as mentioned in the `Usage` section.
* The user needs to setup the desired filters **before** starting MSFS 2020. The simulator unfortunately can not handle this file dynamically and it is always loaded at startup.
* The script is currently tested only with a **MS Store** version of _MSFS 2020_. You are welcome to test it on a Steam version of the Sim and I will be thankful for any feedback.
* Currently the user can only set the following filter types
    * **Airports** section with all kinds of runway types
    * **Heliports** section
    * **POIs** section
    * **Navigation** section
* The **Map** section with the following is not supported. I personally think that this section is never touched anyway.
    * Background Map
    * Weather Layer
    * Wind Effect
    * Friends
    * Third Party Content
* **MSFS 2024** is not supported yet as - at this time - it's unclear how the format of the filters will be and whether it is even neccessary to use this script. They might have finally fixed that issue *fingers xd*

## Feedback
I am always happy to get some feedback. Please don't hesitate if you find a bug.

## Video Tutorial
[YouTube Tutorial](https://www.youtube.com/watch?v=eoR6c2z3Opg)