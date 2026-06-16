param(
    [Parameter(Mandatory = $true)]
    [string]$ImagePath,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$Gender,

    [switch]$Commit,
    [switch]$Push
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedImage = Resolve-Path -LiteralPath $ImagePath
$male = [string][char]0x7537
$female = [string][char]0x5973

if (($Gender -ne $male) -and ($Gender -ne $female)) {
    throw "Gender must be male or female in Chinese."
}

function Get-MaxSuffix {
    param(
        [string]$Prefix,
        [string]$Extension
    )

    $pattern = '^{0}_(\d+)\.{1}$' -f [regex]::Escape($Prefix), [regex]::Escape($Extension)
    $items = Get-ChildItem -LiteralPath $root -File | ForEach-Object {
        if ($_.Name -match $pattern) {
            [int]$Matches[1]
        }
    }

    if (-not $items) {
        throw "No files found matching $Prefix`_xx.$Extension"
    }

    ($items | Measure-Object -Maximum).Maximum
}

function Format-CertDate {
    param([datetime]$Date)

    $yearChar = [string][char]0x5E74
    $monthChar = [string][char]0x6708
    $dayChar = [string][char]0x65E5

    return ("{0:yyyy}" + $yearChar + "{0:MM}" + $monthChar + "{0:dd}" + $dayChar) -f $Date
}

$latestTou = Get-MaxSuffix -Prefix "Tou" -Extension "png"
$latestCert = Get-MaxSuffix -Prefix "Cert" -Extension "html"
$nextTou = $latestTou + 1
$nextCert = $latestCert + 1

if ($nextTou -ne $nextCert) {
    throw "Next Tou number ($nextTou) and next Cert number ($nextCert) differ. Please reconcile existing files first."
}

$next = $nextCert
$sourceCert = Join-Path $root ("Cert_{0}.html" -f $latestCert)
$targetCert = Join-Path $root ("Cert_{0}.html" -f $next)
$targetTou = Join-Path $root ("Tou_{0}.png" -f $next)

if (Test-Path -LiteralPath $targetCert) {
    throw "Target HTML already exists: $targetCert"
}

if (Test-Path -LiteralPath $targetTou) {
    throw "Target image already exists: $targetTou"
}

Copy-Item -LiteralPath $resolvedImage -Destination $targetTou
Copy-Item -LiteralPath $sourceCert -Destination $targetCert

$html = Get-Content -Raw -Encoding UTF8 -LiteralPath $targetCert
$numberMatch = [regex]::Match($html, "Number:\s*'(\d+)'")
if (-not $numberMatch.Success) {
    throw "Could not find Number in $sourceCert"
}

$nextNumber = ([int64]$numberMatch.Groups[1].Value) + 1
$certDate = Format-CertDate ((Get-Date).Date.AddDays(-7))

$html = [regex]::Replace($html, "NumberID:\s*'\d+'", "NumberID: '$next'")
$html = [regex]::Replace($html, "Name:\s*'[^']*'", "Name: '$Name'")
$html = [regex]::Replace($html, "Gender:\s*'[^']*'", "Gender: '$Gender'")
$html = [regex]::Replace($html, "Number:\s*'\d+'", "Number: '$nextNumber'")
$html = [regex]::Replace($html, "Date:\s*'[^']*'", "Date: '$certDate'")

Set-Content -Encoding UTF8 -LiteralPath $targetCert -Value $html

Write-Host "Created Tou_$next.png"
Write-Host "Created Cert_$next.html"
Write-Host "NumberID: $next"
Write-Host "Name: $Name"
Write-Host "Gender: $Gender"
Write-Host "Number: $nextNumber"
Write-Host "Date: $certDate"

if ($Commit -or $Push) {
    git -C $root add .
    git -C $root commit -m "Add certificate $next for $Name"
}

if ($Push) {
    git -C $root push
}
