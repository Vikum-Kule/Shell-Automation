#Read line by line from property file
$inventoryManagementProps = convertfrom-stringdata (get-content .\Properties\inventory_property.txt -raw)

#define test cases as DAX queries
$test_cases = 'EVALUATE
ADDCOLUMNS (
    UNION (
    
//    test 1
        ROW (
          "Test Name", "Net Sales Total",
            "Expected Value", '+ $inventoryManagementProps.net_sales_total +',
            "Actual Value", {[Net Sales]}
        ),
//    test 2
        ROW (
            "Test Name", " Last Year Net Sales Total",
            "Expected Value", '+ $inventoryManagementProps.last_year_net_sales_total +',
            "Actual Value", {[LY Net Sales]}
        ),
//    test 3
        ROW (
            "Test Name", " Total Inventory Units",
            "Expected Value", '+ $inventoryManagementProps.total_inventory_units +',
            "Actual Value", {[Total Inventory Units]}
        ),
//    test 4
        ROW (
            "Test Name", " Total Inventory Cost",
            "Expected Value", '+ $inventoryManagementProps.total_inventory_cost +',
            "Actual Value", ROUNDUP   ( {[Total Inventory Cost]},  2 )
        ),
//    test 5
        ROW (
            "Test Name", " Cumulative Total Products",
            "Expected Value", '+ $inventoryManagementProps.cumulative_total_products +',
            "Actual Value", {[Cumulative Total-Products]}
        ),
//    test 6
        ROW (
            "Test Name", " Number Of Stock Outs",
            "Expected Value", '+ $inventoryManagementProps.number_of_stock_outs +',
            "Actual Value", {[#OutOfStock]}
        )
    ),
    "Test Result", IF ( [Expected Value] <> [Actual Value], "Faild", "Pass" )
)'

Write-Output $test_cases

$deployment_params = Get-Content -Raw -Path "./Parameters.json" | Convertfrom-Json
$azure_bi_analysisserver_name =  $deployment_params.parameters.azure_bi_analysisserver_name.value

# connecting to the Azure analysis server EnactorretailSales model and pass test casess
Invoke-ASCmd -Server $azure_bi_analysisserver_name -Database "EnactorRetailSales" -Query $test_cases | Out-File -FilePath .\Results\inventory_result.xml

