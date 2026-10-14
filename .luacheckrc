std = "lua51"
max_line_length = false
self = false

globals = {
    "TrumpMuteDB",
    "SLASH_TRUMPMUTE1",
    "SLASH_TRUMPMUTE2",
    "SlashCmdList",
}

read_globals = {
    -- Frames & UI
    "CreateFrame", "DEFAULT_CHAT_FRAME",
    -- Chat filters (ChatFrameUtil on newer clients)
    "ChatFrameUtil", "ChatFrame_AddMessageEventFilter",
    -- Global APIs
    "issecretvalue", "UnitName",
    -- Lua helpers WoW adds
    "strtrim", "strlower",
}
