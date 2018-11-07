# Vibrato Tech Test - Candidate Application

## Candidate Details
Name: Mert Senel <br/>
Contact: mertsenel@gmail.com <br/>

## High level Architectural Overview

### 1- Front-End  <br/>
-Google Cloud managed Kubernetes Cluster <br/>
-Auto-scaling Enabled for both Cluster and Pods  <br/>
-Minimum 2 Nodes (For High Availability) and can scale up to 4 nodes <br/>
-Auto-scaler for pods that runs the VibratoTechTest Application <br/>
	
### 2- Database <br/>
-Cloud SQL managed database server service <br/>
-Highly Available as it has been configured with "Regional" Availability Type <br/>

### 3-Security<br/>
-Both services hosted in Google Cloud and in same region so traffic in between the front-end and the database never leaves Google's Datacentre Network <br/>
- SQL Cloud proxy used for connection configured with a service account <br/>
- Service account credentials are stored in GKE Cluster as a secret <br/>
	
- Application documentation states that database settings can only be configured via conf.toml so I didn’t try to pass values as env values  <br/>
- Application code has SSL setting disabled hardcoded so I haven’t modified that. <br/>
	
## Requirements
(I've worked on a Windows 10 Professional x64 for other Operating Systems Requirements might Change) <br/>

1-Google Cloud SDK for Windows https://cloud.google.com/sdk/docs/quickstart-windows  <br/>
2-Docker CE for Windows https://www.docker.com/get-started  <br/>
3-Powershell 5.1 or up <br/>

Once Gcloud cloud shell is install run commands below for installing additional tools and updating current toolkit <br/>

gcloud init <br/>
gcloud components install kubectl <br/>
gcloud components update <br/>



## Instructions
1- Install Requirements <br/>
2- Create a project and Enable Billing on the created Google Cloud Project  <br/>
3- Update projectconfig.json with your preferred settings  <br/>

You may just use default values I've committed.  <br/>
imagenameandversion should be in "techtestapp:v1" format <br/>
please see default(committed) values and adjust accordingly  <br/>
you may just append them with a number.  <br/>

{<br/>
"projectname":"YOURPROJECTNAME",  <br/>
"gcregion":"australia-southeast1", <br/>
"gcezone":"australia-southeast1-a", <br/>
"sqlinstancename":"YOURSQLINSTANCENAME", <br/>
"sqleditorsa":"YOUR-DESIRED-SERVICE-ACCOUNT-NAME", <br/>
"gkeclustername" : "YOUR-DESIRED-GKE-CLUSTER-NAME", <br/>
"imagenameandversion" : "IMAGE-NAME-AND-VERSION-FOR-TAGGING"  <br/>
}<br/>


4- Open powershell as administrator  <br/>
5- Set your working directory with the command below <br/>
`cd "C:\YOUR-REPO-CLONE-PATH\Vibrato-TechTestApp-Candidate"` 

***Scripts are using relative paths so being in correct working directory is important.***

6-  Within the same Powershell shell window issue command `gcloud init` 
	define your configuration, user account and project
	Make sure the project name matches the project name configured on the projectconfig.json
	you dont have to select default compute zone as scripts already defines them. 
	
7- on the same shell execute script named "1-gcloud-prep-project" via <br/>
`.\1-gcloud-prep-project`  <br/>

This script will enable necessary APIs on your project <br/>

8- Execute second script named "2-generate-infra.ps1” via <br/>
`.\2-generate-infra.ps1` <br/>
		
This script will provision and sql cloud instance <br/>
Create a database called "app" in that instance <br/>
Create a Google Cloud Kubernetes Cluster with autoscaling enabled  <br/>
	
This script will generate a txt file "SQLINSTANCE-CONNECTION-NAME.txt"  <br/>
In this file you will find the SQL instance connection name which will be later needed  <br/>
to update techtestapp.yml config   <br/>
	
9-  Execute thirds script named "3-configuregkecluster"  via <br/>
`.\3-configuregkecluster.ps1`<br/>
		
This script will generate a service account <br/>
Assign Cloud SQL Editor role to this service account <br/>
Download private key credentials for this account  <br/>
Create a secret in the Kubernetes Cluster for our deployment's sql proxy to use <br/>

10- Update the techtestapp.yml file with correct values for <br/>

a- Container image for our app   <br/>
The format is gcr.io/<YOUR-PROJECT-ID>/<IMAGENAME:VERSION>  <br/>

Example: gcr.io/vib-test1/techtestapp:v6 <br/>

b- Update command for cloudsql-proxy block <br/>
the format is "-instances=$PROJECT:$REGION:$INSTANCE=tcp:5432" <br/>
	
Example: -instances=vib-test1:australia-southeast1:postgresql6=tcp:5432" <br/>

For your convenience $PROJECT:$REGION:$INSTANCE value can be <br/>
grabbed directly from "SQLINSTANCE-CONNECTION-NAME.txt" 
	
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
	
	NAME                     TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE 
	kubernetes               ClusterIP      10.43.240.1   <none>        443/TCP        1d 
	techtestapp-deployment   LoadBalancer   10.43.246.3   <pending>     80:30140/TCP   1m 
	
keep trying and eventually you should see something similar to:  <br/>

	NAME                     TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE 
	kubernetes               ClusterIP      10.43.240.1   <none>          443/TCP        1d 
	techtestapp-deployment   LoadBalancer   10.43.246.3   35.189.38.156   80:30140/TCP   54m 
	
	
14- You may also want to see pods auto scaled or not  you may see that via  <br/>
`kubectl get pods`  <br/>
	
You should see at least 4 pods that belongs to techtestapp-deployment (as that what we have set as minimum number) <br/>
	
The output should be like this:  <br/>
	
	NAME                                      READY     STATUS    RESTARTS   AGE 
	techtestapp-deployment-7d7f76c55c-cgvqx   2/2       Running   0          49m 
	techtestapp-deployment-7d7f76c55c-dhmzv   2/2       Running   0          49m 
	techtestapp-deployment-7d7f76c55c-dndfq   2/2       Running   0          49m 
	techtestapp-deployment-7d7f76c55c-wpjm2   2/2       Running   0          54m 
	
	
	

## Notes for Assessor
-Sometimes Google cloud fails to provision the GKE Kluster due to resource limitations compute quotas etc. on defined region. <br/> 
-If this happens you may try another region or try again some time later. <br/>
-I've automated the infrastructure deployment as well but if Google Clouds fabric fails to deliver please <br/>
provision the necessary infrastructure manually and update the projectconfig.json accordingly <br/>
Skip script#2 ("2-generate-infra.ps1") and just continue with other as usual.  <br/>
	











