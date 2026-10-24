-- Run from the repository root: lune run tests/vault_teleport.luau
local fs = require('@lune/fs')
local luau = require('@lune/luau')
local source = fs.readFile('mr_h_addon.lua')
luau.compile(source)
local function extract(first, last)
    local start = assert(source:find(first, 1, true))
    local finish = assert(source:find(last, start, true))
    return source:sub(start, finish - 1)
end
local code = extract('        local function stopMovement()', '        local function protectCallback')
    .. extract('        local function maintainTeleport()', '        local function wants(')
local factory = luau.load([[
return function(env)
    local state, Variables = env.state, env.Variables
    local LocalPlayer, Crouch, Toggles = env.LocalPlayer, env.Crouch, env.Toggles
    local heldFrame, slideCharacter, previousSlide = 'target', nil, false
    local pending, connectHook = nil, nil
    local hookedFunctions, savedToggles = {}, {}
    local Vector3 = {zero = 0}
    local currentCharacter = env.currentCharacter
    local MrHShouldPauseAutoFloor = env.paused
    local MrHAutoFloorPivot = env.pivot
    local mrhReleasePause = function() end
]] .. code .. [[
    return {tick = maintainTeleport, stop = stopMovement}
end
]])()
local calls, events = {}, {}
local character = {GetAttribute = function() return false end}
local root = {}
local alive, paused = true, false
local env = {
    state = {running = true, epoch = 0},
    Variables = {slideSH = true, hook = true, cogAlt = true},
    LocalPlayer = {Character = character}, Toggles = {},
    Crouch = {FireServer = function(_, ...)
        table.insert(calls, table.pack(...))
        table.insert(events, 'remote')
    end},
    currentCharacter = function() if alive then return character, root end end,
    paused = function() return paused end,
    pivot = function() table.insert(events, 'pivot') end,
}
local controller = factory(env)
controller.tick()
controller.tick()
assert(#calls == 2, 'send every heartbeat even with the namecall hook')
for _, call in calls do assert(call.n == 2 and call[1] == false and call[2] == true) end
assert(table.concat(events, ',') == 'remote,pivot,remote,pivot', 'handshake must precede pivot')
paused = true
controller.tick()
assert(#calls == 2, 'safe pause must suppress movement and handshake')
paused, alive = false, false
controller.tick()
assert(#calls == 2, 'dead or missing character must not send')
alive = true
character = {GetAttribute = function() return false end}
env.LocalPlayer.Character = character
controller.tick()
assert(#calls == 3, 'resume handshake after respawn')
controller.stop()
assert(not env.state.running and not env.Variables.slideSH)
assert(#calls == 4 and calls[4][1] == false and calls[4][2] == false, 'restore crouch and slide on stop')
controller.tick()
assert(#calls == 4, 'stopped or unloaded controller must not send')
print('PASS: full source compiles; heartbeat payload/order, pause, character recovery, and stop cleanup')
