#This script assumes you have your Gcloud environment initiated 
#This script needs to be ran after you have enabled APIs neccesary for this project. 

$JsonObject = Get-Content  .\projectconfig.json | ConvertFrom-Json

$projectname = $JsonObject[0].projectname;
$gcezone = $JsonObject[0].gcezone;
$sqlinstancename = $JsonObject[0].sqlinstancename;
$gcregion = $JsonObject[0].gcregion;

#just in case setting projectname and default computezone desired at the beginning of the script 
gcloud config set project $projectname
gcloud config set compute/zone $gcezone

gcloud sql instances create $sqlinstancename --cpu=2 --memory=7680MiB --database-version=POSTGRES_9_6 --availability-type=regional --region=$computezone --gce-zone $gcezone

gcloud sql users set-password postgres --instance=$sqlinstancename  --password=Password#1

gcloud sql databases create app --instance=$sqlinstancename

