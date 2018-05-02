Trace-VstsEnteringInvocation $MyInvocation	

try {
    $path = Get-VstsInput -Name FilePath -Require
	$variable = Get-VstsInput -Name VariableName -Require
	$newlines = Get-VstsInput -Name AddNewlines -Require

	Write-Host "Setting '$variable' to content of the file '$path'."

	$fileContent = ""
	if($newlines -eq $true){
		Write-Host "Adding newline characters to the file."
		$fileString = Get-Content $path

		For ($i=0; $i -le $fileString.Length; $i++) {
			$fileContent += $fileString[$i]

			if($i + 1 -lt $fileString.Length){
				$fileContent += "\n"
			}
		}
	}else{
		$fileContent = Get-Content $path -Raw
	}

	Write-Host "##vso[task.setvariable variable=$($variable);]$fileContent"
	Write-Host $fileContent
}
finally 
{
    Trace-VstsLeavingInvocation $MyInvocation
}