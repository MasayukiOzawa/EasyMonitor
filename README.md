# EZMonitor
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMasayukiOzawa%2FEzMonitor%2Fmaster%2FDeployments%2Fazuredeploy.json" target="_blank">
  <img src="https://aka.ms/deploytoazurebutton" />
</a>

EZMonitor (Easy Monitor) は、Azure Functions と Log Analytics を使用した、SQL Database のメトリクス収集機能です。  
Deploy to Azure から ARM Template による展開を行うことで、メトリクスの可視化を行う Workbook も含めてデプロイが行われます。。

 <img src="./img/workbook.png" />

## 展開方法
1. Deploy to Azure から ARM テンプレートの展開を行います。  
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMasayukiOzawa%2FEzMonitor%2Fmaster%2FDeployments%2Fazuredeploy.json" target="_blank">
  <img src="https://aka.ms/deploytoazurebutton" />
</a>
1. 必要な情報を入力し、展開を行います。  
  - Sql Server Name :  情報取得対象の SQL Database 名 (ex : contoso.database.windows.net)  
  (SQL Database に接続する場合は、database.windows.net まで指定してください) 
  - Database Name : 取得対象の DB 名
  - Database Login : SQL Database の接続ログイン  
    Premium / Business Critical を使用している場合は、対象 DB に対して、次のクエリを実行することでログインを作成することができます。  
    それ以外のサービスレベルについては、必要となる権限を付与できないため、SQL Database の管理者での接続が必要となります。
    ```
    CREATE USER <ログイン名> WITH PASSWORD='<パスワード>'
    GRANT VIEW DATABASE STATE TO <ログイン名>
    ```
    - Max Thread : 関数実行時に何並列で情報の取得を行うかの指定
    - Workbook Id : データ可視化用の Workbook の GUID となるため、変更しないでください
<img src="./img/TemplateDeploy.png">


展開を行うと、リソースグループに、Log Analytics の Workbook が展開された状態となります。  
<img src="./img/ResourceGroup.png">  
Azure Functions により、Log Analytics に取得された情報は、この Workbook から情報を確認することができます。


## 参考情報
- [Azure Functions PowerShell Reference](https://docs.microsoft.com/ja-jp/azure/azure-functions/functions-reference-powershell)
- [Log Analytics HTTP Collecter API Refernce](https://docs.microsoft.com/ja-jp/azure/azure-monitor/platform/data-collector-api)
- [Run your Azure Functions from a package file](https://docs.microsoft.com/en-us/azure/azure-functions/run-functions-from-deployment-package)