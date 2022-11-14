AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.AutomaticFrameAdvance = true
ENT.PrintName = "Breedable Melon"
ENT.Category = "Fun + Games"
ENT.Spawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Genome")
	self:NetworkVar("Entity",0,"MelonOwner")
	if SERVER then
		self:NetworkVarNotify("Genome", self.OnGenomeChanged )
	end
end
if SERVER then
	function ENT:OnGenomeChanged(name,old,new)
		self:SetMelonColor(new)
	end
end
function ENT:OnTakeDamage(info)
	self:Remove()
end
function ENT:Initialize()
	if CLIENT then return end
	self:SetModel("models/props_junk/watermelon01.mdl")
	self:SetMaterial("models/team_melon")
	self:RebuildPhysics()
	local chance = math.random(3)
	self:SetGenome((chance == 1 and 3) or (chance == 2 and 18) or (chance == 3 and 55))
end
function ENT:RebuildPhysics()

	-- This is necessary so that the vphysics.dll will not crash when attaching constraints to the new PhysObj after old one was destroyed
	-- TODO: Somehow figure out why it happens and/or move this code/fix to the constraint library
	self.ConstraintSystem = nil
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysWake()

end
function ENT:SpawnFunction(ply,tr,ClassName)
	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetMelonOwner(ply)
	ent:Spawn()
	return ent
end
function ENT:Use(a)
	if self:GetMelonOwner() == a or Melon_FFA:GetBool() then
		if Melon_Heal:GetBool() then
			a:SetHealth(a:Health()+Melon_HealthCodes[tonumber(Melon_Colors[self:GetGenome()+1])])
		end
		self:Remove()
	end
end

function ENT:Think()
	local mate
	if Melon_MaxMelons:GetInt() == #ents.FindByClass("breedable_melon") then return end
	for _, i in ipairs(ents.FindInSphere( self:GetPos(),20 )) do
		if i ~= self and i:GetClass() == "breedable_melon" then
			mate = i
			break
		end
	end
	if !IsValid(mate) then
		if math.random()<0.01 and SERVER then
			local clone = ents.Create("breedable_melon")
			clone:SetPos(self:GetPos()+(VectorRand():GetNormalized()*Vector(20,20,0)))
			clone:Spawn()
			clone:DropToFloor()
			clone:SetOwner(self:GetOwner())
			clone:SetGenome(self:GetGenome())
			melon_breeding_dbgmsg(self:GetTGenome().." Cloned")
			hook.Run("melon_breeding_melon_cloned",{},self,clone)
		end
	elseif math.random()<0.05 then
		self:Breed(mate)
	end
	
	self:NextThink( CurTime() + 2/Melon_Timescale:GetFloat() )
	return true
end

function ENT:Breed(mate)
	--[[
	00 = 100% 0
	01 = 50% 1,0
	02 = 100% 1
	11 = 25% 2,0; 50% 1
	12 = 50% 1,2
	22 = 100% 2
	]]
	if IsValid(mate) then
		local Genes = ""
		for i = 1,4 do
			local MG = mate:GetTGenome()[i]
			local SG = self:GetTGenome()[i]
			if SG=="0" and MG=="0" then
				Genes = Genes.."0"
			elseif (SG=="0" and MG=="1") or (SG=="1" and MG=="0") then
				Genes = Genes..math.random(0,1)
			elseif (SG=="0" and MG=="2") or (SG=="2" and MG=="0") then
				Genes = Genes.."1"
			elseif SG=="1" and MG=="1" then
				local chance = math.random(4)
				Genes = Genes..(chance==1 and "0" or chance==2 and "2" or "1")
			elseif (SG=="1" and MG=="2") or (SG=="2" and MG=="1") then
				Genes = Genes..math.random(1,2)
			elseif SG=="2" and MG=="2" then
				Genes = Genes.."2"
			end
		end
		local GNum = 0
		for i = 0,3 do
			GNum = GNum + (Genes[4-i] * 3^i)
		end
		if SERVER then
			local child = ents.Create("breedable_melon")
			child:SetPos(self:GetPos()+(VectorRand():GetNormalized()*Vector(150,150,0))+Vector(0,0,50))
			child:Spawn()
			child:DropToFloor()
			child:SetOwner(self:GetOwner())
			child:SetGenome(GNum)
			melon_breeding_dbgmsg(Genes.." from "..mate:GetTGenome().." & "..self:GetTGenome())
			hook.Run("melon_breeding_melon_bred",{},self,mate,child)
		end
	end
end
function ENT:GetTGenome()
	local G1 = math.floor(self:GetGenome()/27)%3
	local G2 = math.floor(self:GetGenome()/9)%3
	local G3 = math.floor(self:GetGenome()/3)%3
	local G4 = self:GetGenome()%3
	return G1..G2..G3..G4
end
function ENT:SetMelonColor(gene)
	local c = tonumber(Melon_Colors[gene+1])
	self:SetColor(Melon_ColorCodes[c])
end