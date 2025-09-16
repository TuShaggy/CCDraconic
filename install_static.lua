-- install_static.lua — versión estática, sin usar la API de GitHub
-- Descarga solo los archivos clave del HUD

local RAW_BASE = "https://raw.githubusercontent.com/TuShaggy/CCDraconic/main/"

local files = {
  { url = "startup.lua",      path = "startup.lua" },
  { url = "drmon.lua",        path = "drmon.lua" },
  { url = "lib/ui.lua",       path = "lib/ui.lua" },
  { url = "lib/reactor.lua",  path = "lib/reactor.lua" },
}

local function ensureDir(path)
  local parts = {}
  for part in string.gmatch(path, "[^/]+") do table.insert(parts, part) end
  if #parts > 1 then
    local dir = table.concat(parts, "/", 1, #parts-1)
    if not fs.exists(dir) then fs.makeDir(dir) end
  end
end

for _, f in ipairs(files) do
  ensureDir(f.path)
  write("Descargando "..f.path.." … ")
  local h = http.get(RAW_BASE .. f.url)
  if h then
    local data = h.readAll() h.close()
    local fh = fs.open(f.path, "w")
    fh.write(data) fh.close()
    print("OK")
  else
    print("ERROR")
  end
end

print("Instalación terminada. Reinicia con `reboot`.")
