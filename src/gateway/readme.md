
# UHI Gateway

### Approach

![alt text](https://github.com/NHA-ABDM/UHI/blob/main/assets/approach.jpg?raw=true)


-   Gateway handles only initial discovery (Search and On_Search)
-   EUAs and HSPAs will register to the network registry
-   After initial discovery
-   Discovery, Booking and Fulfilment will transact from EUA to HSPA directly


The UHI gateway enables service discovery & handshaking between an EUA & HSPA for facilitating user-initiated service search via the UHI layer. Gateway comprises of 3 main components

### Highlevel Diagram

![alt text](https://github.com/NHA-ABDM/UHI/blob/main/assets/Gateway_HLD.jpg?raw=true)



### Network registry – EUA & HSPA on-boarding
    
Network registry will be an important component of the UHI layer. It will be involved in onboarding/registration of EUA , HSPA and the Gateway itself which act as the participants in the UHI ecosystem. It establishes  authorised communication between the participants. This registry is envisioned to act as a single source of truth for all authorised network participants who have been approved and verified to ensure privacy & security of the communication and data happening within the UHI layer.
> Network registry is an important component, currently the implementer can device any microservice for network registry

### Service Discovery & Handshake between EUA & HSPA
    

An end user shall be able to search a required service by providing a **“search intent”** to the UHI gateway via an EUA, which in turn routs the search requests to many relevant integrated HSPAs. This function will include:

1.  Enable searching a healthcare service via an EUA reference application by enabling multiple advanced search criteria as detailed out under the “service discovery “section.
    
2.  EUA will enable service list aggregation and price comparison for services like digital consultation, physical consultations, lab sample collection, online pharmacy booking etc via the UHI gateway from multiple registered/integrated HSPAs via asynchronous calls.
    
3.  Enable sending a booking request to a selected HSPA from the aggregated service list and providing billing details. In turn the HSPA will share the payment link for the patient to make payment for a prepaid health service or holding the service fee amount on booking confirmation similar to credit card payments can also be explored.
    

  

### APIs

-   **/search** (search API)– Basic & Advanced search for EUAs to send a search intent which is routed by the gateway using the network registry and broadcasted to all registered and authorized HSPAs to get the service availability & slots.
    
-   **/on_search** (on_search API) – To get response against the search intent from all the registered & authorized HSPA who has the service available. This will enable the EUA to aggregate & list the available service catalogue with the health professional and slot details for the end user to choose from to initiate a service booking.


### Definitions

Keywords | Definitions
|------------------------------------|----------------------------------|
UHI (Unified Health Interface) |  UHI gateway as a public good that will enable digital health services to provide services to end users in the healthcare ecosystem.
Health Service Provider (HSPA) |  All healthcare service providers or care givers including health professionals, facilities like hospital, clinics, labs etc. are known as HSPAs.
End User Applications (EUA) | EUAs are patient centric applications that can be utilized by the patients to access various health services like appointment booking, digital consultation, lab sample collection booking etc. EUAs will be integrated with the UHI layer to enable service search, request and service rendering acknowledgements.

### Diagrams

**Overview**

![alt text](https://github.com/NHA-ABDM/UHI/blob/main/assets/ABDM.png?raw=true)

**Sequence**

![alt text](https://github.com/NHA-ABDM/UHI/blob/main/assets/sequence.jpg?raw=true)

