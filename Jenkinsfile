pipeline {
  agent any

  stages {

    stage('Setup') {
      steps {

        script {

          // Check if mysql is already running
          def mysql_running = sh (
            script: "docker inspect --format='{{.State.Running}}' mysql_test",
            returnStdout: true
          ).trim() == 'true'

          if (!mysql_running) {
            // Set up MySql in a container

            docker.image('mysql:5.7').run(
              '--name mysql_test ' +
              '-e "MYSQL_ROOT_PASSWORD=my-secret-pw" ' +
              '-p 127.0.0.1:3306:3306'
            )
          }

          // Wait for it to be ready
          docker.image('mysql:5').inside("--network container:mysql_test") {
            /* Wait until mysql service is up */
            sh 'while ! mysqladmin ping --silent; do sleep 1; done'
          }
        }
      }
    }

    /*
        rake db:setup
        rake db:migrate
        docker run -p 127.0.0.1:3306:3306 --name mysql-test -e MYSQL_ROOT_PASSWORD=my-secret-pw mysql:5.7
    */


    stage('Build Image'){
      steps {
        echo 'Building docker image...'

        script {
          def app = docker.build('jenkins-docker-sample')

          app.inside {
            sh 'rake db:setup'
            sh 'rake db:migrate'
            sh 'rspec'
          }
        }
      }
    }
  }
}
