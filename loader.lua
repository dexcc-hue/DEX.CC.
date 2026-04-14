-- DEX.CC Loader v1.3 (Beta)
-- No copies esto wey, solo ejecútalo en Roblox jaja
-- Si estás leyendo esto en el navegador... ya perdiste xd

local a = "d"
local b = "e"
local c = "x"
local d = "."
local e = "c"
local f = "c"
local g = math.random(1,999999)
local h = "https://raw.githubusercontent.com/dexcc-hue/DEX.CC/main/main.lua"

local function basura1()
    print("Cargando sistema anti-leak...")
    return "xd"
end

local function basura2()
    local x = {}
    for i=1,50 do
        table.insert(x, "basura"..i)
    end
    return table.concat(x, "")
end

local function basura3()
    return "DEX.CC" .. string.reverse("CC.XED")
end

print("DEX.CC iniciado correctamente " .. basura3())
print(basura2())

local realLink = h .. "?t=" .. tostring(g) -- truco tonto para confundir

-- ========================
-- CARGANDO SCRIPT REAL...
-- ========================

loadstring(game:HttpGet("https://raw.githubusercontent.com/dexcc-hue/DEX.CC./main/main.lua", true))()

-- Fin del loader (no mires más wey)
-- Si llegaste hasta aquí... eres curioso xd
