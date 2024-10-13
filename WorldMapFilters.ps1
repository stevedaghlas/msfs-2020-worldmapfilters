# Define the log file path (you can change this path if needed)
$logFilePath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "WorldMapFilters.log"

# Function to write logs to the file
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logFilePath -Value $logMessage
    Write-Host $logMessage
}

# Function to log and handle errors
function Handle-Error {
    param (
        [string]$errorMessage
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - ERROR: $errorMessage"
    Add-Content -Path $logFilePath -Value $logMessage
    Write-Host $logMessage
    Write-Host "An error occurred: $errorMessage"
    Read-Host "Press any key to exit"
    exit
}

# Define possible locations for the UserCfg.opt file (Windows Store and Steam)
$steamCfgPath = "$env:APPDATA\Microsoft Flight Simulator\UserCfg.opt"
$windowsStoreCfgPath = "$env:LOCALAPPDATA\Packages\Microsoft.FlightSimulator_8wekyb3d8bbwe\LocalCache\UserCfg.opt"

# Log: Start checking for UserCfg.opt file
Write-Log "Checking for UserCfg.opt in the following locations:"
Write-Log "Steam path: $steamCfgPath"
Write-Log "Windows Store path: $windowsStoreCfgPath"

# Check which version the user has and get the path to UserCfg.opt
if (Test-Path $steamCfgPath) {
    $userCfgPath = $steamCfgPath
    Write-Log "Found UserCfg.opt at: $steamCfgPath"
} elseif (Test-Path $windowsStoreCfgPath) {
    $userCfgPath = $windowsStoreCfgPath
    Write-Log "Found UserCfg.opt at: $windowsStoreCfgPath"
} else {
    Handle-Error "Could not find the UserCfg.opt file. Please make sure MSFS 2020 is installed."
}

# Read the UserCfg.opt file to extract the InstalledPackagesPath
try {
    $installedPackagesPathLine = Select-String -Path $userCfgPath -Pattern 'InstalledPackagesPath'
} catch {
    Handle-Error "Failed to read the UserCfg.opt file."
}

# Extract the path without line numbers or extra information
if ($installedPackagesPathLine) {
    try {
        $installedPackagesPath = $installedPackagesPathLine -replace '.*?"([^"]+?)".*', '$1'
        $installedPackagesPath = $installedPackagesPath.Trim()
    } catch {
        Handle-Error "Failed to parse InstalledPackagesPath from the UserCfg.opt file."
    }
} else {
    Handle-Error "Failed to find InstalledPackagesPath in $userCfgPath."
}

# Log: Output the cleaned InstalledPackagesPath
Write-Log "Found InstalledPackagesPath: $installedPackagesPath"

# Construct the path to WorldmapFilters.xml based on the InstalledPackagesPath
$worldmapFiltersPath = Join-Path $installedPackagesPath 'Official\OneStore\fs-base\worldmap\WorldmapFilters.xml'

# Log: Output the constructed path to WorldmapFilters.xml
Write-Log "Looking for WorldmapFilters.xml at: $worldmapFiltersPath"

# Check if the WorldmapFilters.xml exists at the constructed path
if (-not (Test-Path $worldmapFiltersPath)) {
    Handle-Error "Could not find WorldmapFilters.xml at $worldmapFiltersPath."
}

# Load the WorldmapFilters.xml file
try {
    [xml]$xmlDoc = Get-Content $worldmapFiltersPath
    Write-Log "Loaded WorldmapFilters.xml successfully."
} catch {
    Handle-Error "Failed to load WorldmapFilters.xml."
}

# Define the filters to ask the user about (runways, heliports, POI, navaids)
$filterSections = @(
    @{ id="RUNWAY_HARD"; label="Hard Runway" },
    @{ id="RUNWAY_GRASS"; label="Grass Runway" },
    @{ id="RUNWAY_WATER"; label="Water Runway" },
    @{ id="RUNWAY_SNOW"; label="Snow Runway" },
    @{ id="RUNWAY_SAND"; label="Sand Runway" },
    @{ id="RUNWAY_HELI"; label="Heli Runway" },
    @{ id="RUNWAY_OTHER"; label="Other Runway" },
    @{ id="TYPE_HELIPORT"; label="Heliport" },
    @{ id="TYPE_LANDMARK"; label="Landmarks (POI)" },
    @{ id="TYPE_CITY"; label="Cities (POI)" },
    @{ id="TYPE_FAUNA"; label="Fauna (POI)" },
    @{ id="MAP_AIRSPACES"; label="Airspaces (Navaids)" },
    @{ id="TYPE_NAVAID"; label="Navaids (Navaids)" },
    @{ id="TYPE_RNAV_FIX"; label="RNAV Fixes (Navaids)" }
)

# Function to ask the user for input
function Get-UserInput {
    param (
        [string]$label,
        [string]$currentValue
    )
    
    $inputValid = $false
    while (-not $inputValid) {
        $userInput = Read-Host "$label (1=ON, 0=OFF, press Enter to keep current: $currentValue)"
        
        if ($userInput -eq "1" -or $userInput -eq "0") {
            $inputValid = $true
            return $userInput
        } elseif ($userInput -eq "") {
            # If the user presses Enter, keep the current value
            $inputValid = $true
            return $currentValue
        } else {
            Write-Host "Invalid input. Please enter 1 or 0."
        }
    }
}

# Loop through each filter and ask the user
foreach ($filter in $filterSections) {
    try {
        $currentStatus = $xmlDoc.SelectSingleNode("//FilterDefinition[FilterID='$($filter.id)']/OnOff").'#text'
        $userInput = Get-UserInput "$($filter.label)" $currentStatus
    
        # Update the XML based on user input or retain the current value
        $newStatus = if ($userInput -eq "1") { "ON" } elseif ($userInput -eq "0") { "OFF" } else { $currentStatus }
        $xmlDoc.SelectSingleNode("//FilterDefinition[FilterID='$($filter.id)']/OnOff").'#text' = $newStatus

        # Log: Output the new status for each filter
        Write-Log "$($filter.label): Updated to $newStatus"
    } catch {
        Handle-Error "Failed to update filter for $($filter.label)."
    }
}

# Overwrite the existing XML file with the updated content
try {
    $xmlDoc.Save($worldmapFiltersPath)
    Write-Log "Filters updated successfully in $worldmapFiltersPath."
} catch {
    Handle-Error "Failed to save the updated WorldmapFilters.xml file."
}

# Log: Complete
Write-Log "Script finished successfully."

# Wait for user input before exiting
Read-Host "Press any key to exit"
