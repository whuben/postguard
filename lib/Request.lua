--create by whuben
--2017-07-01
--Description: class for fetching the request object

local ck = require 'lib.resty.cookie'

local ngx_var = ngx.var
local ngx_req_get_method = ngx.req.get_method
local ngx_req_get_headers = ngx.req.get_headers
local ngx_req_get_url_args = ngx.req.get_uri_args

local _M = {
    
}
_M.VERSION = "0.1"

function  _M.new(self)
    local request = {
    uri = nil,
    method = nil,
    client_ip = nil,
    server_ip = nil,
    headers = nil,
    cookies = nil,
    uri_args = nil,
    body = nil
    }
    return setmetatable(request,{ __index = self })
end

function _M.get_uri(self)
    if self.uri == nil then
        self.uri = ngx_var.uri
    end
    return self.uri
end

function _M.get_method(self)
    if self.method == nil then
        self.method = ngx_req_get_method()
    end
    return self.method
end

function _M.get_client_ip(self)
    if self.client_ip == nil then
        self.client_ip = ngx_var.remote_addr
    end
end

function _M.get_server_ip(self)
    if self.server_ip == nil then
        self.server_ip = ngx_var.http_host
    end
    return self.server_ip
end

function _M.get_headers(self)
    if self.headers == nil then
        self.headers = ngx_req_get_headers()
    end
    return self.headers
end

function _M.get_cookies(self)
    -- the cookie may get nil value
    if self.cookies == nil then
        self.cookies = ck:get_all()
        if self.cookies == nil then 
            self.cookies = {}
        end
    end
    return self.cookies
end

function _M.get_uri_args(self)
    if self.uri_args == nil then
        self.uri_args = ngx_req_get_url_args()
    end
    return self.uri_args
end

function _M.get_body(self)
    --TBC
    return self.body
end

return _M
