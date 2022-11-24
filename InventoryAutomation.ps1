#Read line by line from property file


foreach($line in [System.IO.File]::ReadLines(".\Properties\inventory_property.txt"))
{
	#get total expected value 
  Write-Output $line
      if ($line.Contains("(1)Net_Sales_Total")) {
		$position = $line.IndexOf(":")      
		$netSalesTotal = $line.Substring($position+1)
		Write-Output $netSalesTotal
	}
	#get total counted value
	elseif ($line.Contains("(2)Last_Year_Net_Sales")) {
      	$position = $line.IndexOf(":")      
		$LYnetSalesTotal = $line.Substring($position+1)
		Write-Output $LYnetSalesTotal
	}
}


#define test cases as DAX queries
$test_cases = 'EVALUATE
ADDCOLUMNS (
    UNION (
    
//    test 1
        ROW (
          "Test Name", "Net Sales Total",
            "Expected Value", '+ $netSalesTotal +',
            "Actual Value", {[Net Sales]}
        ),
//    test 1
        ROW (
            "Test Name", " Last Year Net Sales Total",
            "Expected Value", '+ $LYnetSalesTotal +',
            "Actual Value", {[LY Net Sales]}
        )
    ),
    "Test Result", IF ( [Expected Value] <> [Actual Value], "Faild", "Pass" )
)'

Write-Output $test_cases


# connecting to the Azure analysis server Cahemanagement model and pass test casess
Invoke-ASCmd -Server "asazure://uksouth.asazure.windows.net/prevalas001" -Database "EnactorRetailSales" -Query $test_cases | Out-File -FilePath .\Results\inventory_result.xml

