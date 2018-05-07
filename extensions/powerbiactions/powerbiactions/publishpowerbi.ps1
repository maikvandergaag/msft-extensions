Write-Host "Publishing PowerBI FIle: $filePattern, in group: $groupName with user: $userName"

$searchedFiles = Get-ChildItem $filePattern
foreach($foundFile in $searchedFiles){
	$directory = $foundFile.DirectoryName
	$file = $foundFile.Name

	$filePath = "$directory\$file"
	Write-Host "Trying to publish PowerBI File: $filePath"

	#Check for exisiting report
	$fileNamewithoutextension = [IO.Path]::GetFileNameWithoutExtension($filePath)
	Write-Host "Checking for existing Reports with the name: $fileNamewithoutextension"

	$report = Get-PowerBiReport -GroupPath $groupsPath -AccessToken $token -ReportName $fileNamewithoutextension -Verbose
 
	$nameConflict = "Abort"
	if($report){
		Write-Verbose "Reports exisits"
		if($overwrite){
			Write-Verbose "Reports exisits and needs to be overwritten"
			$nameConflict = "Overwrite"
		}
	}

	Write-Verbose $groupsPath
	Write-Verbose $token
	Write-Verbose $filePath
	Write-Verbose $nameConflict

	#Import PowerBi file
	Write-Host "Importing PowerBI File"
	Import-PowerBiFile -GroupPath $groupsPath -AccessToken $token -Path $filePath -Conflict $nameConflict -Verbose
}

