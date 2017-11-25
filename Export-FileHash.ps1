<#
.SYNOPSIS
Exports file hashes.

.DESCRIPTION
Exports file hashes.

.PARAMETER Files
An array of files to be hashed.

.PARAMETER Algorithm
The hash algorithm do be used.
Default is SHA256.

.PARAMETER Force
Force the script to overwrite the output file.

.EXAMPLE


.NOTES
	File Name  : Export-FileHash.ps1
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
	[String[]]
	$Files
,
	[String]
    [ValidateSet("MD5","SHA1","SHA256","SHA384","SHA512")]
    [Parameter(Position=2)]
	$Algorithm = "SHA256"
    ,
    [String]
    $OutFile = $null
,
	[Switch]
	$Force=$false
)

# Get files
$Files | ForEach-Object {
    $FileList += Get-ChildItem -Path $_ -File
}

# Init progress bar
$ProgressBarCount = 0;
$ProgressBarTotal = $FileList.Length

# Go through all files
$FileList | ForEach-Object {
    $File = $_
    $Filename = $File.Name
    if ($OutFile -eq $null) {
        $HashFilename = $File.FullName + "." + $Algorithm.ToLower()
    } else {
        if ($OutFile.EndsWith("." + $Algorithm.ToLower())) {
            $HashFilename = [System.IO.Path]::Combine($File.Directory.FullName, $OutFile)
        } else {
            $HashFilename = [System.IO.Path]::Combine($File.Directory.FullName, $OutFile) + "." + $Algorithm.ToLower()
        }
    }
    
    # Write progress
	Write-Progress -Activity "Exprting file hashes" -Status "Processing $Filename" -PercentComplete ([int] (($ProgressBarCount++/$ProgressBarTotal)*100))
    
    # Hash file
    $Hash = Get-FileHash -Path $_ -Algorithm $Algorithm

    # Write hash to file
    ("" + $Hash.Hash + "  " + $Filename) | Out-File -FilePath $HashFilename -Append:($OutFile -ne $null) -Force:$Force
}