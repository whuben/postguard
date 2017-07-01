--create by whuben
--2017-06-20
--Description: config file for postguard

local _M = {
    enabled = "on",           -- enable the postguard detection
    mode = 1,                 -- 0:trainning mode,only record the referer of every post request to error log; 1: detection mode
    tags = {
        category = "cookie",  -- custom user tag by cookie 
        name = "post_guard"   -- the param name of cookie
    },
    req_expire = 600          -- the expire time of a GET reqeust recorded in the shared dict
}

return _M