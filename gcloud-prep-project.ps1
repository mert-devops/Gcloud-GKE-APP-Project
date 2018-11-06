#This script assumes you have your Gcloud local configuration is initiated


$JsonObject = Get-Content  .\projectconfig.json | ConvertFrom-Json

$projectname = $JsonObject[0].projectname;
$gcezone = $JsonObject[0].gcezone;
$billingaccountid = $JsonObject[0].billingaccountid

#just in case setting projectname and default computezone desired at the beginning of the script 
gcloud config set project $projectname
gcloud config set compute/zone $gcezone

gcloud services enable bigquery-json.googleapis.com --async
gcloud services enable compute.googleapis.com --async
gcloud services enable container.googleapis.com --async
gcloud services enable containerregistry.googleapis.com --async
gcloud services enable oslogin.googleapis.com --async
gcloud services enable pubsub.googleapis.com --async
gcloud services enable sqladmin.googleapis.com --async
gcloud services enable storage-api.googleapis.com --async
