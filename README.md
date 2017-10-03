`Adding phone number to redirect traffic`

    curl -i http://localhost:8001/v1/ivr_routing -X POST --data api_name=ivr --data "phone_number=254702729659"
    
`Enable plugin this plugin`
    
    curl -i http://localhost:8001/plugins --data name=africastalking_ivr_routing