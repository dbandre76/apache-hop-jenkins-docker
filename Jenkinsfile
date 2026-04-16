 pipeline{agent any
environment{
HOP_PROJECT='hopdbt'
HOP_SCRIPT='/usr/local/tomcat/webapps/ROOT/hop-run.sh'
DOCKER_CONTAINER='hopcontainer-data-eng'
DBT_CONTAINER='dbt-dbt-data-eng'
DBT_PROJECT_DIR='/dbt/dbt_aws'
AWS_ACCESS_KEY_ID=credentials('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY=credentials('AWS_SECRET_ACCESS_KEY')
}
stages{
stage('Checkout'){steps{checkout scm}}
stage('Detectar pipelines modificados'){steps{script{
sh "git fetch origin ${env.BRANCH_NAME?:'main'}"
def arquivos=sh(script:"git diff origin/main...HEAD --name-only",returnStdout:true).trim().split('\n').findAll{it}
def hopFiles=arquivos.findAll{it.endsWith('.hpl')||it.endsWith('.hwf')}
if(hopFiles.isEmpty()){
echo "Nenhum pipeline modificado"
currentBuild.result='SUCCESS'
return
}
echo "Arquivos modificados: ${hopFiles}"
hopFiles.each{filePath->
def relativePath=filePath.replace('projeto_hop/','')
def ambientes=(env.BRANCH_NAME=='main')?['prd']:['dev','qa']
ambientes.each{ambiente->
echo "Executando ambiente: ${ambiente}"
if(ambiente=='prd'){
input message:"Aprovar execução em PRD?"
}
sh """
docker exec ${DOCKER_CONTAINER} bash -c \"${HOP_SCRIPT} -p ${HOP_PROJECT} -f /usr/local/tomcat/webapps/ROOT/project/${relativePath} -e hopdbt-${ambiente} -r local\"
"""
sh """
docker exec ${DBT_CONTAINER} dbt test --project-dir ${DBT_PROJECT_DIR} --target ${ambiente} --select source:bronze
"""
}
}
}}}}
post{
success{echo "Pipeline executed successfully"}
failure{echo "Pipeline failed"}
}
}