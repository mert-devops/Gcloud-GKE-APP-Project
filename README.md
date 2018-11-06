# Vibrato Tech Test - Candidate Application



## Overview
Canditate: Mert Senel<br/>
Contact: mertsenel@gmail.com

## Requirements
(I've worked on a Windows 10 Professional x86 for other Operating Systems Requirements might Change)

1-Google Cloud SDK for Windows
2-Docker CE for Windows
3-Powershell 5.1 or up

Once Gcloud cloud shell is install run commands below for installing additional tools and updating current toolkit

gcloud init
gcloud components install kubectl
gcloud components update

** the

## Instructions
1- Install Requirements
2- Create a project and Enable Billing on create Gcloud Project
3- Update projectconfig.json with your prefered settings

You may just use default values I've checked-in. 
imagenameandversion should be in "techtestapp:v1" format
please see default values and adjust accordingly 
you may just append them with a number. 

{
"projectname":"YOURPROJECTNAME", 
"gcregion":"australia-southeast1", 
"gcezone":"australia-southeast1-a",
"sqlinstancename":"YOURSQLINSTANCENAME",
"sqleditorsa":"YOUR-DESIRED-SERVICE-ACCOUNT-NAME",
"gkeclustername" : "YOUR-DESIRED-GKE-CLUSTER-NAME",
"imagenameandversion" : "IMAGE-NAME-AND-VERSION-FOR-TAGGING" 
}


4- Open powershell as administrator
5- Set your working directory with commands
cd "C:\YOUR-REPO-CLONE-PATH\Vibrato-TechTestApp-Candidate"

********** Scripts are using relative paths so being in correct working directory is important. 

6-  issue command gcloud init
	define your configuration, user account and project 
	Make sure the project name matches the project name configured on the projectconfig.json
	you dont have to select default compute zone as scripts already defines them. 
	
7- on the same shell execute script named "1-gcloud-prep-project" via
`.\1-gcloud-prep-project`

This script will enable neccesary apis on your project 

8- Execute second script named ""














 
