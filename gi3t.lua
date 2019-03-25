function saveFile(text,name)
    local file = fs.open(name,"w")
    file.write(text)
    file.close()
end

args = {...}
command = args[1]
gistId = args[2]
shell.run("pastebin get 4nRg9CHU json")
os.loadAPI("json")
str = http.get("https://api.github.com/gists/" .. gistId).readAll()
obj = json.decode(str)
files = obj["files"]

keys = {}
i = 0
for k, v in pairs(files) do
    keys[i] = k
    i = i + 1
end

rawUrl = files[keys[0]].raw_url
rawStr = http.get(rawUrl).readAll()

if command == "run" then

    funcStr = rawStr
    func = loadstring(funcStr)
    pcall(func, table.unpack(args, 3))

elseif command == "get" then
    saveFile(rawStr, keys[0])
    print(keys[0] .. " saved.")
end
