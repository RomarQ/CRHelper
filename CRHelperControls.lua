function CRHelper.UI:TopLevelWindow(name, parent, dims, anchor, hidden)
	--Validate arguments
	if (name==nil or name=="") then return end
	parent=(parent==nil) and GuiRoot or parent
	if (#dims~=2) then return end
	if (#anchor~=4 and #anchor~=5) then return end
	hidden=(hidden==nil) and false or hidden

	--Create the window
	local window=_G[name]
	if (window==nil) then window=WINDOW_MANAGER:CreateTopLevelWindow(name) end

	--Apply properties
	window=CRHelper.Chain(window)
		:SetDimensions(dims[1], dims[2])
		:ClearAnchors()
		:SetAnchor(anchor[1], #anchor==5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
		:SetHidden(hidden)
	.__END
	return window
end

function CRHelper.UI:Control(name, parent, dims, anchor, hidden)
	--Validate arguments
	if (name==nil or name=="") then return end
	parent=(parent==nil) and GuiRoot or parent
	if (dims=="inherit" or #dims~=2) then dims={parent:GetWidth(), parent:GetHeight()} end
	if (#anchor~=4 and #anchor~=5) then return end
	hidden=(hidden==nil) and false or hidden

	--Create the control
	local control=_G[name]
	if (control==nil) then control=WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL) end

	--Apply properties
	local control=CRHelper.Chain(control)
		:SetDimensions(dims[1], dims[2])
		:ClearAnchors()
		:SetAnchor(anchor[1], #anchor==5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
		:SetHidden(hidden)
	.__END
	return control
end

function CRHelper.UI:Backdrop(name, parent, dims, anchor, center, edge, tex, hidden)
	--Validate arguments
	if (name==nil or name=="") then return end
	parent=(parent==nil) and GuiRoot or parent
	if (dims=="inherit" or #dims~=2) then dims={parent:GetWidth(), parent:GetHeight()} end
	if (#anchor~=4 and #anchor~=5) then return end
	center=(center~=nil and #center==4) and center or {0,0,0,0.4}
	edge=(edge~=nil and #edge==4) and edge or {0,0,0,1}
	hidden=(hidden==nil) and false or hidden

	--Create the backdrop
	local backdrop=_G[name]
	if (backdrop==nil) then backdrop=WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP) end

	--Apply properties
	local backdrop=CRHelper.Chain(backdrop)
		:SetDimensions(dims[1], dims[2])
		:ClearAnchors()
		:SetAnchor(anchor[1], #anchor==5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
		:SetCenterColor(center[1], center[2], center[3], center[4])
		:SetEdgeColor(edge[1], edge[2], edge[3], edge[4])
		:SetEdgeTexture("",8,2,2)
		:SetHidden(hidden)
		:SetCenterTexture(tex)
	.__END
	return backdrop
end

function CRHelper.UI:Label(name, parent, dims, anchor, font, color, align, text, hidden)
	--Validate arguments
	if (name==nil or name=="") then return end
	parent=(parent==nil) and GuiRoot or parent
	if (dims=="inherit" or #dims~=2) then dims={parent:GetWidth(), parent:GetHeight()} end
	if (#anchor~=4 and #anchor~=5) then return end
	font	=(font==nil) and "ZoFontGame" or font
	color	=(color~=nil and #color==4) and color or {1, 1, 1, 1}
	align	=(align~=nil and #align==2) and align or {1, 1}
	hidden	=(hidden==nil) and false or hidden

	--Create the label
	local label=_G[name]
	if (label==nil) then label=WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL) end

	--Apply properties
	local label=CRHelper.Chain(label)
		:SetDimensions(dims[1], dims[2])
		:ClearAnchors()
		:SetAnchor(anchor[1], #anchor==5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
		:SetFont(font)
		:SetColor(color[1], color[2], color[3], color[4])
		:SetHorizontalAlignment(align[1])
		:SetVerticalAlignment(align[2])
		:SetText(text)
		:SetHidden(hidden)
	.__END
	return label
end

function CRHelper.Chain(object)
	--Setup the metatable
	local T={}
	setmetatable(T, {__index=function(self, func)
		--Know when to stop chaining
		if func=="__END" then return object end
		--Otherwise, add the method to the parent object
		return function(self, ...)
			assert(object[func], func .. " missing in object")
			object[func](object, ...)
			return self
		end
	end})
	--Return the metatable
	return T
end