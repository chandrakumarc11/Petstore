pipeline {
    agent {
       label 'master'
    }
    tools{
        jdk 'jdk21'
        maven 'maven3'
    }
    
parameters {
        choice(
            name: 'RUN_STAGE',
            choices: [
                'ALL',
	        	'GitCheckout',
                'COMPILE',
                'SONAR',
                'BUILD',
                'DOCKER',
                'TRIVY',
                'DEPLOY'
            ],
            description: 'Select Stage to Run'
        )
    }

    environment{
        SCANNER_HOME= tool 'sonar-scanner'
    }
    stages {
        stage('Git Checkout') {
            steps {
               git changelog: false, poll: false, url: 'https://github.com/chandrakumarc11/Petstore.git'
            }
        }
        
        stage('Compile') {
            steps {
               sh "mvn clean compile"
            }
        } 
        
        stage('Sonarqube analysis') {
            steps {
               sh ''' $SCANNER_HOME/bin/sonar-scanner \
               -Dsonar.host.url=http://172.31.28.132:9000 \
               -Dsonar.login=squ_9830bfd5a5d1ed26eec3efe4125e7e16dc890aed \
               -Dsonar.projectName=petstore \
               -Dsonar.java.binaries=. \
               -Dsonar.projectKey=petstore '''
            }
        }
        
//        stage('OWASP Dependency') {
  //  steps {
    //    dependencyCheck additionalArguments: '''
      //      --scan ./ 
     //       --nvdApiKey=7D256160-3270-F111-836E-129478FCB64D
    //    ''',
      //  odcInstallation: 'DP'

    //    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
  //  }
//}
        
        stage('Build') {
            steps {
               sh "mvn clean install -DskipTests=true -Dcargo.maven.skip=true"
            }
        }


stage('Build & Push Docker image') {
    steps {
        withCredentials([
            sshUserPrivateKey(credentialsId: 'docker-ssh', keyFileVariable: 'KEY'),
            usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USER', passwordVariable: 'PASS')
        ]) {
            sh '''
            echo "===== STEP 1: Check WAR exists in Jenkins ====="
            ls -l target/

            echo "===== STEP 2: Copy WAR to Docker EC2 ====="
            scp -i $KEY -o StrictHostKeyChecking=no target/jpetstore.war ubuntu@172.31.28.132:/home/ubuntu/

            echo "===== STEP 3: SSH into Docker EC2 ====="
            ssh -i $KEY -o StrictHostKeyChecking=no ubuntu@172.31.28.132 "

                echo '===== STEP 4: Check file received ====='
                ls -l /home/ubuntu/

                cd /home/ubuntu

                if [ ! -d Petstore ]; then
                    git clone https://github.com/chandrakumarc11/Petstore.git
                fi

                cd Petstore

                echo '===== STEP 5: Prepare target folder ====='
                mkdir -p target

                echo '===== STEP 6: Move WAR into correct place ====='
                mv /home/ubuntu/jpetstore.war target/jpetstore.war

                echo '===== STEP 7: Verify WAR file ====='
                ls -l target/

                echo '===== STEP 8: Docker build ====='
                docker build -t chandru04/petstore:latest .

                echo '===== STEP 9: Docker push ====='
                echo $PASS | docker login -u $USER --password-stdin
                docker push chandru04/petstore:latest
            "
            '''
        } 
    }
}




        stage('Trivy'){
            steps{
                sh "trivy image chandru04/petstore:latest"
            }
        }
        
stage('Deploy Container') {
    steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'docker-ssh', keyFileVariable: 'KEY')]) {
            sh '''
            ssh -i $KEY -o StrictHostKeyChecking=no ubuntu@172.31.28.132 "

                echo '===== STEP 1: Stop old container (if exists) ====='
                docker stop petstore || true
                docker rm petstore || true

                echo '===== STEP 2: Pull latest image ====='
                docker pull chandru04/petstore:latest

                echo '===== STEP 3: Run container ====='
                docker run -d -p 8080:8080 --name petstore chandru04/petstore:latest

                echo '===== STEP 4: Verify running container ====='
                docker ps
            "
            '''
        } 
    }
}

        
    }
}
