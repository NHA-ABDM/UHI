
```
components:
  schemas:
    Ack:
      description: Describes the ACK response
      type: object
      properties:
        status:
          type: string
          description: 'Describe the status of the ACK response. If schema validation passes, status is ACK else it is NACK'
          enum:
            - ACK
            - NACK
      required:
        - status
    Address:
      description: Describes an address
      type: object
      properties:
        door:
          type: string
          description: Door / Shop number of the address
        name:
          type: string
          description: 'Name of address if applicable. Example, shop name'
        building:
          type: string
          description: Name of the building or block
        street:
          type: string
          description: Street name or number
        locality:
          type: string
          description: 'Name of the locality, apartments'
        ward:
          type: string
          description: Name or number of the ward if applicable
        city:
          type: string
          description: City name
        state:
          type: string
          description: State name
        country:
          type: string
          description: Country name
        area_code:
          type: string
          description: 'Area code. This can be Pincode, ZIP code or any equivalent'
    Agent:
      description: Describes an order executor
      allOf:
        - $ref: '#/components/schemas/Person'
        - $ref: '#/components/schemas/Contact'
        - type: object
    Billing:
      description: Describes a billing event
      type: object
      properties:
        name:
          description: Personal details of the customer needed for billing.
          type: string
        organization:
          $ref: '#/components/schemas/Organization'
        address:
          $ref: '#/components/schemas/Address'
        email:
          type: string
          format: email
        phone:
          type: string
        time:
          $ref: '#/components/schemas/Time'
        tax_number:
          type: string
        created_at:
          type: string
          format: date-time
        updated_at:
          type: string
          format: date-time
      required:
        - name
        - phone
    Catalog:
      description: Describes a UHI Protocol-Provider catalog
      type: object
      properties:
        descriptor:
          $ref: '#/components/schemas/Descriptor'
        categories:
          type: array
          items:
            $ref: '#/components/schemas/Category'
        fulfillments:
          type: array
          items:
            $ref: '#/components/schemas/Fulfillment'
        payments:
          type: array
          items:
            $ref: '#/components/schemas/Payment'
        providers:
          type: array
          items:
            $ref: '#/components/schemas/Provider'
        exp:
          type: string
          description: Time after which catalog has to be refreshed
          format: date-time
    Category:
      description: Describes a category
      type: object
      properties:
        id:
          type: string
          description: Unique id of the category
        parent_category_id:
          $ref: '#/components/schemas/Category/properties/id'
        descriptor:
          $ref: '#/components/schemas/Descriptor'
        time:
          $ref: '#/components/schemas/Time'
        tags:
          $ref: '#/components/schemas/Tags'
    City:
      description: Describes a city
      type: object
      properties:
        name:
          type: string
          description: Name of the city
        code:
          type: string
          description: City code
    Contact:
      type: object
      properties:
        phone:
          type: string
        email:
          type: string
        tags:
          $ref: '#/components/schemas/Tags'
    Context:
      description: Describes a UHI Protocol message context
      type: object
      properties:
        domain:
          $ref: '#/components/schemas/Domain'
        country:
          $ref: '#/components/schemas/Country/properties/code'
        city:
          $ref: '#/components/schemas/City/properties/code'
        action:
          type: string
          description: Defines the UHI Protocol API call. Any actions other than the enumerated actions are not supported by UHI Protocol Protocol
          enum:
            - search
            - select
            - init
            - confirm
            - status
            - on_search
            - on_select
            - on_init
            - on_confirm
            - on_status
        core_version:
          type: string
          description: Version of UHI Protocol core API specification being used
        consumer_id:
          type: string
          format: uri
          description: Unique id of the Consumer. By default it is the fully qualified domain name of the Consumer
        consumer_uri:
          type: string
          format: uri
          description: URI of the Consumer for accepting callbacks. Must have the same domain name as the consumer_id
        provider_id:
          type: string
          format: uri
          description: Unique id of the Provider. By default it is the fully qualified domain name of the Provider
        provider_uri:
          type: string
          format: uri
          description: URI of the Provider. Must have the same domain name as the provider_id
        transaction_id:
          type: string
          description: This is a unique value which persists across all API calls from search through confirm
        message_id:
          type: string
          description: This is a unique value which persists during a request / callback cycle
        timestamp:
          type: string
          format: date-time
          description: Time of request generation in RFC3339 format
        key:
          type: string
          description: The encryption public key of the sender
        ttl:
          type: string
          description: The duration in ISO8601 format after timestamp for which this message holds valid
      required:
        - domain
        - action
        - country
        - city
        - core_version
        - transaction_id
        - message_id
        - consumer_id
        - consumer_uri
        - timestamp
    Country:
      description: Describes a country.
      type: object
      properties:
        name:
          type: string
          description: Name of the country
        code:
          type: string
          description: Country code as per ISO 3166-1 and ISO 3166-2 format
    DecimalValue:
      description: Describes a decimal value
      type: string
      pattern: '[+-]?([0-9]*[.])?[0-9]+'

    Descriptor:
      description: Describes the description of a real-world object.
      type: object
      properties:
        name:
          type: string
        code:
          type: string
        symbol:
          type: string
        short_desc:
          type: string
        long_desc:
          type: string
        images:
          type: array
          items:
            $ref: '#/components/schemas/Image'
        audio:
          type: string
          format: uri
        3d_render:
          type: string
          format: uri

    Domain:
      description: Describes the domain of an object
      type: string

    Duration:
      description: Describes duration as per ISO8601 format
      type: string

    Error:
      description: Describes an error object
      type: object
      properties:
        type:
          type: string
        code:
          type: string
          description: 'UHI Protocol specific error code. For full list of error codes, refer to error_codes.md in the root folder of this repo'
        path:
          type: string
          description: Path to json schema generating the error. Used only during json schema validation errors
        message:
          type: string
          description: Human readable message describing the error
      required:
        - type
        - code

    Fulfillment:
      description: Describes how a single product/service will be rendered/fulfilled to the end customer
      type: object
      properties:
        id:
          type: string
          description: Unique reference ID to the fulfillment of an order
        type:
          type: string
          description: This describes the type of fulfillment
        provider_id:
          $ref: '#/components/schemas/Provider/properties/id'
        state:
          $ref: '#/components/schemas/State'
        tracking:
          type: boolean
          description: Indicates whether the fulfillment allows tracking
          default: false
        customer:
          type: object
          properties:
            person:
              $ref: '#/components/schemas/Person'
            contact:
              $ref: '#/components/schemas/Contact'
        person:
          $ref: '#/components/schemas/Agent'
        person:
          $ref: '#/components/schemas/Person'
        contact:
          $ref: '#/components/schemas/Contcat'
        start:
          description: Details on the start of fulfillment
          type: object
          properties:
            time:
              $ref: '#/components/schemas/Time'
            instructions:
              $ref: '#/components/schemas/Descriptor'
            contact:
              $ref: '#/components/schemas/Contact'
            person:
              $ref: '#/components/schemas/Person'
        end:
          description: Details on the end of fulfillment
          type: object
          properties:
            time:
              $ref: '#/components/schemas/Time'
            instructions:
              $ref: '#/components/schemas/Descriptor'
            contact:
              $ref: '#/components/schemas/Contact'
            person:
              $ref: '#/components/schemas/Person'
        tags:
          $ref: '#/components/schemas/Tags'
    
    Image:
      description: 'Image of an object. <br/><br/> A url based image will look like <br/><br/>```uri:http://path/to/image``` <br/><br/>'
      type: string
    
    Intent:
      description: Intent of a user. Used for searching for services
      type: object
      properties:
        descriptor:
          $ref: '#/components/schemas/Descriptor'
        provider:
          $ref: '#/components/schemas/Provider'
        fulfillment:
          $ref: '#/components/schemas/Fulfillment'
        payment:
          $ref: '#/components/schemas/Payment'
        category:
          $ref: '#/components/schemas/Category'
        item:
          $ref: '#/components/schemas/Item'
        tags:
          $ref: '#/components/schemas/Tags'
            
    ItemQuantity:
      description: Describes count or amount of an item
      type: object
      properties:
        allocated:
          type: object
          properties:
            count:
              type: integer
              minimum: 0
            measure:
              $ref: '#/components/schemas/Scalar'
        available:
          type: object
          properties:
            count:
              type: integer
              minimum: 0
            measure:
              $ref: '#/components/schemas/Scalar'
        maximum:
          type: object
          properties:
            count:
              type: integer
              minimum: 1
            measure:
              $ref: '#/components/schemas/Scalar'
        minimum:
          type: object
          properties:
            count:
              type: integer
              minimum: 0
            measure:
              $ref: '#/components/schemas/Scalar'
        selected:
          type: object
          properties:
            count:
              type: integer
              minimum: 0
            measure:
              $ref: '#/components/schemas/Scalar'
    Item:
      description: Describes an item. Allows for domain extension.
      type: object
      properties:
        id:
          description: This is the most unique identifier of a service item. An example of an Item ID could be the SKU of a product.
          type: string
          format: '#/components/schemas/Item/properties/id'
        parent_item_id:
          $ref: '#/components/schemas/Item/properties/id'
        descriptor:
          $ref: '#/components/schemas/Descriptor'
        price:
          $ref: '#/components/schemas/Price'
        category_id:
          $ref: '#/components/schemas/Category/properties/id'
        fulfillment_id:
          $ref: '#/components/schemas/Fulfillment/properties/id'
        time:
          $ref: '#/components/schemas/Time'
        matched:
          type: boolean
        related:
          type: boolean
        recommended:
          type: boolean
        tags:
          $ref: '#/components/schemas/Tags'
    Language:
      description: indicates language code. UHI Protocol supports country codes as per ISO 639.2 standard
      type: object
      properties:
        code:
          type: string
   
    Name:
      type: string
      description: 'Describes the name of a person in format: ./{given_name}/{honorific_prefix}/{first_name}/{middle_name}/{last_name}/{honorific_suffix}'
      pattern: '^\./[^/]+/[^/]*/[^/]*/[^/]*/[^/]*/[^/]*$'

    Order:
      description: Describes the details of an order
      type: object
      properties:
        id:
          type: string
          description: Hash of order object without id
        state:
          type: string
        provider:
          type: object
          properties:
            id:
              $ref: '#/components/schemas/Provider/properties/id'
        items:
          type: array
          items:
            type: object
            properties:
              id:
                $ref: '#/components/schemas/Item/properties/id'
              quantity:
                $ref: '#/components/schemas/ItemQuantity/properties/selected'
            required:
              - id
        billing:
          $ref: '#/components/schemas/Billing'
        fulfillment:
          $ref: '#/components/schemas/Fulfillment'
        quote:
          $ref: '#/components/schemas/Quotation'
        payment:
          $ref: '#/components/schemas/Payment'
        created_at:
          type: string
          format: date-time
        updated_at:
          type: string
          format: date-time

    Organization:
      description: Describes an organization
      type: object
      properties:
        name:
          type: string
        cred:
          type: string

    Page:
      description: Describes a page in a search result
      type: object
      properties:
        id:
          type: string
        next_id:
          type: string

    Payment:
      description: Describes a payment
      type: object
      properties:
        uri:
          type: string
          description: 'A payment target uri to be called by the UHI Protocol-Consumer. Supported formats are <br></br>a) https and, <br></br>b) payto - Refer to RFC8905'
          format: uri
        tl_method:
          type: string
          enum:
            - https
            - payto
        params:
          type: object
          properties:
            transaction_id:
              type: string
              description: This value will be placed in the the $transaction_id url param in case of http/get and in the requestBody http/post requests
            transaction_status:
              type: string
            amount:
              $ref: '#/components/schemas/Price/properties/value'
            currency:
              $ref: '#/components/schemas/Price/properties/currency'
          additionalProperties:
            type: string
          required:
            - currency
        type:
          type: string
          descriptor: Stage at which the payment is expected
          enum:
            - ON-ORDER
            - PRE-FULFILLMENT
            - ON-FULFILLMENT
            - POST-FULFILLMENT
        status:
          type: string
          enum:
            - PAID
            - NOT-PAID
        time:
          $ref: '#/components/schemas/Time'

    Person:
      description: Describes a person.
      type: object
      properties:
        id:
          type: string
        name:
          $ref: '#/components/schemas/Name'
        image:
          $ref: '#/components/schemas/Image'
        dob:
          type: string
          format: date
        gender:
          type: string
          description: 'Gender of something, typically a Person, but possibly also fictional characters, animals, etc. While Male and Female may be used, text strings are also acceptable for people who do not identify as a binary gender'
        cred:
          type: string
        tags:
          $ref: '#/components/schemas/Tags'
      required:
        - name

    Policy:
      description: Describes a policy. Allows for domain extension.
      type: object
      properties:
        id:
          type: string
        descriptor:
          $ref: '#/components/schemas/Descriptor'
        parent_policy_id:
          $ref: '#/components/schemas/Policy/properties/id'
        time:
          $ref: '#/components/schemas/Time'

    Price:
      description: Describes the price of an item. Allows for domain extension.
      type: object
      properties:
        currency:
          type: string
        value:
          $ref: '#/components/schemas/DecimalValue'
        estimated_value:
          $ref: '#/components/schemas/DecimalValue'
        computed_value:
          $ref: '#/components/schemas/DecimalValue'
        listed_value:
          $ref: '#/components/schemas/DecimalValue'
        offered_value:
          $ref: '#/components/schemas/DecimalValue'
        minimum_value:
          $ref: '#/components/schemas/DecimalValue'
        maximum_value:
          $ref: '#/components/schemas/DecimalValue'
          
    Provider:
      description: 'Describes a service provider. This can be a restaurant, a hospital, a Store etc'
      type: object
      properties:
        id:
          type: string
          description: 'Id of the provider'
        descriptor:
          $ref: '#/components/schemas/Descriptor'
        category_id:
          type: string
          description: 'Category Id of the provider'
        time:
          $ref: '#/components/schemas/Time'
        categories:
          type: array
          items:
            $ref: '#/components/schemas/Category'
        fulfillments:
          type: array
          items:
            $ref: '#/components/schemas/Fulfillment'
        payments:
          type: array
          items:
            $ref: '#/components/schemas/Payment'
        items:
          type: array
          items:
            $ref: '#/components/schemas/Item'
        exp:
          type: string
          description: Time after which catalog has to be refreshed
          format: date-time
        tags:
          $ref: '#/components/schemas/Tags'

    Quotation:
      description: Describes a quote
      type: object
      properties:
        price:
          $ref: '#/components/schemas/Price'
        breakup:
          type: array
          items:
            type: object
            properties:
              title:
                type: string
              price:
                $ref: '#/components/schemas/Price'
        ttl:
          $ref: '#/components/schemas/Duration'

    Scalar:
      description: An object representing a scalar quantity.
      type: object
      properties:
        type:
          type: string
          enum:
            - CONSTANT
            - VARIABLE
        value:
          type: number
        estimated_value:
          type: number
        computed_value:
          type: number
        range:
          type: object
          properties:
            min:
              type: number
            max:
              type: number
        unit:
          type: string
      required:
        - value
        - unit

    Schedule:
      description: Describes a schedule
      type: object
      properties:
        frequency:
          $ref: '#/components/schemas/Duration'
        holidays:
          type: array
          items:
            type: string
            format: date-time
        times:
          type: array
          items:
            type: string
            format: date-time

    State:
      description: Describes a state
      type: object
      properties:
        descriptor:
          $ref: '#/components/schemas/Descriptor'
        updated_at:
          type: string
          format: date-time
        updated_by:
          type: string
          description: ID of entity which changed the state

    Subscriber:
      type: object
      description: 'Any entity which wants to authenticate itself on a network. This can be a UHI Protocol-Consumer, UHI Protocol-Provider, DG.'
      properties:
        subscriber_id:
          type: string
          description: Registered domain name of the subscriber. Must have a valid SSL certificate issued by a Certificate Authority of the operating region
        type:
          type: string
          enum:
            - consumer
            - provider
            - gateway
        cb_url:
          type: string
          description: Callback URL of the subscriber. The Registry will call this URL's on_subscribe API to validate the subscriber\'s credentials
        domain:
          $ref: '#/components/schemas/Domain'
        city:
          $ref: '#/components/schemas/City/properties/code'
        country:
          $ref: '#/components/schemas/Country/properties/code'
        signing_public_key:
          type: string
          description: 'Signing Public key of the subscriber. <br/><br/>Any subscriber platform (dhp_consumer, dhp_provider, dg) who wants to transact on the network must digitally sign the ```requestBody``` using the corresponding private key of this public key and send it in the transport layer header. In case of ```HTTP``` it is the ```Authorization``` header. <br><br/>The ```Authorization``` will be used to validate the signature of a dhp_consumer or dhp_provider.<br/><br/>Furthermore, if an API call is being proxied or multicast by a UHI Protocol Gateway, the BG must use it\''s signing key to digitally sign the ```requestBody``` using the corresponding private key of this public key and send it in the ```Proxy-Authorization``` header.'
        encryption_public_key:
          type: string
          description: Encryption public key of the dhp_consumer subscriber. Any dhp_provider must encrypt the ```requestBody.message``` value of the ```on_search``` API using this public key.
        status:
          type: string
          enum:
            - INITIATED
            - UNDER_SUBSCRIPTION
            - SUBSCRIBED
            - INVALID_SSL
            - UNSUBSCRIBED
        created:
          type: string
          description: Timestamp when a subscriber was added to the registry with status = INITIATED
          format: date-time
        updated:
          type: string
          format: date-time
        expires:
          type: string
          description: Expiry timestamp in UTC derived from the ```lease_time``` of the subscriber
          format: date-time

    Tags:
      description: Describes a tag. This is a simple key-value store which is used to contain read-only metadata
      additionalProperties:
        type: string

    Time:
      description: Describes time in its various forms. It can be a single point in time; duration; or a structured timetable of operations
      type: object
      properties:
        label:
          type: string
        timestamp:
          type: string
          format: date-time
        duration:
          $ref: '#/components/schemas/Duration'
        range:
          type: object
          properties:
            start:
              type: string
              format: date-time
            end:
              type: string
              format: date-time
        days:
          type: string
          description: comma separated values representing days of the week
        schedule:
          $ref: '#/components/schemas/Schedule'
          ```
