# Elastic Stack with RabbitMQ

This is a set up of Elastic Stack with RabbitMQ as the Message Broker feeding in data to the stack.

The messages are published from NodeRED using MQTT protocol. MQTT is use to simulate messages being published from IoT devices such as a sensor device reading the surrounding  temperature.

The stack deployment is setup into two separate environment: one for development (Dev)and testing, and one for production (Prod).

Two environment is used so that developer may first test the stack locally using the Development Environment deployment. The Dev environment is run using docker-compose for easy start up and test.

The Prod environment is deployed via Kubernetes.

## Development Environment (Dev)

To run the Dev environment, a custom RabbitMQ docker image must be created first. At the root directory of the project run the following code below to create and tag a RabbitMQ image:

```sh
$ docker build -t rabbitmq-mqtt:v1 -f ./DockerFile/Dockerfile.RabbitMQ .
```

## Production Environment (Prod)
