
local AFRICASTALKING_IVR_ROUTING = {
    primary_key = {"id"},
    table = "africastalking_ivr_routing",
    cache_key = { "phone_number" },
    fields = {
        id = {type = "id", dao_insert_value = true},
        phone_number = {type = "string", unique = true, required = true},
        api_id = {type = "id", required = true,  foreign = "apis:id"}
    }
}

return {
    africastalking_ivr_routing = AFRICASTALKING_IVR_ROUTING
}