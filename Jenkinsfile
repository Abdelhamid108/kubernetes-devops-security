pipeline {
    agent any

    environment {
        HOST_WORKSPACE = "/var/lib/docker/volumes/jenkins_home/workspace/$JOB_NAME"
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
                sh '''
                    docker run --rm \
                      -v "$HOST_WORKSPACE:/project" \
                      -w /project \
                      openpolicyagent/conftest \
                      test \
                      --policy kubernetes_security_opa.rego \
                      k8s_deployment_service.yaml
                '''
            }
        }

        stage('Kubernetes Deploy - Dev') {
            steps {
                withKubeConfig([
                    credentialsId: 'jenkins-kubernetes-token',
                    serverUrl: 'https://192.168.239.132:6443'
                ]) {
                    sh '''
                        sed -i \
                          "s#replace#abdelhameed208/numeric-app:${GIT_COMMIT}#g" \
                          k8s_deployment_service.yaml

                        kubectl version
                        kubectl apply -f k8s_deployment_service.yaml
                    '''
                }
            }
        }
    }

    post {
        always {
            junit 'target/surefire-reports/*.xml'

            jacoco execPattern: 'target/jacoco.exec'

            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'

            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        }
    }
}
