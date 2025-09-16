-- drmon.lua — HUD estilo drmon con botón AU y control de flujo (ATM10)
term.setCursorPos(3,7) term.write(string.format("Output: %s RF/t", ui.nfmt(info.output)))
term.setCursorPos(3,8) term.write(string.format("Flow (gate): %s RF/t", ui.nfmt(state.flow)))


-- barras
local bx, bw = 3, w-6
ui.bar(bx, 10, bw, 3, info.fieldPct, "Field", colors.green)
ui.bar(bx, 14, bw, 3, info.satPct, "Saturation", colors.orange)
local tPct = math.max(0, math.min(100, (info.temperature or 0) / 10000 * 100))
ui.bar(bx, 18, bw, 3, tPct, "Temp", colors.red)


-- botones (abajo)
local by = h - 3
local gaps = #buttons + 1
local bwBtn = math.max(5, math.floor((w - gaps) / #buttons))
local x = 1
for i, btn in ipairs(buttons) do
x = x + 1
btn.x, btn.y, btn.w, btn.h = x, by, bwBtn, 3
ui.button(btn.x, btn.y, btn.w, btn.h, btn.label, btn.toggle and state.auto)
x = x + bwBtn
end
end


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


-- primer render
refresh()
drawAll()


-- ======================
-- Bucle principal
-- ======================
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
