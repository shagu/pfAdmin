pfAdmin.ticket = { }
pfAdmin.ticket.windows = { }

function pfAdmin.ticket:ResetTicketDialog(id)
	pfAdmin.ticket.windows[id].author:SetText("|cff33ffccAuthor:|r -")
	pfAdmin.ticket.windows[id].assigned:SetText("|cff33ffccAssignee:|r -")
	pfAdmin.ticket.windows[id].tid:SetText("|cff33ffcc#|r--")
	pfAdmin.ticket.windows[id].created:SetText("|cff33ffccCreated:|r -")
	pfAdmin.ticket.windows[id].modified:SetText("|cff33ffccModified:|r -")
	pfAdmin.ticket.windows[id].scroll.text:SetText("")
end

function pfAdmin.ticket:ShowTicketDialog(id)
	pfAdmin.ticket.windows[id] = pfAdmin.ticket.windows[id] or pfAdmin.ticket:CreateTicketDialog(id)
	pfAdmin.ticket.windows[id]:Show()

	pfAdmin:SendQuery(".ticket " .. id, function(result)
		if result then
			local ret = pfAdmin:ParseQuery(result)

			if ret.id then
				pfAdmin.ticket:ResetTicketDialog(id)
				pfAdmin.ticket.windows[id].data = ret
				pfAdmin.ticket.windows[id].author:SetText("|cff33ffccAuthor:|r " .. (ret.creator or "-"))
				pfAdmin.ticket.windows[id].assigned:SetText("|cff33ffccAssignee:|r " .. (ret.assigned or "-"))
				pfAdmin.ticket.windows[id].tid:SetText("|cff33ffcc#|r" .. ret.id)
				pfAdmin.ticket.windows[id].created:SetText("|cff33ffccCreated:|r " .. (ret.created or "-"))
				pfAdmin.ticket.windows[id].modified:SetText("|cff33ffccModified:|r -" .. (ret.changed or "-"))

				if ret.message and pfAdmin.ticket.windows[id].scroll.text:GetText() == "" then
					pfAdmin.ticket.windows[id].scroll.text:SetText(ret.message)
				elseif ret.message then
					pfAdmin.ticket.windows[id].scroll.text:SetText(pfAdmin.ticket.windows[id].scroll.text:GetText() .. "\n" .. ret.message)
				end
			end
		end
	end)
end

function pfAdmin.ticket:CreateTicketDialog(id)
	f = CreateFrame("Frame", "pfAdminTicket" .. id, UIParent)
	f:SetFrameStrata("DIALOG")
	f:SetPoint("CENTER", 0,0)
	f:SetHeight(450)
	f:SetWidth(420)
	f:EnableMouseWheel(1)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:SetID(id)
	f:SetScript("OnMouseDown", function()
		this:StartMoving()
		this:Raise()
	end)
	f:SetScript("OnMouseUp", function() this:StopMovingOrSizing() end)
	pfUI.api.CreateBackdrop(f, nil, nil, .75)

	do -- title
		f.title = f:CreateFontString("Status", "LOW", "GameFontNormal")
		f.title:SetFontObject(GameFontWhite)
		f.title:SetPoint("TOP", f, "TOP", 0, -8)
		f.title:SetJustifyH("LEFT")
		f.title:SetFont(pfUI.font_default, 14)
		f.title:SetText("|cff33ffccpf|rAdmin: Ticket")
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

	f.author = f:CreateFontString("Status", "LOW", "GameFontNormal")
	f.author:SetFontObject(GameFontWhite)
	f.author:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -30)
	f.author:SetJustifyH("LEFT")
	f.author:SetFont(pfUI.font_default, 14)

	f.assigned = f:CreateFontString("Status", "LOW", "GameFontNormal")
	f.assigned:SetFontObject(GameFontWhite)
	f.assigned:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -30)
	f.assigned:SetJustifyH("RIGHT")
	f.assigned:SetFont(pfUI.font_default, 14)

	f.tid = f:CreateFontString("Status", "LOW", "GameFontNormal")
	f.tid:SetFontObject(GameFontWhite)
	f.tid:SetPoint("TOP", f, "TOP", 0, -40)
	f.tid:SetJustifyH("LEFT")
	f.tid:SetFont(pfUI.font_default, 20)

	f.created = f:CreateFontString("Status", "LOW", "GameFontNormal")
	f.created:SetFontObject(GameFontWhite)
	f.created:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -50)
	f.created:SetJustifyH("LEFT")
	f.created:SetFont(pfUI.font_default, 14)

	f.modified = f:CreateFontString("Status", "LOW", "GameFontNormal")
	f.modified:SetFontObject(GameFontWhite)
	f.modified:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -50)
	f.modified:SetJustifyH("RIGHT")
	f.modified:SetFont(pfUI.font_default, 14)

	do -- button: assign
	  f.assignButton = CreateFrame("Button", "SendItemDialogAbort", f)
	  pfUI.api.SkinButton(f.assignButton)
	  f.assignButton:SetPoint("BOTTOMLEFT", 5, 5)
	  f.assignButton:SetWidth(75)
	  f.assignButton:SetHeight(25)
	  f.assignButton.text = f.assignButton:CreateFontString("Caption", "LOW", "GameFontWhite")
	  f.assignButton.text:SetAllPoints(f.assignButton)
	  f.assignButton.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
	  f.assignButton.text:SetText("Assign to Me")
	  f.assignButton:SetScript("OnClick", function()
			if this:GetParent().data.assigned == UnitName("player") then
				SendChatMessage(".ticket unassign " .. id, "GUILD")
				this.text:SetText("Assign to Me")
			else
				SendChatMessage(".ticket assign " .. id, "GUILD")
				this.text:SetText("Unassign to Me")
			end
			pfAdmin.ticket:ShowTicketDialog(id)
	  end)
	end

	do -- button: refresh
	  f.ticketCloseButton = CreateFrame("Button", "SendItemDialogAbort", f)
	  pfUI.api.SkinButton(f.ticketCloseButton)
	  f.ticketCloseButton:SetPoint("BOTTOMLEFT", 80, 5)
	  f.ticketCloseButton:SetWidth(75)
	  f.ticketCloseButton:SetHeight(25)
	  f.ticketCloseButton.text = f.ticketCloseButton:CreateFontString("Caption", "LOW", "GameFontWhite")
	  f.ticketCloseButton.text:SetAllPoints(f.ticketCloseButton)
	  f.ticketCloseButton.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
	  f.ticketCloseButton.text:SetText("Resolv")
	  f.ticketCloseButton:SetScript("OnClick", function()
	    foobar()
	  end)
	end

	do -- button: refresh
	  f.mailButton = CreateFrame("Button", "SendItemDialogAbort", f)
	  pfUI.api.SkinButton(f.mailButton)
	  f.mailButton:SetPoint("BOTTOMRIGHT", -5, 5)
	  f.mailButton:SetWidth(50)
	  f.mailButton:SetHeight(25)
	  f.mailButton.text = f.mailButton:CreateFontString("Caption", "LOW", "GameFontWhite")
	  f.mailButton.text:SetAllPoints(f.mailButton)
	  f.mailButton.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
	  f.mailButton.text:SetText("Mail")
	  f.mailButton:SetScript("OnClick", function()
	    foobar()
	  end)
	end

	do -- button: refresh
	  f.refundItem = CreateFrame("Button", "SendItemDialogAbort", f)
	  pfUI.api.SkinButton(f.refundItem)
	  f.refundItem:SetPoint("BOTTOMRIGHT", -55, 5)
	  f.refundItem:SetWidth(50)
	  f.refundItem:SetHeight(25)
	  f.refundItem.text = f.refundItem:CreateFontString("Caption", "LOW", "GameFontWhite")
	  f.refundItem.text:SetAllPoints(f.refundItem)
	  f.refundItem.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
	  f.refundItem.text:SetText("Item")
	  f.refundItem:SetScript("OnClick", function()
	    foobar()
	  end)
	end

	do -- button: refresh
	  f.whisperButton = CreateFrame("Button", "SendItemDialogAbort", f)
	  pfUI.api.SkinButton(f.whisperButton)
	  f.whisperButton:SetPoint("BOTTOMRIGHT", -105, 5)
	  f.whisperButton:SetWidth(50)
	  f.whisperButton:SetHeight(25)
	  f.whisperButton.text = f.whisperButton:CreateFontString("Caption", "LOW", "GameFontWhite")
	  f.whisperButton.text:SetAllPoints(f.whisperButton)
	  f.whisperButton.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
	  f.whisperButton.text:SetText("Whisper")
	  f.whisperButton:SetScript("OnClick", function()
	    foobar()
	  end)
	end

	do -- button: refresh
	  f.interactButton = CreateFrame("Button", "SendItemDialogAbort", f)
	  pfUI.api.SkinButton(f.interactButton)
	  f.interactButton:SetPoint("BOTTOMRIGHT", -155, 5)
	  f.interactButton:SetWidth(50)
	  f.interactButton:SetHeight(25)
	  f.interactButton.text = f.interactButton:CreateFontString("Caption", "LOW", "GameFontWhite")
	  f.interactButton.text:SetAllPoints(f.interactButton)
	  f.interactButton.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
	  f.interactButton.text:SetText("Interact")
	  f.interactButton:SetScript("OnClick", function()
	    foobar()
	  end)
	end

	do -- Edit Box
		f.scroll = pfUI.api.CreateScrollFrame("pfAdminTicketsScroll", f)
		f.scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -80)
		f.scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 40)
		f.scroll:SetWidth(320)
		f.scroll:SetHeight(320)

		f.scroll.backdrop = CreateFrame("Frame", "pfAdminTicketsScrollBackdrop", f.scroll)
		f.scroll.backdrop:SetFrameLevel(1)
		f.scroll.backdrop:SetPoint("TOPLEFT", f.scroll, "TOPLEFT", -5, 5)
		f.scroll.backdrop:SetPoint("BOTTOMRIGHT", f.scroll, "BOTTOMRIGHT", 5, -5)
		pfUI.api.CreateBackdrop(f.scroll.backdrop, nil, true)

		f.scroll.text = CreateFrame("EditBox", "pfAdminTicketsScrollText", f.scroll)
		f.scroll.text:SetMultiLine(true)
		f.scroll.text:SetWidth(320)
		f.scroll.text:SetHeight(320)

		f.scroll.text:SetAllPoints(f.scroll)
		f.scroll.text:SetTextInsets(20,20,20,0)
		f.scroll.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
		f.scroll.text:SetAutoFocus(false)
		f.scroll.text:SetJustifyH("LEFT")
		f.scroll.text:SetScript("OnEscapePressed", function() this:ClearFocus() end)
		f.scroll.text:SetScript("OnTextChanged", function()
			this:GetParent():UpdateScrollChildRect()
		  this:GetParent():UpdateScrollState()
		end)

		f.scroll:SetScrollChild(f.scroll.text)
	end

	return f
end
