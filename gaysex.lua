Content = ""

do
  local function httpRequest(options)
    local fn = (typeof(request) == "function" and request)
      or (typeof(http_request) == "function" and http_request)
      or (syn and typeof(syn.request) == "function" and syn.request)
      or (http and typeof(http.request) == "function" and http.request)
      or (fluxus and typeof(fluxus.request) == "function" and fluxus.request)
    if not fn then
      error("no request API (need request / http_request / syn.request)")
    end
    return fn(options)
  end
  if typeof(syn) ~= "table" then
    syn = {}
  end
  syn.request = syn.request or httpRequest
  if typeof(http_request) ~= "function" then
    http_request = httpRequest
  end
  if typeof(request) ~= "function" then
    request = httpRequest
  end
end

local FINITY_UI_URLS = {
  "https://raw.githubusercontent.com/mickievely/macrov4-gaysex/main/finityuifork.lua",
  "https://raw.githubusercontent.com/infinitylua/Luascripts/main/finityuifork.lua",
}
if type(_G.FINITY_UI_URL) == "string" then
  table.insert(FINITY_UI_URLS, 1, _G.FINITY_UI_URL)
end

local function httpGetBody(url)
  if game and typeof(game.HttpGet) == "function" then
    local ok, body = pcall(function()
      return game:HttpGet(url, true)
    end)
    if ok and type(body) == "string" and #body > 500 then
      return body
    end
  end
  if game and typeof(game.HttpGetAsync) == "function" then
    local ok, body = pcall(function()
      return game:HttpGetAsync(url)
    end)
    if ok and type(body) == "string" and #body > 500 then
      return body
    end
  end
  local req = request or http_request or (syn and syn.request)
  if req then
    local res = req({ Url = url, Method = "GET" })
    if res and type(res.Body) == "string" and #res.Body > 500 then
      return res.Body
    end
  end
  return nil
end

local function loadFinityUiFromFile()
  if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then
    return nil
  end
  local paths = {}
  if type(_G.FINITY_UI_READFILE) == "string" then
    table.insert(paths, _G.FINITY_UI_READFILE)
  end
  for _, path in ipairs({
    "macrov4/backup/finityuifork.lua",
    "backup/finityuifork.lua",
    "finityuifork.lua",
    "macrov4/finityuifork.lua",
  }) do
    table.insert(paths, path)
  end
  for _, path in ipairs(paths) do
    if isfile(path) then
      local compiled = loadstring(readfile(path), path)
      if compiled then
        local ok, lib = pcall(compiled)
        if ok and type(lib) == "table" and lib.new then
          return lib
        end
      end
    end
  end
  return nil
end

local function loadFinityUi()
  local localLib = loadFinityUiFromFile()
  if localLib then
    return localLib
  end
  if _G.FINITY_LOCAL_ONLY == true then
    error("Finity UI load failed — add macrov4/finityuifork.lua to Volt workspace")
  end
  for _, url in ipairs(FINITY_UI_URLS) do
    if type(url) == "string" then
      local source = httpGetBody(url)
      if source then
        local compiled, err = loadstring(source, "FinityUI")
        if not compiled then
          warn("Finity compile failed:", err)
        else
          local ok, lib = pcall(compiled)
          if ok and type(lib) == "table" and lib.new then
            return lib
          end
          warn("Finity load failed:", lib)
        end
      end
    end
  end
  local localLib = loadFinityUiFromFile()
  if localLib then
    return localLib
  end
  error("Finity UI load failed — set _G.FINITY_UI_URL or add finityuifork.lua to workspace")
end

local Finity = loadFinityUi()
local Main = Finity.new(true, "Bee Swarm Simulator Trainer | Hide GUI: ( ; )")
Main:ChangeToggleKey(Enum.KeyCode.Semicolon)

-- Name blacklist
local BLACKLIST = { "Kalantaika", "BOLOSTAIABOGINA", "2.0" }
for _, banned in ipairs(BLACKLIST) do
  if game.Players.LocalPlayer.Name == banned then
    game.Players.LocalPlayer:Kick("You are blacklisted!")
    return
  end
end

-- Anti-AFK kick
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
  VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
  task.wait(1)
  VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

local ClientStatCache = require(game.ReplicatedStorage.ClientStatCache)
local playerStats = ClientStatCache:Get()

local SCRIPT_VERSION = "2.0"

-- Runtime toggles / settings (Finity UI mutates these globals)
autofarmMode = "Walk"
noclipEnabled = false
targetField = "Dandelion Field"
farmWalkSpeed = 70
feedLineUp = 1
feedLineRight = 1
feedFoodType = "Treat"
feedFoodAmount = 1
feedWaitBeforeUse = 0.5
convertCount = 0
autoDigEnabled = false
popBubblesEnabled = false
fieldReady = false
autofarmEnabled = false
webhookUrlDisplay = (type(_G.bsshook) == "string" and _G.bsshook) or "NaN"
autoSprinklerEnabled = false
honeyConverting = false
autofarmLoopActive = false
fakeServerAlertEnabled = false
trainCrabEnabled = false
trainSnailEnabled = false
tpToRaresEnabled = false
collectTicketsEnabled = false
autoDispenserEnabled = false
autoWealthClockEnabled = false
autoFreeAntpassEnabled = false
autoHoneyStormEnabled = false
hideHoneyTokensEnabled = false
tpToEggsEnabled = false
bringTornadoEnabled = false
gatherFlamesEnabled = false
gatherMarksEnabled = false
coconutCatcherEnabled = false
autoFeedEnabled = false
autofarmMeteorsEnabled = false
meteorFastModeEnabled = false
autoInstantConverterEnabled = false
webhookAfterConvertEnabled = false
autoFieldBoostersEnabled = false
monsterSpawners = workspace.MonsterSpawners
dispenserStrawberryEnabled = false
dispenserBlueberryEnabled = false
dispenserTreatEnabled = false
dispenserCoconutEnabled = false
dispenserGlueEnabled = false
badgeAutofarmEnabled = false
badgeAutoCollect = true
badgeFarmPriority = "Lowest Progress"
badgeFarmPinnedField = "Dandelion Field"
badgeMaxTier = 5
badgeFarmCurrentSet = ""
badgeFarmAllDoneNotified = false
sprinklersPlaced = false
sprinklerMissingNotified = false
autoDigLoopRunning = false
activeConfigName = "config.json"
configStatusText = "Config: none"
pendingConfigNotice = nil

local SPRINKLER_NAMES = {
  "The Supreme Saturator",
  "Diamond Drenchers",
  "Golden Gushers",
  "Silver Soakers",
  "Basic Sprinkler",
}
local SPRINKLER_NAME_SET = {}
for _, sprinklerName in ipairs(SPRINKLER_NAMES) do
  SPRINKLER_NAME_SET[sprinklerName] = true
end

local BADGE_LEVEL_TO_TIER = {
  Junior = 1,
  Cadet = 2,
  Hotshot = 3,
  Ace = 4,
  Grandmaster = 5,
}

local function normalizeFieldName(name)
  if type(name) ~= "string" then
    return nil
  end
  if name == "Pumpkin Patch" then
    return "Pumpkin Field"
  end
  return name
end

local function applyMacrov4Config(cfg)
  if type(cfg) ~= "table" then
    return
  end

  if type(cfg.field) == "string" then
    targetField = normalizeFieldName(cfg.field) or cfg.field
  end
  if type(cfg.autofarmMode) == "string" then
    autofarmMode = cfg.autofarmMode
  end
  if cfg.farmWalkSpeed ~= nil then
    farmWalkSpeed = tonumber(cfg.farmWalkSpeed) or farmWalkSpeed
  end
  if cfg.autofarmEnabled ~= nil then
    autofarmEnabled = cfg.autofarmEnabled == true
  end
  if cfg.autoDigEnabled ~= nil then
    autoDigEnabled = cfg.autoDigEnabled == true
  end
  if cfg.autoSprinklerEnabled ~= nil then
    autoSprinklerEnabled = cfg.autoSprinklerEnabled == true
  end
  if cfg.autoInstantConverterEnabled ~= nil then
    autoInstantConverterEnabled = cfg.autoInstantConverterEnabled == true
  end
  if cfg.webhookAfterConvert ~= nil then
    webhookAfterConvertEnabled = cfg.webhookAfterConvert == true
  end
  if type(cfg.webhookUrl) == "string" and cfg.webhookUrl ~= "" then
    _G.bsshook = cfg.webhookUrl
    webhookUrlDisplay = cfg.webhookUrl
  end
  if cfg.badgeAutofarm ~= nil then
    badgeAutofarmEnabled = cfg.badgeAutofarm == true
  end
  if cfg.badgeAutoCollect ~= nil then
    badgeAutoCollect = cfg.badgeAutoCollect == true
  end
  if type(cfg.badgePriority) == "string" then
    badgeFarmPriority = cfg.badgePriority
  end
  if type(cfg.badgePinnedField) == "string" then
    badgeFarmPinnedField = normalizeFieldName(cfg.badgePinnedField) or cfg.badgePinnedField
  end
  if cfg.badgeMaxTier ~= nil then
    badgeMaxTier = tonumber(cfg.badgeMaxTier) or badgeMaxTier
  end

  local autoFarm = cfg.autoFarm
  if type(autoFarm) == "table" then
    if type(autoFarm.field) == "string" then
      targetField = normalizeFieldName(autoFarm.field) or autoFarm.field
    end
    if autoFarm.enabled ~= nil then
      autofarmEnabled = autoFarm.enabled == true
    end
    if autoFarm.autoDig ~= nil then
      autoDigEnabled = autoFarm.autoDig == true
    end
    if autoFarm.autoSprinkler ~= nil then
      autoSprinklerEnabled = autoFarm.autoSprinkler == true
    end
    if autoFarm.farm_badges ~= nil then
      badgeAutofarmEnabled = autoFarm.farm_badges == true
    end
    if autoFarm.badge_priority == "Lowest Needed Pollen" then
      badgeFarmPriority = "Most Pollen Needed"
    elseif type(autoFarm.badge_priority) == "string" then
      badgeFarmPriority = autoFarm.badge_priority
    end
    if type(autoFarm.badge_level) == "string" then
      badgeMaxTier = BADGE_LEVEL_TO_TIER[autoFarm.badge_level] or badgeMaxTier
    end
  end

  local webhook = cfg.webhook
  if type(webhook) == "table" then
    if type(webhook.url) == "string" and webhook.url ~= "" then
      _G.bsshook = webhook.url
      webhookUrlDisplay = webhook.url
    end
    if webhook.enabled ~= nil then
      webhookAfterConvertEnabled = webhook.enabled == true
    end
  end

  local settings = cfg.settings
  if type(settings) == "table" then
    if type(settings.movement_method) == "string" then
      autofarmMode = settings.movement_method
    end
    if settings.walkspeed ~= nil then
      farmWalkSpeed = tonumber(settings.walkspeed) or farmWalkSpeed
    end
  end

  if cfg.autoFreeAntpass ~= nil then
    autoFreeAntpassEnabled = cfg.autoFreeAntpass == true
  end
  local misc = cfg.miscellaneous
  if type(misc) == "table" and type(misc.dispensers) == "table" then
    for _, name in pairs(misc.dispensers) do
      if type(name) == "string" and string.find(string.lower(name), "ant pass", 1, true) then
        autoFreeAntpassEnabled = true
        break
      end
    end
  end
end

if type(_G.MACROV4_CONFIG) == "table" then
  applyMacrov4Config(_G.MACROV4_CONFIG)
end

local function getLocalRoot()
  local player = game.Players.LocalPlayer
  local char = player and player.Character
  return char and char:FindFirstChild("HumanoidRootPart")
end

function Tween(duration, targetCFrame)
  local root = getLocalRoot()
  if not root then
    return
  end
  pcall(function()
    local tween = game:GetService("TweenService"):Create(
      root,
      TweenInfo.new(duration, Enum.EasingStyle.Linear),
      { CFrame = targetCFrame }
    )
    tween:Play()
    wait(duration)
  end)
end

local HttpService = game:GetService("HttpService")

function sendDiscordWebhook(embed)
  local url = _G.bsshook
  if type(url) ~= "string" or url == "" then
    return
  end
  local body = HttpService:JSONEncode({
    content = Content,
    embeds = { embed },
  })
  local req = request or http_request or (syn and syn.request)
  if not req then
    return
  end
  req({
    Url = url,
    Method = "POST",
    Headers = { ["Content-Type"] = "application/json" },
    Body = body,
  })
end

local function normalizeConfigFile(name)
  name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if name == "" then
    name = game.Players.LocalPlayer.Name .. ".json"
  end
  if not name:lower():match("%.json$") then
    name = name .. ".json"
  end
  name = name:gsub("[\\/]", "")
  return name
end

local function readTextFile(paths)
  if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then
    return nil, nil
  end
  for _, path in ipairs(paths) do
    local ok, exists = pcall(isfile, path)
    if ok and exists then
      local readOk, body = pcall(readfile, path)
      if readOk and type(body) == "string" and body ~= "" then
        return body, path
      end
    end
  end
  return nil, nil
end

local function readJsonFile(paths)
  local body, path = readTextFile(paths)
  if not body then
    return nil, nil
  end
  local ok, data = pcall(function()
    return HttpService:JSONDecode(body)
  end)
  if ok and type(data) == "table" then
    return data, path
  end
  return nil, path
end

local function configBodyPaths(fileName)
  return {
    "macrov4/configs/" .. fileName,
    "configs/" .. fileName,
    fileName,
  }
end

function snapshotMacroConfig()
  return {
    field = targetField,
    autofarmMode = autofarmMode,
    farmWalkSpeed = farmWalkSpeed,
    autofarmEnabled = autofarmEnabled == true,
    autoDigEnabled = autoDigEnabled == true,
    autoSprinklerEnabled = autoSprinklerEnabled == true,
    autoInstantConverterEnabled = autoInstantConverterEnabled == true,
    webhookAfterConvert = webhookAfterConvertEnabled == true,
    webhookUrl = (type(_G.bsshook) == "string" and _G.bsshook) or "",
    badgeAutofarm = badgeAutofarmEnabled == true,
    badgeAutoCollect = badgeAutoCollect == true,
    badgePriority = badgeFarmPriority,
    badgePinnedField = badgeFarmPinnedField,
    badgeMaxTier = badgeMaxTier,
    autoFreeAntpass = autoFreeAntpassEnabled == true,
  }
end

function applyAccountDefaults()
  if game.Players.LocalPlayer.Name ~= "ju_bin095" then
    return
  end
  autofarmEnabled = true
  autoDigEnabled = true
  autoSprinklerEnabled = true
  badgeAutofarmEnabled = true
  badgeAutoCollect = true
  autoFreeAntpassEnabled = true
end

function loadMacroConfig(fileName)
  fileName = normalizeConfigFile(fileName or activeConfigName)
  local cfg, path = readJsonFile(configBodyPaths(fileName))
  if not cfg then
    configStatusText = "Config missing: " .. fileName
    return false
  end
  applyMacrov4Config(cfg)
  applyAccountDefaults()
  activeConfigName = fileName
  configStatusText = "Config: " .. fileName
  pendingConfigNotice = "Loaded " .. tostring(path or fileName)
  return true
end

function loadPlayerConfig()
  local playerName = game.Players.LocalPlayer.Name
  local pointer = readJsonFile({
    "macrov4/" .. playerName,
    playerName,
  })
  local fileName = playerName .. ".json"
  if type(pointer) == "table" and type(pointer.Config) == "string" and pointer.Config ~= "" then
    fileName = pointer.Config
  end
  if loadMacroConfig(fileName) then
    return true
  end
  configStatusText = "Config: none (" .. playerName .. ")"
  applyAccountDefaults()
  return false
end

loadPlayerConfig()

local PARTICLE_RADIUS = 50

local function approachPart(root, part, tweenAllowed)
  if tweenAllowed == false then
    return
  end
  if autofarmMode == "Tween" and tweenAllowed then
    Tween(0.2, CFrame.new(part.Position))
    wait(0.2)
  elseif autofarmMode == "Walk" then
    local hum = game.Players.LocalPlayer.Character.Humanoid
    hum.WalkSpeed = farmWalkSpeed
    hum:MoveTo(part.Position)
  else
    root.CFrame = part.CFrame
    wait(0.1)
  end
end

local function forEachNearbyParticle(root, namePredicate, action)
  for _, part in pairs(workspace.Particles:GetChildren()) do
    if namePredicate(part) then
      if (part.Position - root.Position).Magnitude <= PARTICLE_RADIUS then
        action(part)
      end
    end
  end
end

--[[ collectLeafDisks — lime WarningDisk (field leaves) ]]
function collectLeafDisks()
  local root = getLocalRoot()
  if not root then
    return
  end
  local lime = BrickColor.new("Lime green")
  forEachNearbyParticle(root, function(part)
    return part.Name == "WarningDisk" and part.BrickColor == lime
  end, function(part)
    local allowTween = autofarmMode ~= "Tween" or gatherFlamesEnabled
    approachPart(root, part, allowTween)
  end)
end

function gatherFlames()
  local root = getLocalRoot()
  if not root then
    return
  end
  forEachNearbyParticle(root, function(part)
    return string.find(part.Name, "FlamePart", 1, true) ~= nil
  end, function(part)
    local allowTween = autofarmMode ~= "Tween" or gatherFlamesEnabled
    approachPart(root, part, allowTween)
  end)
end

--[[ --- coconutcatch (decompiler lost name; restored from flame/bubble pattern) --- ]]
function catchCoconuts()
  local root = getLocalRoot()
  if not root then
    return
  end
  for _, part in pairs(workspace.Particles:GetChildren()) do
    if string.find(part.Name, "Coconut", 1, true) then
      local dist = (part.Position - root.Position).magnitude
      if dist <= 50 then
        if autofarmMode == "Tween" and coconutCatcherEnabled then
          Tween(0.2, CFrame.new(part.Position))
          wait(0.2)
        elseif autofarmMode == "Walk" then
          local hum = game.Players.LocalPlayer.Character.Humanoid
          hum.WalkSpeed = farmWalkSpeed
          hum:MoveTo(part.Position)
        else
          root.CFrame = part.CFrame
          wait(0.1)
        end
      end
    end
  end
end

function collectBubbles()
  local root = getLocalRoot()
  if not root then
    return
  end
  forEachNearbyParticle(root, function(part)
    return string.find(part.Name, "Bubble", 1, true) ~= nil
  end, function(part)
    local allowTween = autofarmMode ~= "Tween" or popBubblesEnabled
    approachPart(root, part, allowTween)
  end)
end

function gatherMarks()
  if not gatherMarksEnabled then
    return
  end
  local root = getLocalRoot()
  if not root then
    return
  end
  for _, station in pairs(workspace.Stations:GetChildren()) do
    if string.find(station.Name, "SignStation", 1, true) then
      for _, mark in pairs(station:GetChildren()) do
        if string.find(mark.Name, "Base", 1, true) and (mark.Position - root.Position).Magnitude <= PARTICLE_RADIUS then
          local allowTween = autofarmMode ~= "Tween" or gatherMarksEnabled
          approachPart(root, mark, allowTween)
        end
      end
    end
  end
end

--[[ --- Token collect (walk / tween / teleport / lerp) --- ]]
local COLLECT_TOKEN_RADIUS = 60

local function tokenHasFarmedMarker(token)
  return token:FindFirstChild("farmed") ~= nil
end

local function markTokenFarmed(token)
  local m = Instance.new("IntValue")
  m.Name = "farmed"
  m.Parent = token
end

local function skipOwnPlayerPollenToken(token)
  if token.Name ~= game.Players.LocalPlayer.Name then
    return false
  end
  return not tokenHasFarmedMarker(token)
end

local function collectOneToken(token, root, character)
  if token.Transparency == 1 then
    return "done"
  end
  if autofarmMode == "Tween" and autofarmEnabled then
    noclipEnabled = true
    Tween(0.4, token.CFrame)
    token.Transparency = 1
    noclipEnabled = false
  elseif autofarmMode == "Teleport (Cause Kicks)" then
    noclipEnabled = true
    root.CFrame = token.CFrame
    token.Transparency = 1
    noclipEnabled = false
  elseif autofarmMode == "Lerp" and autofarmEnabled then
    noclipEnabled = true
    for step = 0, 1, 0.1 do
      if not autofarmEnabled then
        break
      end
      character.HumanoidRootPart.CFrame =
        character.HumanoidRootPart.CFrame:lerp(token.CFrame, step)
      token.Transparency = 1
      wait()
    end
    noclipEnabled = false
  elseif autofarmMode == "Walk" and autofarmEnabled then
    noclipEnabled = true
    local hum = character.Humanoid
    while token.Transparency ~= 1 and autofarmEnabled do
      hum.WalkSpeed = farmWalkSpeed
      hum:MoveTo(token.Position)
      token.Transparency = 1
    end
    noclipEnabled = false
  else
    return "skip"
  end
  wait(0.4)
  return "ok"
end

function collectTokensWalk()
  local player = game.Players.LocalPlayer
  local character = player.Character
  if not character then
    return
  end
  local root = character:FindFirstChild("HumanoidRootPart")
  if not root then
    return
  end
  rootP = root

  for _, token in pairs(workspace.Collectibles:GetChildren()) do
    if not skipOwnPlayerPollenToken(token) then
      local dist = (token.Position - root.Position).Magnitude
      if dist <= COLLECT_TOKEN_RADIUS and not tokenHasFarmedMarker(token) then
        markTokenFarmed(token)
        local status = collectOneToken(token, root, character)
        if status == "done" then
          return
        end
      end
    end
  end
end

--[[ --- collecttoken: instant snap (non-walk modes) --- ]]
function collectTokens()
  local root = getLocalRoot()
  if not root then
    return
  end
  rootP = root
  local playerName = game.Players.LocalPlayer.Name

  for _, token in pairs(workspace.Collectibles:GetChildren()) do
    local ownUnfarmed = token.Name == playerName and not tokenHasFarmedMarker(token)
    local tooFar = (token.Position - root.Position).Magnitude > COLLECT_TOKEN_RADIUS
    if not ownUnfarmed and not tooFar and not tokenHasFarmedMarker(token) then
      markTokenFarmed(token)
      root.CFrame = token.CFrame
      wait(0.1)
    end
  end
end

function collectTokenAt(position)
  pcall(function()
    game.Players.LocalPlayer.Character.Humanoid:MoveTo(position)
  end)
end

function Notify(title, duration)
  duration = duration or 5
  pcall(function()
    game.StarterGui:SetCore("SendNotification", {
      Title = "BSS Trainer",
      Text = title,
      Duration = duration,
    })
  end)
end

function WalkTo(target)
  pcall(function()
    game.Players.LocalPlayer.Character.Humanoid:MoveTo(target)
  end)
end

--[[ --- Noclip: force swimming state while enabled --- ]]
local function noclipOnStepped()
  if not noclipEnabled then
    return
  end
  local hum =
    game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
  if hum then
    hum:ChangeState(11)
  end
end

game:GetService("RunService").Stepped:Connect(noclipOnStepped)

honeytimer = honeytimer or 0

function fixHoneyConversion()
  local player = game.Players.LocalPlayer
  local pollen = player.CoreStats.Pollen.Value
  if pollen <= 1 then
    return
  end
  if not autofarmEnabled and not autofarmLoopActive then
    return
  end

  honeytimer = 0
  Tween(0.1, player.SpawnPos.Value)
  wait(0.1)
  require(game.ReplicatedStorage.Events).ClientCall("PlayerHiveCommand", "ToggleHoneyMaking")

  repeat
    wait(1)
    honeytimer = honeytimer + 1
    pollen = player.CoreStats.Pollen.Value
    if pollen < 1 then
      break
    end
  until honeytimer >= 90

  honeytimer = 0
  wait()
  fieldReady = false

  if player.CoreStats.Pollen.Value > 1 then
    fixHoneyConversion()
  end
end

local function toolClickEvent(tool, skipSprinklers)
  if not tool or not tool:IsA("Tool") then
    return nil
  end
  if skipSprinklers and SPRINKLER_NAME_SET[tool.Name] then
    return nil
  end
  local click = tool:FindFirstChild("ClickEvent", true)
  if click and (click:IsA("RemoteEvent") or click.FireServer) then
    return click
  end
  return nil
end

function findToolClickEvent(player, skipSprinklers)
  if not player then
    return nil
  end
  local playerFolder = workspace:FindFirstChild(player.Name)
  if playerFolder then
    local click = toolClickEvent(playerFolder:FindFirstChildOfClass("Tool"), skipSprinklers)
    if click then
      return click
    end
  end
  local character = player.Character
  if character then
    local click = toolClickEvent(character:FindFirstChildOfClass("Tool"), skipSprinklers)
    if click then
      return click
    end
  end
  local backpack = player:FindFirstChild("Backpack")
  if backpack then
    for _, tool in ipairs(backpack:GetChildren()) do
      local click = toolClickEvent(tool, skipSprinklers)
      if click then
        return click
      end
    end
  end
  return nil
end

local function findSprinklerTool(player, sprinklerName)
  local containers = {
    player.Character,
    player:FindFirstChild("Backpack"),
    workspace:FindFirstChild(player.Name),
  }
  for _, container in ipairs(containers) do
    if container then
      local tool = container:FindFirstChild(sprinklerName)
      if tool and tool:IsA("Tool") then
        return tool
      end
    end
  end
  return nil
end

local function findCollectorTool(player)
  local containers = {
    player.Character,
    player:FindFirstChild("Backpack"),
    workspace:FindFirstChild(player.Name),
  }
  for _, container in ipairs(containers) do
    if container then
      for _, tool in ipairs(container:GetChildren()) do
        if tool:IsA("Tool") and not SPRINKLER_NAME_SET[tool.Name] and toolClickEvent(tool, true) then
          return tool
        end
      end
    end
  end
  return nil
end

local function swingCollectorTool()
  local player = game.Players.LocalPlayer
  local character = player.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  local tool = findCollectorTool(player)
  if tool and humanoid and tool.Parent ~= character then
    pcall(function()
      humanoid:EquipTool(tool)
    end)
  end
  if tool then
    pcall(function()
      tool:Activate()
    end)
    local click = toolClickEvent(tool, true)
    if click then
      pcall(function()
        click:FireServer()
      end)
    end
  end
  pcall(function()
    GameEvents.ClientCall("ToolCollect")
  end)
  pcall(function()
    LocalCollect.Run()
  end)
  local vim = game:GetService("VirtualInputManager")
  pcall(function()
    vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
  end)
  return tool ~= nil
end


local ToyEvent = game.ReplicatedStorage.Events.ToyEvent
local HiveFeed = game.ReplicatedStorage.Events.ConstructHiveCellFromEgg
local ItemPackage = game.ReplicatedStorage.Events.ItemPackageEvent
local TweenService = game:GetService("TweenService")
local GameEvents = require(game.ReplicatedStorage.Events)
local LocalCollect = require(game.ReplicatedStorage.Collectors.LocalCollect)

local function fireToy(toyName)
  ToyEvent:FireServer(toyName)
end

local function statsOwnSprinkler(stats, sprinklerName)
  if type(stats) ~= "table" then
    return false
  end
  local direct = tonumber(stats[sprinklerName])
  if direct and direct > 0 then
    return true
  end
  for _, value in pairs(stats) do
    if type(value) == "table" then
      local count = tonumber(value[sprinklerName])
      if count and count > 0 then
        return true
      end
    end
  end
  return false
end

local function equippedSprinklerNames()
  local player = game.Players.LocalPlayer
  local found, seen = {}, {}
  local containers = {
    player.Character,
    player:FindFirstChild("Backpack"),
    workspace:FindFirstChild(player.Name),
  }
  for _, container in ipairs(containers) do
    if container then
      for _, tool in ipairs(container:GetChildren()) do
        if tool:IsA("Tool") and SPRINKLER_NAME_SET[tool.Name] and not seen[tool.Name] then
          seen[tool.Name] = true
          table.insert(found, tool.Name)
        end
      end
    end
  end
  if #found > 0 then
    return found
  end
  pcall(function()
    local stats = ClientStatCache:Get()
    if stats then
      playerStats = stats
    end
  end)
  for _, sprinklerName in ipairs(SPRINKLER_NAMES) do
    if statsOwnSprinkler(playerStats, sprinklerName) then
      table.insert(found, sprinklerName)
    end
  end
  return found
end

local function jumpForSprinkler(humanoid, root, spot)
  if spot then
    root.CFrame = spot
  end
  humanoid.Jump = true
  pcall(function()
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
  end)
  local started = os.clock()
  while os.clock() - started < 0.45 do
    local rising = false
    pcall(function()
      rising = root.AssemblyLinearVelocity.Y > 6
    end)
    if humanoid.FloorMaterial == Enum.Material.Air or rising then
      break
    end
    task.wait()
  end
  task.wait(0.08)
  if humanoid.FloorMaterial ~= Enum.Material.Air and spot then
    root.CFrame = spot + Vector3.new(0, 6, 0)
    pcall(function()
      root.AssemblyLinearVelocity = Vector3.new(0, 45, 0)
    end)
    task.wait(0.08)
  end
end

local function useSprinkler(player, humanoid, sprinklerName)
  local tool = findSprinklerTool(player, sprinklerName)
  if tool and humanoid then
    pcall(function()
      humanoid:EquipTool(tool)
    end)
    task.wait(0.05)
  end
  pcall(function()
    GameEvents.ClientCall("PlayerActivesCommand", { Name = sprinklerName })
  end)
  if tool then
    pcall(function()
      tool:Activate()
    end)
    local click = tool:FindFirstChild("ClickEvent", true)
    if click and click.FireServer then
      pcall(function()
        click:FireServer()
      end)
    end
  end
end

function placeEquippedSprinklers()
  local player = game.Players.LocalPlayer
  local character = player.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  local root = character and character:FindFirstChild("HumanoidRootPart")
  if not humanoid or not root then
    return false
  end
  local names = equippedSprinklerNames()
  if #names == 0 then
    if not sprinklerMissingNotified then
      sprinklerMissingNotified = true
      Notify("No sprinkler equipped", "2")
    end
    return false
  end
  sprinklerMissingNotified = false
  local spot = fieldpos or root.CFrame
  for _, sprinklerName in ipairs(names) do
    jumpForSprinkler(humanoid, root, spot)
    useSprinkler(player, humanoid, sprinklerName)
    task.wait(0.35)
    if spot then
      root.CFrame = CFrame.new(spot.Position.X, root.Position.Y, spot.Position.Z)
    end
  end
  local collector = findCollectorTool(player)
  if collector then
    pcall(function()
      humanoid:EquipTool(collector)
    end)
  end
  Notify("Sprinklers: " .. table.concat(names, ", "), "2")
  return true
end

-- Finity checkbox: callback(checked) passes the new on/off state.
local function toggleCheckboxLoop(isOn, enable, loopFn)
  return function(checked)
    local wantOn = checked == true
    enable(wantOn)
    if not wantOn then
      return
    end
    task.spawn(function()
      while isOn() do
        loopFn()
      end
    end)
  end
end

local function getHumanoidRoot()
  local char = game.Players.LocalPlayer.Character
  return char and char:FindFirstChild("HumanoidRootPart")
end

local function collectibleDecal(part)
  return part:FindFirstChildOfClass("Decal")
end

local function grabCollectibleIfTexture(part, textureIds)
  if part.Transparency >= 0.2 then
    return
  end
  local decal = collectibleDecal(part)
  if not decal or not decal.Texture then
    return
  end
  if not textureIds[decal.Texture] then
    return
  end
  local root = getHumanoidRoot()
  if root then
    root.CFrame = part.CFrame
  end
  part.Transparency = 1
end

local function scanCollectiblesForTextures(textureIds, waitTime)
  for _, part in pairs(workspace.Collectibles:GetChildren()) do
    grabCollectibleIfTexture(part, textureIds)
  end
  task.wait(waitTime or 0.2)
end

local EGG_DECAL_TEXTURES = {
  ["rbxassetid://1987257040"] = true,
  ["rbxassetid://1987253833"] = true,
  ["rbxassetid://1987255318"] = true,
  ["rbxassetid://2007771339"] = true,
  ["rbxassetid://1471850677"] = true,
  ["rbxassetid://1471848094"] = true,
  ["rbxassetid://1471849394"] = true,
  ["rbxassetid://4520739302"] = true,
}

local RARE_DECAL_TEXTURES = {
  ["rbxassetid://2028603146"] = true,
  ["rbxassetid://4483267595"] = true,
  ["rbxassetid://4520736128"] = true,
  ["rbxassetid://2863468407"] = true,
  ["rbxassetid://1987257040"] = true,
  ["rbxassetid://1987253833"] = true,
  ["rbxassetid://1987255318"] = true,
  ["rbxassetid://2529092020"] = true,
  ["rbxassetid://2584584968"] = true,
  ["rbxassetid://1471850677"] = true,
  ["rbxassetid://1471848094"] = true,
  ["rbxassetid://2504978518"] = true,
  ["rbxassetid://2863122826"] = true,
  ["rbxassetid://2060626811"] = true,
  ["rbxassetid://4520739302"] = true,
  ["rbxassetid://2495936060"] = true,
  ["rbxassetid://2545746569"] = true,
  ["rbxassetid://2542899798"] = true,
  ["rbxassetid://2495935291"] = true,
  ["rbxassetid://2676715441"] = true,
  ["rbxassetid://3080740120"] = true,
  ["rbxassetid://3027672238"] = true,
}

local TICKET_TEXTURE = { ["rbxassetid://1674871631"] = true }
local HONEY_TOKEN_TEXTURE = { ["rbxassetid://1472135114"] = true }

local FIELD_TP_OPTIONS = {
  "Dandelion Field",
  "Sunflower Field",
  "Mushroom Field",
  "Blue Flower Field",
  "Clover Field",
  "Spider Field",
  "Bamboo Field",
  "Strawberry Field",
  "Pineapple Field",
  "Cactus Field",
  "Pine Tree Forest",
  "Pumpkin Field",
  "Rose Field",
  "Mountain Top Field",
  "Coconut Field",
  "Pepper Field",
  "Stump Field",
}

local FOOD_OPTIONS = { "Treat", "Strawberry", "Blueberry", "Pineapple", "SunflowerSeed" }
local AUTOFARM_MODE_OPTIONS = { "Walk", "Teleport (Cause Kicks)", "Lerp", "Tween" }


fieldpos = fieldpos or CFrame.new()
maxpollen = maxpollen or 0
playerdied = playerdied or false

local FIELD_CFRAMES = {
  ["Dandelion Field"] = CFrame.new(-37, 4, 220.1),
  ["Sunflower Field"] = CFrame.new(-212, 3.4, 191.7),
  ["Mushroom Field"] = CFrame.new(-93.6, 3.4, 117.2),
  ["Blue Flower Field"] = CFrame.new(151, 4, 96.5),
  ["Clover Field"] = CFrame.new(161, 33.6, 183.8),
  ["Spider Field"] = CFrame.new(-45, 19.4, -2),
  ["Bamboo Field"] = CFrame.new(126.7, 20, -27.1),
  ["Strawberry Field"] = CFrame.new(-175.9, 20.4, 0),
  ["Pineapple Field"] = CFrame.new(267.7, 68.2, -201.1),
  ["Cactus Field"] = CFrame.new(-186, 68, -102),
  ["Pine Tree Forest"] = CFrame.new(-328.3, 68.5, -187.5),
  ["Pumpkin Field"] = CFrame.new(-190, 68, -184.3),
  ["Rose Field"] = CFrame.new(-330.7, 20, 125.5),
  ["Mountain Top Field"] = CFrame.new(73.2, 176.35, -167),
  ["Stump Field"] = CFrame.new(423, 96.3, -179.6),
  ["Coconut Field"] = CFrame.new(-258, 72, 457),
  ["Pepper Field"] = CFrame.new(-479, 123, 525),
}

local Badges = require(game.ReplicatedStorage.Badges)

local BADGE_SET_TO_FIELD = {
  Sunflower = "Sunflower Field",
  Dandelion = "Dandelion Field",
  Mushroom = "Mushroom Field",
  ["Blue Flower"] = "Blue Flower Field",
  Clover = "Clover Field",
  Spider = "Spider Field",
  Strawberry = "Strawberry Field",
  Bamboo = "Bamboo Field",
  Pineapple = "Pineapple Field",
  Pumpkin = "Pumpkin Field",
  Cactus = "Cactus Field",
  Rose = "Rose Field",
  ["Pine Tree"] = "Pine Tree Forest",
}

local BADGE_POLLEN_SETS = {
  "Sunflower",
  "Dandelion",
  "Mushroom",
  "Blue Flower",
  "Clover",
  "Spider",
  "Strawberry",
  "Bamboo",
  "Pineapple",
  "Pumpkin",
  "Cactus",
  "Rose",
  "Pine Tree",
}

local BADGE_FIELD_OPTIONS = {
  "Dandelion Field",
  "Sunflower Field",
  "Mushroom Field",
  "Blue Flower Field",
  "Clover Field",
  "Spider Field",
  "Bamboo Field",
  "Strawberry Field",
  "Pineapple Field",
  "Cactus Field",
  "Pine Tree Forest",
  "Pumpkin Field",
  "Rose Field",
}

local BADGE_PRIORITY_OPTIONS = { "Lowest Progress", "Most Pollen Needed", "Pinned Field" }
local BADGE_TIER_OPTIONS = { "Junior (1)", "Cadet (2)", "Hotshot (3)", "Ace (4)", "Grandmaster (5)" }

local function refreshPlayerStats()
  local ok, stats = pcall(function()
    return ClientStatCache:Get()
  end)
  if ok and stats then
    playerStats = stats
  end
  return playerStats
end

local function badgeTierOwned(setName)
  local badges = playerStats and playerStats.Badges
  if not badges then
    return 0
  end
  return badges[setName] or 0
end

-- Skip sets already at Stop-at tier or fully completed in-game (no next tier).
local function badgeSetNeedsFarm(setName)
  if badgeTierOwned(setName) >= badgeMaxTier then
    return false
  end
  local data = Badges.GetSetData(setName, playerStats)
  if not data or not data.NextTier then
    return false
  end
  return true
end

local function badgeFarmPinnedSet()
  for setName, fieldName in pairs(BADGE_SET_TO_FIELD) do
    if fieldName == badgeFarmPinnedField then
      return setName
    end
  end
  return "Dandelion"
end

local function tryCollectReadyBadges()
  if not badgeAutoCollect then
    return
  end
  refreshPlayerStats()
  for _, setName in ipairs(BADGE_POLLEN_SETS) do
    if badgeSetNeedsFarm(setName) then
      local data = Badges.GetSetData(setName, playerStats)
      if data and data.Collectible == true then
        pcall(function()
          Badges.ClientCollect(setName)
        end)
        task.wait(0.35)
        refreshPlayerStats()
      end
    end
  end
end

local function pickBadgeFarmField()
  refreshPlayerStats()

  if badgeFarmPriority == "Pinned Field" then
    local pinnedSet = badgeFarmPinnedSet()
    if badgeSetNeedsFarm(pinnedSet) then
      badgeFarmCurrentSet = pinnedSet
      return badgeFarmPinnedField
    end
  end

  for _, setName in ipairs(BADGE_POLLEN_SETS) do
    if badgeSetNeedsFarm(setName) then
      local data = Badges.GetSetData(setName, playerStats)
      if data and data.Collectible == true then
        badgeFarmCurrentSet = setName
        return BADGE_SET_TO_FIELD[setName]
      end
    end
  end

  local bestSet, bestScore
  for _, setName in ipairs(BADGE_POLLEN_SETS) do
    if badgeSetNeedsFarm(setName) then
      local data = Badges.GetSetData(setName, playerStats)
      local goal = tonumber(data.GoalAmount) or 0
      local current = tonumber(data.CurrentAmount) or 0
      local need = math.max(goal - current, 0)
      local score
      if badgeFarmPriority == "Lowest Progress" then
        score = data.PercentProgress or 0
      else
        score = -need
      end
      if not bestSet then
        bestSet, bestScore = setName, score
      elseif badgeFarmPriority == "Lowest Progress" then
        if score < bestScore then
          bestSet, bestScore = setName, score
        end
      elseif score < bestScore then
        bestSet, bestScore = setName, score
      end
    end
  end

  if bestSet then
    badgeFarmCurrentSet = bestSet
    return BADGE_SET_TO_FIELD[bestSet]
  end
  badgeFarmCurrentSet = ""
  return nil
end

local function applyBadgeAutofarmTarget()
  tryCollectReadyBadges()
  local fieldName = pickBadgeFarmField()
  if not fieldName then
    if badgeAutofarmEnabled and not badgeFarmAllDoneNotified then
      badgeFarmAllDoneNotified = true
      Notify("Pollen badges: nothing left to farm (tier cap " .. tostring(badgeMaxTier) .. ")", "2")
    end
    return
  end
  badgeFarmAllDoneNotified = false
  if FIELD_CFRAMES[fieldName] then
    if targetField ~= fieldName then
      targetField = fieldName
      fieldReady = false
    end
  end
end

function ui_Discord_Invite()
  if setclipboard then
    setclipboard("https://discord.gg/T97SmtTegD")
  end
end

function ui_Field(choice)
  Notify("You choosed: " .. choice, "1")
  targetField = choice
  fieldReady = false
end

function ui_Autofarm(checked)
  autofarmEnabled = checked == true
  if not autofarmEnabled then
    fieldReady = false
    honeyConverting = false
    badgeAutofarmEnabled = false
  end
end

function ui_Badge_Autofarm(checked)
  badgeAutofarmEnabled = checked == true
  if badgeAutofarmEnabled then
    badgeFarmAllDoneNotified = false
    autofarmEnabled = true
    gatherMarksEnabled = false
    coconutCatcherEnabled = false
    applyBadgeAutofarmTarget()
    Notify("Badge farm → " .. tostring(targetField) .. " (" .. tostring(badgeFarmCurrentSet) .. ")", "2")
  end
end

function ui_Badge_Auto_Collect(checked)
  badgeAutoCollect = checked == true
end

function ui_Badge_Priority(choice)
  badgeFarmPriority = choice
  if badgeAutofarmEnabled then
    applyBadgeAutofarmTarget()
  end
end

function ui_Badge_Pinned_Field(choice)
  badgeFarmPinnedField = choice
  if badgeAutofarmEnabled then
    applyBadgeAutofarmTarget()
  end
end

function ui_Badge_Max_Tier(choice)
  local tier = tonumber(choice:match("(%d+)"))
  badgeMaxTier = tier or 5
  badgeFarmAllDoneNotified = false
  if badgeAutofarmEnabled then
    applyBadgeAutofarmTarget()
  end
end

function ui_Badge_Show_Status()
  refreshPlayerStats()
  tryCollectReadyBadges()
  local fieldName = pickBadgeFarmField()
  if fieldName then
    targetField = fieldName
    fieldReady = false
  end
  local setName = badgeFarmCurrentSet or "?"
  local data = setName ~= "?" and Badges.GetSetData(setName, playerStats)
  local msg = setName .. " @ " .. tostring(targetField)
  if data and data.TierDesc then
    msg = msg .. " — " .. data.TierDesc:gsub("\n", " ")
  end
  Notify(msg, "3")
end

function ui_Auto_Dig(checked)
  autoDigEnabled = checked == true
  if not autoDigEnabled or autoDigLoopRunning then
    return
  end
  autoDigLoopRunning = true
  spawn(function()
    while autoDigEnabled do
      pcall(swingCollectorTool)
      wait(0.1)
    end
    autoDigLoopRunning = false
  end)
end

function ui_Auto_Instant_Converter(checked)
  autoInstantConverterEnabled = checked == true
end

function ui_Auto_Sprinkler(checked)
  autoSprinklerEnabled = checked == true
end

function ui_Gather_Marks(checked)
  gatherMarksEnabled = checked == true
end

function ui_Coconut_Catcher(checked)
  coconutCatcherEnabled = checked == true
end

function ui_Pop_Bubbles(checked)
  popBubblesEnabled = checked == true
end

function ui_Gather_Flames(checked)
  gatherFlamesEnabled = checked == true
end

function ui_Train_Crab(checked)
  trainCrabEnabled = checked == true
  if not trainCrabEnabled then
    noclipEnabled = false
    return
  end
  local crabCframe = CFrame.new(-259, 111.8, 496.4)
  task.spawn(function()
    while trainCrabEnabled do
      task.wait(0.1)
      noclipEnabled = true
      Tween(0.5, crabCframe)
    end
    noclipEnabled = false
  end)
end

function ui_Train_Snail(checked)
  trainSnailEnabled = checked == true
  if not trainSnailEnabled then
    return
  end
  local snailCframe = CFrame.new(427, 75.5, -177)
  task.spawn(function()
    while trainSnailEnabled do
      task.wait(0.1)
      Tween(0.5, snailCframe)
    end
    Tween(0.5, CFrame.new(-114.833679, 4.92991686, 270.470154))
  end)
end

ui_Auto_Dispenser = toggleCheckboxLoop(
    function() return autoDispenserEnabled end,
    function(v) autoDispenserEnabled = v end,
    function()
      task.wait(1)
      if dispenserBlueberryEnabled then
        fireToy("Blueberry Dispenser")
      elseif dispenserStrawberryEnabled then
        fireToy("Strawberry Dispenser")
      elseif dispenserTreatEnabled then
        fireToy("Treat Dispenser")
      elseif dispenserCoconutEnabled then
        fireToy("Coconut Dispenser")
      elseif dispenserGlueEnabled then
        fireToy("Glue Dispenser")
      end
    end
  )

ui_Auto_HoneyStorm = toggleCheckboxLoop(
    function() return autoHoneyStormEnabled end,
    function(v) autoHoneyStormEnabled = v end,
    function()
      task.wait(1)
      fireToy("Honeystorm")
    end
  )

ui_Auto_Field_Boosters = toggleCheckboxLoop(
    function() return autoFieldBoostersEnabled end,
    function(v) autoFieldBoostersEnabled = v end,
    function()
      task.wait(1)
      fireToy("Field Booster")
      fireToy("Red Field Booster")
      fireToy("Blue Field Booster")
    end
  )

ui_Auto_Wealth_Clock = toggleCheckboxLoop(
    function() return autoWealthClockEnabled end,
    function(v) autoWealthClockEnabled = v end,
    function()
      task.wait(1)
      fireToy("Wealth Clock")
    end
  )

ui_Auto_Free_Antpass = toggleCheckboxLoop(
    function() return autoFreeAntpassEnabled end,
    function(v) autoFreeAntpassEnabled = v end,
    function()
      task.wait(1)
      fireToy("Free Ant Pass Dispenser")
    end
  )

ui_TP_To_Eggs_use_at_own_risk = toggleCheckboxLoop(
    function() return tpToEggsEnabled end,
    function(v) tpToEggsEnabled = v end,
    function()
      scanCollectiblesForTextures(EGG_DECAL_TEXTURES, 0.2)
    end
  )

ui_TP_To_Rares_use_at_own_risk = toggleCheckboxLoop(
    function() return tpToRaresEnabled end,
    function(v) tpToRaresEnabled = v end,
    function()
      scanCollectiblesForTextures(RARE_DECAL_TEXTURES, 0.2)
    end
  )

ui_Collect_Tickets_use_at_own_risk = toggleCheckboxLoop(
    function() return collectTicketsEnabled end,
    function(v) collectTicketsEnabled = v end,
    function()
      scanCollectiblesForTextures(TICKET_TEXTURE, 0.1)
    end
  )

ui_Autofarm_Meteors_use_at_own_risk = toggleCheckboxLoop(
    function() return autofarmMeteorsEnabled end,
    function(v) autofarmMeteorsEnabled = v end,
    function()
      task.wait(1)
      local purple = BrickColor.new("Royal purple")
      for _, part in pairs(workspace.Particles:GetChildren()) do
        if not autofarmMeteorsEnabled then
          break
        end
        if part.Name == "WarningDisk" and part.BrickColor == purple then
          if meteorFastModeEnabled then
            local root = getHumanoidRoot()
            if root then
              root.CFrame = part.CFrame
            end
          else
            Tween(1, part.CFrame)
          end
        end
      end
    end
  )

function ui_Fast_Mode(checked)
  meteorFastModeEnabled = checked == true
end

function ui_Line_up(value)
  feedLineUp = value
end

function ui_Line_right(value)
  feedLineRight = value
end

function ui_Wait_before_using(value)
  feedWaitBeforeUse = tonumber(value) or feedWaitBeforeUse
end

function ui_Food_Amount(value)
  feedFoodAmount = value
end

function ui_Food(choice)
  feedFoodType = choice
end

ui_Toggle_Autofeed = toggleCheckboxLoop(
    function() return autoFeedEnabled end,
    function(v) autoFeedEnabled = v end,
    function()
      task.wait(tonumber(feedWaitBeforeUse) or 0.5)
      if not autoFeedEnabled then
        return
      end
      HiveFeed:InvokeServer(
        tonumber(feedLineRight),
        tonumber(feedLineUp),
        feedFoodType,
        tonumber(feedFoodAmount)
      )
    end
  )

function ui_Equip_Mask(maskName)
  ItemPackage:InvokeServer("Equip", {
    Mute = true,
    Type = maskName,
    Category = "Accessory",
  })
end

function ui_Generate_Supreme_Star_Amulet()
  game.ReplicatedStorage.Events.ToyEvent:FireServer("Supreme Star Amulet Generator")
end

function ui_Generate_Diamond_Star_Amulet()
  game.ReplicatedStorage.Events.ToyEvent:FireServer("Diamond Star Amulet Generator")
end

function ui_Generate_Gold_Star_Amulet()
  game.ReplicatedStorage.Events.ToyEvent:FireServer("Gold Star Amulet Generator")
end

function ui_Generate_Silver_Star_Amulet()
  game.ReplicatedStorage.Events.ToyEvent:FireServer("Silver Star Amulet Generator")
end

function ui_Generate_Bronze_Star_Amulet()
  game.ReplicatedStorage.Events.ToyEvent:FireServer("Bronze Star Amulet Generator")
end

function ui_Generate_Moon_Amulet()
  game.ReplicatedStorage.Events.ToyEvent:FireServer("Moon Amulet Generator")
end

function ui_Teleport_Field(choice)
  local cf = FIELD_CFRAMES[choice]
  if cf then
    Tween(1, cf)
  end
end

function ui_Teleport_to_hive()
  Tween(1, game.Players.LocalPlayer.SpawnPos.Value)
end

ui_Bring_Tornado = toggleCheckboxLoop(
    function() return bringTornadoEnabled end,
    function(v) bringTornadoEnabled = v end,
    function()
      task.wait(0.3)
      local player = game.Players.LocalPlayer
      local char = player.Character
      local root = char and char:FindFirstChild("HumanoidRootPart")
      if not root then
        return
      end
      local tweenInfo = TweenInfo.new(0.3)
      for _, particle in pairs(workspace.Particles:GetDescendants()) do
        if particle.Name == "Root" or particle.Name == "Plane" then
          for _, token in pairs(workspace.Collectibles:GetChildren()) do
            local nameStr = tostring(token)
            if nameStr == player.Name or nameStr == "C" then
              if (token.Position - root.Position).Magnitude <= 60 then
                local goal = { CFrame = CFrame.new(token.Position.X, root.Position.Y, token.Position.Z) }
                TweenService:Create(particle, tweenInfo, goal):Play()
              end
            end
          end
        end
      end
    end
  )

function ui_Go_to_AntChallange()
  local antCf = CFrame.new(93.4228, 32.3983, 553.128)
  Tween(1, antCf)
  task.wait(1)
  fireToy("Ant Challenge")
  local root = getHumanoidRoot()
  if root then
    root.Position = Vector3.new(93.4228, 42.3983, 553.128)
  end
  task.wait(2)
  local char = game.Players.LocalPlayer.Character
  local hum = char and char:FindFirstChildOfClass("Humanoid")
  if hum then
    hum.Name = "1"
    local clone = char:FindFirstChild("1")
    if clone then
      local newHum = clone:Clone()
      newHum.Parent = char
      newHum.Name = "Humanoid"
      task.wait()
      clone:Destroy()
    end
  end
  for _ = 1, 4 do
    Tween(1, antCf)
  end
  task.wait(8)
  Tween(1, antCf)
end

function ui_Noclip(checked)
  noclipEnabled = checked == true
end

ui_Hide_Honey_Tokens_Laggy = toggleCheckboxLoop(
    function() return hideHoneyTokensEnabled end,
    function(v) hideHoneyTokensEnabled = v end,
    function()
      task.wait(0.1)
      for _, part in pairs(workspace.Collectibles:GetChildren()) do
        local decal = collectibleDecal(part)
        if decal and decal.Texture == "rbxassetid://1472135114" and part.Transparency < 0.2 then
          part.Transparency = 1
        end
      end
    end
  )

function ui_Alert_Text(text)
  local box = game.Players.LocalPlayer.PlayerGui.ScreenGui.ServerMessage.TextBox
  box.Text = text
end

function ui_Fake_Server_Alert(checked)
  fakeServerAlertEnabled = checked == true
  local msg = game.Players.LocalPlayer.PlayerGui.ScreenGui.ServerMessage
  msg.Visible = fakeServerAlertEnabled
end

function ui_Send_after_convert(checked)
  webhookAfterConvertEnabled = checked == true
end

function ui_Autofarm_Mode(choice)
  Notify("You choosed: " .. choice, "1")
  autofarmMode = choice
end

function ui_Walking_Autofarm_Speed(value)
  farmWalkSpeed = tonumber(value) or farmWalkSpeed
end

function ui_Strawberry_Dispenser(checked)
  dispenserStrawberryEnabled = checked == true
end

function ui_Blueberry_Dispenser(checked)
  dispenserBlueberryEnabled = checked == true
end

function ui_Treat_Dispenser_Pineapple(checked)
  dispenserTreatEnabled = checked == true
end

function ui_Coconut_Dispenser(checked)
  dispenserCoconutEnabled = checked == true
end

function ui_Glue_Dispenser(checked)
  dispenserGlueEnabled = checked == true
end

function ui_Config_Name(text)
  activeConfigName = normalizeConfigFile(text)
  configStatusText = "Config: " .. activeConfigName
end

function ui_Config_Save()
  local fileName = normalizeConfigFile(activeConfigName)
  activeConfigName = fileName
  if typeof(writefile) ~= "function" then
    Notify("writefile missing", "2")
    return
  end
  local payload = HttpService:JSONEncode(snapshotMacroConfig())
  local playerName = game.Players.LocalPlayer.Name
  local pointer = HttpService:JSONEncode({ Config = fileName })
  pcall(function()
    if typeof(makefolder) == "function" then
      if typeof(isfolder) ~= "function" or not isfolder("macrov4") then
        makefolder("macrov4")
      end
      if typeof(isfolder) ~= "function" or not isfolder("macrov4/configs") then
        makefolder("macrov4/configs")
      end
    end
  end)
  local ok, err = pcall(function()
    writefile("macrov4/configs/" .. fileName, payload)
    writefile("macrov4/" .. playerName, pointer)
  end)
  if not ok then
    Notify("Config save failed: " .. tostring(err), "3")
    return
  end
  configStatusText = "Config: " .. fileName
  Notify("Saved macrov4/configs/" .. fileName, "2")
end

function ui_Config_Load()
  local fileName = normalizeConfigFile(activeConfigName)
  if not loadMacroConfig(fileName) then
    Notify(configStatusText, "2")
    return
  end
  if autoDigEnabled then
    ui_Auto_Dig(true)
  end
  if badgeAutofarmEnabled then
    ui_Badge_Autofarm(true)
  elseif autofarmEnabled then
    ui_Autofarm(true)
  end
  sprinklersPlaced = false
  Notify(pendingConfigNotice or configStatusText, "2")
end

function ui_Destroy_GUI()
  local core = game:GetService("CoreGui")
  local gui = core:FindFirstChild("FinityUI")
  if gui then
    gui:Destroy()
  end
  fieldReady = false
end

--[[ --- Finity UI wiring --- ]]
local CatHome = Main:Category("Home")
local CatAutofarm = Main:Category("Autofarm")
local CatBadge = Main:Category("Badge Autofarm")
local CatBees = Main:Category("Bees")
local CatMisc = Main:Category("Misc")
local CatSettings = Main:Category("Settings")

do
  local info = CatHome:Sector("Information")
  info:Cheat("Label", "Script by never forget me#1080")
  info:Cheat("Label", "Version: v" .. SCRIPT_VERSION)
  info:Cheat("Label", "neverforgetme @ forum.robloxscripts.com")
  info:Cheat("Label", "Hide GUI: Semicolon ( ; )")
  info:Cheat("Button", "Discord Invite", ui_Discord_Invite, { text = "Copy" })
  info:Cheat("Label", "Thx for using my script <3")

  local credits = CatHome:Sector("Credits")
  credits:Cheat("Label", "Fake#5860 - helped with lua learning")
  credits:Cheat("Label", "xxxYoloxxx999#2166 - inspired me")
end

do
  local farm = CatAutofarm:Sector("Autofarming")
  farm:Cheat("Dropdown", "Field", ui_Field, { options = FIELD_TP_OPTIONS })
  farm:Cheat("Checkbox", "Autofarm", ui_Autofarm)
  farm:Cheat("Checkbox", "Auto Dig", ui_Auto_Dig)
  farm:Cheat("Checkbox", "Auto Instant Converter", ui_Auto_Instant_Converter)
  farm:Cheat("Checkbox", "Auto Sprinkler", ui_Auto_Sprinkler)
  farm:Cheat("Checkbox", "Gather Marks", ui_Gather_Marks)
  farm:Cheat("Checkbox", "Coconut Catcher", ui_Coconut_Catcher)
  farm:Cheat("Checkbox", "Pop Bubbles", ui_Pop_Bubbles)
  farm:Cheat("Checkbox", "Gather Flames", ui_Gather_Flames)
  farm:Cheat("Checkbox", "Train Crab", ui_Train_Crab)
  farm:Cheat("Checkbox", "Train Snail", ui_Train_Snail)

  local farm2 = CatAutofarm:Sector("Autofarming 2")
  farm2:Cheat("Checkbox", "Auto-Dispenser", ui_Auto_Dispenser)
  farm2:Cheat("Label", "^ Check 'Settings'")
  farm2:Cheat("Checkbox", "Auto HoneyStorm", ui_Auto_HoneyStorm)
  farm2:Cheat("Checkbox", "Auto Field Boosters", ui_Auto_Field_Boosters)
  farm2:Cheat("Checkbox", "Auto Wealth Clock", ui_Auto_Wealth_Clock)
  farm2:Cheat("Checkbox", "Auto Free Antpass", ui_Auto_Free_Antpass)
  farm2:Cheat("Checkbox", "TP To Eggs (use at own risk)", ui_TP_To_Eggs_use_at_own_risk)
  farm2:Cheat("Checkbox", "TP To Rares (use at own risk)", ui_TP_To_Rares_use_at_own_risk)
  farm2:Cheat("Checkbox", "Collect Tickets (use at own risk)", ui_Collect_Tickets_use_at_own_risk)
  farm2:Cheat("Checkbox", "Autofarm Meteors (use at own risk)", ui_Autofarm_Meteors_use_at_own_risk)
  farm2:Cheat("Checkbox", "^ Fast Mode", ui_Fast_Mode)
end

do
  local badge = CatBadge:Sector("Pollen Badges")
  badge:Cheat("Label", "Flower fields only (no Coconut / Pepper / Stump / Mt.Top)")
  badge:Cheat("Checkbox", "Badge Autofarm (pollen only)", ui_Badge_Autofarm)
  badge:Cheat("Checkbox", "Auto-collect ready badges", ui_Badge_Auto_Collect)
  badge:Cheat("Dropdown", "Field priority", ui_Badge_Priority, { options = BADGE_PRIORITY_OPTIONS })
  badge:Cheat("Dropdown", "Pinned field", ui_Badge_Pinned_Field, { options = BADGE_FIELD_OPTIONS })
  badge:Cheat("Dropdown", "Stop at tier", ui_Badge_Max_Tier, { options = BADGE_TIER_OPTIONS })
  badge:Cheat("Button", "Show badge status", ui_Badge_Show_Status, { text = "Refresh" })
  badge:Cheat("Label", "Uses game Badges API from ClientStatCache")
end

do
  local bees = CatBees:Sector("General Settings")
  bees:Cheat("Textbox", "Line up", ui_Line_up, { placeholder = "1,2,3,..." })
  bees:Cheat("Textbox", "Line right", ui_Line_right, { placeholder = "1,2,3,..." })
  bees:Cheat("Textbox", "Wait before using", ui_Wait_before_using, { placeholder = "default is 0.5" })

  local feeding = CatBees:Sector("Feeding")
  feeding:Cheat("Label", "Advanced Guide for it in our discord")
  feeding:Cheat("Textbox", "Food Amount", ui_Food_Amount, { placeholder = "1,2,3,..." })
  feeding:Cheat("Dropdown", "Food", ui_Food, { options = FOOD_OPTIONS })
  feeding:Cheat("Checkbox", "Toggle Autofeed", ui_Toggle_Autofeed)
end

do
  local toys = CatMisc:Sector("Toy Events")
  toys:Cheat("Dropdown", "Equip Mask", ui_Equip_Mask, {
    options = { "Honey Mask", "Bubble Mask", "Fire Mask", "Gummy Mask", "Demon Mask", "Diamond Mask" },
  })
  toys:Cheat("Button", "Generate", ui_Generate_Supreme_Star_Amulet, { text = "Supreme Star Amulet" })
  toys:Cheat("Button", "Generate", ui_Generate_Diamond_Star_Amulet, { text = "Diamond Star Amulet" })
  toys:Cheat("Button", "Generate", ui_Generate_Gold_Star_Amulet, { text = "Gold Star Amulet" })
  toys:Cheat("Button", "Generate", ui_Generate_Silver_Star_Amulet, { text = "Silver Star Amulet" })
  toys:Cheat("Button", "Generate", ui_Generate_Bronze_Star_Amulet, { text = "Bronze Star Amulet" })
  toys:Cheat("Button", "Generate", ui_Generate_Moon_Amulet, { text = "Moon Amulet" })
end

do
  local tp = CatMisc:Sector("Teleports")
  tp:Cheat("Dropdown", "Fiels", ui_Teleport_Field, { options = FIELD_TP_OPTIONS })
  tp:Cheat("Button", "Teleport to hive", ui_Teleport_to_hive, { text = "" })

  local other = CatMisc:Sector("Other")
  if convertCount ~= nil then
    other:Cheat("Label", "CSKC (probably detects): " .. tostring(convertCount))
  else
    other:Cheat("Label", "CSKC (probably detects): 0")
  end
  other:Cheat("Checkbox", "Bring Tornado", ui_Bring_Tornado)
  other:Cheat("Button", "Go to AntChallange", ui_Go_to_AntChallange, { text = "with semi-godmode" })
  other:Cheat("Checkbox", "Noclip", ui_Noclip)
  other:Cheat("Checkbox", "Hide Honey Tokens (Laggy)", ui_Hide_Honey_Tokens_Laggy)
end

do
  local visual = CatMisc:Sector("Visual Functions")
  visual:Cheat("Textbox", "Alert Text", ui_Alert_Text, { placeholder = "text" })
  visual:Cheat("Checkbox", "Fake Server Alert", ui_Fake_Server_Alert)
end

do
  local hook = CatMisc:Sector("Webhooking (any executor with request)")
  hook:Cheat("Label", "Webhook: " .. tostring(webhookUrlDisplay))
  hook:Cheat("Checkbox", "Send after convert (_G.bsshook)", ui_Send_after_convert)
end

do
  local af = CatSettings:Sector("Autofarm Settings")
  af:Cheat("Dropdown", "Autofarm Mode", ui_Autofarm_Mode, { options = AUTOFARM_MODE_OPTIONS })
  af:Cheat("Textbox", "Walking Autofarm Speed", ui_Walking_Autofarm_Speed, { placeholder = "default = 70" })
  af:Cheat("Label", "^ May cause glitches in autofarm")

  local disp = CatSettings:Sector("Auto-Dispenser Settings")
  disp:Cheat("Checkbox", "Strawberry Dispenser", ui_Strawberry_Dispenser)
  disp:Cheat("Checkbox", "Blueberry Dispenser", ui_Blueberry_Dispenser)
  disp:Cheat("Checkbox", "Treat Dispenser (Pineapple)", ui_Treat_Dispenser_Pineapple)
  disp:Cheat("Checkbox", "Coconut Dispenser", ui_Coconut_Dispenser)
  disp:Cheat("Checkbox", "Glue Dispenser", ui_Glue_Dispenser)

  local gui = CatSettings:Sector("GUI Settings")
  gui:Cheat("Button", "Destroy GUI", ui_Destroy_GUI, { text = "Destroy" })

  local cfg = CatSettings:Sector("Config")
  cfg:Cheat("Label", configStatusText)
  cfg:Cheat("Textbox", "Config file", ui_Config_Name, { placeholder = activeConfigName })
  cfg:Cheat("Button", "Save config", ui_Config_Save, { text = "Save" })
  cfg:Cheat("Button", "Load config", ui_Config_Load, { text = "Load" })
end

function autofarmMainLoop()
  local deathConnection

  while true do
    wait(0.1)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
      if badgeAutofarmEnabled then
        applyBadgeAutofarmTarget()
      end

      if autofarmEnabled and not autofarmLoopActive then
        if not badgeAutofarmEnabled then
          if gatherMarksEnabled then
            gatherMarks()
          end
          if popBubblesEnabled then
            collectBubbles()
          end
          if gatherFlamesEnabled then
            gatherFlames()
          end
          if coconutCatcherEnabled then
            catchCoconuts()
          end
        elseif autoDigEnabled then
          swingCollectorTool()
        end
      end

      local progress = character:FindFirstChild("ProgressLabel", true)
      if progress and progress.Text then
        local capFromUi = tonumber(progress.Text:match("%d+$"))
        if capFromUi then
          maxpollen = capFromUi
        end
      end

      local fieldCframe = FIELD_CFRAMES[targetField]
      if fieldCframe then
        fieldpos = fieldCframe
      end

      local pollen = tonumber(player.CoreStats.Pollen.Value)
      local cap = tonumber(maxpollen)
      local holdCycle = false
      if autofarmEnabled and pollen and cap then
        if pollen < cap then
          if not fieldReady then
            Tween(1, fieldpos)
            wait(1)
            convertCount = convertCount + 1
            fieldReady = true
            if autoSprinklerEnabled and not sprinklersPlaced then
              sprinklersPlaced = placeEquippedSprinklers()
            end
          elseif fieldReady then
            if autoSprinklerEnabled and not sprinklersPlaced then
              sprinklersPlaced = placeEquippedSprinklers()
            end
            if math.random(0, 75) == 74 then
              Tween(1, fieldpos)
              wait(1)
            end
            if autofarmMode == "Walk" then
              collectTokensWalk()
            else
              collectTokens()
            end
          end
          autofarmLoopActive = false
          wait(0.2)
        else
          if autoInstantConverterEnabled then
            local toy = game.ReplicatedStorage.Events.ToyEvent
            for _, converterName in ipairs({ "Instant Converter", "Instant Converter B", "Instant Converter C" }) do
              if tonumber(player.CoreStats.Pollen.Value) + 1 > cap then
                toy:FireServer(converterName)
                if tonumber(player.CoreStats.Pollen.Value) + 1 < cap then
                  wait(1)
                  holdCycle = true
                  break
                end
              end
            end
          end

          if not holdCycle then
            fieldReady = false
            sprinklersPlaced = false
            autofarmLoopActive = true
            Tween(1, player.SpawnPos.Value)

            if webhookAfterConvertEnabled then
              local honeyText = player.PlayerGui.ScreenGui.MeterHUD.HoneyMeter.Bar.TextLabel.Text
              local utc = os.date("!*t", os.time())
              sendDiscordWebhook({
                color = "3454955",
                title = "Webhook stats",
                description = "Honey = " .. honeyText .. "\n\nConverting times: " .. tostring(convertCount),
                author = { name = player.Name },
                timestamp = string.format(
                  "%d-%d-%dT%02d:%02d:%02dZ",
                  utc.year,
                  utc.month,
                  utc.day,
                  utc.hour,
                  utc.min,
                  utc.sec
                ),
              })
            end

            honeyConverting = false
            wait(4)
            fixHoneyConversion()
            wait(4)
          end
        end
      end

      if autofarmEnabled and not holdCycle and pollen and cap then
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum and not deathConnection then
          deathConnection = hum.Died:Connect(function()
            if not autofarmEnabled then
              return
            end
            playerdied = true
            autofarmEnabled = false
            badgeAutofarmEnabled = false
            autofarmLoopActive = false
            fieldReady = false
            deathConnection = nil
          end)
        end

        if playerdied then
          wait(10)
          playerdied = false
          autofarmEnabled = true
          if badgeFarmCurrentSet ~= "" then
            badgeAutofarmEnabled = true
          end
          Tween(1, fieldpos)
          autofarmLoopActive = false
          fieldReady = true
          if autoSprinklerEnabled then
            sprinklersPlaced = placeEquippedSprinklers()
          end
          deathConnection = nil
        end
      end
    end
  end
end

spawn(autofarmMainLoop)

function minigameLayerFixLoop()
  while true do
    wait()
    local screen = game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
    local layer = screen:WaitForChild("MinigameLayer")
    for _, child in pairs(layer:GetChildren()) do
      local grid = child:WaitForChild("GuiGrid", 1)
      if grid then
        for _, desc in pairs(grid:GetDescendants()) do
          if desc.Name == "ObjContent" or desc.Name == "ObjImage" then
            desc.Visible = true
          end
        end
      end
    end
  end
end

spawn(minigameLayerFixLoop)

if pendingConfigNotice then
  Notify(pendingConfigNotice, "3")
end
if autoDigEnabled then
  ui_Auto_Dig(true)
end
if badgeAutofarmEnabled then
  ui_Badge_Autofarm(true)
elseif autofarmEnabled then
  ui_Autofarm(true)
end
if autoFreeAntpassEnabled then
  ui_Auto_Free_Antpass(true)
end

wait(2)
for _, token in pairs(workspace.Collectibles:GetChildren()) do
  if not token:FindFirstChild("farmed") then
    local m = Instance.new("IntValue")
    m.Name = "farmed"
    m.Parent = token
  end
end