--
-- Created by IntelliJ IDEA.
-- User: francis
-- Date: 02/10/2017
-- Time: 17:29
-- To change this template use File | Settings | File Templates.
--

local crud = require "kong.api.crud_helpers"
local inspect = require "inspect"
local responses = require "kong.tools.responses"
local app_helpers = require "lapis.application"

return {
    ["/v1/ivr_routing/"] = {
        before = function(self, dao_factory, helpers)
            ngx.log(ngx.INFO, "params:", inspect(self.params))
            local api_name = self.params.api_name
            api_name = string.gsub(api_name, " ", "")
            self.params.api_name_or_id = self.params.api_name
            self.params['api_name'] = nil
            crud.find_api_by_name_or_id(self, dao_factory, helpers)
--            crud.find_api_by_name_or_id(self, dao_factory, helpers)
            self.params.api_id = self.api.id
            ngx.log(ngx.INFO, "params:", inspect(self.params))
        end,
        -- load paginated phone numbers
        GET = function(self, dao_factory, helpers)
            crud.paginated_set(self, dao_factory.africastalking_ivr_routing)
        end,
        -- create a phone number to route
        POST = function(self, dao_factory)
            crud.post(self.params, dao_factory.africastalking_ivr_routing)
        end,
        -- edit a phone number to edit
        PUT = function(self, dao_factory)
            crud.put(self.params, dao_factory.africastalking_ivr_routing)
        end
    }
}
