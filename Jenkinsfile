pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        GIT_URL       = 'https://github.com/divyap1571/AI-Powered-E-Commerce-DevOps-Cloud-Native-Delivery-Platform-.git'
        GIT_BRANCH    = 'main'
        IMAGE_NAME    = 'nexvion-web'
        TEST_CONTAINER = 'nexvion-ci-test'
        TEST_PORT     = '18080'
    }

    stages {
        stage('Checkout Code from GitHub') {
            steps {
                git branch: "${GIT_BRANCH}",
                    url: "${GIT_URL}"

                sh '''
                    echo "GitHub checkout successful."
                    echo "Workspace: $WORKSPACE"
                    git log -1 --oneline
                '''
            }
        }

        




stage('Trivy Filesystem Security Scan') {
    steps {
        sh '''
            set -eu
            trivy fs \
              --scanners vuln,secret \
              --severity HIGH,CRITICAL \
              --exit-code 1 \
              .
        '''
    }
}



        stage('Build Docker Image') {
            steps {
                sh '''
                    set -eu

                    docker build \
                      -t ${IMAGE_NAME}:${BUILD_NUMBER} \
                      -t ${IMAGE_NAME}:latest .

                    echo "Docker image built successfully."
                    docker images ${IMAGE_NAME}
                '''
            }
        }
        
stage('DevSecOps - Trivy Image Scan') {
    steps {
        sh '''
            set -eu

            trivy image \
              --severity HIGH,CRITICAL \
              --ignore-unfixed \
              --format table \
              nexvion-web:${BUILD_NUMBER}
        '''
    }
}


stage('Docker Smoke Test') {
    steps {
        sh '''
            set -eu

            docker rm -f ${TEST_CONTAINER} >/dev/null 2>&1 || true

            cleanup() {
                docker rm -f ${TEST_CONTAINER} >/dev/null 2>&1 || true
            }
            trap cleanup EXIT

            docker run -d \
              --name ${TEST_CONTAINER} \
              -p 127.0.0.1:${TEST_PORT}:80 \
              ${IMAGE_NAME}:${BUILD_NUMBER}

            for attempt in $(seq 1 30); do
                if curl --fail --silent \
                  http://127.0.0.1:${TEST_PORT}/ \
                  -o /dev/null; then
                    echo "Docker smoke test passed."
                    exit 0
                fi

                if [ "$(docker inspect -f '{{.State.Running}}' ${TEST_CONTAINER})" != "true" ]; then
                    echo "Container stopped unexpectedly."
                    docker logs ${TEST_CONTAINER} || true
                    exit 1
                fi

                sleep 2
            done

            echo "Smoke test failed after waiting for the application."
            docker logs ${TEST_CONTAINER} || true
            exit 1
        '''
    }
}

        
        
        
stage('Push Image to Docker Hub') {
    steps {
        withCredentials([
            usernamePassword(
                credentialsId: 'dockerhub-credentials',
                usernameVariable: 'DH_USER',
                passwordVariable: 'DH_TOKEN'
            )
        ]) {
            sh '''
                set -eu
                set +x

                echo "$DH_TOKEN" | docker login \
                  --username "$DH_USER" \
                  --password-stdin

                docker tag nexvion-web:${BUILD_NUMBER} \
                  "$DH_USER/nexvion-web:${BUILD_NUMBER}"

                docker tag nexvion-web:${BUILD_NUMBER} \
                  "$DH_USER/nexvion-web:latest"

                docker push "$DH_USER/nexvion-web:${BUILD_NUMBER}"
                docker push "$DH_USER/nexvion-web:latest"

                docker logout
                echo "Docker Hub push completed."
            '''
        }
    }
}


        stage('Verify Existing Application') {
            steps {
                sh '''
                    set -eu

                    curl --fail --silent \
                      http://127.0.0.1:8080/ -o /dev/null

                    echo "Existing application returned HTTP 200."
                '''
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: GitHub checkout, Docker build and tests completed.'
        }

        failure {
            echo 'FAILED: Check the Console Output for the first error.'
        }

        always {
            sh '''
                docker rm -f ${TEST_CONTAINER} \
                  >/dev/null 2>&1 || true
            '''
        }
    }
}
