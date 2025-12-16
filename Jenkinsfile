// Jenkins Pipeline for DevOps Multi-Cloud Project
// Includes: Code quality, Docker build, security scan, tests, push, deploy

pipeline {
    agent any
    
    environment {
        // Docker Registry
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE_NAME = 'devops-sample-app'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        
        // SonarQube
        SONAR_HOST_URL = 'http://sonarqube:9000'
        SONAR_TOKEN = credentials('sonarqube-token')
        
        // Application
        APP_NAME = 'devops-sample-app'
        APP_VERSION = "${BUILD_NUMBER}"
        
        // Kubernetes
        KUBECONFIG = credentials('kubeconfig')
        K8S_NAMESPACE = 'default'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📦 Checking out code...'
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                }
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo '📥 Installing dependencies...'
                dir('phase2-cicd/sample-app') {
                    sh 'npm ci'
                }
            }
        }
        
        stage('Code Quality - SonarQube') {
            steps {
                echo '🔍 Running SonarQube analysis...'
                dir('phase2-cicd/sample-app') {
                    script {
                        def scannerHome = tool 'SonarQubeScanner'
                        withSonarQubeEnv('SonarQube') {
                            sh """
                                ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=${APP_NAME} \
                                -Dsonar.projectName=${APP_NAME} \
                                -Dsonar.projectVersion=${APP_VERSION} \
                                -Dsonar.sources=. \
                                -Dsonar.exclusions=node_modules/**,test/** \
                                -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                            """
                        }
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                echo '🚦 Waiting for Quality Gate...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                echo '🧪 Running tests...'
                dir('phase2-cicd/sample-app') {
                    sh 'npm test -- --coverage'
                }
            }
            post {
                always {
                    junit '**/test-results/*.xml'
                    publishHTML([
                        reportDir: 'phase2-cicd/sample-app/coverage',
                        reportFiles: 'index.html',
                        reportName: 'Code Coverage Report'
                    ])
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                dir('phase2-cicd/sample-app') {
                    script {
                        dockerImage = docker.build(
                            "${DOCKER_REGISTRY}/${env.DOCKER_IMAGE_NAME}:${GIT_COMMIT_SHORT}",
                            "--build-arg BUILD_DATE=\$(date -u +'%Y-%m-%dT%H:%M:%SZ') " +
                            "--build-arg VCS_REF=${GIT_COMMIT_SHORT} " +
                            "--build-arg VERSION=${APP_VERSION} ."
                        )
                        
                        // Also tag as latest
                        dockerImage.tag('latest')
                    }
                }
            }
        }
        
        stage('Security Scan - Trivy') {
            steps {
                echo '🔒 Scanning image for vulnerabilities...'
                script {
                    sh """
                        trivy image \
                        --severity HIGH,CRITICAL \
                        --format json \
                        --output trivy-report.json \
                        ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${GIT_COMMIT_SHORT}
                    """
                    
                    // Also generate human-readable report
                    sh """
                        trivy image \
                        --severity HIGH,CRITICAL \
                        ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${GIT_COMMIT_SHORT}
                    """
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
                }
            }
        }
        
        stage('Push to Registry') {
            steps {
                echo '📤 Pushing image to Docker registry...'
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", DOCKER_CREDENTIALS_ID) {
                        dockerImage.push("${GIT_COMMIT_SHORT}")
                        dockerImage.push('latest')
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            when {
                branch 'main'
            }
            steps {
                echo '🚀 Deploying to Kubernetes...'
                script {
                    sh """
                        kubectl set image deployment/${APP_NAME} \
                        ${APP_NAME}=${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${GIT_COMMIT_SHORT} \
                        --namespace=${K8S_NAMESPACE} \
                        --record
                    """
                    
                    sh """
                        kubectl rollout status deployment/${APP_NAME} \
                        --namespace=${K8S_NAMESPACE} \
                        --timeout=5m
                    """
                }
            }
        }
        
        stage('Verify Deployment') {
            when {
                branch 'main'
            }
            steps {
                echo '✅ Verifying deployment...'
                script {
                    sh """
                        kubectl get deployment ${APP_NAME} \
                        --namespace=${K8S_NAMESPACE}
                    """
                    
                    sh """
                        kubectl get pods -l app=${APP_NAME} \
                        --namespace=${K8S_NAMESPACE}
                    """
                }
            }
        }
    }
    
    post {
        always {
            echo '🧹 Cleaning up...'
            cleanWs()
        }
        
        success {
            echo '✅ Pipeline completed successfully!'
            script {
                if (env.BRANCH_NAME == 'main') {
                    slackSend(
                        color: 'good',
                        message: "✅ Deployment successful: ${APP_NAME} version ${APP_VERSION}\nCommit: ${GIT_COMMIT_SHORT}"
                    )
                }
            }
        }
        
        failure {
            echo '❌ Pipeline failed!'
            script {
                slackSend(
                    color: 'danger',
                    message: "❌ Deployment failed: ${APP_NAME} version ${APP_VERSION}\nCommit: ${GIT_COMMIT_SHORT}\nCheck: ${BUILD_URL}"
                )
            }
        }
    }
}
