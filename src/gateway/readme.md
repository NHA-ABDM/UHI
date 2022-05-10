
# Components

### Common 

Tech Stack: Java - Spring boot

This is helper for UHI protocol. Contains Beans and POJOs for serializing and de-serializing protocol messages


### Discovery 

Tech Stack : Java - WebFlux, Spring Boot

Microservice to handle incoming and outgoing UHI Protocol messages. This module also interacts with the network registry for validating the incomming and outgoing calls. The tought process behind the module covers the following points
    
    1. Decoupling from gateway to aid scaling
    2. Enhancements to be added can be deployed using Blue/Green deployment to ensure minimum downtime
    

### Gateway 

Tech Stack : Java - Spring Cloud Gateway

This the the core routing mechanism for routing the incoming and outgoing messages
