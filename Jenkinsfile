pipeline {
  agent any

  environment {
    HOP_PROJECT = 'hopdbt'
    HOP_SCRIPT = '/usr/local/tomcat/webapps/ROOT/hop-run.sh'
    DOCKER_CONTAINER = 'hopcontainer-data-eng'
    DBT_CONTAINER = 'dbt-dbt-data-eng'
    DBT_PROJECT_DIR = '/dbt/dbt_aws'

    AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
  }

  stages {
    stage('Detectar pipelines modificados') {
      steps {
        script {

          def arquivos = sh(script: "git diff --name-only HEAD~1 HEAD", returnStdout: true)
            .trim()
            .split('\n')
            .findAll { it }

          def hopFiles = arquivos.findAll { it.endsWith('.hpl') || it.endsWith('.hwf') }

          if (!hopFiles) {
            echo "Nenhum pipeline modificado"
            return
          }

          hopFiles.each { filePath ->

            def nome = filePath.tokenize('/').last()
            def relativePath = filePath.replace('projeto_hop/', '')

            def ambientes = env.BRANCH_NAME == 'main' ? ['prd'] : ['dev', 'qa']

            ambientes.each { ambiente ->

              def hopAmbiente = ambiente
              def dbtTarget = ambiente

              if (ambiente == 'prd') {
                input message: "Executar em PRD?"
              }

              sh """
                docker exec ${DOCKER_CONTAINER} bash -c "${HOP_SCRIPT} \
                  -p ${HOP_PROJECT} \
                  -f /usr/local/tomcat/webapps/ROOT/project/${relativePath} \
                  -e aws-target-${hopAmbiente} \
                  -r local"
              """

              sh """
                docker exec ${DBT_CONTAINER} dbt test \
                  --project-dir ${DBT_PROJECT_DIR} \
                  --target ${dbtTarget} \
                  --select source:silver
              """
            }
          }
        }
      }
    }
  }
}