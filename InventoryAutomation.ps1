#Read line by line from property file


foreach($line in [System.IO.File]::ReadLines(".\Properties\inventory_property.txt"))
{
	#get total net sales value 
      if ($line.Contains("(1)Net_Sales_Total")) {
		$position = $line.IndexOf(":")      
		$netSalesTotal = $line.Substring($position+1)
		Write-Output $netSalesTotal
	}
	#get total last year net sales value
	elseif ($line.Contains("(2)Last_Year_Net_Sales_Total")) {
      	$position = $line.IndexOf(":")      
		$LYnetSalesTotal = $line.Substring($position+1)
		Write-Output $LYnetSalesTotal
	}
  #get total Inventoy Units
	elseif ($line.Contains("(3)Total_Inventory_Units")) {
      	$position = $line.IndexOf(":")      
		$totalInvUnits = $line.Substring($position+1)
		Write-Output $totalInvUnits
	}
  #get total Inventory Cost
	elseif ($line.Contains("(4)Total_Inventory_Cost")) {
      	$position = $line.IndexOf(":")      
		$totalInvCost = $line.Substring($position+1)
		Write-Output $totalInvCost
	}
  #get Cumulative total products
	elseif ($line.Contains("(5)Cumulative_Total_Products")) {
      	$position = $line.IndexOf(":")      
		$cumulativeTotalProducts = $line.Substring($position+1)
		Write-Output $cumulativeTotalProducts
	}
  #get Cumulative total products
	elseif ($line.Contains("(6)Number_Of_Stock_Outs")) {
      	$position = $line.IndexOf(":")      
		$numberOfStockOut = $line.Substring($position+1)
		Write-Output $numberOfStockOut
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
//    test 2
        ROW (
            "Test Name", " Last Year Net Sales Total",
            "Expected Value", '+ $LYnetSalesTotal +',
            "Actual Value", {[LY Net Sales]}
        ),
//    test 3
        ROW (
            "Test Name", " Total Inventory Units",
            "Expected Value", '+ $totalInvUnits +',
            "Actual Value", {[Total Inventory Units]}
        ),
//    test 4
        ROW (
            "Test Name", " Total Inventory Cost",
            "Expected Value", '+ $totalInvCost +',
            "Actual Value", ROUNDUP   ( {[Total Inventory Cost]},  2 )
        ),
//    test 5
        ROW (
            "Test Name", " Cumulative Total Products",
            "Expected Value", '+ $cumulativeTotalProducts +',
            "Actual Value", {[Cumulative Total-Products]}
        ),
//    test 6
        ROW (
            "Test Name", " Number Of Stock Outs",
            "Expected Value", '+ $numberOfStockOut +',
            "Actual Value", {[#OutOfStock]}
        )
    ),
    "Test Result", IF ( [Expected Value] <> [Actual Value], "Faild", "Pass" )
)'

Write-Output $test_cases


# connecting to the Azure analysis server EnactorretailSales model and pass test casess
Invoke-ASCmd -Server "asazure://uksouth.asazure.windows.net/prevalas001" -Database "EnactorRetailSales" -Query $test_cases | Out-File -FilePath .\Results\inventory_result.xml

