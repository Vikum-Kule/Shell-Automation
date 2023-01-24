#get all the properties from the property file
$flashSalesProps = convertfrom-stringdata (get-content .\Properties\flashsales_property.txt -raw)

#define test cases as DAX queries
$test_cases = 'EVALUATE
ADDCOLUMNS (
  UNION(
	  ROW (
         "Test Name", "Net Flash Sales",
         "Expected Value", '+ $flashSalesProps.net_flash_sales +',
         "Actual Value",{ ROUND( [Net Flash Sales],2 ) }
    ),
    ROW (
         "Test Name", "Gross Flash Sales Value",
         "Expected Value", '+ $flashSalesProps.gross_flash_sales_value +',
         "Actual Value",{ [Gross Flash Sales Value] }
    ),	
    ROW (
         "Test Name", "Flash Orders Value",
         "Expected Value", '+ $flashSalesProps.flash_orders_value +',
         "Actual Value",{ [Flash Orders Value] }
    ),	
    ROW (
         "Test Name", "Flash Returns Value",
         "Expected Value", '+ $flashSalesProps.flash_returns_value +',
         "Actual Value",{ [Flash Returns Value] }
    ),	
    ROW (
         "Test Name", "Flash Returns Units",
         "Expected Value", '+ $flashSalesProps.flash_returns_units +',
         "Actual Value",{ [Flash Returns Units] }
    ),	
    ROW (
         "Test Name", "Total Flash Order Units",
         "Expected Value", '+ $flashSalesProps.total_flash_order_units +',
         "Actual Value",{ [Total Flash Order Units] }
    ),	
    ROW (
         "Test Name", "Total Flash Sales Units",
         "Expected Value", '+ $flashSalesProps.total_flash_sales_units +',
         "Actual Value",{ [Total Flash Sales Units] }
    ),	
    ROW (
         "Test Name", "Net Flash Sales Units",
         "Expected Value", '+ $flashSalesProps.net_flash_sales_units +',
         "Actual Value",{ [Net Flash Sales Units] }
    ),
    ROW (
         "Test Name", "LY Flash Sales",
         "Expected Value", '+ $flashSalesProps.ly_flash_sales +',
         "Actual Value",{ [LY Flash Sales] }
    ),	
    ROW (
         "Test Name", "TY Flash Sales",
         "Expected Value", '+ $flashSalesProps.ty_flash_sales +',
          "Actual Value",{ ROUND([TY Flash Sales],2) }
    ),	
    ROW (
         "Test Name", "LY Flash Sales Units",
         "Expected Value", '+ $flashSalesProps.ly_flash_sales_units +',
         "Actual Value",{ [LY Flash Sales Units] }
    ),	
    ROW (
         "Test Name", "TY Flash Sales Units",
         "Expected Value", '+ $flashSalesProps.ty_flash_sales_units +',
         "Actual Value",{ [TY Flash Sales Units] }
    ),	
    ROW (
         "Test Name", "LY Flash Margin Value",
         "Expected Value", '+ $flashSalesProps.ly_flash_margin_value +',
         "Actual Value",{ [LY Flash Margin Value] }
    ),	
    ROW (
         "Test Name", "LY Flash Cost Value",
         "Expected Value", '+ $flashSalesProps.ly_flash_cost_value +',
         "Actual Value",{ [LY Flash Cost Value] }
    ),	
    ROW (
         "Test Name", "TY Flash Margin Value",
         "Expected Value", '+ $flashSalesProps.ty_flash_margin_value +',
         "Actual Value",{ ROUND([TY Flash Margin Value],2) }
    ),	
    ROW (
         "Test Name", "TY Flash Cost Value",
         "Expected Value", '+ $flashSalesProps.ty_flash_cost_value +',
         "Actual Value",{ [TY Flash Cost Value] }
    ),
    ROW (
         "Test Name", "LY Flash Margin Percentage",
         "Expected Value", '+ $flashSalesProps.ly_flash_margin_percentage +',
         "Actual Value",{ [LY Flash Margin Percentage] }
    ),	
    ROW (
         "Test Name", "TY Flash Margin Percentage",
         "Expected Value", '+ $flashSalesProps.ty_flash_margin_percentage +',
         "Actual Value",{ [TY Flash Margin Percentage] }
    ),
    ROW (
         "Test Name", "Cumulative LY Flash Sales",
         "Expected Value", '+ $flashSalesProps.cumulative_ly_flash_Sales +',
         "Actual Value",{ [Cumulative LY Flash Sales] }
    ),
    ROW (
         "Test Name", "Cumulative TY Flash Sales",
         "Expected Value", '+ $flashSalesProps.cumulative_ty_flash_sales +',
         "Actual Value",{ ROUND([Cumulative TY Flash Sales],2) }
    )
  ),
  "Test Result", IF ( [Expected Value] <> [Actual Value], "Faild", "Pass" )
)'

Write-Output $test_cases

$deployment_params = Get-Content -Raw -Path "./Parameters.json" | Convertfrom-Json
$azure_bi_analysisserver_name =  $deployment_params.parameters.azure_bi_analysisserver_name.value

# connecting to the Azure analysis server Cahemanagement model and pass test casess
Invoke-ASCmd -Server $azure_bi_analysisserver_name -Database "FlashSales" -Query $test_cases | Out-File -FilePath .\Results\flashsales_result.xml
