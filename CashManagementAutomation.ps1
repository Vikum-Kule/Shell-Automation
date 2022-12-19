#Read line by line from property file
foreach($line in [System.IO.File]::ReadLines(".\Properties\cashmanagement_property.txt"))
{
	#get total expected value 
      if ($line.Contains("(1)Total Expected val")) {
		$position = $line.IndexOf(":")      
		$totalExpectedVal = $line.Substring($position+1)
		Write-Output $totalExpectedVal
	}
	#get total counted value
	elseif ($line.Contains("(2)Total Counted val")) {
      	$position = $line.IndexOf(":")      
		$totalCountedVal = $line.Substring($position+1)
		Write-Output $totalCountedVal
	}
}

#define test cases as DAX queries
$test_cases = 'EVALUATE
 ADDCOLUMNS (
   UNION(
	ROW (
           "Test Name", "Total Expected Value",
             "Expected Value",'+ $totalExpectedVal+'
 ,
             "Actual Value",{ [TotalExpectedVal] }
         ),	
     ROW (
           "Test Name", "Total Counted Value",
             "Expected Value",'+ $totalCountedVal+'
 ,
             "Actual Value",{ [TotalCountedVal] }
         )
)
,
      "Test Result", IF ( [Expected Value] <> [Actual Value], "Faild", "Pass" )
  )'

# Write-Output $test


# connecting to the Azure analysis server Cahemanagement model and pass test casess
Invoke-ASCmd -Server "asazure://uksouth.asazure.windows.net/prevalas001" -Database "CashManagement" -Query $test_cases | Out-File -FilePath .\Results\cashmanagement_result.xml

