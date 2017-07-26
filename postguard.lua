--create by whuben
--2017-06-20
--Description: postguard

local Log = ngx.log
local Err = ngx.ERR 
local string_format = string.format
local ngx_re_match = ngx.re.match

local DEFAULT_EXPIRE_TIME = 600
local req_dict = ngx.shared.GET_REQ
local post_referer = ngx.shared.POST_REFERER
local config = require "config"
local Request = require "lib.Request"
local req_obj = Request:new()

--return a md5 string for identifying a client user
local function get_client_hash(uri)
    local req_url
    if uri == nil then
        req_url = req_obj:get_uri()
    else
        req_url = uri
    end
    local tag_target = config.tags.category
    local req_cip = req_obj:get_client_ip()
    local req_sip = req_obj:get_server_ip()
    local baseinfo = string_format("%s_%s_%s",req_cip,req_sip,req_url)
    local user_tag = nil
    if tag_target == "cookie" then
        local req_cookies = req_obj:get_cookies()
        local target_name = config.tags.name
        if target_name ~= nil then
            user_tag = req_cookies[target_name]
        end
    end
    if user_tag ~= nil  and type(user_tag) == string then --the key may refer to a table 
        baseinfo = string_format("%s_%s",user_tag,baseinfo)
    end
    return ngx.md5(baseinfo)
end

--fetch the uri from a given referer
local function get_uri_by_referer(referer)
    local m,err = ngx_re_match(referer,[=[https?://[^/]+(/?[^?]*)]=],"jio")
    if m then
        return m[1]
    else
        return nil
    end
end

--bad request response when failed with the checking of postguard
local function bad_request_response()
    err_msg = "Bad Request!"
    ngx.status = ngx.HTTP_BAD_REQUEST
    Log(Err,err_msg)
    ngx.say(err_msg)
    ngx.exit(ngx.status)
end 

-- deal with a GET request
local function deal_get_method()
    --deal with the GET request
    local client_hash = get_client_hash()
    Log(Err,"GET HASH:"..client_hash)
    local expire_time = DEFAULT_EXPIRE_TIME
    if config.req_expire ~= nil then
        expire_time = config.req_expire
    end
    req_dict:set(client_hash,0,expire_time)
end

--deal with a POST request
local function deal_post_method()
    --deal with the post request
    local req_referer = req_obj:get_headers()["referer"]
    local referer_uri = nil
    if req_referer ~= nil then
        referer_uri = get_uri_by_referer(req_referer)
    end
    if config.mode == 0 then -- trainning mode
       -- in trainning mode just recoder every post referer
       if req_referer ~= nil and referer_uri ~= nil then
            local req_url = req_obj:get_uri()
            local sip = req_obj:get_server_ip()
            local baseinfo = string_format("%s_%s",req_url,sip)
            local base_hash = ngx.md5(baseinfo)
            local msg = string_format("[Training Mode] server:%s uri:%s referer_uri:%s",sip,req_url,referer_uri)
            Log(Err,msg)
            --post_referer:set(base_hash,referer_uri)
        end

    else                     --detection mode
        if referer_uri == nil then
            Log(Err,"Can't find the uri from referer")
            return
        end
        local client_hash = get_client_hash(referer_uri)
        if req_dict:get(client_hash) then --check whether the referer uri has been accessd in resent 
            return
        else
            bad_request_response()
        end
    end

end


-- main entry 
local function guard_main()
    if config.enabled ~= "on" then
        return
    end
    local req_method = req_obj:get_method()
    if req_method == "GET" then
        deal_get_method()
    elseif req_method == "POST" or req_method == "PUT" then
        deal_post_method()
    else
        return
    end
end

local function exception(err)
    Log(Err,"[Exception]:"..err)
end

xpcall(guard_main,exception)
