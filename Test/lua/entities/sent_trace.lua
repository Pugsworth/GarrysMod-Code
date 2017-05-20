-- Util

local function debounce(func, waittime)

	local values;
	local nextcall = 0;

	return (function(...)
				if nextcall <= RealTime() then
					values = {...};
					func(unpack(values));
					nextcall = RealTime() + (waittime / 1000);
				end
			end);
end



AddCSLuaFile();

ENT.Type = "anim";
ENT.Base = "base_anim";

ENT.PrintName		= "Trace Test";
ENT.Category		= "Testing";
ENT.Spawnable       = true;
ENT.AdminOnly       = false;

ENT.Author			= "Pugsworth";
ENT.Contact			= "N/A";
ENT.Purpose			= "Test Penetrating traces";
ENT.Instructions	= "N/A";

ENT.RenderGroup = RENDERGROUP_BOTH;
ENT.Editable = true;

local tracerangenwtag = ENT.PrintName:gsub(" ", "_");

if SERVER then
	util.AddNetworkString(tracerangenwtag);
end

local STATE = {
	WAITING  = 0,
	PRIMED   = 1,
	ACTIVE   = 2,
	INACTIVE = 3
};

-- data for use with states
local STATE_DATA = {
	[STATE.WAITING]   = {
		color = {0, 1, 0}
	},
	[STATE.PRIMED]    = {
		color = {1, 1, 0},
		sound = "buttons/lever6.wav"
	},
	[STATE.ACTIVE]    = {
		color = {1, 0, 0},
		sound = "buttons/button9.wav"
	},
	[STATE.INACTIVE]  = {
		color = {0, 0, 0},
		sound = "buttons/button5.wav"
	}
};


function ENT:SetupDataTables()

	self:NetworkVar("Int", 0, "State",        {});
	self:NetworkVar("Int", 1, "StateEnd",     {});
	self:NetworkVar("Float", 0, "TraceRange", {KeyName = "tracerange", Edit = { title="Trace Range", order=0, type="Float", min=4.0, max=1024.0}});

end

-- we want to change the renderbounds to encompass the trace visulization
local function OnTraceRangeChanged(newrange, ent)

	if SERVER then
		net.Start(tracerangenwtag);
		net.WriteEntity(ent);
		net.WriteFloat(newrange);
		net.Broadcast();
	else
		ent:SetRenderBounds(Vector(-2, -2, -2), Vector(2, 2, newrange));
	end

end

if CLIENT then
	net.Receive(tracerangenwtag, function()
		local ent = net.ReadEntity();
		local newrange = net.ReadFloat();
		OnTraceRangeChanged(newrange, ent);
	end);
end


function ENT:Initialize()

	-- SERVER only
	if SERVER then

	    -- Entity initializers
		self:SetModel("models/props_junk/popcan01a.mdl");
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:SetSolid(SOLID_VPHYSICS);

		self:SetUseType(SIMPLE_USE);


		-- Physics

		local phys = self:GetPhysicsObject();
		if phys:IsValid() then
			phys:Wake();
		end


		-- debounce the function that sends the network message to the client
		-- informing them to change the renderbounds
		local debTraceRangeCallback = debounce(OnTraceRangeChanged, 1000);
		self:NetworkVarNotify("TraceRange", function(this, varname, old, new)
			debTraceRangeCallback(new, this);
		end);

	end

	-- Fields

	-- self.m_state    = 0;
	-- self.m_stateEnd = 0;
	self:SetState(0);
	self:SetStateEnd(0);

	self.m_useLock   = false; -- lock use out until next state
	self.m_useQueued = false; -- if used between states, queue the next state

	-- self.m_traceRange = 64;
	self:SetTraceRange(64);

end


function ENT:Think()
	if CLIENT then return; end

	local curstate = self:GetState();
	local curstateend = self:GetStateEnd();

	if curstate == STATE.ACTIVE then
		if curstateend <= RealTime() then
			self:SetStateBoth(STATE.INACTIVE, RealTime() + 1.0);
			self:EmitSound(STATE_DATA[STATE.INACTIVE].sound);
		end

	elseif curstate == STATE.INACTIVE then
		if curstateend <= RealTime() then
			self:SetStateBoth(STATE.WAITING, 0);
		end
	end

end

function ENT:Use(activator, caller)

	if CLIENT then return; end

	if self.m_useLock and self:GetStateEnd() > RealTime() then
		return;
	end

	self.m_useLock = false;

	local curstate = self:GetState();

	if curstate == STATE.WAITING then
		self:SetState(STATE.PRIMED);
		self:EmitSound(STATE_DATA[STATE.PRIMED].sound);

	elseif curstate == STATE.PRIMED then
		self:SetStateBoth(STATE.ACTIVE, RealTime() + 1.0);
		self:DoActive();
	end

end

function ENT:Draw()

	local startpos = self:GetPos();
	local endpos = startpos + self:GetUp() * self:GetTraceRange();
	render.DrawLine(startpos, endpos, color_white, true);

	render.SetColorModulation(unpack(STATE_DATA[self:GetState()].color));

	self:DrawModel();

	render.SetColorModulation(1, 1, 1);

end



function ENT:SetStateBoth(state, stateEnd)

	-- self.m_state    = state;
	-- self.m_stateEnd = stateEnd or 0;

	self:SetState(state);
	self:SetStateEnd(stateEnd or 0);

	if stateEnd > 0 then
		self.m_useLock = true;
	end

end


function ENT:DoActive()

	print("DoActive!");
	self:EmitSound(STATE_DATA[STATE.ACTIVE].sound);

	-- the initial trace to find the surface
	local initialTrace = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetUp() * self:GetTraceRange(),
		filter = self
	});

	if not initialTrace.Hit then return; end

	-- now create a decal using the surface position - normal * 4

	local startpos = initialTrace.HitPos + initialTrace.HitNormal * 4;
	local endpos   = initialTrace.HitPos - initialTrace.HitNormal * 8;
	util.Decal("Scorch", startpos, endpos);

end

-- perform a trace and return all "segments" of hit surfaces
--[[
	surfaces structure:
	{
		[1] = {
			Table (TraceResult) TraceResult,
			Boolean Internal, -- if this segment is an internal segment (starts within)

		},
		...
	}

--]]
local function TracePenetration(tracedata, maxlength)

	local surfaces = {};

	local distance = 0;
	local MAX_DISTANCE = maxlength or 1024;

	local traceRes = {};

	-- variables to track between iterations
	local startpos = tracedata.start;
	local endpos   = tracedata.endpos;
	local filter   = tracedata.filter;

	-- if the next trace is to start internal,
	-- keep track so we know to use FractionLeftSolid or HitPos
	local isInternal = false;

	repeat

		util.TraceLine({
			start  = startpos,
			endpos = endpos,
			filter = filter,
			output = traceRes
		});

	until distance >= MAX_DISTANCE;

	return surfaces;

end
