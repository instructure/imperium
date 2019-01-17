#! /usr/bin/env groovy

pipeline {
    agent { label 'docker' }

    stages {
        stage("Build Image") {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    dockerCacheLoad(image: "imperium_app")
                    sh """docker-compose build --pull"""
                }
            }
        }

        stage("Run Tests") {
            steps {
                sh """docker-compose run --rm app"""
            }
        }
    }

    post {
        success {
            timeout(time: 5, unit: 'MINUTES') {
                dockerCacheStore(image: "imperium_app")
            }
        }
    }
}
