-- install.lua dinámico — descarga todos los archivos de TuShaggy/CCDraconic

local repoUser = "TuShaggy"
local repoName = "CCDraconic"
local branch   = "main"

local api = "https://api.github.com/repos/"..repoUser.."/"..repoName.."/git/trees/"..branch.."?recursive=1"
local rawBase = "https://raw.githubusercontent.com/"..repoUser.."/"..repoName.."/"..branch.."/"

local function ensureDir(path)
  local parts = {}
  for part in string.gmatch(path, "[^/]+") do table.insert(parts, part) end
  table.remove(parts) -- quitamos el archivo
  if #parts > 0 then
    local dir = table.concat(parts, "/")
    if not fs.exists(dir) then fs.makeDir(dir) end
  end
end

print("Consultando archivos en GitHub...")
local res = http.get(api)
if not res then error("No se pudo acceder al API de GitHub") end
local json = textutils.unserializeJSON(res.readAll())
res.close()

for _, item in ipairs(json.tree) do
  if item.type == "blob" then
    local url = rawBase .. item.path
    ensureDir(item.path)
    print("Descargando "..item.path)
    local h = http.get(url)
    if h then
      local data = h.readAll()
      h.close()
      local f = fs.open(item.path, "w")
      f.write(data)
      f.close()
    else
      print("  Error al descargar "..url)
    end
  end
end

print("Instalación completa. Reinicia con `reboot`.")
