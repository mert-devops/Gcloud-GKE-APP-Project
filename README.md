# Vibrato Tech Test - Candidate Application

## Candidate Details
Name: Mert Senel
Contact: mertsenel@gmail.com

## High level Architectural Overview

### 1- Front-End  <br/>
	-Google Cloud managed Kubernetes Cluster
	-Auto-scaling Enabled for both Cluster and Pods 
	- Minimum 2 Nodes (For High Availability) and can scale up to 4 nodes 
	-Auto-scaler for pods that runs the VibratoTechTest Application
	
### 2- Database <br/>
	-Cloud SQL managed database server service
	- Highly Available as it has been configured with "Regional" Availability Type

### 3-Security<br/>
	- Both services hosted in Google Cloud and in same region so  
	traffic in between the front-end and the database never leaves Google's Datacentre Network
	- SQL Cloud proxy used for connection configured with a service account 
	- Service account credentials are stored in GKE Cluster as a secret 
	
	- Application documentation states that database settings can only be configured via 
	  conf.toml so I didn’t try to pass values as env valus  
	  
	- Application code has SSL setting disabled hardcoded so I haven’t modified that. 
	
## Requirements
(I've worked on a Windows 10 Professional x64 for other Operating Systems Requirements might Change)

1-Google Cloud SDK for Windows https://cloud.google.com/sdk/docs/quickstart-windows 
2-Docker CE for Windows https://www.docker.com/get-started 
3-Powershell 5.1 or up

Once Gcloud cloud shell is install run commands below for installing additional tools and updating current toolkit

gcloud init
gcloud components install kubectl
gcloud components update



## Instructions
1- Install Requirements 
2- Create a project and Enable Billing on the created Google Cloud Project 
3- Update projectconfig.json with your preferred settings 

You may just use default values I've committed. 
imagenameandversion should be in "techtestapp:v1" format
please see default(committed) values and adjust accordingly 
you may just append them with a number. 

{
"projectname":"YOURPROJECTNAME",  <br/>
"gcregion":"australia-southeast1", <br/>
"gcezone":"australia-southeast1-a", <br/>
"sqlinstancename":"YOURSQLINSTANCENAME", <br/>
"sqleditorsa":"YOUR-DESIRED-SERVICE-ACCOUNT-NAME", <br/>
"gkeclustername" : "YOUR-DESIRED-GKE-CLUSTER-NAME", <br/>
"imagenameandversion" : "IMAGE-NAME-AND-VERSION-FOR-TAGGING"  <br/>
}


4- Open powershell as administrator 
5- Set your working directory with the command below 
`cd "C:\YOUR-REPO-CLONE-PATH\Vibrato-TechTestApp-Candidate"` 

***Scripts are using relative paths so being in correct working directory is important.***

6-  Within the same Powershell shell window issue command `gcloud init` 
	define your configuration, user account and project
	Make sure the project name matches the project name configured on the projectconfig.json
	you dont have to select default compute zone as scripts already defines them. 
	
7- on the same shell execute script named "1-gcloud-prep-project" via
`.\1-gcloud-prep-project` 

This script will enable necessary APIs on your project 

8- Execute second script named "2-generate-infra.ps1” via 
		`.\2-generate-infra.ps1` 
		
	This script will provision and sql cloud instance <br/>
	Create a database called "app" in that instance <br/>
	Create a Google Cloud Kubernetes Cluster with autoscaling enabled <br/>
	
	This script will generate a txt file "SQLINSTANCE-CONNECTION-NAME.txt" <br/>
	In this file you will find the SQL instance connection name which will be later needed <br/>
	to update techtestapp.yml config  <br/>
	
9-  Execute thirds script named "3-configuregkecluster"  via <br/>
		`.\3-configuregkecluster.ps1`<br/>
		
	This script will generate a service account <br/>
	Assign Cloud SQL Editor role to this service account <br/>
	Download private key credentials for this account  <br/>
	Create a secret in the Kubernetes Cluster for our deployment's sql proxy to use <br/>

10- Update the techtestapp.yml file with correct values for  <br/>
	
	a- Container image for our app  <br/>
	The format is gcr.io/<YOUR-PROJECT-ID>/<IMAGENAME:VERSION> <br/>

	Example: gcr.io/vib-test1/techtestapp:v6 <br/>

	b- Update command for cloudsql-proxy block <br/>
	the format is "-instances=$PROJECT:$REGION:$INSTANCE=tcp:5432" <br/>
	
	Example: -instances=vib-test1:australia-southeast1:postgresql6=tcp:5432" <br/>

	For your convenience $PROJECT:$REGION:$INSTANCE value can be grabbed directly from "SQLINSTANCE-CONNECTION-NAME.txt" <br/>
	
11- Execute forth script name "4-buildndeploy.ps1" via  <br/>
	`.\4-buildndeploy.ps1` <br/>
	
	This script will build the app inside docker image  <br/>
	Tag it as you've configured in projectconfig.json <br/>
	Push the image to your project container registry <br/>
	Create a deployment to your kubernetes cluster via the techtestapp.yml configuration file you have update on last step. <br/>
	Exposes this deployment via creating a service that listens on port 80 and forwards it to our pods port 80 <br/>
	
12- Execute fifth script name "5-postdeployment.ps1" via <br/>
	`.\5-postdeployment.ps1` <br/>
	
	This script will grab the pod name and execute "update db -s" command on that pod for seeding the database tables <br/>
	Enable pod auto-scaler for our deployment. So we will achieve a highly available and auto-scaling front-end.  <br/>
	
	
13- Last script will issue command `kubectl get services` to obtain external IP of the load balancer service <br/>
	and writes it to a file named "PUBLIC-IP-ADDRESS.txt"  <br/>
	
	However assignment of public ip address to the service usually takes couple of minutes <br/>
	
	Hence, on your shell please issue command <br/>
	
	`kubectl get services`  <br/>
	
	Your might see an output like this:  <br/>
	
	NAME                     TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE <br/>
	kubernetes               ClusterIP      10.43.240.1   <none>        443/TCP        1d <br/>
	techtestapp-deployment   LoadBalancer   10.43.246.3   <pending>     80:30140/TCP   1m <br/>
	
	keep trying and eventually you should see something similar to:  <br/>
	NAME                     TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE <br/>
	kubernetes               ClusterIP      10.43.240.1   <none>          443/TCP        1d <br/>
	techtestapp-deployment   LoadBalancer   10.43.246.3   35.189.38.156   80:30140/TCP   54m <br/>
	
	
14- You may also want to see pods auto scaled or not  you may see that via  <br/>
	`kubectl get pods`  <br/>
	
	You should see at least 4 pods that belongs to techtestapp-deployment (as that what we have set as minimum number) <br/>
	
	The output should be like this:  <br/>
	
	NAME                                      READY     STATUS    RESTARTS   AGE <br/>
	techtestapp-deployment-7d7f76c55c-cgvqx   2/2       Running   0          49m <br/>
	techtestapp-deployment-7d7f76c55c-dhmzv   2/2       Running   0          49m <br/>
	techtestapp-deployment-7d7f76c55c-dndfq   2/2       Running   0          49m <br/>
	techtestapp-deployment-7d7f76c55c-wpjm2   2/2       Running   0          54m <br/>
	
	
	

## Notes for Assessor
	-Sometimes Google cloud fails to provision the GKE Kluster due to resource limitations compute quotas etc. on defined region. <br/> 
	-If this happens you may try another region or try again some time later. <br/>
	-I've automated the infrastructure deployment as well but if Google Clouds fabric fails to deliver please <br/>
	provision the necessary infrastructure manually and update the projectconfig.json accordingly <br/>
	Skip script#2 ("2-generate-infra.ps1") and just continue with other as usual.  <br/>
	











