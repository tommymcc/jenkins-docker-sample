def jobs = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]

def parallelStagesMap = jobs.collectEntries {
    ["${it}" : generateStage(it)]
}

def generateStage(job) {
  return {
    stage("stage: ${job}") {

      node {

        // Necessary for scripted pipeline
        docker.image('alpine:latest').inside {
          echo "This is ${job}."
          sh "id"
          sh script: "sleep 15"
        }
      }
    }
  }
}


pipeline {
  agent any

  stages {

    stage('Setup') {
      steps {

        script {
          /*
          * Create a network to link the database and built container
          * It's alright if it already exists
          */
          sh 'docker network create jenkins_test || true'

          setupDatabase()
        }
      }
    }

    /*
    stage('Lint') {
      when { not { branch 'master' } }

      environment {
        PRONTO_TOKEN = credentials('PRONTO_GITHUB_ACCESS_TOKEN')
      }

      steps {
        echo 'Linting...'

        script {

          docker.image('tommymccallig/codelint:0.0.1').inside(
            "-e PRONTO_GITHUB_ACCESS_TOKEN=${env.PRONTO_TOKEN} " +
            "-e PRONTO_PULL_REQUEST_ID=${env.CHANGE_ID} "
          ){
            sh 'pronto run -f github_status github_pr_review -c origin/master'
          }
        }
      }
    }
    */

    stage('Test') {
      when { not { branch 'master' } }

      steps {
        script {
          parallel parallelStagesMap
        }
      }
    }

    stage('Build Image'){
      steps {
        echo 'Building docker image...'

        script {
          def app = docker.build('jenkins-docker-sample')

          // If the database is still initialising, we wait
          ensureDatabase()

          def testConfig =
            '--network jenkins_test ' +
            '-e "DATABASE_URL=mysql2://root:my-secret-pw@jenkinsmysql/testdb"'

          app.inside(testConfig) {
            sh 'rake db:setup'
            sh 'rake db:migrate'
            sh 'rspec --format progress --format RspecJunitFormatter --out tmp/rspec.xml'
          }
        }
      }

      post {
        always {
          junit 'tmp/rspec.xml'
        }
      }
    }
  }
}

def setupDatabase(){
  if (databaseExists() && !databaseRunning()) {
    sh 'docker rm jenkinsmysql'
  }

  if (!databaseExists()) {
    // Set up MySql in a container

    docker.image('mysql:5.7').run(
      '--name jenkinsmysql ' +
      '--network jenkins_test ' +
      '--health-cmd=\'mysqladmin ping --silent\' ' +
      '--health-interval=2s ' +
      '-e "MYSQL_ROOT_PASSWORD=my-secret-pw" ' +
      '-p "3306:3306"'
    )
  }
}

def ensureDatabase(){
  timeout(time: 6, unit: 'MINUTES') {
    while(!databaseHealthy()) {
      sleep 2
    }
  }
}

def databaseHealthy(){
  sh (
    script: "docker inspect --format '{{.State.Health.Status}}' jenkinsmysql",
    returnStdout: true
  ).trim().equals('healthy')
}

def databaseRunning(){
  sh (
    script: "docker inspect --format='{{.State.Running}}' jenkinsmysql",
    returnStdout: true
  ).trim().equals('true')
}

def databaseExists(){
  sh (
    script: "docker inspect jenkinsmysql -f {}",
    returnStatus: true
  ) == 0
}