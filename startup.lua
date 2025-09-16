if fs.exists("drmon.lua") then
shell.run("drmon.lua")
else
print("drmon.lua no encontrado. Ejecuta install.lua para descargar los archivos.")
end
