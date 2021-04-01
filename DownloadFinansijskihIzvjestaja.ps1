# Definisanje header-a zbog provizornog ID-a sesije
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Cookie", "taxisSession=ir3pdvm0e20di2u4p2dfh4d4")

# Pretraga pravnog lica po PIB-u
$pib = "02347806" # npr. Azalea Maritime
Write-Host "Pretraga po PIB-u: $($pib)"
$response = Invoke-RestMethod "https://eprijava.tax.gov.me/TaxisPortal/FinancialStatement/Grid?pib=$($pib)&naziv=&orderBy=naziv&skip=0&take=1" -Method 'POST' -Headers $headers
$taxpayers = $response.TaxPayerRows

# Pronadjena sljedeca pravna lica
foreach ($taxpayer in $taxpayers) {
	Write-Host "Pronadjen: $($taxpayer.PIB) - $($taxpayer.Naziv)"
}

# Pretraga liste finansijskih izvjestaja
Write-Host "`nPretraga liste finansijskih izvjestaja:"
$response = Invoke-RestMethod "https://eprijava.tax.gov.me/TaxisPortal/FinancialStatement/TaxPayerStatementsList?PIB=$($pib)&take=20&skip=0&page=1&pageSize=20" -Method 'POST' -Headers $headers
$finStatements = $response.data

# Pronadjeni sljedeci finansijski izvjestaji
Write-Host "- Pronadjeno $($finStatements.length) finansijskih izvjestaja"

# Download svakog pronadjenog finansijskog izvjestaja
Write-Host "`nDownload finansijskih izvjestaja:"
foreach ($finStatement in $finStatements) {
	$no = $finStatement.FinStatementNumber
	$year = $finStatement.Year
	Write-Host "- Download izvjestaja br. $($no) za godinu $($year)"
	$response = Invoke-RestMethod "https://eprijava.tax.gov.me/TaxisPortal/FinancialStatement/Details?rbr=$($no)" -Method 'POST' -Headers $headers
	
	# Izvjestaji ce biti sacuvani u formatu: <PIB>-<GODINA>.htm
	Out-File -FilePath ".\$($pib)-$($year).htm" -InputObject $response -Encoding UTF8
}

Write-Host "`nGotovo."
