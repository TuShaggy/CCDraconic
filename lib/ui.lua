-- lib/ui.lua — utilidades de UI para CC:Tweaked

-- IMPORTANTE: inicializar la tabla antes de añadir funciones
local ui = {}

-- Devuelve el monitor con mayor área (w*h)
function ui.pickLargestMonitor()
  local best, bestArea = nil, -1
  for _, name in ipairs(peripheral.getNames()) do
    if peripheral.getType(name) == "monitor" then
      local mon = peripheral.wrap(name)
      if mon then
        local w, h = mon.getSize()
        local area = (w or 0) * (h or 0)
        if area > bestArea then
          best, bestArea = mon, area
        end
      end
    end
  end
  return best
end

-- Prepara el monitor
function ui.bindMonitor(mon, scale)
  scale = scale or 0.5
  mon.setTextScale(scale)
  mon.setBackgroundColor(colors.black)
  mon.setTextColor(colors.white)
  mon.clear()
end

-- Centra texto horizontalmente en la fila y
function ui.centered(y, text)
  local w, _ = term.getSize()
  local x = math.max(1, math.floor((w - #tostring(text)) / 2) + 1)
  term.setCursorPos(x, y)
  term.write(tostring(text))
end

-- Rellena rectángulo
function ui.fill(x, y, w, h, bg)
  bg = bg or colors.black
  local prev = term.getBackgroundColor()
  term.setBackgroundColor(bg)
  local row = string.rep(" ", math.max(0, w))
  for i = 0, math.max(0, h - 1) do
    term.setCursorPos(x, y + i)
    term.write(row)
  end
  term.setBackgroundColor(prev)
end

-- Barra de porcentaje 0..100
function ui.bar(x, y, w, h, pct, label, colFill, colBg)
  pct = tonumber(pct) or 0
  if pct < 0 then pct = 0 elseif pct > 100 then pct = 100 end
  colFill = colFill or colors.green
  colBg   = colBg   or colors.gray
  local filled = math.floor(w * pct / 100)
  if filled > 0 then ui.fill(x, y, filled, h, colFill) end
  if filled < w then ui.fill(x + filled, y, w - filled, h, colBg) end
  if label then
    local txt = string.format("%s: %d%%", label, math.floor(pct))
    ui.centered(y + math.floor(h/2), txt)
  end
end

-- Botón
function ui.button(x, y, w, h, label, active)
  local bg = active and colors.blue or colors.gray
  ui.fill(x, y, w, h, bg)
  term.setTextColor(colors.white)
  ui.centered(y + math.floor(h/2), tostring(label))
end

-- Área clicable de un botón
function ui.hit(btn, tx, ty)
  return tx >= btn.x and tx < btn.x + btn.w and ty >= btn.y and ty < btn.y + btn.h
end

-- Formato abreviado: 1.2k, 3.4M, 5.6B
function ui.nfmt(n)
  n = tonumber(n) or 0
  local a = math.abs(n)
  if a >= 1000000000 then
    return string.format("%.2fB", n / 1000000000)
  elseif a >= 1000000 then
    return string.format("%.2fM", n / 1000000)
  elseif a >= 1000 then
    return string.format("%.2fk", n / 1000)
  else
    return tostring(math.floor(n))
  end
end

return ui
