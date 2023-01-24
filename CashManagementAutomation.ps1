#Read line by line from property file.
$cashManagementProps = convertfrom-stringdata (get-content .\Properties\cashmanagement_property.txt -raw)


#define test cases as DAX queries
$test_cases = 'EVALUATE
 ADDCOLUMNS (
   UNION(
	ROW (
           "Test Name", "Total Expected Value",
             "Expected Value",'+ $cashManagementProps.total_expected_val+'
 ,
             "Actual Value",{ [TotalExpectedVal] }
         ),	
     ROW (
           "Test Name", "Total Counted Value",
             "Expected Value",'+ $cashManagementProps.total_counted_val+'
 ,
             "Actual Value",{ [TotalCountedVal] }
         )
)
,
      "Test Result", IF ( [Expected Value] <> [Actual Value], "Faild", "Pass" )
  )'

# Write-Output $test

$deployment_params = Get-Content -Raw -Path "./Parameters.json" | Convertfrom-Json
$azure_bi_analysisserver_name =  $deployment_params.parameters.azure_bi_analysisserver_name.value

# connecting to the Azure analysis server Cahemanagement model and pass test casess
Invoke-ASCmd -Server $azure_bi_analysisserver_name -Database "CashManagement" -Query $test_cases | Out-File -FilePath .\Results\cashmanagement_result.xml

