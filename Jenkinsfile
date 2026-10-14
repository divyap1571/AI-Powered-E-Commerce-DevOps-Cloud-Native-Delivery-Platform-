pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        IMAGE_NAME = 'nexvion-web'
        CONTAINER_NAME = 'nexvion-web'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate Files') {
            steps {
                sh '''
                    set -eu
                    test -f Dockerfile
                    test -f compose.yaml
                    test -f nginx.conf
                    test -f index.html
                    test -f products.html
                    test -f payment.html
                    echo "Required application files are present."
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .'
            }
        }

        stage('Test Docker Image') {
            steps {
                sh '''
                    set -eu
                    docker run -d --rm --name nexvion-ci-test \
                        -p 127.0.0.1:18080:80 \
                        ${IMAGE_NAME}:${BUILD_NUMBER}

                    trap 'docker stop nexvion-ci-test >/dev/null 2>&1 || true' EXIT

                    for attempt in $(seq 1 15); do
                        if curl --fail --silent http://127.0.0.1:18080/ \
                            -o /dev/null; then
                            echo "HTTP smoke test passed."
                            exit 0
                        fi
                        sleep 2
                    done

                    echo "HTTP smoke test failed."
                    exit 1
                '''
            }
        }

        stage('Verify Running Application') {
            steps {
                sh '''
                    set -eu
                    curl --fail --silent http://127.0.0.1:8080/ \
                        -o /dev/null
                    echo "Existing Nexvion deployment is responding."
                '''
            }
        }
    }

    post {
        success {
            echo 'CI pipeline passed: build and smoke test successful.'
        }
        failure {
            echo 'CI pipeline failed. Check stage logs for details.'
        }
    }
}
