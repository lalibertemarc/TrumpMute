-- TrumpMute: anyone who says "trump" in chat gets muted. That message and
-- everything they say afterwards is hidden from your chat windows.
local addonName, ns = ...

local db                -- TrumpMuteDB, set on ADDON_LOADED
local hiddenCount = 0   -- messages hidden this session
local lastLine          -- lineID of the last message we handled
local events = CreateFrame("Frame")

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99TrumpMute|r: " .. msg)
end

local function IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

-- Forever puts a surname where the realm would be ("Sephrina Gam"); first names are
-- unique, so a player is keyed by theirs.
local function FirstName(name)
    return name:match("^[^%s%-]+") or name
end

local function NameKey(name)
    return strlower(FirstName(name))
end

local function IsMe(key)
    local me = UnitName("player")
    return me and not IsSecret(me) and NameKey(me) == key
end

local function Mute(name, reason)
    local key = NameKey(name)
    if db.muted[key] or IsMe(key) then return false end
    db.muted[key] = FirstName(name)
    if db.notify and reason then
        Print(("muted |cffffd100%s|r (%s). |cffaaaaaa/trumpmute unmute %s|r to undo."):format(db.muted[key], reason, db.muted[key]))
    end
    return true
end

---------------------------------------------------------------------------
-- Chat filter
---------------------------------------------------------------------------
-- Runs once per chat frame showing the event; return true to hide the line.
local function Filter(_, _, msg, author, ...)
    if not db or not db.enabled then return false end
    if type(author) ~= "string" or IsSecret(author) or author == "" then return false end

    local key = NameKey(author)
    local lineID = select(9, ...)
    local newLine = not IsSecret(lineID) and lineID ~= lastLine
    if newLine then lastLine = lineID end

    if db.muted[key] then
        if newLine then hiddenCount = hiddenCount + 1 end
        return true
    end

    if type(msg) ~= "string" or IsSecret(msg) or IsMe(key) then return false end
    if not strlower(msg):find(ns.TRIGGER) then return false end

    Mute(author, "said trump")
    if newLine then hiddenCount = hiddenCount + 1 end
    return true
end

-- Newer clients moved this into ChatFrameUtil; use whichever exists.
local AddFilter = (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter) or ChatFrame_AddMessageEventFilter
for _, event in ipairs(ns.CHAT_EVENTS) do
    AddFilter(event, Filter)
end

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------
local function SortedMuted()
    local names = {}
    for _, name in pairs(db.muted) do names[#names + 1] = name end
    table.sort(names)
    return names
end

local function PrintHelp()
    Print(("%s, %d muted, %d messages hidden this session."):format(
        db.enabled and "|cff00ff00on|r" or "|cffff5555off|r", #SortedMuted(), hiddenCount))
    Print("/trumpmute on | off | list | mute <name> | unmute <name> | clear | quiet")
end

local commands = {}

function commands.on()
    db.enabled = true
    Print("on.")
end

function commands.off()
    db.enabled = false
    Print("off. Muted players' messages show again until you turn it back on.")
end

function commands.list()
    local names = SortedMuted()
    if #names == 0 then
        Print("nobody muted.")
    else
        Print(("%d muted: %s"):format(#names, table.concat(names, ", ")))
    end
end

function commands.mute(arg)
    if arg == "" then return Print("usage: /trumpmute mute <name>") end
    if IsMe(NameKey(arg)) then return Print("you can't mute yourself.") end
    if Mute(arg) then
        Print(("muted |cffffd100%s|r."):format(db.muted[NameKey(arg)]))
    else
        Print(("%s is already muted."):format(arg))
    end
end

function commands.unmute(arg)
    if arg == "" then return Print("usage: /trumpmute unmute <name>") end
    local key = NameKey(arg)
    local name = db.muted[key]
    if not name then return Print(("%s isn't muted."):format(arg)) end
    db.muted[key] = nil
    Print(("unmuted |cffffd100%s|r."):format(name))
end

function commands.clear()
    local count = #SortedMuted()
    db.muted = {}
    Print(("unmuted everyone (%d)."):format(count))
end

function commands.quiet()
    db.notify = not db.notify
    Print(db.notify and "will tell you when someone gets muted." or "mutes silently now.")
end

SLASH_TRUMPMUTE1 = "/trumpmute"
SLASH_TRUMPMUTE2 = "/tmute"
SlashCmdList.TRUMPMUTE = function(input)
    if not db then return end
    local cmd, arg = strtrim(input or ""):match("^(%S*)%s*(.-)$")
    local handler = commands[strlower(cmd)]
    if handler then
        handler(strtrim(arg))
    else
        PrintHelp()
    end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, name)
    if event ~= "ADDON_LOADED" or name ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")
    if type(TrumpMuteDB) ~= "table" then TrumpMuteDB = {} end
    db = TrumpMuteDB
    for k, v in pairs(ns.DEFAULTS) do
        if type(db[k]) ~= type(v) then db[k] = v end
    end
    if type(db.muted) ~= "table" then db.muted = {} end
end)
