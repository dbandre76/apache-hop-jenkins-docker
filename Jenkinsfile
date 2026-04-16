pipeline {
  agent any

  environment {
    HOP_PROJECT = 'hopdbt'
    HOP_SCRIPT = '/usr/local/tomcat/webapps/ROOT/hop-run.sh'
    DOCKER_CONTAINER = 'hopcontainer-data-eng'
    DBT_CONTAINER = 'dbt-dbt-data-eng'
    DBT_PROJECT_DIR = '/dbt/dbt_aws'
  }

pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }
  stages {
    stage('Detectar pipelines modificados') {
      steps {
        script {
          def arquivos = sh(script: "git diff --name-only HEAD~1 HEAD", returnStdout: true).trim().split('\n')
          def hopFiles = arquivos.findAll { it.endsWith('.hpl') || it.endsWith('.hwf') }

          if (hopFiles.size() == 0) {
            echo "Nenhum pipeline .hpl ou workflow .hwf modificado. Nada será executado."
          } else {
            hopFiles.each { filePath ->
              def tipo = filePath.endsWith('.hpl') ? 'Pipeline' : 'Workflow'
              def nome = filePath.tokenize('/').last().replace('.hpl', '').replace('.hwf', '')
              def relativePath = filePath.replace('projeto_hop/', '')

              def ambientes = env.BRANCH_NAME == 'main' ? ['prd'] : ['dev', 'qa']

              echo "AQUIIIII path /usr/local/tomcat/webapps/ROOT/project/${relativePath}"

              ambientes.each { ambiente ->
                def hopAmbiente = ambiente.toLowerCase()
                def dbtTarget = ambiente.toLowerCase()
                //def dbtTarget = 'dev'

                if (ambiente == 'prd') {
                  stage("Aprovação para PRD - ${nome}") {
                    input message: "Deseja executar ${tipo} '${nome}' em PRD?"
                  }
                }
                //-e ${hopAmbiente} \\
                stage("Hop - ${hopAmbiente}") {
                  echo "Executando ${tipo} ${nome} no ambiente ${hopAmbiente}"
                  sh """
                    docker exec ${DOCKER_CONTAINER} bash -c "${HOP_SCRIPT} \\
                      -p ${HOP_PROJECT} \\
                      -f /usr/local/tomcat/webapps/ROOT/project/${relativePath} \\
                      -e hopdbt-${hopAmbiente} \\
                      -r local"
                  """
                }
                //teste
                stage("DBT Test - Bronze - ${hopAmbiente}") {
                  echo "Executando dbt test nos sources Bronze (${dbtTarget})"
                  sh """
                    docker exec ${DBT_CONTAINER} dbt test \\
                      --project-dir ${DBT_PROJECT_DIR} \\
                      --target ${dbtTarget} \\
                      --select source:bronze
                  """
                }

                stage("DBT Run - Silver - ${hopAmbiente}") {
                  echo "Executando dbt run nos modelos Silver (${dbtTarget})"
                  sh """
                    docker exec ${DBT_CONTAINER} dbt run \\
                      --project-dir ${DBT_PROJECT_DIR} \\
                      --target ${dbtTarget} \\
                      --select path:models/silver
                  """
                }

                stage("DBT Test - Silver - ${hopAmbiente}") {
                  echo "Executando dbt test nos modelos Silver (${dbtTarget})"
                  sh """
                    docker exec ${DBT_CONTAINER} dbt test \\
                      --project-dir ${DBT_PROJECT_DIR} \\
                      --target ${dbtTarget} \\
                      --select path:models/silver
                  """
                }

                stage("DBT Docs Generate - ${hopAmbiente}") {
                  echo "Gerando documentação atualizada do dbt para o ambiente ${dbtTarget}"
                  sh """
                    docker exec ${DBT_CONTAINER} dbt docs generate \\
                      --project-dir ${DBT_PROJECT_DIR} \\
                      --target ${dbtTarget}
                  """
                }
              }
            }
          }
        }
      }
    }
  }
}
