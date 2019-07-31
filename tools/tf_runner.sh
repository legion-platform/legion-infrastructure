#!/usr/bin/env bash
#Script for Legion clusters orchestration

function ReadArguments() {

	export VERBOSE=false
	export TF_SUPPORTED_COMMANDS=(create destroy)

	if [ $# == 0 ]; then
		echo "Options not specified! Use -h for help!"
		exit 1
	fi

	while test $# -gt 0
	do
        case "$1" in
            -h|--help)
				echo "tf_runner.sh - Run Terraform modules for Legion clusters orchestration."
				echo "Usage: ./tf_runner.sh [OPTIONS]"
				echo " "
				echo "options:"
                echo "command[create|destroy]         command to execute: $TF_SUPPORTED_COMMANDS"
				echo "-t  --verbose          		  verbose mode for debug purposes"
                echo "-h  --help               		  show brief help"
				exit 0
				;;
			create)
				export COMMAND="create"
				shift
				;;
			destroy)
				shift
				export COMMAND="destroy"
				shift
				;;
			-v|--verbose)
				export VERBOSE="true"
				shift
				;;
			*)
				echo "Unknown option: $1. Use -h for help."
				exit 1
				;;
		esac
	done

	# Check mandatory parameters
	if [ ! $COMMAND ]; then
		echo "Error! --command argument must be specified. Use -h for help!"
		exit 1
	fi
	# Read GCP credentials path from env
	if [ ! $GCP_CREDENTIALS ]; then
		echo "Error: No GCP credentials found. Pass path to the credentials json file as GCP_CREDENTIALS env var!"
		exit 1
	fi
	if [ ! $PROFILE ]; then
		echo "Error: No PROFILE found. Pass path to the Cluster profile json file as PROFILE env var!"
		exit 1
	fi
	# Validate profile path
	if [ ! -f $GCP_CREDENTIALS ]; then
		echo "Error: no Cluster profile found at $GCP_CREDENTIALS path!"
	fi
	# Validate Command parameter
	if [[ ! " ${TF_SUPPORTED_COMMANDS[@]} " =~ " ${COMMAND} " ]]; then
		echo "Error: incorrect Command parameter \"$COMMAND\", must be one of ${TF_SUPPORTED_COMMANDS}!"
	fi
	# Check verbose mode
	if [ $VERBOSE == "true" ]; then
		set -x
	fi
}

# Get parameter from cluster profile
function GetParam() {
	result=$(jq ".$1" $PROFILE | tr -d '"')
	if [ ! result ]; then
		echo "Error: $1 parameter missed in $PROFILE cluster profile"
		exit 1
	else
		echo $result
	fi
}

function TerraformRun() {
	MODULES_ROOT=/opt/legion/terraform/env_types/gcp/gke/
	TF_MODULE=$1
	TF_COMMAND=$2
	WORK_DIR=$MODULES_ROOT/$TF_MODULE

	cd $WORK_DIR
	export TF_DATA_DIR=/tmp/.terraform-$(GetParam 'cluster_name')-$TF_MODULE
	terraform init -backend-config="bucket=$(GetParam 'tfstate_bucket')"
	
	echo "Execute $TF_COMMAND on $TF_MODULE state"

	if [ $TF_COMMAND = "apply" ]; then
		terraform plan -var-file=$PROFILE
		terraform $TF_COMMAND -auto-approve -var-file=$PROFILE
	else
		terraform $TF_COMMAND -auto-approve -var-file=$PROFILE
	fi
}

function SetupGCPAccess() {
	echo "Activate service account"
    gcloud auth activate-service-account --key-file=$GCP_CREDENTIALS --project=$(GetParam "project_id")
}

# Create Legion cluster
function TerraformCreate() {
	echo 'INFO: Apply gke_create TF module'
	TerraformRun gke_create apply
	echo 'INFO: Authorize Kubernetes API access'
	gcloud container clusters get-credentials $(GetParam "cluster_name") --zone $(GetParam "location") --project=$(GetParam "project_id")
	echo 'INFO: Init HELM'
	TerraformRun helm_init apply
	echo 'INFO: Setup K8S Legion dependencies'
	TerraformRun k8s_setup apply
	echo 'INFO: Deploy Legion components'
	TerraformRun legion apply
}

# Destroy Legion cluster
function TerraformDestroy() {
	echo 'INFO: Init HELM'
	helm init --client-only

	echo "INFO: Remove auto-generated fw rules"
	gcloud compute firewall-rules list --filter='name:k8s- AND network:$(GetParam "cluster_name")-vpc' --format='value(name)' --project=$(GetParam "project_id")| while read i; do if (gcloud compute firewall-rules describe --project=$(GetParam "project_id")); then gcloud compute firewall-rules delete \$i --quiet; fi; done

	echo 'INFO: Destroy Legion components'
	TerraformRun legion destroy
	echo 'INFO: Destroy K8S Legion dependencies'
	TerraformRun k8s_setup destroy
	echo 'INFO: Destroy Helm'
	TerraformRun helm_init destroy
	echo 'INFO: Destroy GKE cluster'
	TerraformRun gke_create destroy
}


##################
### Do the job 
##################

ReadArguments "$@"
SetupGCPAccess

if [ $COMMAND == 'create' ]; then
	TerraformCreate
elif [ $COMMAND == 'destroy' ]; then
	TerraformDestroy
else
	echo "Error: invalid command!"
fi
