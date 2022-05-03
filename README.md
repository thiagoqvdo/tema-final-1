# Tema final #1

## Informações
Abaixo contém alguns dos URL's utilizados neste pipeline e o vídeo de demonstração. Todos os repositórios são acessíveis, exceto pelo JFrog.

| Conteúdo                   | URL |
|----------------------------|-----|
| Vídeo de <br/>demonstração |  https://www.youtube.com/watch?v=IUYcLVLHWxU   |
| Repositório da aplicação   | https://github.com/thiagoqvdo/basic-email-sharer |
| Repositório dockerhub      |  https://hub.docker.com/repository/docker/qvdo/basic-email-sharer |
| JFrog Plataform            |  https://thiagoqvdo.jfrog.io/ui/packages |

## Tecnologias utilizadas
Este pipeline contém algumas tecnologias que devem estar presentes em sua máquina local, virtual ou container.

Lista de tecnologias: [Openjdk-11](https://www.oracle.com/br/java/technologies/javase/jdk11-archive-downloads.html), [Git](https://git-scm.com/downloads), [Gradle](https://gradle.org/install/), [Docker](https://docs.docker.com/engine/install/), [Jenkins](https://www.jenkins.io/download/), [Packer](https://www.packer.io/downloads), [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

#### Importante
O projeto utiliza o JFrog Artifactory na nuvem, e não local, por isso não há a necessidade de instalação, mas é necessário um usuário e senha de acesso, que estarei disponibilizando.

## Configurações
Para rodar a pipeline é necessário alguns passos de configuração:

### Start Jenkins
A primeira coisa que deve ser feito é iniciar o Jenkins, ele é a tecnologia principal.
Você pode executar o jenkins tanto localmente, baixando o arquivo .war na lista de tecnologias, quanto em um container docker.

Caso opte pela primeira opção execute no terminal o seguinte comando: 

    java -jar jenkins.war --httpPport=8080

Agora, caso escolha executar em container docker, há diversas maneiras de se fazer, mas eu recomendo a seguinte forma. Execute o comando:

    docker run --name jenkins -p 8080:8080 -p 50000:50000 -v /opt/jenkins/:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):$(which docker) -v /usr/local/bin/packer:/usr/local/bin/packer jenkins/jenkins:lts

Para executar desta forma é importante que já tenha o packer e docker instalados seguindo a documentação oficial.

Depois é importante conceder permissão ao container de executar comandos docker, seguindo da seguinte forma.
Execute este comando para entrar no terminal do container:

    docker exec -u root -it jenkins bash

E depois o comando para fornecer as permissões necessárias:
    
    chmod 666 /var/run/docker.sock

Após iniciar o Jenkins, acesse ele em https://localhost:8080. Siga as instruções para desbloquear e instale os plugins recomendados.

Posteriormente, instale o plugin _Artifactory_, indo em `Manage Jenkins -> Manage Plugins`.
### JFrog Config 
É muito importante para o projeto adicionar as configurações do JFrog Artifactory, para isso vá em `Manage Jenkins -> Configure System` e procure pela seção JFrog.

Clique em `Add JFrog Plataform Instace` e adicione as seguintes informações:

| Propriedade           | Valor                       |
|-----------------------|-----------------------------|
| `Instace ID`          | `basic-email-sharer`        |
| `JFrog Plataform URL` | https://thiagoqvdo.jfrog.io |
| `Username`            | `admin`                     |
| `Password`            | `Unzipping@2022`            |

É importante que o usuário e senha sejam os mesmo, porque é uma plataforma JFrog privada, este é um usuário que eu cadastrei especificamente para este projeto.

### DockerHub Config
Para executar o job2, que criará uma imagem docker e publicar no repositório do docker hub, e preciso primeiramente fazer cadastro na plataforma do Docker Hub.
Depois que se cadastrar, selecione a opção `Create Repository`. Defina o nome do repositório como `basic-email-sharer` e marque como `Public` (é importante que seja este mesmo nome, e esteja como `Public`).

Após isso, acessando `Account Settings -> Security`, crie um _token_ de acesso com permissão `Read, Write, Delete`. É importante que você salve este _token_, poque ele depois ele não é mais visível.

## Jobs
No `Dashboard` do Jenkins, clique em `New Job`. Escolha um nome adequado, selecione a opção `Pipeline` e clique em `Ok`.
Na nova janela aberta, desça até o setor `Pipeline`, e altere onde está `Pipeline script` para `Pipeline script from SCM`. 

No campo `SCM` selecione `Git`, e em `Repository Url` adicione a URL da aplicação.
Todos os jobs seguirão este modelo, alterando apenas o nome do Job e o `Script Path`, que devem ser inseridos da seguinte forma:

| Job  | Path               |
|------|--------------------|
| Job1 | ./job1/Jenkinsfile |
| Job2 | ./job2/Jenkinsfile |
| Job3 | ./job3/Jenkinsfile |

### Job1
O primeiro job contém 4 passos:
1. Clona a branch master da aplicação utilizada neste projeto.
2. Realiza os testes da aplicação e realiza um build, compilando a aplicação em um jar.
3. Faz o upload dos arquivos jar's gerados pela aplicação para o JFrog Artifactory.
4. Publica no artifactory as informações do build realizado.

### Job2
O segundo job contém 2 passos:
1. Faz download dos arquivos jar presente no JFrog Artifactory.
2. Constrói uma imagem docker e exporta para o repositório do usuário inserido no Jenkins.

### Job3
O terceiro job contém 2 passos:
1. Faz pull da imagem construída no job2.
2. Executa um docker run da imagem que foi realizado o pull.

## Utilizando a aplicação

Para utilizar a aplicação, envie uma requisição de método POST para a URL `http://localhost:8090/sendEmail`, contendo no body da requisição um objeto JSON com as propriedades do email.
O objeto JSON deve conter:

* recipient -> Para quem será enviado o email.
* title -> O título/assunto do email.
* message -> A mensagem do email.

Exemplo de objeto JSON:

    {
        "recipient": "emailparaenviar@gmail.com",
        "title": "Teste",
        "message": "Testando envio de emails"
    }
