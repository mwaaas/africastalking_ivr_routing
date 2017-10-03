--
-- Created by IntelliJ IDEA.
-- User: francis
-- Date: 26/05/2017
-- Time: 6:19 AM
-- To change this template use File | Settings | File Templates.
--

return {
    {
        name="001_africastalking_ivr_routing",
        up = [[
        BEGIN;
        create table africastalking_ivr_routing (
	        id uuid not null
	            constraint africastalking_ivr_routing_pkey primary key,
	        phone_number text UNIQUE not null,
	        api_id uuid not null
		        constraint africastalking_ivr_routing_id_1_fk_apis
			    references apis
				deferrable initially deferred,

	        constraint africastalking_ivr_routing_phone_number_permission_id_1_uniq
		    unique (phone_number, api_id)
		    )
		    ;

        create index africastalking_ivr_routing_phone_number_1
	        on africastalking_ivr_routing (phone_number);

        create index africastalking_ivr_routing_api_id_1
	        on africastalking_ivr_routing (api_id);

	    COMMIT;
        ]],
        down = [[
            DROP TABLE "africastalking_ivr_routing";
        ]]
    }
}

