pfAdmin_config = {
  ["server"] = "elysium",
  ["senditem"] = {
    ["subject"] = "Item Service",
    ["text"] = "Your item has been restored.",
  }
}

pfAdmin = CreateFrame("Frame")

pfAdmin.commands = {
  ["elysium"] = {
    -- actions
    ["GM_PLAYERINFO"]   = { ".pinfo #PLAYER", "Player Info" },
    ["GM_GO"]           = { ".go #PLAYER", "Goto" },
    ["GM_APPEAR"]       = { ".goname #PLAYER", "Appear" },
    ["GM_SUMMON"]       = { ".namego #PLAYER", "Summon" },
    ["GM_RECALL"]       = { ".recall #PLAYER", "Recall" },
    ["GM_KICK"]         = { ".kick #PLAYER", "Kick" },
    ["GM_POSSES"]       = { ".posses", "Posses" },
    ["GM_MUTE"]         = { ".mute #PLAYER 5", "Mute 5 Minutes" },
    ["GM_UNMUTE"]       = { ".unmute #PLAYER", "Unmute" },
    ["GM_FREEZE"]       = { ".freez #PLAYER", "Freeze" },
    ["GM_UNFREEZE"]     = { ".unaura 29826", "Unfreeze" },
    ["GM_FLY"]          = { ".gm fly on", "Flying Mode" },
    ["GM_SPEED_BOOST"]  = { ".modify aspeed 5", "Speed Boost" },
    ["GM_SPEED_MAX"]    = { ".modify aspeed 10", "Max Speed" },
    ["GM_SPEED_RESET"]  = { ".modify aspeed 1", "Reset Speed" },
    ["GM_TICKET_LIST"]  = { ".ticket list", "List Tickets" },
    ["SENDITEM"]        = { ".send item \"#PLAYER\" \"#TITLE\" \"#BODY\" #ITEMID", "Send Item Per Mail" },

    -- filter strings
  },
}

-- Query Action
function pfAdmin:SendQuery(command, func)
  -- close last query when still running
  if pfAdmin.query_state then
    pfAdmin.query_func(nil)
  end

  pfAdmin.query_state = GetTime()
  pfAdmin.query_func = func or function() end
  SendChatMessage(command, "GUILD")
end

-- Parse Query Results
function pfAdmin:ParseQuery(result)
  local _, ret = nil, {}
  _, _, ret.id        = strfind(result, "|cffaaffaaTicket|r:|cffaaccff (.-).|r")
  _, _, ret.creator   = strfind(result, "|cff00ff00Creator|r:|cff00ccff |cffffffff|Hplayer:.-|h%[(.-)%]|h|r|r")
  _, _, ret.created   = strfind(result, "|cff00ff00Created|r:|cff00ccff (.-)|r")
  _, _, ret.changed   = strfind(result, "|cff00ff00Changed|r:|cff00ccff (.-)|r")
  _, _, ret.assigned  = strfind(result, "|cff00ff00Assigned to|r:|cff00ccff |cffffffff|Hplayer:.-|h%[(.-)%]|h|r|r")
  _, _, ret.message   = strfind(result, "|cff00ff00Ticket Message|r: %[(.+)%]|r")
  _, _, ret.message_multi = strfind(result, "|cff00ff00Ticket Message|r: %[(.+)")

  if ret.id and not ret.message and ret.message_multi then
    pfAdmin.parse_multi = true
    ret.message = ret.message_multi
  elseif ret.id then
    pfAdmin.parse_multi = nil
  end

  if not ret.id and pfAdmin.parse_multi then
    local _, _, multi_end = strfind(result, "(.+)%]|r")
    if multi_end then
      pfAdmin.parse_multi = nil
      ret.message = multi_end
    else
      ret.message = result
    end
  end

  return ret
end

-- Hide Query Messages
local HookChatFrame_OnEvent = ChatFrame_OnEvent
function ChatFrame_OnEvent(event)
  if event == "CHAT_MSG_SYSTEM" and pfAdmin.query_state then
    pfAdmin.query_func(arg1)
    return
  end
  HookChatFrame_OnEvent(event)
end

-- Timeout Queries
local timeout = .5
local pfAdminQueryTimeout = CreateFrame("Frame")
pfAdminQueryTimeout:SetScript("OnUpdate", function()
  if pfAdmin.query_state and pfAdmin.query_state < GetTime() - .5 then
    pfAdmin.query_state = nil
    pfAdmin.query_func(nil)
  end
end)
