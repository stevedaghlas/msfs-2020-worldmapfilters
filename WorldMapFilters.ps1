# Define possible locations for the UserCfg.opt file (Windows Store and Steam)
$steamCfgPath = "$env:APPDATA\Microsoft Flight Simulator\UserCfg.opt"
$windowsStoreCfgPath = "$env:LOCALAPPDATA\Packages\Microsoft.FlightSimulator_8wekyb3d8bbwe\LocalCache\UserCfg.opt"

# Debug: Output the paths being checked
Write-Host "Checking for UserCfg.opt in the following locations:"
Write-Host "Steam path: $steamCfgPath"
Write-Host "Windows Store path: $windowsStoreCfgPath"

# Check which version the user has and get the path to UserCfg.opt
if (Test-Path $steamCfgPath) {
    $userCfgPath = $steamCfgPath
    Write-Host "Found UserCfg.opt at: $steamCfgPath"
} elseif (Test-Path $windowsStoreCfgPath) {
    $userCfgPath = $windowsStoreCfgPath
    Write-Host "Found UserCfg.opt at: $windowsStoreCfgPath"
} else {
    Write-Host "Could not find the UserCfg.opt file. Please make sure MSFS 2020 is installed."
    Read-Host "Press any key to exit"
    exit
}

# Read the UserCfg.opt file to extract the InstalledPackagesPath
$installedPackagesPathLine = Select-String -Path $userCfgPath -Pattern 'InstalledPackagesPath'

# Extract the path without line numbers or extra information
if ($installedPackagesPathLine) {
    $installedPackagesPath = $installedPackagesPathLine -replace '.*?"([^"]+?)".*', '$1'
    $installedPackagesPath = $installedPackagesPath.Trim()
} else {
    Write-Host "Failed to find InstalledPackagesPath in $userCfgPath."
    Read-Host "Press any key to exit"
    exit
}

# Debug: Output the cleaned InstalledPackagesPath
if ($installedPackagesPath) {
    Write-Host "Found InstalledPackagesPath: $installedPackagesPath"
} else {
    Write-Host "Failed to find InstalledPackagesPath in $userCfgPath."
    Read-Host "Press any key to exit"
    exit
}

# Construct the path to WorldmapFilters.xml based on the InstalledPackagesPath
$worldmapFiltersPath = Join-Path $installedPackagesPath 'Official\OneStore\fs-base\worldmap\WorldmapFilters.xml'

# Debug: Output the constructed path to WorldmapFilters.xml
Write-Host "Looking for WorldmapFilters.xml at: $worldmapFiltersPath"

# Check if the WorldmapFilters.xml exists at the constructed path
if (-not (Test-Path $worldmapFiltersPath)) {
    Write-Host "Could not find WorldmapFilters.xml at $worldmapFiltersPath"
    Read-Host "Press any key to exit"
    exit
}

# Load the WorldmapFilters.xml file
[xml]$xmlDoc = Get-Content $worldmapFiltersPath
Write-Host "Loaded WorldmapFilters.xml successfully."

# Define the runway types to ask about
$runwayTypes = @(
    @{ id="RUNWAY_HARD"; label="Hard Runway" },
    @{ id="RUNWAY_GRASS"; label="Grass Runway" },
    @{ id="RUNWAY_WATER"; label="Water Runway" },
    @{ id="RUNWAY_SNOW"; label="Snow Runway" },
    @{ id="RUNWAY_SAND"; label="Sand Runway" },
    @{ id="RUNWAY_HELI"; label="Heli Runway" },
    @{ id="RUNWAY_OTHER"; label="Other Runway" }
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

# Loop through each runway type and ask the user
foreach ($runway in $runwayTypes) {
    $currentStatus = $xmlDoc.SelectSingleNode("//FilterDefinition[FilterID='$($runway.id)']/OnOff").'#text'
    $userInput = Get-UserInput "$($runway.label)" $currentStatus
    
    # Update the XML based on user input or retain the current value
    $newStatus = if ($userInput -eq "1") { "ON" } elseif ($userInput -eq "0") { "OFF" } else { $currentStatus }
    $xmlDoc.SelectSingleNode("//FilterDefinition[FilterID='$($runway.id)']/OnOff").'#text' = $newStatus
}

# Overwrite the existing XML file with the updated content
$xmlDoc.Save($worldmapFiltersPath)
Write-Host "Filters updated successfully in $worldmapFiltersPath"

# Wait for user input before exiting
Read-Host "Press any key to exit"
