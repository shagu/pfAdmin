--[[ SANDBOX ]]--

local function CreateTicketListRow(count, parent)
  local f = CreateFrame("Button", "pfAdminTicketList" .. count, parent)

  f:SetHeight(25)
  f:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -count * 30 + 15)
  f:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, -count * 30 + 15)

  f.title = f:CreateFontString("Status", "HIGH", "GameFontNormal")
  f.title:SetFont(pfUI.font_default, pfUI_config.global.font_size + 2, "OUTLINE")
  f.title:SetAllPoints(f)
  f.title:SetFontObject(GameFontWhite)
  f.title:SetJustifyH("LEFT")

  f.state = f:CreateFontString("Status", "HIGH", "GameFontNormal")
  f.state:SetFont(pfUI.font_default, pfUI_config.global.font_size + 2, "OUTLINE")
  f.state:SetAllPoints(f)
  f.state:SetFontObject(GameFontWhite)
  f.state:SetJustifyH("RIGHT")

  f:SetScript("OnClick", function()
    pfAdmin.ticket:ShowTicketDialog(this:GetID())
  end)

  f:SetScript("OnEnter", function()
    -- force 'this' to the current frame
    local this = this

    pfAdmin:SendQuery(".ticket " .. this:GetID(), function(result)
      if not MouseIsOver(this) then return end
      if result then
        local ret = pfAdmin:ParseQuery(result)
        if ret.id then
          GameTooltip:SetOwner(this, "ANCHOR_LEFT", -10, -5)
          GameTooltip:SetText("#" .. ret.id .. "|cffffffff by " .. ( ret.creator or UNKNOWN ), .3, 1, .8)
        end

        if ret.message then
          GameTooltip:AddLine(ret.message, .8,.8,.8,1)
        end

        GameTooltip:Show()
      end
    end)

    this.tex:SetTexture(.1,.1,.1)
  end)

  f:SetScript("OnLeave", function()
    GameTooltip:Hide()
    this.tex:SetTexture(.05,.05,.05)
  end)

  f.tex = f:CreateTexture("highlight", "LOW")
  f.tex:SetAllPoints(f)
  f.tex:SetPoint("TOPLEFT", f, "TOPLEFT", -5, 0)
  f.tex:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 5, 0)
  f.tex:SetTexture(.05,.05,.05)
  return f
end

local function RefreshList()
  -- pfAdmin.tickets.scroll.list.items
  pfAdmin.tickets.scroll.list.item_count = 1

  pfAdmin:SendQuery(".ticket list", function(result)
    if result then
      local ret = pfAdmin:ParseQuery(result)

      if ret.id then
        local parent = pfAdmin.tickets.scroll.list
        local count = parent.item_count

        parent.items[count] = parent.items[count] or CreateTicketListRow(count, parent)
        parent.items[count]:Show()

        parent.items[count].title:SetText("|cff33ffcc#" .. ret.id .. " |r by " .. ret.creator .. "|cffaaaaaa [" .. ret.created .. "]|r")
        parent.items[count].state:SetText((ret.assigned or ""))
        parent.items[count]:SetID(ret.id)
        parent.item_count = count + 1
      end
    else
      -- end query
      for i=pfAdmin.tickets.scroll.list.item_count,table.getn(pfAdmin.tickets.scroll.list.items) do
        pfAdmin.tickets.scroll.list.items[i]:Hide()
      end
    end
  end)
end


pfAdmin.tickets = CreateFrame("Frame", "pfAdminTickets", UIParent)
pfAdmin.tickets:SetFrameStrata("HIGH")
pfAdmin.tickets:SetHeight(450)
pfAdmin.tickets:SetWidth(420)
pfAdmin.tickets:SetPoint("CENTER", 0,0)
pfAdmin.tickets:EnableMouseWheel(1)
pfAdmin.tickets:SetMovable(true)
pfAdmin.tickets:EnableMouse(true)
pfAdmin.tickets:RegisterEvent("CHAT_MSG_SYSTEM")
pfAdmin.tickets:SetScript("OnShow", function() RefreshList() end)
pfAdmin.tickets:SetScript("OnMouseDown", function() pfAdmin.tickets:StartMoving() end)
pfAdmin.tickets:SetScript("OnMouseUp", function() pfAdmin.tickets:StopMovingOrSizing() end)
pfAdmin.tickets:SetScript("OnUpdate", function()
  if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + 10 end
  RefreshList()
end)
pfAdmin.tickets:Hide()

pfUI.api.CreateBackdrop(pfAdmin.tickets, nil, nil, .75)

pfAdmin.tickets.title = pfAdmin.tickets:CreateFontString("Status", "LOW", "GameFontNormal")
pfAdmin.tickets.title:SetFontObject(GameFontWhite)
pfAdmin.tickets.title:SetPoint("TOP", pfAdmin.tickets, "TOP", 0, -8)
pfAdmin.tickets.title:SetJustifyH("LEFT")
pfAdmin.tickets.title:SetFont(pfUI.font_default, 14)
pfAdmin.tickets.title:SetText("|cff33ffccpf|rAdmin: Overview")

do -- button: close
  pfAdmin.tickets.closeButton = CreateFrame("Button", "SendItemDialogClose", pfAdmin.tickets)
  pfAdmin.tickets.closeButton:SetPoint("TOPRIGHT", -5, -5)
  pfAdmin.tickets.closeButton:SetHeight(12)
  pfAdmin.tickets.closeButton:SetWidth(12)
  pfAdmin.tickets.closeButton.texture = pfAdmin.tickets.closeButton:CreateTexture("pfQuestionDialogCloseTex")
  pfAdmin.tickets.closeButton.texture:SetTexture("Interface\\AddOns\\pfQuest\\compat\\close")
  pfAdmin.tickets.closeButton.texture:ClearAllPoints()
  pfAdmin.tickets.closeButton.texture:SetAllPoints(pfAdmin.tickets.closeButton)
  pfAdmin.tickets.closeButton.texture:SetVertexColor(1,.25,.25,1)
  pfUI.api.SkinButton(pfAdmin.tickets.closeButton, 1, .5, .5)
  pfAdmin.tickets.closeButton:SetScript("OnClick", function()
   this:GetParent():Hide()
  end)
end

do -- button: refresh
  pfAdmin.tickets.refreshButton = CreateFrame("Button", "SendItemDialogAbort", pfAdmin.tickets)
  pfUI.api.SkinButton(pfAdmin.tickets.refreshButton)
  pfAdmin.tickets.refreshButton:SetPoint("TOPLEFT", 5, -40)
  pfAdmin.tickets.refreshButton:SetWidth(100)
  pfAdmin.tickets.refreshButton:SetHeight(30)
  pfAdmin.tickets.refreshButton.text = pfAdmin.tickets.refreshButton:CreateFontString("Caption", "LOW", "GameFontWhite")
  pfAdmin.tickets.refreshButton.text:SetAllPoints(pfAdmin.tickets.refreshButton)
  pfAdmin.tickets.refreshButton.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfAdmin.tickets.refreshButton.text:SetText("Refresh")
  pfAdmin.tickets.refreshButton:SetScript("OnClick", function()
    RefreshList()
  end)
end

do -- scroll frame
  pfAdmin.tickets.scroll = pfUI.api.CreateScrollFrame("pfAdminTicketsScroll", pfAdmin.tickets)
  pfAdmin.tickets.scroll:SetPoint("TOPLEFT", pfAdmin.tickets, "TOPLEFT", 10, -80)
  pfAdmin.tickets.scroll:SetPoint("BOTTOMRIGHT", pfAdmin.tickets, "BOTTOMRIGHT", -10, 10)
  pfAdmin.tickets.scroll.buttons = { }

  pfAdmin.tickets.scroll.backdrop = CreateFrame("Frame", "pfAdminTicketsScrollBackdrop", pfAdmin.tickets.scroll)
  pfAdmin.tickets.scroll.backdrop:SetFrameLevel(1)
  pfAdmin.tickets.scroll.backdrop:SetPoint("TOPLEFT", pfAdmin.tickets.scroll, "TOPLEFT", -5, 5)
  pfAdmin.tickets.scroll.backdrop:SetPoint("BOTTOMRIGHT", pfAdmin.tickets.scroll, "BOTTOMRIGHT", 5, -5)
  pfUI.api.CreateBackdrop(pfAdmin.tickets.scroll.backdrop, nil, true)
  pfAdmin.tickets.scroll.list = pfUI.api.CreateScrollChild("pfAdminTicketsScrollList", pfAdmin.tickets.scroll)
  --pfAdmin.tickets.scroll.list:SetWidth(420)
  pfAdmin.tickets.scroll.list:SetAllPoints(pfAdmin.tickets.scroll)
  pfAdmin.tickets.scroll.list.items = { }
end
