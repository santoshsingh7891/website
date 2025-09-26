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
    booleanParam(defaultValue: false, description: 'Force deploy to Kubernetes', name: 'FORCE_DEPLOY')
  }

  stages {

    stage('Checkout') {
      steps {
        echo "📥 Checking out code from GitHub..."
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          def IMAGE_TAG = "${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
          echo "🐳 Building Docker image: ${IMAGE_TAG}"
          sh "docker build -t ${IMAGE_TAG} -t ${DOCKER_IMAGE}:latest ."
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        script {
          echo "📤 Pushing Docker images to Docker Hub..."
          docker.withRegistry('https://index.docker.io/v1/', DOCKER_HUB_CREDENTIALS) {
            sh "docker push ${DOCKER_IMAGE}:latest"
            sh "docker push ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
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
        echo "🚀 Deploying to Kubernetes..."
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
      echo "✅ Deployment successful!"
    }
    failure {
      echo "❌ Deployment failed!"
    }
  }
}
