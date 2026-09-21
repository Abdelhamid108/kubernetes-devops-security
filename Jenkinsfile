pipeline {
    agent any

    environment {
        HOST_WORKSPACE = "/var/lib/docker/volumes/jenkins_home/workspace/$JOB_NAME"
        deploymentName = 'devsecops'
        containerName  = 'devsecops-container'
        serviceName    = 'devsecops-svc'
        imageName      = "abdelhameed208/numeric-app:${GIT_COMMIT}"
        applicationURL = 'http://192.168.239.132'
        applicationURI = '/increment/99'
    }

    stages {

        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests=true'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Unit Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Mutation Test') {
            steps {
                sh 'mvn org.pitest:pitest-maven:mutationCoverage'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-local') {
                    sh '''
                        mvn sonar:sonar \
                          -Dsonar.projectKey=Kubernetes-devsecops \
                          -Dsonar.projectName=Kubernetes-devsecops
                    '''
                }

                timeout(time: 2, unit: 'MINUTES') {
                    script {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }
        }

	stage('Vulnerability Scan - Docker') {
 	   steps {
        	parallel(
            		"Dependency Scan": {
                		sh 'mvn dependency-check:check -DossindexAnalyzerEnabled=false'
            			},

            		"Trivy Scan": {
                		sh 'bash trivy-docker-image-scan.sh'
            			},

            		"OPA Dockerfile Scan": {
               			 sh '''
                   		 docker run --rm \
                      		-v "$HOST_WORKSPACE:/project" \
                      		-w /project \
                      		openpolicyagent/conftest \
                      		test \
                      		--policy dockerfile_security.rego \
                      		Dockerfile
                		'''
            			}
        		)
    		}	
	}
        stage('Docker Build and Push') {
            steps {
                withDockerRegistry([
                    credentialsId: 'docker-hub-creds',
                    url: ''
                ]) {
                    sh '''
                        docker build \
                          -t abdelhameed208/numeric-app:$GIT_COMMIT .

                        docker push \
                          abdelhameed208/numeric-app:$GIT_COMMIT
                    '''
                }
            }
        }

        stage('Kubernetes Vulnerability Scan') {
            steps {
                parallel (
                    "OPA Scan":{ 
                        sh '''
                        docker run --rm \
                            -v "$HOST_WORKSPACE:/project" \
                            -w /project \
                            openpolicyagent/conftest \
                            test \
                            --policy kubernetes_security_opa.rego \
                            k8s_deployment_service.yaml
                        '''
                    },

                    "kubeSec Scan":{
                        sh "bash kubesec_scan.sh"
                    },

                    "trivy scan": {
                        sh "bash trivy-k8s-scan.sh"
                    }
                )  
            }
        }

        stage('Kubernetes Deploy - Dev') {
            steps {
                withKubeConfig([
                    credentialsId: 'jenkins-kubernetes-token',
                    serverUrl: 'https://192.168.239.132:6443'
                ]) {
                    sh "bash ./k8s-deployment.sh"
                }
            }
        }
	    stage('Wating for Rollout'){
	        steps{
                sleep time: 100, unit: 'SECONDS'

		    withKubeConfig([
                    credentialsId: 'jenkins-kubernetes-token',
                    serverUrl: 'https://192.168.239.132:6443'
                ]) { 
                   sh "bash ./k8s-deployment-rollout-status.sh"
                 }
	        } 	 
	    }
        stage('Integration Test - Dev'){
            steps{
                script{
                    try {
                        withKubeConfig([
                            credentialsId: 'jenkins-kubernetes-token',
                            serverUrl: 'https://192.168.239.132:6443'
                        ]) {
                            sh "bash integration-test.sh"
                        }
                    } catch (e) {
                        withKubeConfig([
                            credentialsId: 'jenkins-kubernetes-token',
                            serverUrl: 'https://192.168.239.132:6443'
                        ]) {
                            sh "kubectl -n default rollout undo deploy ${deploymentName}"
                        }
                        error("Integration tests failed, rolled back deployment.")
                    }
                }
            }
        }
        stage('OWAS ZAP - DAST SCAN'){
            steps{
                withKubeConfig([
                    credentialsId: 'jenkins-kubernetes-token',
                    serverUrl: 'https://192.168.239.132:6443'
                ]) {
                    sh "bash owasp_zap.sh"
                }
            }
        }

    }

    post {
        always {
            junit 'target/surefire-reports/*.xml'

            jacoco execPattern: 'target/jacoco.exec'

            recordCoverage(
                tools: [[
                    parser: 'PIT',
                    pattern: 'target/pit-reports/**/mutations.xml'
                ]],
                enabledForFailure: true
            )
            
            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'

            publishHTML(
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'owasp-zap-report',
                reportFiles: 'zap_report.html',
                reportName: 'OWASP ZAP HTML Report',
                reportTitles: 'OWASP ZAP HTML Report'
            )
        }

    }
}
