Import-Module Get-ChildItemColor
$env:PATH="${env:HOME}/.local/bin/:${env:PATH}"
$hostname = [Environment]::MachineName
$env:GPG_TTY=$(tty)
function Prompt {"${env:USER}@${hostname} $(Get-Location)$ "}

<#
.SYNOPSIS
	Backup a page to your local ArchiveBox archive 

.EXAMPLE
	Backup-PageToArchive -Url https://example.org 
 
.EXAMPLE
	Backup-PageToArchive -Url https://example.org -Directory /home/example/my-archive

.LINK
	https://archivebox.io/

#>
function Backup-PageToArchive {
	param(
	# The URL of the page to backup
	[Parameter(Mandatory=$true)]
	[String[]]
	$Url,
	# The Directory the archive is placed in
	[String]$Directory = '/home/alc/site-history'
	)
	# Backup the page to the archive
	$env:OUTPUT_DIR = $Directory
	$env:TIMEOUT = "240"
	$archive = "${env:HOME}/git/github/ab/ArchiveBox/archive"

	Write-Output -Message $Url | python $archive
}

<#
.SYNOPSIS
	Start an apache container to access your archive.
 
.DESCRIPTION
	Start an apache container to access your archive.
	
	The container defaults are as follows:
	
	- Host Port: 8080
	- Name: web-archive
 
.EXAMPLE
	Start-Archive -Directory /home/example/my-archive

.EXAMPLE
	Start-Archive -Directory /home/example/my-archive -Name MyArchive -Port 8081	
 
.LINK
	https://podman.io/
.LINK
	https://hub.docker.com/_/httpd
.LINK
	https://archivebox.io/

#>
function Start-Archive {
	param(
		# The directory the archive is in
		[Parameter(Mandatory=$true)]
		[String]$Directory,
		# A name for the container
		[String]$Name = 'web-archive',
		# The port the container binds to on the host.
		[Int]$Port = 8080
	)
	podman run --rm `
	--name ${Name} `
	-p ${Port}:443 `
	-v ${Directory}:/usr/local/apache2/htdocs/:z `
	-v ${env:HOME}/.config/archive-container/httpd.conf:/usr/local/apache2/conf/httpd.conf:z `
	-v ${env:HOME}/.config/archive-container/server.key:/usr/local/apache2/conf/server.key:z `
	-v ${env:HOME}/.config/archive-container/server.crt:/usr/local/apache2/conf/server.crt:z `
	-d httpd:latest
}

<#
.SYNOPSIS
	Stops the nginx container serving the archive.

.DESCRIPTION
	Stops the nginx container serving the archive.

	By default, it will stop a container with the name 'web-archive'
 
.EXAMPLE
	Stop-Archive -Name tech-archive
 
.LINK
	https://podman.io/

.LINK
	https://hub.docker.com/_/nginx
#>
function Stop-Archive {
	param(
		#Can be a container name, or container ID
		[string[]]$Name = 'web-archive'
	)
	podman stop $Name
}
