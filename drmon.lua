-- drmon.lua — HUD estilo drmon con botón AU y control de flujo (ATM10)

-- Cargar librerías
local ui = dofile("lib/ui.lua")
local R  = dofile("lib/reactor.lua")

-- ======================
-- Config editable
-- ======================
local CFG = {
  targetField = 50,
  minFieldSafe = 20,
  maxTemp = 8000,
  tick_s = 0.3,
  steps  = { small=1000, med=10000, big=100000 },
}

-- ======================
-- Periféricos
-- ======================
local rx = R.wrap({})

-- ======================
-- Estado y botones
-- ======================
local state = { auto=true, flow=rx.getFlow() or 0, info={status="?",temperature=0,fieldPct=0,satPct=0,output=0} }

local buttons = {
  {label="-100k", d=-CFG.steps.big},
  {label="-10k",  d=-CFG.steps.med},
  {label="-1k",   d=-CFG.steps.small},
  {label="AU",    toggle=true},
  {label="+1k",   d= CFG.steps.small},
  {label="+10k",  d= CFG.steps.med},
  {label="+100k", d= CFG.steps.big},
}

for _,b in ipairs(buttons) do b.x,b.y,b.w,b.h=0,0,0,0 end

-- ======================
-- Helpers
-- ======================
local function setFlow(v)
  state.flow = rx.setFlow(v)
end

local function nudgeFlow(d)
  setFlow((state.flow or 0) + d)
end

local function refresh()
  local norm, raw = rx.get()
  if norm then state.info = norm end
  state.flow = rx.getFlow() or state.flow or 0
end

local function clamp(v,a,b) if v<a then return a elseif v>b then return b else return v end end

local function autoAdjust(info)
  if not info then return state.flow end
  local flow = state.flow or 0
  local field = info.fieldPct or 0
  local temp  = info.temperature or 0
  local sat   = info.satPct or 0

  if field > 0 and field < CFG.minFieldSafe then
    return 0
  end
  if temp >= 9000 then
    return math.max(0, math.floor(flow * 0.5))
  end

  local err = CFG.targetField - field
  flow = flow + math.floor(err * 800)

  if temp > CFG.maxTemp then
    flow = flow - math.floor((temp - CFG.maxTemp) * 200)
  end

  if sat > 85 then flow = flow + 5000 end
  if sat < 30 then flow = math.max(0, flow - 5000) end

  return clamp(flow, 0, 2000000000)
end

-- ======================
-- Dibujo
-- ======================
local function drawAll()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  local w,h = term.getSize()

  ui.centered(1, "DRMON — HUD (AU="..(state.auto and "ON" or "OFF")..")")
  ui.centered(2, string.format("Status: %s", state.info.status or "?"))

  term.setCursorPos(3,4) term.write(string.format("Temp: %d C", math.floor(state.info.temperature or 0)))
  term.setCursorPos(3,5) term.write(string.format("Field: %d%% (target %d%%)", math.floor(state.info.fieldPct or 0), CFG.targetField))
  term.setCursorPos(3,6) term.write(string.format("Saturation: %d%%", math.floor(state.info.satPct or 0)))
  term.setCursorPos(3,7) term.write(string.format("Output: %s RF/t", ui.nfmt(state.info.output or 0)))
  term.setCursorPos(3,8) term.write(string.format("Flow (gate): %s RF/t", ui.nfmt(state.flow or 0)))

  local bx, bw = 3, w-6
  ui.bar(bx, 10, bw, 3, state.info.fieldPct, "Field", colors.green)
  ui.bar(bx, 14, bw, 3, state.info.satPct,   "Saturation", colors.orange)
  local tPct = math.max(0, math.min(100, (state.info.temperature or 0)/10000*100))
  ui.bar(bx, 18, bw, 3, tPct, "Temp", colors.red)

  local by = h - 3
  local gaps = #buttons + 1
  local bwBtn = math.max(5, math.floor((w - gaps) / #buttons))
  local x = 1
  for _, btn in ipairs(buttons) do
    x = x + 1
    btn.x, btn.y, btn.w, btn.h = x, by, bwBtn, 3
    ui.button(btn.x, btn.y, btn.w, btn.h, btn.label, btn.toggle and state.auto)
    x = x + bwBtn
  end
end

-- ======================
-- Main loop
-- ======================
refresh()
drawAll()

while true do
  local t = os.startTimer(CFG.tick_s)
  local ev, a, b, c = os.pullEvent()
  if ev == "timer" and a == t then
    refresh()
    if state.auto then
      local newFlow = autoAdjust(state.info)
      if newFlow ~= state.flow then setFlow(newFlow) end
    end
    drawAll()
  elseif ev == "monitor_touch" then
    local tx, ty = b, c
    for _, btn in ipairs(buttons) do
      if ui.hit(btn, tx, ty) then
        if btn.toggle then
          state.auto = not state.auto
        elseif btn.d then
          nudgeFlow(btn.d)
        end
        drawAll()
        break
      end
    end
  end
end
