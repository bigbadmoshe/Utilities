<#
	.SYNOPSIS
	Download videos from YoutTube via yt-dlp

	.EXAMPLE
	youtube-dl -URLs @()

	.NOTES
	Invoke "D:\yt-dlp.exe" --list-formats URL

	.NOTES
	--username $username
	--password $password
	--video-password $videopassword

	.LINKS
	https://github.com/yt-dlp/yt-dlp
	https://github.com/BtbN/FFmpeg-Builds
	https://github.com/denoland/deno

#>
function yt-dlp
{
	[CmdletBinding()]
	param
	(
		[string[]]
		$URLs
	)

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	
	if ($Host.Version.Major -eq 5)
	{
		# Progress bar can significantly impact cmdlet performance
		# https://github.com/PowerShell/PowerShell/issues/2138
		$Script:ProgressPreference = "SilentlyContinue"
	}

	# Get the latest yt-dl URL
	# https://github.com/yt-dlp/yt-dlp
	$Parameters = @{
		Uri              = "https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"
		UseBasicParsing  = $true
		Verbose          = $true
	}
	$LatestytdlpURL = ((Invoke-RestMethod @Parameters).assets | Where-Object -FilterScript {$_.name -eq "yt-dlp.exe"}).browser_download_url

	$DownloadsFolder = Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "{374DE290-123F-4565-9164-39C4925E467B}"
	if (-not (Test-Path -Path "$DownloadsFolder\yt-dlp.exe"))
	{
		$Parameters = @{
			Uri              = $LatestytdlpURL
			OutFile          = "$DownloadsFolder\yt-dlp.exe"
			UseBasicParsing  = $true
			Verbose          = $true
		}
		Invoke-WebRequest @Parameters
	}

	# Get the latest FFmpeg URL
	# https://github.com/BtbN/FFmpeg-Builds
	# "ffmpeg-*-win64-lgpl-[0-9].[0-9].zip"
	# gpl includes all dependencies, even those that require full GPL instead of just LGPL
	$Parameters = @{
		Uri              = "https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest"
		UseBasicParsing  = $true
		Verbose          = $true
	}
	$LatestFFmpegURL = ((Invoke-RestMethod @Parameters).assets | Where-Object -FilterScript {$_.name -eq "ffmpeg-master-latest-win64-lgpl.zip"}).browser_download_url

	if (-not (Test-Path -Path "$DownloadsFolder\ffmpeg.exe"))
	{
		$Parameters = @{
			Uri              = $LatestFFmpegURL
			OutFile          = "$DownloadsFolder\FFmpeg.zip"
			UseBasicParsing  = $true
			Verbose          = $true
		}
		Invoke-WebRequest @Parameters

		# Expand ffmpeg.exe from the ZIP archive
		Add-Type -Assembly System.IO.Compression.FileSystem

		$ZIP = [IO.Compression.ZipFile]::OpenRead("$DownloadsFolder\FFmpeg.zip")
		$Entries = $ZIP.Entries | Where-Object -FilterScript {$_.FullName -like "ffmpeg*/bin/ffmpeg.exe"}
		$Entries | ForEach-Object -Process {[IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$DownloadsFolder\ffmpeg.exe", $true)}
		$ZIP.Dispose()

		Remove-Item -Path "$DownloadsFolder\FFmpeg.zip" -Force
	}

	# Get the latest deno URL
	# https://github.com/yt-dlp/yt-dlp/wiki/EJS
	# https://github.com/denoland/deno
	$Parameters = @{
		Uri              = "https://api.github.com/repos/denoland/deno/releases/latest"
		UseBasicParsing  = $true
		Verbose          = $true
	}
	$LatestdenoURL = ((Invoke-RestMethod @Parameters).assets | Where-Object -FilterScript {$_.name -eq "deno-x86_64-pc-windows-msvc.zip"}).browser_download_url

	if (-not (Test-Path -Path "$DownloadsFolder\deno.exe"))
	{
		$Parameters = @{
			Uri              = $LatestdenoURL
			OutFile          = "$DownloadsFolder\deno.zip"
			UseBasicParsing  = $true
			Verbose          = $true
		}
		Invoke-WebRequest @Parameters

		$Parameters = @{
			Path            = "$DownloadsFolder\deno.zip"
			DestinationPath = "$DownloadsFolder"
			Force           = $true
		}
		Expand-Archive @Parameters

		Remove-Item -Path "$DownloadsFolder\deno.zip" -Force
	}


	$Title = "%(title)s.mp4"
	$n = 1

	foreach ($URL in $URLs)
	{
		# Getting URL's IDs
		& "$DownloadsFolder\yt-dlp.exe" --list-formats $URL
		$VideoID = Read-Host -Prompt "`nType prefered video ID"
		$AudioID = Read-Host -Prompt "`nType prefered audio ID"

		# 1. FileName.mp4
		$FileName = "{0}. {1}" -f $n++, $Title

		Start-Process -FilePath "$DownloadsFolder\yt-dlp.exe" -ArgumentList "--js-runtimes deno:`"$DownloadsFolder\deno.exe`" --output `"$DownloadsFolder\$FileName`" --format `"$($VideoID)+$($AudioID)`" $URL"
	}
}
yt-dlp -URLs @("https://www.youtube.com/watch?v=NxY5pItZbS4")
