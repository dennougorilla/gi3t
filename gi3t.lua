local function saveFile(text,name)
    local file = fs.open(name,"w")
    file.write(text)
    file.close()
end

local function printUsage()
    print("Usage:")
    print("gi3t run <GistId> <args>")
    print("gi3t get <GistId>")
end

local function getGist(gistId)
    print("Connecting to gist.github.com...")
    local response = http.get(
        "https://api.github.com/gists/" .. gistId
        )
    if response then
        print("Connecting Success.")

        local str = response.readAll()
        response.close()
        local obj = json.decode(str)
        local files = obj["files"]

        --get Table keys
        local gistFileNames = {}
        local i = 0
        for k, v in pairs(files) do
            gistFileNames[i] = k
            i = i + 1
        end
        if not gistFileNames[0] then
            printError("Can't get gist file.")
            return
        end
        print("Getiing raw file...")
        local rawUrl = files[gistFileNames[0]].raw_url
        local response = http.get(rawUrl)
        if response then
            print("Getting Success.")
            local rawStr = response.readAll()
            response.close()
            return rawStr, gistFileNames
        else
            print("Getting Failed.")
            return
        end
    else
        print("Connecting Failed.")
        return
    end
end

if (not os.loadAPI("json")) then
    printError( "gi3t requires json API" )
    printError( "Get jsonAPI  'pastebin get 4nRg9CHU json'" )
    return
end

local tArgs = {...}
if #tArgs < 2 then
    printUsage()
    return
end

sCommand = tArgs[1]
sCode = tArgs[2]

if sCommand == "run" then
    local funcStr, gistFileNames = getGist(sCode)
    local func = loadstring(funcStr)
    local success, msg = pcall(func, table.unpack(tArgs, 3))
    if not success then
        printError(msg)
    end

elseif sCommand == "get" then
    local funcStr, gistFileNames = getGist(sCode)
    saveFile(funcStr, gistFileNames[0])
    print(gistFileNames[0] .. " saved.")
end
