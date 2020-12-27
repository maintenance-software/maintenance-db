pipeline {
    agent any
    environment {
        PATH = "/usr/local/bin:$PATH"
    }
    stages {
        stage ('Create Data Base Image') {
                    when {
                        expression {
                            DATABASE_IMAGE = sh(returnStdout: true, script: 'docker images -a | grep "maintenance-db"').trim()
                            return !DATABASE_IMAGE
                        }
                    }
                    steps {
                        echo 'Creating Data Base Image'
                        sh 'docker build -t maintenance-db:1.0 ./ '
                    }
        }

        stage ('Create Data Base Container') {
                when {
                    expression {
                        DATABASE_CONTAINER = sh(returnStdout: true, script: 'docker ps -aqf ancestor=maintenance-db:1.0').trim()
                        return !DATABASE_CONTAINER
                    }
                }
                steps {
                    echo 'Creating Data Base'
                    sh '( docker logs -f ' + sh(returnStdout: true, script: 'docker run -d -it -p 5432:5432 maintenance-db:1.0').trim() + ' & ) | grep -m2 "ready to accept"'
                }
        }
        stage('Deploy Data Base') {
            steps {
                echo 'Deploying....'
                sh 'docker start $(docker ps -aqf ancestor=maintenance-db:1.0)'
                sh 'docker run --rm -v $PWD/sql:/flyway/sql -v $PWD/conf:/flyway/conf -v $PWD/jars:/flyway/jars flyway/flyway:7.2.1 migrate'
            }
        }
    }
}
