pipeline {
    agent { label 'ec2orchestrator'}

    environment {
        //Input parameters
        param_git_branch = "${params.GitBranch}"
        param_cluster_name = "${params.ClusterName}"
        param_cluster_type = "${params.ClusterType}"
        param_legion_infra_version = "${params.LegionInfraVersion}"
        param_docker_repo = "${params.DockerRepo}"
        param_helm_repo = "${params.HelmRepo}"
        param_gcp_project = "${params.GcpProject}"
        param_gcp_zone = "${params.GcpZone}"
        //Job parameters
        gcpCredential = "gcp-epmd-legn-legion-automation"
        sharedLibPath = "pipelines/legionPipeline.groovy"
        cleanupContainerVersion = "latest"
        terraformHome =  "/opt/legion/terraform"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
                script {
                    legion = load "${env.sharedLibPath}"
                    legion.getWanIp()
                    legion.buildDescription()
                }
                sshagent(["${env.legionProfilesGitlabKey}"]) {
                    sh"""
                      ssh-keyscan git.epam.com >> ~/.ssh/known_hosts
                      git clone ${env.param_legion_cicd_repo} legion-cicd
                      cd legion-cicd && git checkout ${env.param_legion_cicd_branch}
                    """
                }
            }
        }

        stage('Create Kubernetes Cluster') {
            steps {
                script {
                    legion.createGCPCluster()
                }
            }
        }
    }
    
    post {
        always {
            script {
                legion = load "${env.sharedLibPath}"
                legion.notifyBuild(currentBuild.currentResult)
            }
        }
        cleanup {
            script {
                legion = load "${env.sharedLibPath}"
                legion.revokeGcpAccess()
            }
            deleteDir()
        }
    }
}
