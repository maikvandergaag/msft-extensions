Write-Host "Publishing PowerBI FIle: $filePattern, in group: $groupName with user: $userName"

#AADToken
Write-Host "Getting AAD Token for user: $userName"
$token = Get-AADToken -username $userName -Password $passWord -clientId $clientId -resource $resourceUrl -Verbose

#Current groups
Write-Host "Getting PowerBI group properties; $groupName"
$group = Get-PowerBiGroup -GroupName $groupName -AccessToken $token -Verbose

$searchedFiles = Get-ChildItem $filePattern
foreach($foundFile in $searchedFiles){
	$directory = $foundFile.DirectoryName
	$file = $foundFile.Name

	$filePath = "$directory\$file"
	Write-Host "Trying to publish PowerBI File: $filePath"

	#Check for exisiting report
	$fileNamewithoutextension = [IO.Path]::GetFileNameWithoutExtension($filePath)
	Write-Host "Checking for existing Reports with the name: $fileNamewithoutextension"

	$report = Get-PowerBiReport -GroupId $group.id -AccessToken $token -ReportName $fileNamewithoutextension -Verbose

	$nameConflict = "Abort"
	if($report){
		Write-Verbose "Reports exisits"
		if($overwrite){
			Write-Verbose "Reports exisits and needs to be overwritten"
			$nameConflict = "Overwrite"
		}
	}

	Write-Verbose $group.id
	Write-Verbose $token
	Write-Verbose $filePath
	Write-Verbose $nameConflict

	#Import PowerBi file
	Write-Host "Importing PowerBI File"
	Import-PowerBiFile -GroupId $group.id -AccessToken $token -Path $filePath -Conflict $nameConflict -Verbose
}

