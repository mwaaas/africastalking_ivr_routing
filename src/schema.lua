--
-- Created by IntelliJ IDEA.
-- User: francis
-- Date: 27/09/2017
-- Time: 08:26
-- To change this template use File | Settings | File Templates.
--

local ivr_routing_api = {}
ivr_routing_api['ivr'] = true

return {
  no_consumer = true,
  fields = {
    ivr_routing_api = {
      type = "table",
      default = ivr_routing_api
    },
  }
}
