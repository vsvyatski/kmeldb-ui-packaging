<#
	.SYNOPSIS
		PPA publishing script that runs on Windows

	.DESCRIPTION
		This file is needed if you want to build the source package from Windows by the means
		of Docker.

    .INPUTS
        None

    .OUTPUTS
        None
#>
param(
	# A series to build the source package for: Xenial, Bionic, Eoan or Focal
	[ValidateSet('Xenial', 'Bionic', 'Eoan', 'Focal')]
	[string]$Series = 'Focal',

	# Do not upload to Launchpad
	[switch]$NoUpload
)

$dockerTmpDir = "$PSScriptRoot\out\docker-tmp"

if (-not (Test-Path -PathType Container $dockerTmpDir)) { New-Item -ItemType Directory $dockerTmpDir > $null }
if (-not (Test-Path -PathType Container "$dockerTmpDir\gnupg")) {
	xcopy "$env:USERPROFILE\.gnupg" "$dockerTmpDir\gnupg" /E /I /Q
}

Push-Location "$PSScriptRoot"

$env:SERIES = $Series.ToLower()

docker-compose build --build-arg USER_ID=1000 --build-arg GROUP_ID=1000 source_package
if ($NoUpload.IsPresent) {
	docker-compose run source_package
}
else {
	docker-compose run -e UPLOAD=true source_package
}

Pop-Location
