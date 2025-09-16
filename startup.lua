-- startup.lua — arranque mínimo y claro
if fs.exists("drmon.lua") then
shell.run("drmon.lua")
else
print("drmon.lua no encontrado. Copia los archivos o ejecuta install.")
end
