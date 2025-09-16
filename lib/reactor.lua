-- lib/reactor.lua — wrapper de periféricos (reactor + flux gates)
if peripheral.getType(n) == "flux_gate" then
if not outName then outName = n
elseif not inName and n ~= outName then inName = n end
end
end
return wrapFluxGateByName(outName), wrapFluxGateByName(inName)
end


-- ==== REACTOR ====
local function findReactor(pref)
if pref and peripheral.getType(pref) then
local p = peripheral.wrap(pref); if p then return p end
end
-- intenta por tipo conocido
local p = peripheral.find("draconic_reactor")
if p then return p end
return peripheral.find("reactor")
end


local function normalize(info)
if not info then return nil end
local status = info.status or info.state or info.reactorStatus or "unknown"
local temp = tonumber(info.temperature or info.temp or info.coreTemperature or info.core_temp) or 0
local field = info.fieldStrength or info.field_strength or info.field or info.shield
local sat = info.energySaturation or info.saturation or info.energy or info.coreSaturation
local gen = info.generationRate or info.output or info.generation or 0


local function toPct(v)
if v == nil then return nil end
v = tonumber(v) or 0
if v <= 1 then return v * 100 end
if v <= 100 then return v end
return nil -- parece valor absoluto
end


local fieldPct = toPct(field) or 0
local satPct = toPct(sat) or 0


return {
status = tostring(status),
temperature = temp,
fieldPct = fieldPct,
satPct = satPct,
output = tonumber(gen) or 0,
}
end


function R.wrap(opts)
opts = opts or {}
local rx = findReactor(opts.reactor)
local gateOut, gateIn = findFluxGates(opts.gateOut, opts.gateIn)


local api = {}
function api.get()
local data = nil
if rx and rx.getReactorInfo then
local ok, res = pcall(rx.getReactorInfo)
if ok then data = res end
elseif rx and rx.reactorInfo then
data = safeCall(rx, "reactorInfo")
end
return normalize(data), data
end
function api.setFlow(v)
if gateOut then return gateOut.setFlow(v) end
return 0
end
function api.getFlow()
if gateOut then return gateOut.getFlow() end
return 0
end
function api.gates()
return gateOut, gateIn
end
function api.reactor()
return rx
end
return api
end


return R
