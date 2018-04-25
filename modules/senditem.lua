-- [[ senditem dialog ]] --
local function AnimateBackdrop()
  local r, g, b = this:GetBackdropBorderColor()
  if r <= .2 and g <= .2 and b <= .2 then
    return
  else
    local r = r > .2 and r - .02 or r
    local g = g > .2 and g - .02 or g
    local b = b > .2 and b - .02 or b
    this:SetBackdropBorderColor(r, g, b)
  end
end

local function CreateSendItemDialog()
  local f = CreateFrame("Frame", "SendItemDialog", UIParent)
  f:Hide()
  f:SetPoint("CENTER", 0, 0)
  f:SetHeight(360)
  f:SetWidth(320)
  f:SetScript("OnShow", function()
    pfAdmin.SendItemDialog:ClearFields()
  end)

  pfUI.api.CreateBackdrop(f, default_border)

  f.title = f:CreateFontString("Status", "LOW", "GameFontNormal")
  f.title:SetFontObject(GameFontWhite)
  f.title:SetPoint("TOP", f, "TOP", 0, -8)
  f.title:SetJustifyH("LEFT")
  f.title:SetFont(pfUI.font_default, 14)
  f.title:SetText("|cff33ffccpf|rAdmin: Send Item")

  do -- row: player name
    f.playernameText = f:CreateFontString("Status", "LOW", "GameFontNormal")
    f.playernameText:SetFontObject(GameFontWhite)
    f.playernameText:SetPoint("TOPLEFT", 10, -40)
    f.playernameText:SetWidth(150)
    f.playernameText:SetHeight(30)
    f.playernameText:SetJustifyH("LEFT")
    f.playernameText:SetFont(pfUI.font_default, 14)
    f.playernameText:SetText("Player Name:")

    f.playerInput = CreateFrame("EditBox", "SendItemDialogPlayerName", f)
    pfUI.api.CreateBackdrop(f.playerInput, nil, true)
    f.playerInput:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
    f.playerInput:SetAutoFocus(false)
    f.playerInput:SetJustifyH("RIGHT")
    f.playerInput:SetPoint("TOPRIGHT", -10, -40)
    f.playerInput:SetWidth(150)
    f.playerInput:SetHeight(30)
    f.playerInput:SetTextInsets(10,10,5,5)
    f.playerInput:SetScript("OnEscapePressed", function() this:ClearFocus() end)
    f.playerInput:SetScript("OnTextChanged", function()
      this:SetBackdropBorderColor(.3, 1, .8)
    end)
    f.playerInput:SetScript("OnUpdate", function() AnimateBackdrop() end)
  end

  do -- row: item id
    f.itemidText = f:CreateFontString("Status", "LOW", "GameFontNormal")
    f.itemidText:SetFontObject(GameFontWhite)
    f.itemidText:SetPoint("TOPLEFT", 10, -80)
    f.itemidText:SetWidth(150)
    f.itemidText:SetHeight(30)
    f.itemidText:SetJustifyH("LEFT")
    f.itemidText:SetFont(pfUI.font_default, 14)
    f.itemidText:SetText("Item ID:")

    f.itemidInput = CreateFrame("EditBox", "SendItemDialogItemID", f)
    pfUI.api.CreateBackdrop(f.itemidInput, nil, true)
    f.itemidInput:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
    f.itemidInput:SetAutoFocus(false)
    f.itemidInput:SetJustifyH("RIGHT")
    f.itemidInput:SetPoint("TOPRIGHT", -10, -80)
    f.itemidInput:SetWidth(150)
    f.itemidInput:SetHeight(30)
    f.itemidInput:SetTextInsets(10,10,5,5)
    f.itemidInput:SetScript("OnEscapePressed", function() this:ClearFocus() end)
    f.itemidInput:SetScript("OnTextChanged", function()
      this:SetBackdropBorderColor(.3, 1, .8)
      local text = this:GetText()
      if text ~= "0" then
      else
        -- clear item name
      end
    end)

    f.itemidInput:SetScript("OnEnter", function()
      local id = tonumber(this:GetText()) or 0
      local info = GetItemInfo(id)
      if info then
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -10, -5)
        GameTooltip:SetHyperlink("item:" .. this:GetText() .. ":0:0:0")
        GameTooltip:Show()
      end
    end)

    f.itemidInput:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

    f.itemidInput:SetScript("OnUpdate", function() AnimateBackdrop() end)
  end

  do -- row: mail subject
    f.subjectInput = CreateFrame("EditBox", "SendItemDialogItemCount", f)
    pfUI.api.CreateBackdrop(f.subjectInput, nil, true)
    f.subjectInput:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
    f.subjectInput:SetAutoFocus(false)
    f.subjectInput:SetText("0")
    f.subjectInput:SetJustifyH("CENTER")
    f.subjectInput:SetPoint("TOPRIGHT", -10, -140)
    f.subjectInput:SetWidth(300)
    f.subjectInput:SetHeight(30)
    f.subjectInput:SetScript("OnEscapePressed", function() this:ClearFocus() end)
    f.subjectInput:SetScript("OnTextChanged", function()
      this:SetBackdropBorderColor(.3, 1, .8)
      local text = this:GetText()
      if text ~= "0" then
      else
        -- clear item name
      end
    end)
    f.subjectInput:SetScript("OnUpdate", function() AnimateBackdrop() end)
  end

  do -- row: mail body
    f.bodyFrame = CreateFrame("Frame", nil, f)
    f.bodyFrame:SetWidth(300)
    f.bodyFrame:SetHeight(130)
    f.bodyFrame:SetPoint("TOPRIGHT", -10, -180)
    f.bodyFrame:SetScript("OnUpdate", function() AnimateBackdrop() end)
    pfUI.api.CreateBackdrop(f.bodyFrame, nil, true)

    f.bodyInput = CreateFrame("EditBox", "SendItemDialogItemCount", f.bodyFrame)
    f.bodyInput:SetMultiLine(true)
    f.bodyInput:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
    f.bodyInput:SetPoint("TOPLEFT", f.bodyFrame, "TOPLEFT", 10, -10)
  	f.bodyInput:SetPoint("BOTTOMRIGHT", f.bodyFrame, "BOTTOMRIGHT", -10, 10)
    f.bodyInput:SetAutoFocus(false)
    f.bodyInput:SetJustifyH("CENTER")
    f.bodyInput:SetTextInsets(10,10,5,5)
    f.bodyInput:SetScript("OnEscapePressed", function() this:ClearFocus() end)
    f.bodyInput:SetScript("OnTextChanged", function()
      this:GetParent():SetBackdropBorderColor(.3, 1, .8)
      local text = this:GetText()
      if text ~= "0" then
      else
        -- clear item name
      end
    end)
  end

  do -- button: close
    f.closeButton = CreateFrame("Button", "SendItemDialogClose", f)
    f.closeButton:SetPoint("TOPRIGHT", -5, -5)
    f.closeButton:SetHeight(12)
    f.closeButton:SetWidth(12)
    f.closeButton.texture = f.closeButton:CreateTexture("pfQuestionDialogCloseTex")
    f.closeButton.texture:SetTexture("Interface\\AddOns\\pfQuest\\compat\\close")
    f.closeButton.texture:ClearAllPoints()
    f.closeButton.texture:SetAllPoints(f.closeButton)
    f.closeButton.texture:SetVertexColor(1,.25,.25,1)
    pfUI.api.SkinButton(f.closeButton, 1, .5, .5)
    f.closeButton:SetScript("OnClick", function()
     this:GetParent():Hide()
    end)
  end

  do -- button: abort
    f.abortButton = CreateFrame("Button", "SendItemDialogAbort", f)
    pfUI.api.SkinButton(f.abortButton)
    f.abortButton:SetPoint("BOTTOMLEFT", 10, 10)
    f.abortButton:SetWidth(100)
    f.abortButton:SetHeight(30)
    f.abortButton.text = f.abortButton:CreateFontString("Caption", "LOW", "GameFontWhite")
    f.abortButton.text:SetAllPoints(f.abortButton)
    f.abortButton.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
    f.abortButton.text:SetText("Abort")
    f.abortButton:SetScript("OnClick", function()
      this:GetParent():Hide()
    end)
  end

  do -- button: send
    f.sendButton = CreateFrame("Button", "SendItemDialogSend", f)
    pfUI.api.SkinButton(f.sendButton)
    f.sendButton:SetPoint("BOTTOMRIGHT", -10, 10)
    f.sendButton:SetWidth(100)
    f.sendButton:SetHeight(30)
    f.sendButton.text = f.sendButton:CreateFontString("Caption", "LOW", "GameFontWhite")
    f.sendButton.text:SetAllPoints(f.sendButton)
    f.sendButton.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
    f.sendButton.text:SetText("Send")
    f.sendButton:SetScript("OnClick", function()
      local parent = this:GetParent()
      local player = parent.playerInput:GetText()
      local title = parent.subjectInput:GetText()
      local body = parent.bodyInput:GetText()
      local itemid = parent.itemidInput:GetText()

      local command = pfAdmin.commands[pfAdmin_config["server"]]["SENDITEM"][1]
      command = string.gsub(command, "#PLAYER", player)
      command = string.gsub(command, "#TITLE", title)
      command = string.gsub(command, "#BODY", body)
      command = string.gsub(command, "#ITEMID", itemid)
      SendChatMessage(command)

      pfAdmin.SendItemDialog:ClearFields()
    end)
  end

  return f
end

pfAdmin.SendItemDialog = CreateSendItemDialog()
pfAdmin.SendItemDialog:SetFrameStrata("FULLSCREEN_DIALOG")
pfAdmin.SendItemDialog:SetMovable(true)
pfAdmin.SendItemDialog:EnableMouse(true)
pfAdmin.SendItemDialog:SetScript("OnMouseDown",function()
  this:StartMoving()
end)

pfAdmin.SendItemDialog:SetScript("OnMouseUp",function()
  this:StopMovingOrSizing()
end)

function pfAdmin.SendItemDialog:AddItem(link)
  pfAdmin.SendItemDialog:Show()
  local _, _, itemid = string.find(link, "item:(%d+):%d+:%d+:%d+")
  pfAdmin.SendItemDialog.itemidInput:SetText(itemid)
end

function pfAdmin.SendItemDialog:AddPlayer(player)
  pfAdmin.SendItemDialog:Show()
  pfAdmin.SendItemDialog.playerInput:SetText(player)
end

function pfAdmin.SendItemDialog:ClearFields()
  pfAdmin.SendItemDialog.playerInput:SetText("player")
  pfAdmin.SendItemDialog.itemidInput:SetText("0")
  pfAdmin.SendItemDialog.subjectInput:SetText(pfAdmin_config["senditem"]["subject"])
  pfAdmin.SendItemDialog.bodyInput:SetText(pfAdmin_config["senditem"]["text"])
end

-- [[ hook functions ]] --
local HookSetItemRef = SetItemRef
function SetItemRef(link, text, button)
  if IsShiftKeyDown() then
    -- fill in player name
    if strsub(link, 1, 6) == "player" and pfAdmin.SendItemDialog:IsShown() then
      local name = strsub(link, 8);
      pfAdmin.SendItemDialog:AddPlayer(name)
      return
    end

    -- fill in item id
    if strsub(link, 1, 4) == "item" and not ChatFrameEditBox:IsVisible() then
      pfAdmin.SendItemDialog:AddItem(link)
      return
    end
  end

  HookSetItemRef(link, text, button)
end
