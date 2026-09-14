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
        stage('docker build and push'){
            steps{
             sh 'docker build -t abdelhameed208/numeric-app:""$GIT_COMMIT"" .'
             sh 'docker push abdelhameed208/numeric-app:""$GIT_COMMIT'
            }
        }
    }
}
