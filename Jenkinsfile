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

