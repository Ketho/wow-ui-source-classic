INSPECTFRAME_SUBFRAMES = { "InspectPaperDollFrame", "InspectHonorFrame" };

function InspectFrame_Show(unit)
	HideUIPanel(InspectFrame);
	if ( CanInspect(unit, true) ) then
		NotifyInspect(unit);
		InspectFrame.unit = unit;
		InspectSwitchTabs(1);
	end
end

function InspectFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PORTRAITS_UPDATED");
	self:RegisterEvent("INSPECT_READY");
	self.unit = nil;

	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, 1);
end

function InspectFrame_OnEvent(self, event, ...)
	if(event == "INSPECT_READY") then
		local unit = ...;
		if (InspectFrame.unit and (UnitGUID(InspectFrame.unit) == unit)) then
			ShowUIPanel(InspectFrame);
			InspectFrame_UpdateTabs();
		end
	end

	if ( not self:IsShown() ) then
		return;
	end

	if ( event == "PLAYER_TARGET_CHANGED" or event == "GROUP_ROSTER_UPDATE" ) then
		if ( (event == "PLAYER_TARGET_CHANGED" and self.unit == "target") or
		     (event == "GROUP_ROSTER_UPDATE" and self.unit ~= "target") ) then
			HideUIPanel(InspectFrame);
		end
	elseif ( event == "UNIT_NAME_UPDATE" ) then
		local unit = ...;
		if ( unit == self.unit ) then
			InspectNameText:SetText(GetUnitName(self.unit, true));
		end
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		if unit == self.unit then
			SetPortraitTexture(InspectFramePortrait, self.unit);
		end	
	elseif ( event == "PORTRAITS_UPDATED" ) then
		SetPortraitTexture(InspectFramePortrait, self.unit);
	end
end

function InspectFrame_UnitChanged(self)
	local unit = self.unit;
	NotifyInspect(unit);
	InspectPaperDollFrame_OnShow(self);
	SetPortraitTexture(InspectFramePortrait, unit);
	InspectNameText:SetText(GetUnitName(unit, true));
	InspectFrame_UpdateTabs();
	if ( InspectPVPFrame:IsShown() ) then
		InspectPVPFrame_OnShow();
	end
end

function InspectFrame_OnShow(self)
	if ( not self.unit ) then
		return;
	end
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);	
	SetPortraitTexture(InspectFramePortrait, self.unit);
	InspectNameText:SetText(GetUnitName(self.unit, true));
end

function InspectFrame_OnHide(self)
	self.unit = nil;
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);

	-- Clear the player being inspected
	ClearInspectPlayer();
end

function InspectSwitchTabs(newID)
	local newFrame = _G[INSPECTFRAME_SUBFRAMES[newID]];
	local oldFrame = _G[INSPECTFRAME_SUBFRAMES[PanelTemplates_GetSelectedTab(InspectFrame)]];
	if ( newFrame ) then
		if ( oldFrame ) then
			oldFrame:Hide();
		end
		PanelTemplates_SetTab(InspectFrame, newID);
		newFrame:Show();
	end
end

function InspectFrameTab_OnClick(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	InspectSwitchTabs(self:GetID());
end

function InspectFrame_UpdateTabs()
	if ( not InspectFrame.unit ) then
		return;
	end
end
