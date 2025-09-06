pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'santoshsingh7891'   // change if needed
        DOCKER_IMAGE = 'zendrix-app'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'master', url: 'https://github.com/santoshsingh7891/website.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:latest .'
            }
        }

        stage('Run & Test Locally') {
            steps {
                sh '''
                docker rm -f zendrix-app || true
                docker run -d -p 85:80 --name zendrix-app $DOCKER_IMAGE:latest
                sleep 5
                if curl -s http://localhost:85 | grep -q "html"; then
                  echo "✅ Test Passed: App is running"
                else
                  echo "❌ Test Failed: App is not responding"
                  exit 1
                fi
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                 usernameVariable: 'USER',
                                                 passwordVariable: 'PASS')]) {
                    sh '''
                    echo "$PASS" | docker login -u "$USER" --password-stdin
                    docker tag $DOCKER_IMAGE:latest $DOCKER_HUB_USER/$DOCKER_IMAGE:latest
                    docker push $DOCKER_HUB_USER/$DOCKER_IMAGE:latest
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl delete deployment zendrix-app || true
                kubectl delete service zendrix-service || true

                kubectl create deployment zendrix-app --image=$DOCKER_HUB_USER/$DOCKER_IMAGE:latest
                kubectl expose deployment zendrix-app --type=NodePort --port=80 --name=zendrix-service
                '''
            }
        }
    }
}
