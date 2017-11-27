<#
.SYNOPSIS
Test file hashes.

.DESCRIPTION
Test file hashes.

.PARAMETER File
The file containing the hashes.

.NOTES
	File Name  : Test-FileHash.ps1
	Author     : c4539  
	Requires   : PowerShell V4

.LINK
https://github.com/c4539/pshashsum

#>

#Requires -Version 4

[CmdletBinding(PositionalBinding=$false)]

param(
	[ValidateScript({Test-Path -PathType Leaf -Path $_ })]
	[Parameter(Mandatory=$true,Position=1)]
	[String]
	$File
)

# Get files
$Lines = Get-Content -Path $File

# Get working directory
$Directory = (Get-Item $File).Directory.FullName

# Get algorithm from filename
$Algorithm = (Get-Item $File).Extension.Substring(1).ToUpper()

# Init progress bar
$ProgressBarCount = 0;
$ProgressBarTotal = $Lines.Length

# Go through all files
$Lines | ForEach-Object {
    $Line = $_
    $Hash,$Filename = $Line -Split "  "
    $FileFullname = [System.IO.Path]::Combine($Directory, $Filename)
    
    # Write progress
	Write-Progress -Activity "Testing file hash" -Status "Processing $Filename" -PercentComplete ([int] (($ProgressBarCount++/$ProgressBarTotal)*100))
    
    Write-Host -Object ($Filename + ": ") -NoNewline
    
    if (-not (Test-Path -PathType Leaf -Path $FileFullname)) {
        Write-Host -Object "File not found" -ForegroundColor Red
    } else {
        # Hash file
        $RealHash = Get-FileHash -Path $FileFullname -Algorithm $Algorithm

        if ($RealHash.Hash -eq $Hash) {
            Write-Host -Object "Hash matches" -ForegroundColor Green
        } else {
            Write-Host -Object "Hash does not match" -ForegroundColor Red
        }
    }
}