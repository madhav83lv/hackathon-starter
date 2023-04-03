pipeline {
  agent {
      label 'Slave-1'
  }
  
  tools {
     jdk 'JAVA_11'
     maven 'MAVEN_3'
  }
  
  environment {
		DOCKERHUB_CREDENTIALS=credentials('DockerHub')
	}
	
  options {
      buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
      disableResume()
      disableConcurrentBuilds()
  }
  
   stages {
      stage('Checkout Code'){
          steps {
              git branch: 'main', url: 'https://github.com/madhav83lv/hackathon-starter'
          }
      }
	  
	  stage('Maven Compile'){
          steps {
              sh "mvn clean install"
          }
      }
	  
	  stage('SonarQube Scan'){
          environment {
              scannerHome = tool 'SONAR_4'
          }
          steps {
              withSonarQubeEnv('SONARSERVER'){
                  sh 'mvn clean org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.0.2155:sonar'
              }
          }
      }
      
      stage('Maven Unit Test'){
          steps {
              echo "This stage is performing Unit Test"
              sh "mvn test"
          }
      }
      
      stage('Maven Package'){
          steps {
              echo "This stage is Packaging the Code"
              sh "mvn package"
          }
      }
	  
	  stage('Build') {
			steps {
				sh 'docker build -t devadimadhav/nodeapp:latest .'
				sh 'docker images'
			}
		}
		
		stage('Scan') {
            steps {
                sh 'trivy image --severity HIGH,CRITICAL devadimadhav/nodeapp:latest'
                }
		}
		
		stage('Login') {
			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}
		
		stage('Push') {
			steps {
				sh 'docker push devadimadhav/nodeapp:latest'
			}
		}
		
		
		stage('Apply to K8s') {
		    steps {
		        sh 'ssh -o PasswordAuthentication=yes ubuntu@172.31.4.30 kubectl --namespace=default apply -f /tmp/node-deployment.yaml'
		    }
		}
   }
	  post {
		always {
			sh 'docker logout'
		}
	  }
}
	  
	  
