#This script assumes you have your Gcloud environment initiated 
#This script needs to be ran after you have enabled APIs neccesary for this project. 

$JsonObject = Get-Content  .\projectconfig.json | ConvertFrom-Json

$projectname = $JsonObject[0].projectname;
$gcezone = $JsonObject[0].gcezone;
$sqlinstancename = $JsonObject[0].sqlinstancename;
$gcregion = $JsonObject[0].gcregion;
$sqleditorsa = $JsonObject[0].sqleditorsa;
$gkeclustername = $JsonObject[0].gkeclustername;

#just in case setting projectname and default computezone desired at the beginning of the script 
gcloud config set project $projectname
gcloud config set compute/zone $gcezone



