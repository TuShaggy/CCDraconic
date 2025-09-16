-- install.lua — descarga TODO el repo TuShaggy/CCDraconic manteniendo carpetas
-- Usa la API de GitHub y baja todos los archivos respetando estructura

local REPO_USER = "TuShaggy"
local REPO_NAME = "CCDraconic"
local BRANCH    = "main"

local API_URL  = "https://api.github.com/repos/"..REPO_USER.."/"..REPO_NAME.."/git/trees/"..BRANCH.."?recursive=1"
local RAW_BASE = "https://raw.githubusercontent.com/"..REPO_USER.."/"..REPO_NAME.."/"..BRANCH.."/"

local HEADERS = { ["User-Agent"] = "CC-Tweaked" }

local function ensureDir(path)
  local parts = {}
  for part in string.gmatch(path, "[^/]+") do table.insert(parts, part) end
  if #parts > 1 then
    local dir = table.concat(parts, "/", 1, #parts-1)
    if not fs.exists(dir) then fs.makeDir(dir) end
  end
end

print("Consultando árbol del repo…")
local res = http.get(API_URL, HEADERS)
if not res then error("No se pudo acceder al API de GitHub")
local body = res.readAll() res.close()
local ok, json = pcall(textutils.unserializeJSON, body)
if not ok or not json or not json.tree then
  error("Respuesta del API inválida")
end

local count, failed = 0, 0
for _, item in ipairs(json.tree) do
  if item.type == "blob" then
    local url = RAW_BASE .. item.path
    ensureDir(item.path)
    write("Descargando "..item.path.." … ")
    local h = http.get(url, HEADERS)
    if h then
      local data = h.readAll() h.close()
      local f = fs.open(item.path, "w")
      f.write(data) f.close()
      print("OK")
      count = count + 1
    else
      print("ERROR")
      failed = failed + 1
    end
  end
end
print("Instalación terminada: "..count.." archivos, "..failed.." fallos.")
print("Reinicia con `reboot` o ejecuta `drmon.lua`.")
