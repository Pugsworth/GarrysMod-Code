-------------
-- Convars --
-------------

local convars = {
    enabled = CreateConVar("cl_quickinfo_enable", 1, FCVAR_ARCHIVE, "Enables the hl2 quickinfo.")
};


----------------------
-- Helper functions --
----------------------

local function default(arg, def)
    if not arg then
        return def;
    end

    return arg;
end

local function getDrawPosition()
    if vgui.CursorVisible() then
        return gui.MousePos();
    else
        return ScrW() / 2, ScrH() / 2;
    end
end

local function lerpColor(frac, c1, c2, ptrc)
    local r = Lerp(frac, c1.r, c2.r);
    local g = Lerp(frac, c1.g, c2.g);
    local b = Lerp(frac, c1.b, c2.b);
    local a = Lerp(frac, c1.a, c2.a);

    if ptrc then
        ptrc.r = r;
        ptrc.g = g;
        ptrc.b = b;
        ptrc.a = a;

        return ptrc;
    end

    return Color(r, g, b, a);
end

-- mask clipping helper

local StartMask;
local IntermediateMask;
local EndMask;
do
    local bMaskBegan = false;
    local iWarnCount = 0;

    local function maskwarn(...)
        if iWarnCount < 5 then
            ErrorNoHalt(string.format("[%i]%s", iWarnCount, ...));
            iWarnCount = iWarnCount + 1;
        end
    end

    function StartMask(bdrawmask)
        if bMaskBegan then
            maskwarn("Attempt to start a new mask when one was already started!");
            return; -- don't do stencil operations
        end

        render.ClearStencil();
        render.SetStencilEnable(true);

        render.SetStencilTestMask(1); -- God damnit garry, fix your halo
        render.SetStencilWriteMask(1);

        if bdrawmask then
            render.SetStencilCompareFunction(STENCIL_ALWAYS);
        else
            render.SetStencilCompareFunction(STENCIL_NEVER);
        end
        render.SetStencilFailOperation(STENCIL_INCR);
        render.SetStencilPassOperation(STENCIL_KEEP);
        render.SetStencilZFailOperation(STENCIL_KEEP);

        bMaskBegan = true;
    end

    function IntermediateMask()
        if not bMaskBegan then
            maskwarn("Attempt to intermediate mask when one wasn't started!");
            return;
        end

        render.SetStencilReferenceValue(1);
        render.SetStencilCompareFunction(STENCIL_EQUAL);
    end

    function EndMask()
        if not bMaskBegan then
            maskwarn("Attempt to end mask when one wasn't started!");
            return;
        end

        render.SetStencilEnable(false);

        bMaskBegan = false;
        iWarnCount = 0;
    end
end

-- ammo helper

local ammo = {};
ammo.NONE = -1;
ammo.INFINITE = math.huge;
ammo.INF = ammo.INFINITE;

ammo.invalidvalues = {[ammo.NONE] = true, [ammo.INFINITE] = true};

function ammo.measurable(val, threshold)
    -- if maxclip1 > 0 then return true; end
    if threshold and threshold <= 0 then return false; end

    return not (ammo.invalidvalues[val] or ammo.invalidvalues[threshold]);
end

ammo.cweapons = {
    -- class            maxclip1    maxclip2
    -- -1 = no ammo, math.huge = infinite ammo
    ["weapon_crowbar"]    = {ammo.NONE, ammo.NONE},
    ["weapon_physcannon"] = {ammo.NONE, ammo.NONE},
    ["weapon_physgun"]    = {ammo.NONE, ammo.NONE},
    ["weapon_pistol"]     = {18,        ammo.NONE},
    ["weapon_357"]        = {6,         ammo.NONE},
    ["weapon_smg1"]       = {45,        ammo.INF},
    ["weapon_ar2"]        = {30,        ammo.NONE},
    ["weapon_shotgun"]    = {6,         ammo.NONE},
    ["weapon_crossbow"]   = {1,         ammo.NONE},
    ["weapon_frag"]       = {ammo.INF,  ammo.NONE},
    ["weapon_rpg"]        = {ammo.INF,  ammo.NONE},
    ["weapon_bugbait"]    = {ammo.NONE, ammo.NONE},
    ["weapon_stunstick"]  = {ammo.NONE, ammo.NONE}
};

function ammo.Clip1(wep)
    return wep:Clip1();
end

function ammo.MaxClip1(wep)
    if wep:IsScripted() then
        return wep.Primary and wep.Primary.ClipSize or -1;
    end

    local cwep = ammo.cweapons[wep:GetClass()];

    if cwep then
        return cwep[1];
    end

    return ammo.NONE;
end

function ammo.Clip2(wep)
    return wep:Clip2();
end

function ammo.MaxClip2(wep)
    if wep:IsScripted() then
        return wep.Secondary and wep.Secondary.ClipSize or -1;
    end

    local cwep = ammo.cweapons[wep:GetClass()];

    if cwep then
        return cwep[2];
    end

    return ammo.NONE;
end

function ammo.Ammo1(wep)
    return LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType());
end

function ammo.Ammo2(wep)
    return LocalPlayer():GetAmmoCount(wep:GetSecondaryAmmoType());
end

-----------
-- Enums --
-----------

local HEALTH_WARNING_THRESHOLD = 25;
local AMMO_PERC_THRESHOLD      = 0.25;
local EVENT_DURATION           = 1.0;
local BRIGHTNESS_FULL          = 255;
local BRIGHTNESS_DIM           = 64;
local FADE_IN_TIME             = 0.5;
local FADE_OUT_TIME            = 2.0;

----------
-- Side --
----------

surface.CreateFont("QuickInfo2", {
    font = "HalfLife2",
    size = 128,
    antialias = true,
    additive = false
});

local SIDE = {
    Base = "Panel"
};

-- AccessorFunc(SIDE, "m_eSide", "Side", FORCE_NUMBER); -- SetSide(LEFT) / SetSide(RIGHT);
AccessorFunc(SIDE, "m_colLight", "ColorLight");
AccessorFunc(SIDE, "m_colNormal", "ColorNormal");
AccessorFunc(SIDE, "m_colCaution", "ColorCaution");
AccessorFunc(SIDE, "m_iScale", "Scale"); -- 1 = 128px
AccessorFunc(SIDE, "m_nValue", "Value");
AccessorFunc(SIDE, "m_nMaxValue", "MaxValue");
AccessorFunc(SIDE, "m_nThreshold", "Threshold");

function SIDE:Init()
    self.m_fAng = math.rad(40); -- 40 degrees space between 0 and start
    self:SetValue(0);
    self:SetMaxValue(0);
    self:SetScale(1);
    self:SetSide(LEFT);

    self.m_bWarn = false;
    self.m_fFade = 0.0;

    -- self:NoClipping(true);

    self:SetColorLight(NamedColor("Yellowish"));
    self:SetColorNormal(NamedColor("Normal"));
    self:SetColorCaution(NamedColor("Caution"));

    surface.SetFont("QuickInfo2");
    local w, h = surface.GetTextSize(self.m_charFilled);
    self:SetSize(w + 2, h + 2);
end

function SIDE:SetValue(value)

    -- if warn indicator has been triggered, but the value changes before it finishes the animation, then boost the animation
    if (self.m_nValue ~= value) and (self.m_bWarn) and (self.m_fFade > 0) then
        self.m_fFade = math.min(self.m_fFade, 10);
    end

    self.m_nValue = value;

end

function SIDE:SetSide(side)
    assert(type(side) == "number");
    self.m_eSide = side;
    self.m_charEmpty = side == LEFT and '{' or '}';
    self.m_charFilled = side == LEFT and '[' or ']';
end

function SIDE:GetSide()
    return self.m_eSide;
end

function SIDE:Think()

    if ammo.measurable(self.m_nMaxValue, self.m_nThreshold) then
        if self.m_nValue and self.m_nThreshold and self.m_nMaxValue > 1 and self.m_nValue < self.m_nThreshold and self.m_nValue ~= 0 then
            if not self.m_bWarn then
                self.m_bWarn = true;
                self.m_fFade = 255.0; -- ???

                LocalPlayer():EmitSound("HUDQuickInfo.LowHealth");
            end
        else
            self.m_bWarn = false;
        end
    else
        if self.m_bWarn then
            self.m_bWarn = false;
        end
    end
end

function SIDE:drawMask(w, h)
    local value = self.m_nValue;
    local maxvalue = self.m_nMaxValue;
    local side = self.m_eSide;

    surface.SetFont("QuickInfo2")
    local tw, th = surface.GetTextSize(self.m_charFilled);

    local ox, oy = -22, th / 2;
    local dist = 70;

    if side == LEFT then
        ox = w + 20;
        dist = dist * -1;
    end

    local frac = ammo.measurable(maxvalue, self.m_nThreshold) and (value / maxvalue) or 1;

    if self.m_bWarn and self.m_fFade > 0 then
        frac = 1.0;
        self.m_fFade = self.m_fFade - (100 * FrameTime());
    end

    local ph = math.pi / 2;
    local rr = self.m_fAng + ((ph - self.m_fAng) * 2) * (1 - frac);
    local verts;

    if side == LEFT then
        verts = {
            { -- origin, which is left middle or right middle depending on side
                x = ox,
                y = oy
            },
            {
                x = ox + math.sin(rr) * dist,
                y = oy + math.cos(rr) * dist

            },
            {
                x = ox + math.sin(math.pi - self.m_fAng) * dist,
                y = oy + math.cos(math.pi - self.m_fAng) * dist
            },
        };
    else
        verts = {
            { -- origin, which is left middle or right middle depending on side
                x = ox,
                y = oy
            },
            {
                x = ox + math.sin(self.m_fAng) * dist,
                y = oy + math.cos(self.m_fAng) * dist

            },
            {
                x = ox + math.sin(math.pi - rr) * dist,
                y = oy + math.cos(math.pi - rr) * dist
            },
        };
    end

    surface.SetDrawColor(color_black);
    surface.DrawPoly(verts);
end

function SIDE:drawDebug(w, h)
    ---[[
    surface.SetDrawColor(color_white);
    surface.DrawOutlinedRect(0, 0, w, h);

    surface.SetFont("QuickInfo2");
    local tw, th = surface.GetTextSize(self.m_charEmpty);

    surface.SetDrawColor(Color(200, 80, 80));
    surface.DrawOutlinedRect(1, 1, tw, th);

    surface.SetDrawColor(Color(80, 200, 80));
    surface.DrawLine(0, th / 2, tw, th / 2);
    --]]
end

function SIDE:getColor()
    if self.m_bWarn then
        local sinScale = math.abs(math.sin(CurTime() * 8) * 128);
        self.m_colCaution.a = 128 + sinScale;

        return self.m_colCaution;
    end

    return self.m_colNormal;
end

function SIDE:Paint(w, h)

    surface.SetTextColor(self:getColor());
    surface.SetFont("QuickInfo2");
    surface.SetTextPos(1, -16);
    surface.DrawText(self.m_charEmpty);

    StartMask(false);
        self:drawMask(w, h);
    IntermediateMask();
        surface.SetTextPos(1, -16);
        surface.DrawText(self.m_charFilled);
    EndMask();

    -- self:drawDebug(w, h);
end

-----------
-- PANEL --
-----------

local PANEL = {
    Base = "Panel"
};

function PANEL:Init()
    self.m_pLeft = vgui.CreateFromTable(SIDE, self);
    self.m_pLeft:SetSide(LEFT);
    self.m_pLeft:SetThreshold(HEALTH_WARNING_THRESHOLD);

    self.m_pRight = vgui.CreateFromTable(SIDE, self);
    self.m_pRight:SetSide(RIGHT);

    self.m_iLastHealth = 0;
    self.m_iLastAmmo = 0;

    self.m_bDimmed = false;

    self.m_lastEvent = RealTime();

    -- self:SizeToChildren(false, true);
    -- self:InvalidateLayout();
end

function PANEL:PerformLayout()
    -- print("Perform Layout");

    self.m_pLeft:Dock(LEFT);
    self.m_pRight:Dock(RIGHT);

    self:SizeToChildren(false, true);
    local w, h = self:GetSize();
    local OFFSET_X = 2;
    self:SetPos(OFFSET_X + (ScrW() / 2 - (w / 2)), ScrH() / 2 - (128 / 2));
end

local ply;

function PANEL:DimThink(health, clip1)
    if (self.m_iLastAmmo ~= clip1 or self.m_iLastHealth ~= health) then

        self.m_iLastAmmo = clip1;
        self.m_iLastHealth = health;

        self.m_lastEvent = RealTime();
    end

    if (RealTime() - self.m_lastEvent) > EVENT_DURATION then
        if not self.m_bDimmed then
            self.m_bDimmed = true;
            self:AlphaTo(BRIGHTNESS_DIM, FADE_OUT_TIME);
        end

    elseif self.m_bDimmed then
        self.m_bDimmed = false;
        self:AlphaTo(BRIGHTNESS_FULL, FADE_IN_TIME);
    end
end

function PANEL:Think()
    if IsValid(ply) then
        local health = ply:Health();

        self.m_pLeft:SetValue(math.max(0, health));
        self.m_pLeft:SetMaxValue(100);

        local wep = ply:GetActiveWeapon();
        local clip1;
        if IsValid(wep) then
            clip1 = ammo.Clip1(wep);
            maxclip1 = ammo.MaxClip1(wep);

            self.m_pRight:SetValue(clip1);
            self.m_pRight:SetMaxValue(maxclip1);
            self.m_pRight:SetThreshold(maxclip1 * AMMO_PERC_THRESHOLD);

            -- print(maxclip1, maxclip1 / AMMO_PERC_THRESHOLD)
        else
            clip1 = ply:Alive() and 1 or 0;

            self.m_pRight:SetValue(clip1);
            self.m_pRight:SetMaxValue(ammo.NONE);
            self.m_pRight:SetThreshold(0);
        end

        self:DimThink(health, clip1);
    end
end

function PANEL:Paint(w, h)
    -- surface.SetDrawColor(Color(80, 80, 200));
    -- surface.DrawOutlinedRect(0, 0, w, h);
    if not IsValid(ply) then ply = LocalPlayer(); end
end

local function alphaThink(self, pnl, frac)
    if not self.m_iAlphaStart then self.m_iAlphaStart = pnl:GetAlpha(); end

    pnl:SetAlpha(Lerp(frac, self.m_iAlphaStart, self.m_iAlpha));
end

function PANEL:AlphaTo(alpha, duration)

    if self.m_anim then self.m_anim.Think = nil; self.m_anim = nil; end -- cut any animation short if one exists and is still running

    local anim = self:NewAnimation(duration, 0, nil, nil);
    anim.m_iAlpha = alpha;
    anim.Think = alphaThink;

    self.m_anim = anim;
end

--------------
-- Creation --
--------------

if HUD_QUICKINFO then
    HUD_QUICKINFO:Remove();
end

HUD_QUICKINFO = vgui.CreateFromTable(PANEL);
HUD_QUICKINFO:SetSize(97, 0);
-- HUD_QUICKINFO:ParentToHUD();
-- HUD_QUICKINFO:NoClipping(true);

cvars.AddChangeCallback("cl_quickinfo_enable", function(name, oldVal, newVal)

    if not HUD_QUICKINFO then
        return;
    end

    local bov = tobool(oldVal);
    local bnv = tobool(newVal);

    if bov == false and bnv == true then
        HUD_QUICKINFO:Show();
    elseif bov == true and bnv == false then
        HUD_QUICKINFO:Hide();
    end

end);

