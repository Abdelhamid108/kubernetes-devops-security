pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }
      stage('Unit Test'){
            steps{
              sh "mvn test" 
            }
	      }
        stage('Mutation Test'){
          steps{
            sh "mvn org.pitest:pitest-maven:mutationCoverage"
          }
        }
        stage('SonarQube Analysis') {
          steps {
            withSonarQubeEnv('sonar-local') {

              sh '''
                  mvn clean verify \
                    org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
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
        stage('Vulnerability Scan - Docker'){
          steps{
            parallel(
              "Dependency Scan": {
                sh "mvn dependency-check:check"
              },
              "Trivy Scan": {
                // sh "bash trivy-docker-image-scan.sh"
                sh "echo 'trivy scan'"
              }
            )
          }
        }
        stage('docker build and push'){
            steps{
             withDockerRegistry([credentialsId: "docker-hub-creds", url: ""]) {
              sh 'docker build -t abdelhameed208/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push abdelhameed208/numeric-app:""$GIT_COMMIT'
              }
            }
        }
        stage('kubernetes deploy -Dev'){
          steps {
            withKubeConfig([credentialsId: 'jenkins-kubernetes-token', serverUrl: 'https://192.168.239.132:6443']){
              sh "sed -i 's#replace#abdelhameed208/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
              sh "kubectl version"
              sh "kubectl apply -f k8s_deployment_service.yaml"
            }
          }
        }
      post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
          pitmutation mutationStatsFile:'**/target/pit-reports/**/mutations.xml'
          dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'



        }
      }
    }
}
