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
          post {
            always {
              junit 'target/surefire-reports/*.xml'
              jacoco execPattern: 'target/jacoco.exec'
            }	
          }
	      }
        stage('Mutation Test'){
          steps{
            sh "mvn org.pitest:pitest-maven:mutationCoverage"
          }
          post{
            always {
              pitmutation mutationStatsFile:'**/target/pit-reports/**/mutations.xml'
            }
          }
        }
        stage('SonarQube - SAST'){
          steps{
            withCredntials([string(credntailsId: 'sonar-token', variable: 'SONAR_TOKEN')]){
              sh '''
                mvn sonar:sonar \
                  -Dsonar.projectKey=Abdelhamid108_kubernetes-devops-security \
                  -Dsonar.organization=abdelhamid108 \
                  -Dsonar.token=$SONAR_TOKEN
              '''
            }
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
    }
}
