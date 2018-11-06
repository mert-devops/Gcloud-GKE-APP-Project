#This script assumes you have your Gcloud local configuration is initiated
#This script needs to be ran after you have generated neccesary gcloud infrastruce and enabled APIs neccesary for this project. 

$JsonObject = Get-Content  .\projectconfig.json | ConvertFrom-Json

$projectname = $JsonObject[0].projectname;
$gcezone = $JsonObject[0].gcezone;
$gkeclustername = $JsonObject[0].gkeclustername;
$imagenameandversion = $JsonObject[0].imagenameandversion;


#just in case setting projectname and default computezone desired at the beginning of the script 
gcloud config set project $projectname
gcloud config set compute/zone $gcezone

#creating docker image and tagging before pushing it to gcloud projects container registery
Set-Location .\App\

docker build . -t gcr.io/$projectname/$imagenameandversion

Set-Location ..\

#request a token and pass it to docker for logging in to the projects container registery
$token=gcloud auth print-access-token
docker login -u oauth2accesstoken -p $token https://gcr.io

#pushing (uploading) image to registery so our kubernetes deployment can use this image in container spec
docker push gcr.io/$projectname/$imagenameandversion

#request credentials for kubernetes cluster, updates local config so kubectl can authenticate
gcloud container clusters get-credentials $gkeclustername

#create kubernetes deployment via config file
kubectl create -f techtestapp.yml

#create a service with type load balancer in order to expose port 80 to our deployment tagged pods provides external HTTP address
kubectl expose deployment techtestapp-deployment --type=LoadBalancer --port 80 --target-port 80

