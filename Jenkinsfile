pipeline {
  agent any

  triggers {
    cron('H H 25 * *') // automatic run on 25th
  }

  environment {
    DOCKER_HUB_CREDENTIALS = 'dockerhub-credentials'
    DOCKER_IMAGE = "singhsantosh7891/website"
  }

  parameters {
    booleanParam(defaultValue: false, description: 'Force deploy', name: 'FORCE_DEPLOY')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          IMAGE_TAG = "${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
          sh "docker build -t ${IMAGE_TAG} -t ${DOCKER_IMAGE}:latest ."
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_HUB_CREDENTIALS}") {
            docker.image("${DOCKER_IMAGE}:latest").push()
            docker.image("${DOCKER_IMAGE}:${env.BUILD_NUMBER}").push()
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      when {
        expression {
          def day = new Date().format('dd', TimeZone.getTimeZone('Asia/Kolkata'))
          return (day == '25') || params.FORCE_DEPLOY
        }
      }
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh "kubectl apply -f k8s/namespace.yaml"
          sh "kubectl apply -f k8s/deployment.yaml"
          sh "kubectl apply -f k8s/service.yaml"
          sh "kubectl rollout status deployment/website-deployment -n production --timeout=120s"
        }
      }
    }
  }

  post {
    success {
      echo "✅ Deployment successful"
    }
    failure {
      echo "❌ Deployment failed"
    }
  }
}
