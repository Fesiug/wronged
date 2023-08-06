
if CLIENT then

local cv_wronged = CreateClientConVar( "wronged", 1, true, false )
local cv_wronged_scale = CreateClientConVar( "wronged_scale", 3, true, false )
local cv_wronged_time = CreateClientConVar( "wronged_time", 4, true, false )

local function cui( inp )
	return math.Round( inp * cv_wronged_scale:GetFloat() )
end

local function genfonts()
surface.CreateFont("WRONGED_1", {
	font = "PF Tempesta Seven Bold",
	extended = false,
	size = cui( 16 ),
	weight = 0,
	antialias = false,
})

surface.CreateFont("WRONGED_2", {
	font = "PF Tempesta Seven Compressed",
	extended = false,
	size = cui( 10 ),
	weight = 1000,
	antialias = false,
})

surface.CreateFont("WRONGED_3", {
	font = "PF Tempesta Seven Extended",
	extended = false,
	size = cui( 8 ),
	weight = 0,
	antialias = false,
})
end

cvars.AddChangeCallback("wronged_scale", function(convar_name, value_old, value_new)
    genfonts()
end)

local fick = {
	[0] =	2,
	[1] =	1,
	[2] =	2,
	[3] =	3,
	[4] =	4, -- Left arm
	[5] =	4, -- Right arm
	[6] =	6, -- Left leg
	[7] =	6, -- Right leg
	[10] =	10,
}

local transl = {
	[0] =	"GENERIC",
	[1] =	"HEAD",
	[2] =	"CHEST",
	[3] =	"STOMACH",
	[4] =	"ARM", -- Left arm
	[5] =	"ARM", -- Right arm
	[6] =	"LEG", -- Left leg
	[7] =	"LEG", -- Right leg
	[10] =	"GEAR",
}

local wronged = {}

net.Receive( "WRONGED", function()
	local ent = net.ReadEntity()
	local dmg = net.ReadFloat()
	local hg = net.ReadUInt( 4 )
	hg = fick[hg]

	
	if !wronged[ent] then wronged[ent] = {} end
	local we = wronged[ent]
	we.time = CurTime()
	we.dmg = (we.dmg or 0) + dmg
	
	if !we.dmgtable then we.dmgtable = {} end
	local dm = we.dmgtable

	if dm[hg] then
		local t = dm[hg]
		t.dmg = t.dmg + dmg
		t.hit = t.hit + 1
		t.time = CurTime()
	else
		dm[hg] = { dmg = dmg, hit = 1, time = CurTime() }
	end
end)

hook.Add( "HUDPaint", "WRONGED_HUDPaint", function()
	if !cv_wronged:GetBool() then return end
	local s = cui( 0.5 )
	local off = cui( 8 )
	local off2 = cui( 62 + 5 )
	local w, h = cui( 86 ), cui( 62 )
	
	local num = 0
	for i, v in SortedPairsByMemberValue( wronged, "time", true ) do
		if v.time <= CurTime()-(cv_wronged_time:GetFloat()) then wronged[i] = nil continue end

		local x, y = 0, 0
		x, y = off, off
		y = y + (num*off2)
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( x+s, y+s, w, h )

		surface.SetDrawColor( 255, 100, 0, 255 )
		surface.DrawRect( x, y, w, h )

		local al = math.TimeFraction( v.time+cv_wronged_time:GetFloat(), v.time, CurTime() )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( x, y, math.min( (cui( 78 )*al)+(s*2), w ), cui( 2 ) )

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( x, y, cui( 78 )*al, cui( 1 ) )
		

		x, y = off + cui( 4 ), off + cui( 2 )
		y = y + (num*off2)
		surface.SetFont( "WRONGED_2" )
		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos( x+s, y+s )
		surface.DrawText( "WRONGED...:" )
		
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( x, y )
		surface.DrawText( "WRONGED...:" )
		
		if IsValid( i ) then
			x, y = off + cui( 8 ), off + cui( 10 )
			y = y + (num*off2)
			surface.SetFont( "WRONGED_3" )
			surface.SetTextColor( 0, 0, 0, 255 )
			surface.SetTextPos( x+s, y+s )
			surface.DrawText( i:Nick() )
			
			surface.SetTextColor( 255, 255, 255, 255 )
			surface.SetTextPos( x, y )
			surface.DrawText( i:Nick() )
		end
		
		x, y = off + cui( 8 ), off + cui( 13 )
		y = y + (num*off2)
		surface.SetFont( "WRONGED_1" )
		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos( x+s, y+s )
		surface.DrawText( "-" .. math.Round(v.dmg) )

		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( x, y )
		surface.DrawText( "-" .. math.Round(v.dmg) )
		
		local huuh = 0
		for k, p in SortedPairsByMemberValue( v.dmgtable, "time", true ) do
			surface.SetFont( "WRONGED_3" )
			local al = 255--math.TimeFraction( p.time+4, p.time, CurTime() )*255
			x, y = cui( 16 ), cui( 34 + huuh * 6 )
			y = y + (num*off2)
			local text = transl[k] .. " x " .. p.hit
			surface.SetTextColor( 0, 0, 0, al )
			surface.SetTextPos( x + s, y + s )
			surface.DrawText( text )

			surface.SetTextColor( 255, 255, 255, al )
			surface.SetTextPos( x, y )
			surface.DrawText( text )

			x = cui( 68 )
			text = "-- "..math.Round(p.dmg)
			surface.SetTextColor( 0, 0, 0, al )
			surface.SetTextPos( x + s, y + s )
			surface.DrawText( text )

			surface.SetTextColor( 255, 255, 255, al )
			surface.SetTextPos( x, y )
			surface.DrawText( text )
			huuh = huuh + 1
		end
		num = num + 1
	end
	
	local menus = {
		["options"]	= { text = "Options",	func = function(panel)
			panel:AddControl("header", { description = "Settings for WRONGED!." })
			
			panel:AddControl("checkbox", { label = "Enable", command = "wronged" })
			panel:ControlHelp( "Enable (on the client)" )
			panel:AddControl("slider", { type = "float", label = "Scale", command = "wronged_scale", min = 1, max = 5 })
			panel:ControlHelp( "Scale of the UI" )
			panel:AddControl("slider", { label = "Time", command = "wronged_time", min = 3, max = 10 })
			panel:ControlHelp( "How long the UI will stay up" )

			panel:AddControl("checkbox", { label = "Enable (Server)", command = "wronged_sv" })
			panel:ControlHelp( "Enable (on the server)" )
		end },
	}

	hook.Add("PopulateToolMenu", "WRONGED_Options", function()
		for menu, data in pairs(menus) do
			spawnmenu.AddToolMenuOption("Options", "WRONGED", "wronged_" .. menu, data.text, "", "", data.func)
		end
	end)

end)

else
	util.AddNetworkString( "WRONGED" )

	local cv_wronged_sv = CreateConVar( "wronged_sv", 1, FCVAR_ARCHIVE )

	hook.Add( "PostEntityTakeDamage", "WRONGED_PostEntityTakeDamage", function( target, dmginfo )
		local att = dmginfo:GetAttacker()
		if cv_wronged_sv:GetBool() and ( target:IsPlayer() and IsValid( att ) ) then
			net.Start("WRONGED")
				net.WriteEntity( target )
				net.WriteFloat( dmginfo:GetDamage() )
				net.WriteUInt( target:LastHitGroup(), 4 )
			net.Send( att )
		end
	end )

end