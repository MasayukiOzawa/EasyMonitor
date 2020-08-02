param($Timer)

# Wait-Debugger
Write-Host "Function Start"

if (-not (Get-Module -ListAvailable powershell-yaml)) {
    throw "powershell-yaml is not installed."
}

$yamlCollections = Get-ChildItem ".\conf.d\*.yaml"

try {
    $con = New-Object System.Data.SqlClient.SqlConnection($ENV:SQL_CONNECTION_STRING)
    if ($env:CLIENT_ID) {
        $resourceURI = "https://database.windows.net/"
        $tokenAuthURI = $env:MSI_ENDPOINT + "?resource=$resourceURI&api-version=2017-09-01&clientid=$env:CLIENT_ID"
        $tokenResponse = Invoke-RestMethod -Method Get -Headers @{"Secret" = "$env:MSI_SECRET" } -Uri $tokenAuthURI
        $accessToken = $tokenResponse.access_token
        $con.AccessToken = $accessToken
    }
    $con.Open()

    $yamlCollections | ForEach-Object -ThrottleLimit $ENV:MAX_THREAD -Parallel {
        $yaml = (Get-Content $PSItem.FullName) | ConvertFrom-Yaml
        $sql = $yaml.monitor_sql
        $logType = $yaml.metrics_name

        $cmd = ($using:con).CreateCommand()
        $cmd.CommandText = $sql

        $dt = New-Object System.Data.DataTable
        $sql = $yaml.monitor_sql
    
        $reader = $cmd.ExecuteReader()
        $dt.Load($reader)
        $reader.Close()
        $reader.Dispose()
        $cmd.Dispose()
    
        if ($dt.Rows.Count -gt 0) {
            $json = $dt.rows | Select-Object -ExcludeProperty @("RowError", "RowState", "Table", "ItemArray", "HasErrors") | Convertto-Json
            $response = Post-LogAnalyticsData -customerId $ENV:LAW_WORKSPACEID -sharedKey $ENV:LAW_SHAREDKEY -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType 
            if ($response -ne 200) {
                throw "Request response was an error."
            }
            else {
                Write-Host ("{0} metrics collection successful." -f $yaml.metrics_name)

            }
        }
    }
}
catch {
    Write-Error $PSItem.Exception
    throw $PSItem.Exception
}
finally {
    $con.Close()
    $con.Dispose()
}