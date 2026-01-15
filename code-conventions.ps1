<#
.SYNOPSIS
    Dit script laat je tekst bestanden maken in een folder met een eigen gekozen bestandsnaam.

.DESCRIPTION
    Een CLI omgeving die je de optie geeft om bestanden aan te maken binnen een folder en deze te openen met je teksteditor.
    
#>

$FilesPath = ".\files\"

if (-not (Test-Path -Path ".\files")) {
    New-Item -Type Directory -Path ".\files"
}

function Add-ErrorToLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $ErrorException,

        [Parameter()]
        [string]$Message
    )

    <#
    .SYNOPSIS
        Deze functie regelt de error logging. Maakt het error.log bestand als deze niet aanwezig is.
        Heeft de optie om een error te laten zien.
    #>

    try {
        if (-not (Test-Path -ItemType Directory -Path ".\logs")) {
            New-Item -Type Directory -Path ".\logs"

            if (-not (Test-Path -Path ".\logs\error.log")) {
                New-Item -Path ".\logs\error.log"
            }
        }
    }
    catch {
        Write-Host "Fout tijdens het maken van het log bestand"
    }

    if ($Message) {
        Write-Error $Message
    }

    Add-Content -Path ".\logs\error.log" -Value $ErrorException.Exception.Message
}

function Exit-ActionsCLI {
    <#
    .SYNOPSIS
        Exit het script.
    #>

    Clear-Host
    exit
}

function New-File {
    <#
    .SYNOPSIS
        Vraag de gebruiker om een bestandsnaam, checkt of deze bestaat en maakt hem aan als dit niet zo is.
    #>
    Clear-Host

    $FileName = Read-Host "Hoe wil je het bestand noemen?"
    $FileExtension = "txt"
    $File = $FileName + "." + $FileExtension

    if (Test-Path -Path ($FilesPath + $File)) {
        Write-Host "Het bestand bestaat al, probeer het nog een keer."
        Start-Sleep -Seconds 2
        New-File
    }

    try {
        New-Item -Path $FilesPath -Name $File

        Write-Host "Bestand is successvol aangemaakt"
        Start-Sleep -Seconds 2
        Show-ActionsCLI
    }
    catch {
        Add-ErrorToLog -ErrorException $_ -Message "Kon het bestand niet aanmaken, probeer het nogmaals met een andere naam."
    }
}

function Open-File {
    <#
    .SYNOPSIS
        Haalt tekst bestanden op uit de files folder, Toont deze, gebruiker kiest een bestand en dit bestand opent als deze bestaat.
    #>
    Clear-Host

    $Files = Get-ChildItem -Path $FilesPath -Name -Include *.txt

    if ($Files.Count -eq 0) {
        Write-Host "Geen Bestanden gevonden"
    }

    foreach ($File in $Files) {
        Write-Host $File
    }

    $ChosenFile = Read-Host "Kies een bestand"

    if (Test-Path -Path ($FilesPath + $ChosenFile)) {
        Invoke-Item ($FilesPath + $ChosenFile)

        Show-ActionsCLI
    }
    else {
        Write-Host "Dit bestand bestaat niet, probeer nogmaals."

        Start-Sleep -Seconds 2
        Open-File
    }
}

class CLIAction {
    [string]$letter
    [string]$name
    $callback;
}

function Show-ActionsCLI {
    <#
    .SYNOPSIS
        Toont script acties, gebruiker kiest een actie, script voert functie gebonden aan de actie.
    #>
    Clear-Host

    $CLIFunctions = @(
        [CLIAction]@{
            letter   = "N";
            name     = "Nieuw Bestand";
            callback = "New-File"
        },
        [CLIAction]@{
            letter   = "O";
            name     = "Open Bestand";
            callback = "Open-File" 
        }
        [CLIAction]@{
            letter   = "X";
            name     = "Sluiten";
            callback = "Exit-ActionsCLI"
        }
    )

    foreach ($CLIFunction in $CLIFunctions) {
        Write-Host "$($CLIFunction.letter)) $($CLIFunction.name)"
    }

    $Choice = Read-Host "Select an option"

    if (-not $Choice) {
        Write-Host "Ongeldige keuze, probeer nogmaals."
        Start-Sleep -Seconds 2

        Show-ActionsCLI
    }

    $Choice.ToUpper()
    if ($CLIFunctions.letter -contains $Choice) {
        try {
            foreach ($CLIFunction in $CLIFunctions) {
                if ($CLIFunction.letter -eq $Choice) {
                    Invoke-Expression $CLIFunction.callback
                }
            }
        }
        catch {
            Add-ErrorToLog -ErrorException $_
        }
    }
    else {
        Write-Host "Ongeldige keuze, probeer nogmaals."
        Start-Sleep -Seconds 2

        Show-ActionsCLI
    }
}

Show-ActionsCLI