#This script assumes you have your Gcloud local configuration is initiated
#This script needs to be ran after you have generated neccesary gcloud infrastruce and enabled APIs neccesary for this project. 

$JsonObject = Get-Content  .\projectconfig.json | ConvertFrom-Json

$projectname = $JsonObject[0].projectname;
$gcezone = $JsonObject[0].gcezone;
$sqlinstancename = $JsonObject[0].sqlinstancename;

#just in case setting projectname and default computezone desired at the beginning of the script 
gcloud config set project $projectname
gcloud config set compute/zone $gcezone

Set-Location .\App\

docker build . -t gcr.io/$projectname/techtestapp:v1

$token=gcloud auth print-access-token
docker login -u oauth2accesstoken -p $token https://gcr.io

docker push gcr.io/$projectname/techtestapp:v1

kubectl expose deployment techtestapp-deployment --type=LoadBalancer --port 80 --target-port 80
