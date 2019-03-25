--Title: gi3t
--version: v1.11
--Author: dennougorilla

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
            i = i + 1
            gistFileNames[i] = k
        end
        if #gistFileNames == 0 then
            printError("Can't get gist file.")
            return
        end
        print("Getiing raw files...")
        local rawUrls = {}
        for i, name in ipairs(gistFileNames) do
            rawUrls[i] = files[name].raw_url
        end
        local rawStrs = {}
        for i, url in ipairs(rawUrls) do
            local response = http.get(url)
            if response then
                print("Getting " ..gistFileNames[i] .." Success.")
                rawStrs[i] = response.readAll()
                response.close()
            else
                print(gistFileNames[i], "Getting Failed.")
                return
            end
        end
        return rawStrs, gistFileNames
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
    local funcStrs, keys = getGist(sCode)
    local num = 1
    if #funcStrs > 1 then
        print(sCode .." have many gist. Input number of file you want to run.")
        for i, k in ipairs(keys) do
            print(i.." "..k)
        end
        num = read()
        if tonumber(num) > #keys then
            printError("Input correct number.")
            return
        end
    end
    print("running "..keys[tonumber(num)])
    shell.run("clear")
    local func = loadstring(funcStrs[tonumber(num)])
    local success, msg = pcall(func, table.unpack(tArgs, 3))
    if not success then
        printError(msg)
    end

elseif sCommand == "get" then
    local funcStrs, keys = getGist(sCode)
    for i, k in ipairs(keys) do
        local sPath = shell.resolve(k)
        if fs.exists(sPath) then
            print(k .." File already exists. Do you want to overwrite?(y/n)")
            local yon = read()
            if yon == "y" then
                saveFile(funcStrs[i], k)
                print("Downloaded as " ..k)
            end
        else
            saveFile(funcStrs[i], k)
            print("Downloaded as " ..k)
        end
    end
end
