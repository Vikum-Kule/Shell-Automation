#get all the properties from the property file
$SPExceptionProps = convertfrom-stringdata (get-content .\Properties\salesperson_exception_property.txt -raw)

#define test cases as DAX queries
$test_cases = 'EVALUATE
ADDCOLUMNS (
  UNION(
	  ROW (
         "Test Name", "Net Sales",
         "Expected Value", '+ $SPExceptionProps.net_sales +',
         "Actual Value",{ ROUND( [Net Sales],2 ) }
    ),
    ROW (
         "Test Name", "Transaction Count",
         "Expected Value", '+ $SPExceptionProps.transaction_count +',
         "Actual Value",{ [Transaction Count] }
    ),	
    ROW (
         "Test Name", "Returns Units (+)",
         "Expected Value", '+ $SPExceptionProps.returns_units +',
         "Actual Value",{ [Returns Units (+)] }
    ),	
    ROW (
         "Test Name", "Returns Value (+)",
         "Expected Value", '+ $SPExceptionProps.returns_value +',
         "Actual Value",{ [Returns Value (+)] }
    ),	
    ROW (
         "Test Name", "Total Discounts",
         "Expected Value", '+ $SPExceptionProps.total_discounts +',
         "Actual Value",{ [Total Discounts] }
    ),	
    ROW (
         "Test Name", "Total Price Overrides",
         "Expected Value", '+ $SPExceptionProps.total_price_overrides +',
         "Actual Value",{ [Total PriceOverrides] }
    ),	
    ROW (
         "Test Name", "Total Return Values within x% of auth threshold",
         "Expected Value", '+ $SPExceptionProps.total_return_values_within_auth_threshold +',
         "Actual Value",{ ROUND([Total Return Values within x% of auth threshold],2) }
    ),	
    ROW (
         "Test Name", "Transaction Count (Returns Within AT)",
         "Expected Value", '+ $SPExceptionProps.transaction_count_returns_within_auth_threshold +',
         "Actual Value",{ [Transaction Count (Returns Within AT)] }
    ),
    ROW (
         "Test Name", "Total Voided Transaction Count",
         "Expected Value", '+ $SPExceptionProps.total_voided_transaction_count +',
         "Actual Value",{ [Total Voided Tr Count] }
    ),	
    ROW (
         "Test Name", "Total Voided Values",
         "Expected Value", '+ $SPExceptionProps.total_voided_values +',
          "Actual Value",{ ROUND([Total VoidedValues],2) }
    )
  ),
  "Test Result", IF ( [Expected Value] <> [Actual Value], "Faild", "Pass" )
)'

Write-Output $test_cases

# connecting to the Azure analysis server Cahemanagement model and pass test casess
Invoke-ASCmd -Server "asazure://uksouth.asazure.windows.net/prevalas001" -Database "EnactorRetailSales" -Query $test_cases | Out-File -FilePath .\Results\salesperson_exception_result.xml
