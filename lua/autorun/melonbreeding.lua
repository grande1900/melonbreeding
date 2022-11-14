Melon_DbgMesgs = CreateConVar( "melonbreeding_dbgmsgs",0,FCVAR_REPLICATED+FCVAR_PROTECTED,"Enable Debug Messages for Melon Breeding",0,1)
Melon_Heal = CreateConVar( "melonbreeding_heal",1,FCVAR_REPLICATED+FCVAR_PROTECTED,"Heals you when eating melons",0,1)
Melon_FFA = CreateConVar( "melonbreeding_ffa",1,FCVAR_REPLICATED+FCVAR_PROTECTED,"Allows other players to eat your melons",0,1)
Melon_Timescale = CreateConVar( "melonbreeding_timescale",1,FCVAR_REPLICATED+FCVAR_PROTECTED,"Timescale",0.004,60)
Melon_MaxMelons = CreateConVar( "melonbreeding_maxmelons",256,FCVAR_REPLICATED+FCVAR_PROTECTED,"Maximum amount of Breedable Melons, Set to 0 for no limit.",0,1024)
Melon_Colors = "111111222333111222333333111451451452633451452633633451745745745663441742663663841"
-- White Purple Yellow Red Magenta Orange Dark Blue
Melon_ColorCodes = {
	{r=255,g=255,b=255, a=255},
	{r=64,g=16,b=128, a=255},
	{r=255,g=255,b=16, a=255},
	{r=255,g=16,b=16, a=255},
	{r=255,g=128,b=192, a=255},
	{r=255,g=128,b=16, a=255},
	{r=16,g=16,b=16, a=255},
	{r=16,g=128,b=255, a=255}}
Melon_HealthCodes = {
	2,
	3,
	1,
	5,
	4,
	3,
	0,
	20
}
function melon_breeding_dbgmsg(s)
	if Melon_DbgMesgs:GetBool() then
		PrintMessage(HUD_PRINTTALK,s)
	end
end
if SERVER then
hook.Add("Think","melon_breeding_checkovermelons",function()
	local melons = ents.FindByClass("breedable_melon")
	if #melons > Melon_MaxMelons:GetInt() and Melon_MaxMelons:GetInt() > 0 then
		for i = Melon_MaxMelons:GetInt()+1, #melons do
			melons[i]:Remove()
		end
	end
end)
end