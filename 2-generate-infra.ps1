#This script assumes you have your Gcloud environment initiated 
#This script needs to be ran after you have enabled APIs neccesary for this project. 

$JsonObject = Get-Content  .\projectconfig.json | ConvertFrom-Json

$projectname = $JsonObject[0].projectname;
$sqlinstancename = $JsonObject[0].sqlinstancename;
$gcezone = $JsonObject[0].gcezone;
$gcregion = $JsonObject[0].gcregion;
$sqleditorsa = $JsonObject[0].sqleditorsa;
$gkeclustername = $JsonObject[0].gkeclustername;

#just in case setting projectname and default computezone desired at the beginning of the script 
gcloud config set project $projectname
gcloud config set compute/zone $gcezone


#genereate cloud sql instance for postgresql availlability regional flag will provide redundancy 
gcloud sql instances create $sqlinstancename --cpu=2 --memory=7680MiB `
--database-version=POSTGRES_9_6 --availability-type=regional --region=$gcregion

#set password for postgres user
gcloud sql users set-password postgres --instance=$sqlinstancename  --password=Password#1

#generating database doesnt work from the environment so we will create the database prior and just seed tables
gcloud sql databases create app --instance=$sqlinstancename

#writes sql instance connection name to a txt file. This connection name needs to be updated in techtestapp.yaml file
$sqlinstanceobj=gcloud sql instances describe $sqlinstancename --format json | ConvertFrom-Json

#output connection name so assessor can found conneciton name easily to update .yaml file
$sqlinstanceobj.connectionName | Out-file SQLINSTANCE-CONNECTION-NAME.txt -Force


#generate Google Cloud Kubernetes cluster with Autoscaling enabled

gcloud container clusters create $gkeclustername --num-nodes 2  --region $gcregion `
        --enable-autoscaling --min-nodes 2 --max-nodes 4
