# Elastic Stack with RabbitMQ

This is a set up of Elastic Stack with RabbitMQ as the Message Broker feeding in data to the stack.

The messages are published from NodeRED using MQTT protocol. MQTT is use to simulate messages being published from IoT devices such as a sensor device reading the surrounding  temperature.

The stack deployment is setup into two separate environment: one for development (Dev)and testing, and one for production (Prod).

Two environment is used so that developer may first test the stack locally using the Development Environment deployment. The Dev environment is run using docker-compose for easy start up and test.

The Prod environment is deployed via Kubernetes.

## Software Development Workflow

This project was created to demonstrate a workflow for software development. 

An application is first dockerised and tested locally using Docker Compose to orchestrate the Docker services together (Docker Compose will be replaced by Kubernetes in Pro). Docker Compose is used in the Dev environment because it's easy to set up quickly and get to testing the application.


## Development Environment (Dev)

To run the Dev environment, a custom RabbitMQ docker image must be created first. At the root directory of the project run the following code below to create and tag a RabbitMQ image:

```sh
$ docker build -t rabbitmq-mqtt:v1 -f RabbitMQ.Dockerfile .
```

## Production Environment (Prod)

The Prod environment will be deployed to a Kubernetes (k8s) cluster on Azure.

In the production environment a customer LogStash docker image must be created to include the config file for RabbitMQ input of LogStash. At the root directory of the project run the following code below to create and tag a LogStash image:

```sh
$ docker build -t logstash-rabbitmq:v1 -f Logstash.Dockerfile .
```

The following command below is use for:
- create the Azure resource group
- create a Azure container registry
- push Docker images to the registry
- create a service principle
- assign permission for the Kubernestes cluster to be able to pull from the registry
- create a Kubernetes cluster
- get credential of the Kubernetes cluster
- apply a Kubernetes config file to the cluster

```sh
$ az group create --name elasticStackRabbitMQ --location southeastasia
$ az acr create --resource-group elasticStackRabbitMQ --name <containerRegistryName> --sku Basic
$ az acr list --resource-group elasticStackRabbitMQ --query "[].{acrLoginServer:loginServer}" --output table
$ az acr login --name <acrName>
$ docker tag rabbitmq-mqtt:v1 <acrName>/rabbitmq-mqtt:v1
$ docker push <acrName>/rabbitmq-mqtt:v1
$ docker tag logstash-rabbitmq:v1 <acrName>/logstash-rabbitmq:v1
$ docker push <acrName>/logstash-rabbitmq:v1
$ az acr repository list --name <containerRegistryName> --output table
$ az acr repository show-tags --name <containerRegistryName> --repository logstash-rabbitmq --output table
$ az acr repository show-tags --name <containerRegistryName> --repository rabbitmq-mqtt --output table
$ az ad sp create-for-rbac --skip-assignment
$ az acr show --resource-group elasticStackRabbitMQ --name <containerRegistryName> --query "id" --output tsv
$ az role assignment create --assignee <appId> --scope <acrId> --role acrpull
$ az aks create --resource-group elasticStackRabbitMQ --name AKSCluster --node-count 2 --service-principal <appId> --client-secret <password> --generate-ssh-keys --no-wait
$ az aks get-credentials --resource-group elasticStackRabbitMQ --name AKSCluster --overwrite-existing
$ kubectl apply -f elastic-stack-rabbitmq.yaml
```
