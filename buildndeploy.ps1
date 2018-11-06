#This script assumes you have your Gcloud environment initiated 
#This script needs to be ran after you have generated neccesary gcloud infrastruce and enabled APIs neccesary for this project. 

$JsonObject = Get-Content  .\projectconfig.json | ConvertFrom-Json

$projectname = $JsonObject[0].projectname;



Set-Location .\App\

docker build . -t gcr.io/$projectname/techtestapp:v1

$token=gcloud auth print-access-token
docker login -u oauth2accesstoken -p $token https://gcr.io