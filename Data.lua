-- TrumpMute: static data.
local _, ns = ...

-- Lowercased whole-word patterns, each with the word named in the "muted" notice.
-- "trump" matches "Trump", "TRUMP!", "trump's"; not "trumpet" or "trumps".
ns.TRIGGERS = {
    { pattern = "%f[%a]trump%f[%A]", word = "trump" },
    { pattern = "%f[%a]republicans?%f[%A]", word = "republican" },
}

-- Player chat a muted player can show up in.
ns.CHAT_EVENTS = {
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE",
    "CHAT_MSG_WHISPER", "CHAT_MSG_CHANNEL",
    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
    "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_AFK", "CHAT_MSG_DND", "CHAT_MSG_COMMUNITIES_CHANNEL",
}

ns.DEFAULTS = {
    enabled = true,
    notify = true, -- print a line when someone gets muted
}
