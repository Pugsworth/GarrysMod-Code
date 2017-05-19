
local PANEL = {};

AccessorFunc(PANEL, "m_bSelectingTarget", "SelectingTarget");

function PANEL:Init()
end

function PANEL:Setup(vars)

    self:Clear();

    local canvas = self:Add("DPanel");
    canvas:SetDrawBackground(false);
    canvas:Dock(FILL);

    self.IsEditing = function(self)
        return self:GetSelectingTarget();
    end

    self.SetValue = function(self, ...)
    end

    self:SetSelectingTarget(false);


    self:AddButton("Player Position", function() end, false);
    self:AddButton("Cursor Position", function() end, false);

    self:AddButton("Begin Picker", function() end, true, "End Picker");

end

function PANEL:AddButton(name, callback, isToggle, ...)
    local ext = {...};

    local btn = self.canvas:Add("DButton");
    btn:SetText(name);
    btn:SizeToContents();

    if isToggle then
        btn:SetIsToggle(isToggle);
        btn.OnToggled = function(this, toggleState)
            callback(self, toggleState, unpack(ext));
        end
    else
        btn.DoClick = function(this)
            callback(self, unpack(ext));
        end
    end

    self.m_buttons[#self.m_buttons+1] = btn;

    return btn;
end

derma.DefineControl("DProperty_TargetSelect", "", PANEL, "DProperty_Generic");
