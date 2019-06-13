#!groovy

@Library('github.com/red-panda-ci/jenkins-pipeline-library@v3.1.6') _

// Initialize global config
cfg = jplConfig('dc-get-next-release-number', 'bash', '', [slack: '#integrations', email:'redpandaci+dc-get-next-release-number@gmail.com'])

pipeline {
    agent none

    stages {
        stage ('Initialize') {
            agent { label 'docker' }
            steps  {
                jplStart(cfg)
            }
        }
        stage ('Build') {
            agent { label 'docker' }
            steps {
                script {
                    jplDockerPush (cfg, "kairops/dc-get-next-release-number", "test", ".", "https://registry.hub.docker.com", "cikairos-docker-credentials")
                }
            }
        }
        stage ('Test') {
            agent { label 'docker' }
            steps  {
                sh 'bin/test.sh'
            }
        }
        stage ('Make release'){
            agent { label 'docker' }
            when { branch 'release/new' }
            steps {
                script { cfg.releaseTag = sh (script: "kd get-next-release-number .", returnStdout: true).trim() }
                jplDockerPush (cfg, "kairops/dc-get-next-release-number", cfg.releaseTag.substring(1), ".", "https://registry.hub.docker.com", "cikairos-docker-credentials")
                jplDockerPush (cfg, "kairops/dc-get-next-release-number", "latest", ".", "https://registry.hub.docker.com", "cikairos-docker-credentials")
                jplCloseRelease(cfg)
            }
        }
    }

    post {
        always {
            jplPostBuild(cfg)
        }
    }

    options {
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(artifactNumToKeepStr: '20',artifactDaysToKeepStr: '30'))
        disableConcurrentBuilds()
        timeout(time: 1, unit: 'DAYS')
    }
}
