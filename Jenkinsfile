node {
    stage('Clone') {
       git branch: 'main', url: 'https://github.com/Satti402/firstrepo.git'
        }

    stage('clean') {
       sh ' mvn clean'
        }

    stage('validate') {
       sh ' mvn validate'
        }

    stage('compile') {
       sh ' mvn compile'
        }
    stage('Sonar scan') {
       sh ' mvn sonar:sonar \
  -Dsonar.host.url=http://34.125.50.26:9000 \
  -Dsonar.login=e4e65c6f4898f7fd9e230cfc192e2c6a51a6a145 '
        }

    stage('test') {
       sh ' mvn test'
        }
        
    stage('package') {
       sh ' mvn package'
        }
    stage('deploy') {
       sh ' mvn deploy'
        }  
    
}

