#This script assumes you have your Gcloud local configuration is initiated
#This script needs to be ran after you have generated neccesary gcloud infrastruce and enabled APIs neccesary for this project. 

$JsonObject = Get-Content  .\projectconfig.json | ConvertFrom-Json

$projectname = $JsonObject[0].projectname;
$gcezone = $JsonObject[0].gcezone;
$gkeclustername = $JsonObject[0].gkeclustername;

#just in case setting projectname and default computezone desired at the beginning of the script 
gcloud config set project $projectname
gcloud config set compute/zone $gcezone


gcloud container clusters get-credentials $gkeclustername

#grab the pod name from techtestapp app to execute seed database command
kubectl get pods -o json
$podname=kubectl get pod -l app=techtestapp -o jsonpath="{.items[0].metadata.name}"

#execute seed database command
kubectl exec $podname -t -i -- /bin/sh -c "./TechTestApp updatedb -s"

#we can now enable pod auto-scaling for our deployment
#kubectl autoscale deployment techtestapp-deployment --max 10 --min 4 --cpu-percent 50

kubectl get services | out-file .\PUBLIC-IP-ADDRESS.txt -Force