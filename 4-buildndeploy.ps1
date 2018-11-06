#This script assumes you have your Gcloud local configuration is initiated
#This script needs to be ran after you have generated neccesary gcloud infrastruce and enabled APIs neccesary for this project. 

$JsonObject = Get-Content  .\projectconfig.json | ConvertFrom-Json

$projectname = $JsonObject[0].projectname;
$gcezone = $JsonObject[0].gcezone;

#just in case setting projectname and default computezone desired at the beginning of the script 
gcloud config set project $projectname
gcloud config set compute/zone $gcezone

Set-Location .\App\

docker build . -t gcr.io/$projectname/techtestapp:v1

Set-Location ..\

$token=gcloud auth print-access-token
docker login -u oauth2accesstoken -p $token https://gcr.io

docker push gcr.io/$projectname/techtestapp:v1

gcloud container clusters get-credentials $gkeclustername

kubectl create -f techtestapp.yml

kubectl expose deployment techtestapp-deployment --type=LoadBalancer --port 80 --target-port 80

kubectl get pods -o json

$podname=kubectl get pod -l app=techtestapp1 -o jsonpath="{.items[0].metadata.name}"

kubectl exec $podname -t -i -- /bin/sh -c "./TechTestApp updatedb -s"

#kubectl autoscale deployment techtestapp1 --max 10 --min 4 --cpu-percent 50