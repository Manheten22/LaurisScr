local api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
api.script_id = "0374efb065518f41319ffcba6adbcac0"
    local status = api.check_key(script_key)
    if status.code == "KEY_VALID" then
        local secs = status.data.auth_expire > 0 and (status.data.auth_expire - os.time()) or math.huge
        _G.script_key       = key
        getgenv().script_key = key
        api.load_script()
    elseif status.code == "KEY_HWID_LOCKED" then
        print("Key locked to another HWID.\nReset via bot.")
    elseif status.code == "KEY_INCORRECT" then
        print("Key wrong or deleted!")
    else

    end
