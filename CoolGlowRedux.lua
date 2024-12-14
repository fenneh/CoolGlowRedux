local CG = LibStub("AceAddon-3.0"):NewAddon("CoolGlowRedux", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("CoolGlowRedux")
local LDB = LibStub("LibDataBroker-1.1")
local LDBI = LibStub("LibDBIcon-1.0")
local LCG = LibStub('LibCustomGlow-1.0')
local MyClass = select(2, UnitClass('player'))
local ClassColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[MyClass] or RAID_CLASS_COLORS[MyClass]
CG.ClassColor = {ClassColor.r, ClassColor.g, ClassColor.b, 1}
CG.version = C_AddOns.GetAddOnMetadata("CoolGlowRedux", "Version")
CG.addonName = "|cfff2f251Cool Glow Redux|r"
CG.icon = [[Interface\Addons\CoolGlowRedux\media\icon.tga]]
CG.NewSign = '|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:14:14|t'
function CG:Print(...)
	print("|cfff2f251".."Cool Glow Redux|r:", ...)
end
function CG:PrintURL(url) -- Credit: Azilroka
	return format("|cfff2f251[|Hurl:%s|h%s|h]|r", url, url)
end
------ [Defaults & Options] ------
local defaults = {
	profile = {
		Welcome = true,
		Notify = true,
		minimap = {
			hide = false,
		},
		Style = "Pixel",
		Color = {r = 0.95, g = 0.95, b = 0.32, a = 1},
		ClassColor = false,
		DisableGlow = false,
		Button = {
			Frequency = 0.2,
		},
		Pixel = {
			NumLines = 8,
			Frequency = 0.45,
			Length = 8,
			Thickness = 2,
			XOffset = 0,
			YOffset = 0,
			Border = false,
		},
		AutoCast = {
			NumParticles = 8,
			Frequency = 0.45,
			Scale = 1,
			XOffset = 0,
			YOffset = 0,
		},
	}
}
local options = {
	type = "group",
	handler = CG,
	name = L["Cool Glow Redux"],
	childGroups = "tab",
	args = {
		intro = {
			order = 1,
			type = 'description',
			fontSize = "medium",
			name = L["CG_DESC"],
			image = function() return CG.icon, 100, 100 end,
		},
		Space1 = {
			order = 2,
			type = "description",
			name = "",
		},
		Space2 = {
			order = 4,
			type = "description",
			name = "",
		},
		minimap = {
			order = 7,
			type = "toggle",
			name = L["Minimap Button"],
			desc = L["Show the minimap button."],
			get = function() return not CG.db.profile.minimap.hide end,
			set = function(info, value)
				CG.db.profile.minimap.hide = not value
				if value then
						LDBI:Show("CoolGlowRedux")
					else
						LDBI:Hide("CoolGlowRedux")
					end
				end,
		},
		Space3 = {
			order = 8,
			type = "description",
			name = "",
		},
		DisableGlow = {
			order = 9,
			type = "toggle",
			name = L["Disable Glow"]..CG.NewSign,
			desc = L["Remove all glows from all the spell activations overlay glow."],
			get = function(info) return CG.db.profile.DisableGlow end,
			set = function(info, value) CG.db.profile.DisableGlow = value end,
		},
		Test = {
			order = 10,
			type = "execute",
			name = L["Display Glow"],
			desc = L["TEST_DESC"],
			func = function() CG:ToggleTestFrame() end,
		},
		Space4 = {
			order = 11,
			type = "description",
			name = "",
		},
		Style = {
			order = 12,
			type = "select",
			name = L["Style"],
			disabled = function() return CG.db.profile.DisableGlow end,
			get = function(info) return CG.db.profile.Style end,
			set = function(info, value) CG.db.profile.Style = value end,
			values = {
				["Button"] = L["Button Glow"],
				["Pixel"] = L["Pixel Glow"],
				["AutoCast"] = L["AutoCast Glow"],
			},
		},
		Color = {
			order = 13,
			type = "color",
			name = L["Color"],
			hasAlpha = true,
			disabled = function() return CG.db.profile.DisableGlow or CG.db.profile.ClassColor end,
			get = function(info)
				local t = CG.db.profile.Color
				return t.r, t.g, t.b, t.a
			end,
			set = function(info, r, g, b, a)
				local t = CG.db.profile.Color
				t.r, t.g, t.b, t.a = r, g, b, a
				CG:ActionbarGlow()
			end,
		},
		ClassColor = {
			order = 14,
			type = "toggle",
			name = L["Class Color"],
			desc = L["Use class color glow, this will overwrite color picker color."],
			disabled = function() return CG.db.profile.DisableGlow end,
			get = function(info) return CG.db.profile.ClassColor end,
			set = function(info, value) CG.db.profile.ClassColor = value end,
		},
		Button = {
			order = 30,
			type = "group",
			name = L["Button Glow"],
			disabled = function() return CG.db.profile.DisableGlow end,
			get = function(info) return CG.db.profile.Button[ info[#info] ] end,
			set = function(info, value) CG.db.profile.Button[ info[#info] ] = value; CG:ActionbarGlow() end,
			args = {
				Frequency = {
					order = 1,
					type = "range",
					name = L["Frequency"],
					desc = L["Animation speed. Negative values will rotate anti-clockwise."],
					min = 0, max = 1, step = 0.1,
				},
			},
		},
		Pixel = {
			order = 31,
			type = "group",
			name = L["Pixel Glow"],
			disabled = function() return CG.db.profile.DisableGlow end,
			get = function(info) return CG.db.profile.Pixel[ info[#info] ] end,
			set = function(info, value) CG.db.profile.Pixel[ info[#info] ] = value; CG:ActionbarGlow() end,
			args = {
				NumLines = {
					order = 1,
					type = "range",
					name = L["Num Lines"],
					desc = L["Defines the number of lines the glow will spawn."],
					min = 4, max = 20, step = 1,
				},
				Frequency = {
					order = 2,
					type = "range",
					name = L["Frequency"],
					desc = L["Sets the animation speed of the glow. Negative values will rotate the glow anti-clockwise."],
					min = -2, max = 2, step = 0.01,
				},
				Length = {
					order = 3,
					type = "range",
					name = L["Length"],
					desc = L["Defines the length of each individual glow lines."],
					min = 2, max = 20, step = 1,
				},
				Thickness = {
					order = 4,
					type = "range",
					name = L["Thickness"],
					desc = L["Defines the thickness of the glow lines."],
					min = 1, max = 6, step = 1,
				},
				XOffset = {
					order = 5,
					type = "range",
					name = L["X-Offset"],
					min = -5, max = 5, step = 1,
				},
				YOffset = {
					order = 6,
					type = "range",
					name = L["Y-Offset"],
					min = -5, max = 5, step = 1,
				},
				Border = {
					order = 7,
					type = "toggle",
					name = L["Border"],
					desc = L["Show border under lines."],
				},
			},
		},
		AutoCast = {
			order = 32,
			type = "group",
			name = L["AutoCast Glow"],
			disabled = function() return CG.db.profile.DisableGlow end,
			get = function(info) return CG.db.profile.AutoCast[ info[#info] ] end,
			set = function(info, value) CG.db.profile.AutoCast[ info[#info] ] = value; CG:ActionbarGlow() end,
			args = {
				NumParticles = {
					order = 1,
					type = "range",
					name = L["Num Particles"],
					desc = L["Defines the number of particle groups. Each group contains 4 particles."],
					min = 4, max = 16, step = 1,
				},
				Frequency = {
					order = 2,
					type = "range",
					name = L["Frequency"],
					desc = L["Sets the animation speed of the glow. Negative values will rotate the glow anti-clockwise."],
					min = -2, max = 2, step = 0.01,
				},
				Scale = {
					order = 3,
					type = "range",
					name = L["Scale"],
					min = 0.5, max = 4, step = 0.1,
				},
				XOffset = {
					order = 4,
					type = "range",
					name = L["X-Offset"],
					min = -5, max = 5, step = 1,
				},
				YOffset = {
					order = 5,
					type = "range",
					name = L["Y-Offset"],
					min = -5, max = 5, step = 1,
				},
			},
		},
	},
}
------ [Minimap Button] ------
local function tooltip_draw()
	local tooltip = GameTooltip;
	-- build the tooltip
	tooltip:ClearLines()
	tooltip:AddDoubleLine(CG.addonName.."", "v"..CG.version, 0.95, 0.95, 0.32, 0.95, 0.95, 0.32)
	tooltip:AddLine(" ")
	tooltip:AddLine("|c"..RAID_CLASS_COLORS[MyClass].colorStr..L["Left-Click|r to open the option settings."], 0.95, 0.95, 0.32)
	tooltip:AddLine("|c"..RAID_CLASS_COLORS[MyClass].colorStr..L["Right-Click|r to display the current proc glow."], 0.95, 0.95, 0.32)
	tooltip:Show()	
end
-- function copied from LibDBIcon-1.0.lua
local function getAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end
local colorFrame = CreateFrame("frame");
local tooltip_update_frame = CreateFrame("FRAME");
local colorElapsed = 0;
local colorDelay = 2;
local r, g, b = 0.94, 0.95, 0.32;
local r2, g2, b2 = random(2)-1, random(2)-1, random(2)-1;
local Broker_CoolGlow;
Broker_CoolGlow = LDB:NewDataObject("CoolGlowRedux", {
	type = "data source",
	text = "CoolGlowRedux",
	icon = "Interface\\Addons\\CoolGlowRedux\\media\\iconbroker.blp",
	OnClick = function(_, button)
		if button == "LeftButton" then
			CG:ToggleConfig()
		elseif button == "RightButton" then
			CG:ToggleTestFrame()
		end
	end,
	OnEnter = function(self)
		colorFrame:SetScript("OnUpdate", function(self, elaps)
		colorElapsed = colorElapsed + elaps;
		if(colorElapsed > colorDelay) then
			colorElapsed = colorElapsed - colorDelay;
			r, g, b = r2, g2, b2;
			r2, g2, b2 = random(2)-1, random(2)-1, random(2)-1;
		end
		Broker_CoolGlow.iconR = r + (r2 - r) * colorElapsed / colorDelay;
		Broker_CoolGlow.iconG = g + (g2 - g) * colorElapsed / colorDelay;
		Broker_CoolGlow.iconB = b + (b2 - b) * colorElapsed / colorDelay;
		end);
		local elapsed = 0;
		local delay = 1;
		tooltip_update_frame:SetScript("OnUpdate", function(self, elap)
		elapsed = elapsed + elap;
			if(elapsed > delay) then
				elapsed = 0;
				tooltip_draw();
			end
		end);
		GameTooltip:SetOwner(self, "ANCHOR_NONE");
		GameTooltip:SetPoint(getAnchors(self))
		tooltip_draw()
	end,
	OnLeave = function(self)
		colorFrame:SetScript("OnUpdate", nil);
		tooltip_update_frame:SetScript("OnUpdate", nil);
		GameTooltip:Hide();
	end,
	iconR = 0.95,
	iconG = 0.95,
	iconB = 0.32,
})
------ [Core Framework] ------
function CG:OnInitialize()
	CG.db = LibStub("AceDB-3.0"):New("CoolGlowReduxDB", defaults)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Cool Glow Redux", options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Cool Glow Redux")
	-- Create Profiles Table
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Cool Glow Redux Profiles", options.args.profiles)
	options.args.profiles.order = -10
	LDBI:Register("CoolGlowRedux", Broker_CoolGlow, CG.db.profile.minimap)
end
function CG:OnEnable()
    self:ActionbarGlow()
	self:CreateTestFrame()
	self:RegisterChatCommand("cg", "ToggleConfig")
    self:RegisterChatCommand("coolglow", "ToggleConfig")
	self:RegisterChatCommand("cgt", "ToggleTestFrame")
	self:RegisterChatCommand("cgtest", "ToggleTestFrame")
end
function CG:ToggleConfig()
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory("Cool Glow Redux")
    else
        -- Fallback for classic/older versions
        InterfaceOptionsFrame_OpenToCategory("Cool Glow Redux")
    end
end
function CG:PLAYER_ENTERING_WORLD()
    if CG.db.profile.Welcome then
        CG:Print((L["Version |cfff2f251%s|r is loaded."]):format(CG.version))
    end
    CG:UnregisterEvent("PLAYER_ENTERING_WORLD")
end
CG:RegisterEvent("PLAYER_ENTERING_WORLD")
function CG:CreateTestFrame()
	local test = CreateFrame("Frame", "CoolGlowTestFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	test:ClearAllPoints()
	test:SetPoint("TOP", UIParent, "TOP", 0, -110)
	test:SetSize(50, 50)
	if C_AddOns.IsAddOnLoaded("ElvUI") then
		test:SetTemplate("Transparent")
	else
		test:SetBackdrop({
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			edgeFile = "edgeFile", tile = false, tileSize = 0, edgeSize = 1,
			insets = {top = 0, left = 0, bottom = 0, right = 0},
		})
		test:SetBackdropColor(18/255, 18/255, 18/255, 0.6)
		test:SetBackdropBorderColor(0, 0, 0, 1)
	end
	test:SetFrameStrata("HIGH")
	test:Hide()
	test:SetMovable(true)
	test:SetResizable(true)
	test:EnableMouse(true)
	test:SetClampedToScreen(true)
	test:RegisterForDrag("LeftButton")
	test:SetResizeBounds(10, 10, 100, 100)
	test:SetScript("OnMouseDown", function(self, button) 
		if button == "RightButton" and not self.isSizing then
			self:StartSizing()
			self.isSizing = true
		end
	end)
	test:SetScript("OnMouseUp", function(self, button) 
		if button == "RightButton" and self.isSizing then
			self:StopMovingOrSizing()
			self.isSizing = false
			CGSize.Width = self:GetWidth()
			CGSize.Height = self:GetHeight()
		end
	end)
	test:SetScript("OnDragStart", test.StartMoving)
	test:SetScript("OnDragStop", function(self)
	  self:StopMovingOrSizing()
	  CGPosition.XPos = self:GetLeft()
	  CGPosition.YPos = self:GetBottom()
	end)
end
function CG:PLAYER_LOGIN()
	CoolGlowPerCharDB = CoolGlowPerCharDB or {} -- Create table if one doesn't exist
	CGPosition = CoolGlowPerCharDB -- Assign settings declared above
	CGSize = CoolGlowPerCharDB -- Assign settings declared above
	if CGPosition.XPos then
		CoolGlowTestFrame:ClearAllPoints()
		CoolGlowTestFrame:SetPoint("BOTTOMLEFT", CGPosition.XPos, CGPosition.YPos)
	end
	if CGSize.Width then
		CoolGlowTestFrame:SetSize(CGSize.Width, CGSize.Height)
	end
end
CG:RegisterEvent("PLAYER_LOGIN")
function CG:ToggleTestFrame()
    if CoolGlowTestFrame:IsShown() then
		CG:StopGlow(CoolGlowTestFrame)
		CoolGlowTestFrame:Hide()
    else
		CG:StartGlow(CoolGlowTestFrame)
		CoolGlowTestFrame:Show()
    end
end
------ [Core Function] ------
function CG:ActionbarGlow()
    -- Hook before the original function is called
    self:SecureHook("ActionButton_ShowOverlayGlow", function(button)
        -- Stop the default glow if it exists
        ActionButton_HideOverlayGlow(button)
        -- Apply our custom glow
        CG:StartGlow(button)
    end)
    
    self:SecureHook("ActionButton_HideOverlayGlow", function(button)
        CG:StopGlow(button)
    end)
end
function CG:StartGlow(button)
	if CG.db.profile.DisableGlow then return end
	local Color = {CG.db.profile.Color.r, CG.db.profile.Color.g, CG.db.profile.Color.b, CG.db.profile.Color.a or 1}
	if CG.db.profile.Style == "Button" then
		LCG.ButtonGlow_Start(button, (CG.db.profile.ClassColor and CG.ClassColor) or Color, CG.db.profile.Button.Frequency)
	elseif CG.db.profile.Style == "Pixel" then
		LCG.PixelGlow_Start(button, (CG.db.profile.ClassColor and CG.ClassColor) or Color, CG.db.profile.Pixel.NumLines, CG.db.profile.Pixel.Frequency, CG.db.profile.Pixel.Length, CG.db.profile.Pixel.Thickness, CG.db.profile.Pixel.XOffset, CG.db.profile.Pixel.YOffset, CG.db.profile.Pixel.Border)
	elseif CG.db.profile.Style == "AutoCast" then
		LCG.AutoCastGlow_Start(button, (CG.db.profile.ClassColor and CG.ClassColor) or Color, CG.db.profile.AutoCast.NumParticles, CG.db.profile.AutoCast.Frequency, CG.db.profile.AutoCast.Scale, CG.db.profile.AutoCast.XOffset, CG.db.profile.AutoCast.YOffset)
	end
end
function CG:StopGlow(button)
	LCG.ButtonGlow_Stop(button)
	LCG.PixelGlow_Stop(button)
	LCG.AutoCastGlow_Stop(button)
end
------ [Static Popups] ------
StaticPopupDialogs["COOLGLOW_RLUI"] = {
    text = L["One or more of the changes you have made require you to reload your UI."],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
        ReloadUI() 
    end,
    whileDead = true,
    hideOnEscape = false,
}