#This script assumes you have your Gcloud environment initiated 
#This script needs to be ran after you have enabled APIs neccesary for this project. 

$JsonObject = Get-Content  .\projectconfig.json | ConvertFrom-Json

$projectname = $JsonObject[0].projectname;
$gcezone = $JsonObject[0].gcezone;
$sqlinstancename = $JsonObject[0].sqlinstancename;
$sqleditorsa = $JsonObject[0].sqleditorsa;
$gkeclustername = $JsonObject[0].gkeclustername;

#just in case setting projectname and default computezone desired at the beginning of the script 
gcloud config set project $projectname
gcloud config set compute/zone $gcezone

#in order for kubectl to work we need to grab credentials via gcloud
gcloud container clusters get-credentials $gkeclustername

#generate private key for the sql editor service account in json format
gcloud iam service-accounts keys create ./key.json `
  --iam-account $sqleditorsa@$projectname.iam.gserviceaccount.com
  
#Store the credentials as a kubernetes cluster secret this will be later reffered in .yaml file
kubectl create secret generic cloudsql-instance-credentials `
    --from-file=credentials.json=./key.json

Remove-Item -path ./key.json -Force