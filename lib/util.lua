local util = {}

local http = require("http")
local json = require("json")

function util:fetch_versions()
    local resp, err = http.get({
        url = "https://api.github.com/repos/ninja-build/ninja/releases"
    })
    if err ~= nil or resp.status_code ~= 200 then
        return {}
    end
    local osType = RUNTIME.osType
    local archType = RUNTIME.archType
    if osType == "windows" then
        osType = "win"
        archType = archType == "amd64" and "" or "-arm64"
    elseif osType == "linux" then
        osType = "linux"
        archType = archType == "amd64" and "" or "-aarch64"
    elseif osType == "darwin" then
        osType = "mac"
        archType = ""
    end
    local body = json.decode(resp.body)
    local versions = {}
    for _, release in pairs(body) do
        local tag = release["tag_name"]
        local assets = release["assets"]
        for _, asset in pairs(assets) do
            local name = asset["name"]
            if string.match(name, osType .. archType .. "%.zip$") then
                tag = string.gsub(tag, "v", "")
                table.insert(versions, tag)
            end
        end
    end
    return versions
end

function util:fetch_available()
    local versions = self:fetch_versions()
    local result = {}
    for i, v in ipairs(versions) do
        table.insert(result, {
            version = v,
            note = i == 1 and "latest" or ""
        })
    end
    return result
end

function util:has_value(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end

    return false
end

function util:get_info(version)
    local versions = self:fetch_versions()
    local file

    if version == "latest" then
        version = versions[1]
    end
    if not self:has_value(versions, version) then
        print("Unsupported version: " .. version)
        os.exit(1)
    end

    local osType = RUNTIME.osType
    local archType = RUNTIME.archType
    if osType == "windows" then
        osType = "win"
        archType = archType == "amd64" and "" or "-arm64"
    elseif osType == "linux" then
        osType = "linux"
        archType = archType == "amd64" and "" or "-aarch64"
    elseif osType == "darwin" then
        osType = "mac"
        archType = ""
    end

    local url = "https://github.com/ninja-build/ninja/releases/download/v" ..
    version .. "/ninja-" .. osType .. archType .. ".zip"
    print("Downloading " .. url)

    return {
        url = url,
        version = version
    }
end

return util
