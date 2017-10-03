--
-- Created by IntelliJ IDEA.
-- User: francis
-- Date: 27/09/2017
-- Time: 08:26
-- To change this template use File | Settings | File Templates.
--

local BasePlugin = require "kong.plugins.base_plugin"
local responses = require "kong.tools.responses"
local singletons = require "kong.singletons"
local json = require('cjson.safe')
local ngx = ngx
local kong_pub_utils = require "kong.tools.public"
local url      = require "socket.url"
local tonumber = tonumber
--local router = require "kong.core.router"


local AfricastalkingIvrRouting = BasePlugin:extend()
AfricastalkingIvrRouting.PRIORITY = 1998

function AfricastalkingIvrRouting:new()
  AfricastalkingIvrRouting.super.new(self, "africastalking_ivr_routing")
end


function AfricastalkingIvrRouting:access(config)

    AfricastalkingIvrRouting.super.access(self)

    ngx.log(ngx.INFO, "============ africastalking_ivr_routing ============")

    -- Details (from ngx context) of api being accessed
    local service = ngx.ctx.api

    ngx.log(
        ngx.INFO,
        "API being accessed:",
        json.encode(service)
    )

    local api_name = service['name']

    ngx.log(
        ngx.INFO,
        "[africastalking_ivr_routing]: CONFIG passed: ",
        json.encode(config)
    )

    if config['ivr_routing_api'][api_name] ~= nil then
        -- get service code
        ngx.log(
            ngx.INFO,
            "[africastalking_ivr_routing]: API redirect: ",
            json.encode(api_name))

        local request_body_params = AfricastalkingIvrRouting.retrieve_body_parameters()
        local inspect = require "inspect"
        local callerNumber = request_body_params.callerNumber
        ngx.log(ngx.INFO, "caller_to_route:", callerNumber)
        if callerNumber ~= nil then
            local cache_key = singletons.dao.africastalking_ivr_routing:cache_key(callerNumber)
            local api, err = singletons.cache:get(
                cache_key,
                nil,
                AfricastalkingIvrRouting.get_api_details,
                callerNumber
            )

            if err then
                ngx.log(ngx.INFO, "error:", err)
            elseif api == nil then
                ngx.log(ngx.INFO, "Api not found")
            else
                local parsed = url.parse(api.upstream_url)

                local upstream_url_t = {
                    scheme             = parsed.scheme,
                    host               = parsed.host,
                    port               = tonumber(parsed.port)
                }
                if not upstream_url_t.port then
                    if parsed.scheme == "https" then
                        upstream_url_t.port = 443
                    else
                        upstream_url_t.port = 80
                    end
                end
                -- parsed.scheme
                ngx.ctx.balancer_address.host = upstream_url_t.host
                ngx.ctx.balancer_address.port = upstream_url_t.port
                local var = ngx.var
                var.upstream_scheme = upstream_url_t.scheme
                var.upstream_uri = ""
            end

        end
    else
        ngx.log(
            ngx.INFO,
            "[africastalking_ivr_routing]: API exempted from redirect: ",
            json.encode(api_name)
    )
    end
end

function AfricastalkingIvrRouting.get_api_details(callerNumber)
    ngx.log(ngx.INFO, "HERE:", callerNumber)
    callerNumber = string.gsub(callerNumber, "+", "")
    local ivr_routing, error = singletons.dao.africastalking_ivr_routing:find_all({
        phone_number = callerNumber
    })
    local inspect = require "inspect"
    ngx.log(ngx.INFO, "API:", inspect(ivr_routing))
    -- when an error occurs, return nil and the error
    if error then
        ngx.log(ngx.INFO, "ERROR:", error)
        return nil, error
    end
        -- not found
    if not ivr_routing then
        return nil, string.format("api %s not found", callerNumber)
    end

    if #ivr_routing == 0 then
        return nil, string.format("api %s not found", callerNumber)
    end

    local api_id = ivr_routing[1].api_id

    return singletons.dao.apis:find { id = api_id }
end

function AfricastalkingIvrRouting.retrieve_body_parameters()
    -- get http parametes passed from both body and query
    ngx.req.read_body()
    local gba = kong_pub_utils.get_body_args

    return AfricastalkingIvrRouting.table_merge(ngx.req.get_uri_args(), gba())
end

function AfricastalkingIvrRouting.table_merge(t1, t2)
    -- merge two tables into one
    if not t1 then t1 = {} end
    if not t2 then t2 = {} end

    local res = {}
    for k, v in pairs(t1) do res[k] = v end
    for k, v in pairs(t2) do res[k] = v end
    return res
end

function AfricastalkingIvrRouting.split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end


return AfricastalkingIvrRouting