#This script assumes you have your Gcloud environment initiated 
#This script needs to be ran after you have generated neccesary gcloud infrastruce and enabled APIs neccesary for this project. 

$JsonObject = Get-Content .\projectconfig.json | ConvertFrom-Json


$projectname = $JsonObject[0].projectname;

Set-Location .\App\


