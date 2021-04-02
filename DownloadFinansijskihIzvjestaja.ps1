
# Deklarisanje niza kompanija
$companies = New-Object "System.Collections.Generic.Dictionary[[String], [String]]"
$companies.Add("03014215", "Coinis")
$companies.Add("02686473", "Domen")
$companies.Add("02775018", "CoreIT")
$companies.Add("02632284", "Logate")
$companies.Add("02783061", "Bild Studio")
$companies.Add("02907259", "Amplitudo")
$companies.Add("03073572", "Datum Solutions")
$companies.Add("02713098", "Poslovna Inteligencija")
$companies.Add("03037258", "International Bridge")
$companies.Add("02731517", "Fleka")
$companies.Add("02679744", "Datalab")
$companies.Add("03167453", "Omnitech")
$companies.Add("03131343", "SynergySuite")
$companies.Add("03122123", "Alicorn")
$companies.Add("03066258", "Codingo")
$companies.Add("03274357", "Uhura Solutions")
$companies.Add("02246244", "Winsoft")
$companies.Add("02177579", "Cikom")
$companies.Add("02961717", "Media Monkeys")
$companies.Add("03091627", "Codeus")
$companies.Add("03084434", "Digital Control")
$companies.Add("03165663", "Ridgemax")

# Formiranje CSV fajla za smjestanje rezultata
Set-Content -Path ".\Results.csv" -Value '"Company","Year","TotalIncome","Profit","EmployeeCount","NetPayCosts","AveragePay"'

# Definisanje header-a zbog provizornog ID-a sesije
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Cookie", "taxisSession=ir3pdvm0e20di2u4p2dfh4d4")

foreach ($company in $companies.GetEnumerator()) {
	Write-Host "`nPrikupljanje podataka za: $($company.Value) ($($company.Key))"

	# Pretraga pravnog lica po PIB-u na portalu ePrijava
	$pib = $company.Key
	$response = Invoke-RestMethod "https://eprijava.tax.gov.me/TaxisPortal/FinancialStatement/Grid?pib=$($pib)&naziv=&orderBy=naziv&skip=0&take=1" -Method 'POST' -Headers $headers
	$taxpayers = $response.TaxPayerRows

	# Pronadjena sljedeca pravna lica
	foreach ($taxpayer in $taxpayers) {
		Write-Host "Pronadjen: $($taxpayer.PIB) - $($taxpayer.Naziv)"
	}
	
	# Kreiranje pod-foldera za pravno lice
	New-Item -ItemType Directory -Force -Path ".\$($company.Value)\" | Out-Null

	# Detalji pravnog lica
	Write-Host "`nDownload detalja pravnog lica"
	$response = Invoke-RestMethod "https://eprijava.tax.gov.me/TaxisPortal/TaxPayerCompanies/Details?PIB=$($pib)" -Method 'POST' -Headers $headers
	Out-File -FilePath ".\$($company.Value)\$($pib).htm" -InputObject $response -Encoding UTF8

	# Pretraga liste finansijskih izvjestaja
	Write-Host "`nPretraga liste finansijskih izvjestaja"
	$response = Invoke-RestMethod "https://eprijava.tax.gov.me/TaxisPortal/FinancialStatement/TaxPayerStatementsList?PIB=$($pib)&take=20&skip=0&page=1&pageSize=20" -Method 'POST' -Headers $headers
	$finStatements = $response.data

	# Pronadjeni sljedeci finansijski izvjestaji
	Write-Host "Pronadjeno $($finStatements.length) finansijskih izvjestaja"
	# $finStatements

	# Download svakog pronadjenog finansijskog izvjestaja
	Write-Host "`nDownload finansijskih izvjestaja..."
	foreach ($finStatement in $finStatements) {
		$no = $finStatement.FinStatementNumber
		$year = $finStatement.Year
		Write-Host "Download izvjestaja br. $($no) za godinu $($year)"
		$response = Invoke-RestMethod "https://eprijava.tax.gov.me/TaxisPortal/FinancialStatement/Details?rbr=$($no)" -Method 'POST' -Headers $headers
		
		# Izvjestaji ce biti sacuvani u formatu: <PIB>-<GODINA>.htm
		Out-File -FilePath ".\$($company.Value)\$($pib)-$($year).htm" -InputObject $response -Encoding UTF8
		
		$content = [IO.File]::ReadAllText(".\$($company.Value)\$($pib)-$($year).htm")
		
		# Pretraga podatka: totalIncome
		$totalIncome = 0
		$pattern = '(?:(PRIHODI|Prihodi).+\r\n.+(201).+\r\n.+\r\n[^>]+>)(?<totalIncome>\d+)(?:</td>)'
		$result = [regex]::Matches($content, $pattern)
		if ($result -ne $null) {
			$totalIncome = $result[0].Groups['totalIncome'].Value -as [int]
		}
		
		# Pretraga podatka: profit
		$profit = 0
		$pattern = '(?:(Neto sveobuhvatni|NETO REZULTAT).+\r\n.+(260|232).+\r\n.+\r\n[^>]+>)(?<profit>\d+)(?:</td>)'
		$result = [regex]::Matches($content, $pattern)
		if ($result -ne $null) {
			$profit = $result[0].Groups['profit'].Value -as [int]
		}

		# Pretraga podatka: employeeCount
		$employeeCount = 0
		$pattern = '(?:(broj zaposlenih).+\r\n.+(001).+\r\n.+\r\n[^>]+>)(?<employeeCount>\d+)(?:</td>)'
		$result = [regex]::Matches($content, $pattern)
		if ($result -ne $null) {
			$employeeCount = $result[0].Groups['employeeCount'].Value -as [int]
		}
		
		# Pretraga podatka: netPayCosts i kalkulacija averagePay
		$netPayCosts = 0
		$averagePay = 0

		$pattern = '(?:(naknada zarada).+\r\n.+(212).+\r\n.+\r\n[^>]+>)(?<netPayCosts>\d+)(?:</td>)'
		$result = [regex]::Matches($content, $pattern)
		if ($result -ne $null) {
			$netPayCosts = $result[0].Groups['netPayCosts'].Value -as [int]
			$averagePay = $netPayCosts / $employeeCount / 12
		}
		
		# Upis rezultata u Results.csv fajl
		Add-Content -Path ".\Results.csv" -Value """$($company.Value)"", $($year), $($totalIncome), $($profit), $($employeeCount), $($netPayCosts), $($averagePay)"

	}
	
}

Write-Host "`nGotovo."
