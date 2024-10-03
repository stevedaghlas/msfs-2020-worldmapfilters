# MSFS 2020 WorldMapFilters

## Introduction
This simple Powershell script is used to setup the WorldMapFilters for MSFS 2020. The behaviour of this script is similar to that for the `FSLTL Injection`. The user is prompted to answer some "questions".

## Explanation
The script starts by finding out whether your MSFS 2020 is a _Steam_ or _MS Store_ version.
In any case, it will lookup the config file with the name _UserCfg.opt_. This UserConfig file contains information about the location of your _Packages_ folder.
After that, it will determine the location of your _WorldMapFilters.xml_ file which contains all the filter settings for the world map in MSFS 2020.
The user then is prompted with a couple of questions about which runways to show or hide.

## Usage
* Make sure to backup your original _WorldMapFilters.xml_ file. The location of that file depends on your MSFS version and is shown in the output of the script. You can always hit `CTRL+C` to cancel the operation.
* Download the **_WorldMapFilters.ps1_** file
* Right click and `Run with PowerShell`
* The user is now prompted to type either `1` to turn the setting `ON` or `0` to turn it `OFF`
* You can always skip a setting by just hitting `ENTER`


## Limitations
* The script is currently tested with a MS Store version of MSFS 2020.
* Currently the user can only set the runway types. Future improvements will include Weather, Cities, POIs, Landmarks, Fauna, Airspaces, Navaids etc.
* MSFS 2024 is not supported yet as - at this time - it's unclear how the format of the filters will be and whether it is even neccessary to use this script. They might have finally fixed that issue *fingers xd*