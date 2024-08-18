pipeline {
    agent any
    
    tools {
        maven "MAVEN3"
        jdk "OracleJDK8"
    }

    environment {
        registry = "itsnotrohit/jenkins-ci-cd-docker-build" //DockerHub_account_name/Desired_container_name
        registryCredential = 'dockerhub' //Name of dockerhub credential added in Jenkins
    }

    stages {

        stage('Build') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo "Now Archiving."
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Checkstyle Analysis') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }

        stage('Build App Image') {
            steps {
                script {
                    dockerImage = docker.build registry + ":v$BUILD_NUMBER"
                }
            }
        }

        stage('Sonar Analysis') {
            environment {
                scannerHome = tool 'sonar4.7'
            }
            steps {
                withSonarQubeEnv('sonar') {
                    sh '''${scannerHome}/bin/sonar-scanner \
                    -Dsonar.host.url=http://192.168.33.12:9000 \
                    -Dsonar.projectKey=sample \
                    -Dsonar.projectName=sample \
                    -Dsonar.projectVersion=1.0 \
                    -Dsonar.sources=src/ \
                    -Dsonar.java.binaries=target/test-classes/com/itsnotrohit/account/controllerTest/ \
                    -Dsonar.junit.reportsPath=target/surefire-reports/ \
                    -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                    -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Upload Image'){
            steps {
                script {
                    docker.withRegistry('', registryCredential) {
                        dockerImage.push("v$BUILD_NUMBER")
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Remove Unused Images') {
            steps {
                sh "docker rmi $registry:v$BUILD_NUMBER"
            }
        }

        // stage('Deploy on Kubernetes') {
        //     agent { label 'KOPS' }
        //     steps {
        //         sh "helm upgrade --install --force sample-stack helm/helmcharts --set appimage=${registry}:v${BUILD_NUMBER}"
        //         ////helm upgrade --install --force name_of_chart path/to/charts --set variable_name=variable_value (optionally) --namespace namespace_name
        //     }
        // }
    }
}