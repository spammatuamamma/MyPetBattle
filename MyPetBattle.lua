-----------------
-- MyPetBattle --
-----------------
MyPetBattle = {}
---------------
---- SETUP ----
---------------
	-- Set SavedVariables to default values if they do not exist

		-- TEAM SETUP
--		if (not MPB_CONFIG_TEAMSETUP_RANDOM_TEAM_PET_HEALTH_THRESHOLD) then
--			MPB_CONFIG_TEAMSETUP_RANDOM_TEAM_PET_HEALTH_THRESHOLD = 0.60
--		end
--		
--		if (not MPB_CONFIG_TEAMSETUP_PET1_LEVEL_ADJUSTMENT) then
--			MPB_CONFIG_TEAMSETUP_PET1_LEVEL_ADJUSTMENT = -2
--		end
--		
--		if (not MPB_CONFIG_TEAMSETUP_PET2_LEVEL_ADJUSTMENT) then
--			MPB_CONFIG_TEAMSETUP_PET2_LEVEL_ADJUSTMENT = -2
--		end
--		
--		if (not MPB_CONFIG_TEAMSETUP_PET3_LEVEL_ADJUSTMENT) then
--			MPB_CONFIG_TEAMSETUP_PET3_LEVEL_ADJUSTMENT = 2
--		end
--		
--		-- PRE-COMBAT
--		if (not MPB_CONFIG_PRE_COMBAT_ATTEMPT_STRONGEST_RANDOM_TEAM) then
--			MPB_CONFIG_PRE_COMBAT_ATTEMPT_STRONGEST_RANDOM_TEAM = false
--		end
--		
--		-- COMBAT
--		if (not MPB_CONFIG_COMBAT_SWAP_PET_HEALTH_THRESHOLD) then
--			MPB_CONFIG_COMBAT_SWAP_PET_HEALTH_THRESHOLD = 0.35
--		end
--		
--		-- POST-COMBAT
--		if (not MPB_CONFIG_POST_COMBAT_USE_REVIVE_BATTLE_PETS_AFTER_COMBAT) then
--			MPB_CONFIG_POST_COMBAT_USE_REVIVE_BATTLE_PETS_AFTER_COMBAT = true
--		end
--
--		if (not MPB_CONFIG_POST_COMBAT_USE_BATTLE_PET_BANDAGE_AFTER_COMBAT) then
--			MPB_CONFIG_POST_COMBAT_USE_BATTLE_PET_BANDAGE_AFTER_COMBAT = false
--		end
--
--		if (not MPB_CONFIG_POST_COMBAT_AUTOMATIC_NEW_RANDOM_TEAM_AFTER_COMBAT) then
--			MPB_CONFIG_POST_COMBAT_AUTOMATIC_NEW_RANDOM_TEAM_AFTER_COMBAT = true
--		end
--
--		-- MISC
--		if (not MPB_CONFIG_MISC_AUTOMATIC_RELEASE_NON_RARES) then
--			MPB_CONFIG_MISC_AUTOMATIC_RELEASE_NON_RARES = false
--		end		


-- INITIALIZATION -
mypetbattle_enabled = false
mypetbattle_join_pvp = false
mypetbattle_capture_rares = false
mypetbattle_capture_common_uncommon = false
mypetbattle_auto_forfeit = false
mypetbattle_wintrade_enabled = false

-- Variable used to make sure we only call the heal function 1 time after combat.
-- It will be set to "false" on events:PET_BATTLE_OPENING_DONE
-- and set back to "true" on events:UPDATE_SUMMONPETS_ACTION
mypetbattle_hasHealedAfterCombat = true

RegisterAddonMessagePrefix("MPB")

--------------------
---- SETUP DONE ----
--------------------

name, speciesName = C_PetBattles.GetName(LE_BATTLE_PET_ALLY, currentPetID)

---------------------
-- EVENTS HANDLING --
---------------------
local mypetbattle_frame, events = CreateFrame("Frame"), {};


--------------------------------------------------------
-- LOAD A LOT OF STUFF WHEN THE ADDON HAS BEEN LOADED --
function events:ADDON_LOADED(...)
--	print("ADDON_LOADED")
	local addonName = ...
--	if addonName == "MyPetBattle" then
--		print("Loaded |cffff8000MPB")
--	end

	-- Set UI elements to SavedVariables
	-- TEAM SETUP
	EditBox_min_team_pet_health:SetText(tostring(MPB_CONFIG_TEAMSETUP_RANDOM_TEAM_PET_HEALTH_THRESHOLD * 100)) 
	Slider_pet1_level:SetValue(MPB_CONFIG_TEAMSETUP_PET1_LEVEL_ADJUSTMENT)
	Slider_pet2_level:SetValue(MPB_CONFIG_TEAMSETUP_PET2_LEVEL_ADJUSTMENT)
	Slider_pet3_level:SetValue(MPB_CONFIG_TEAMSETUP_PET3_LEVEL_ADJUSTMENT)
	
	-- PRE-COMBAT
	CheckButton15:SetChecked(MPB_CONFIG_PRE_COMBAT_ATTEMPT_STRONGEST_RANDOM_TEAM)
	-- COMBAT
	EditBox_swap_pet_health_threshold:SetText(tostring(MPB_CONFIG_COMBAT_SWAP_PET_HEALTH_THRESHOLD * 100)) 

	-- POST-COMBAT
	CheckButton12:SetChecked(MPB_CONFIG_POST_COMBAT_USE_REVIVE_BATTLE_PETS_AFTER_COMBAT)
	CheckButton14:SetChecked(MPB_CONFIG_POST_COMBAT_USE_BATTLE_PET_BANDAGE_AFTER_COMBAT)
	CheckButton11:SetChecked(MPB_CONFIG_POST_COMBAT_AUTOMATIC_NEW_RANDOM_TEAM_AFTER_COMBAT)

	-- MISC	
	CheckButton13:SetChecked(MPB_CONFIG_MISC_AUTOMATIC_RELEASE_NON_RARES)

	-- LOAD LAST USED DESIRED_PET_LEVEL FOR THE RANDOM TEAM GENERATION
	local loadLastUsedDesiredPetLevel = MPB_EDITBOX_DESIRED_PET_LEVEL
	EditBox_PetLevel:SetText(loadLastUsedDesiredPetLevel) 
--	EditBox_PetLevel:SetText("25") 
	
	-- LOCK PETS FOR RANDOM TEAM GENERATION
	Check_lock_pet_1:SetChecked(MPB_LOCK_PET1)
	Check_lock_pet_2:SetChecked(MPB_LOCK_PET2)
	Check_lock_pet_3:SetChecked(MPB_LOCK_PET3)

	-- Set texture for Config Button (gear) manually as the XML file do not want do what I want!
	MPB_Config_Button:SetNormalTexture("Interface\\Addons\\MyPetBattle\\Images\\icon-config")
	MPB_Config_Button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")

	-- Call function in Frame.lua to update the position of the minimap button
	MPB_MMButton_UpdatePosition()

	-- Show/hide ui at login according to character specific savedvariable
	if MPB_SHOW_UI == nil then MPB_SHOW_UI = true end -- Set variable to true the first time
	SlashCmdList.MYPETBATTLE('ui') -- Call slash command to show/hide ui
end

function events:PLAYER_LOGIN(...)				-- 
--	print("PLAYER_LOGIN")
	print("\124cFFFF9933My Pet Battle ready for action")
	-- Set default text of textfield "PetLevel" for random team generation
end

function events:PLAYER_ENTERING_WORLD(...)				-- 
--	print("PLAYER_ENTERING_WORLD")
end

function events:PET_BATTLE_ABILITY_CHANGED(...)				-- 
--	print("PET_BATTLE_ABILITY_CHANGED")
end
function events:PET_BATTLE_ACTION_SELECTED(...)				-- Player selected a pet action
--	print("PET_BATTLE_ACTION_SELECTED")
end
function events:PET_BATTLE_AURA_APPLIED(...)				-- Aura applied e.g. Adrenaline for 3 turn (3 stacks)
--	print("PET_BATTLE_AURA_APPLIED")
end
function events:PET_BATTLE_AURA_CANCELED(...)				-- 
--	print("PET_BATTLE_AURA_CANCELED")
end
function events:PET_BATTLE_AURA_CHANGED(...)				-- Aura changed e.g. Adrenaline changed to 2 stacks
--	print("PET_BATTLE_AURA_CHANGED")
end
function events:PET_BATTLE_CAPTURED(...)					-- 
--	print("PET_BATTLE_CAPTURED")
end
function events:PET_BATTLE_CLOSE(...)						-- 
--	print("PET_BATTLE_CLOSE")
	-- Close the Stopwatch window after battle
	if ( StopwatchFrame:IsShown() ) then
		StopwatchFrame:Hide();
	end
	
	-- Resetting variable opening is done
	petBattleOpeningIsDone = false
end

function events:PET_BATTLE_FINAL_ROUND(...)					-- 
--	print("PET_BATTLE_FINAL_ROUND")
end

function events:PET_BATTLE_HEALTH_CHANGED(...)				-- 
	-- petOwner, petIndex, healthChange
--	local myOutput1, myOutput2, myOutput3 = ...;
--	print("OUTPUT: " .. myOutput1 .. ", " .. myOutput2 .. ", " .. myOutput3)

--	print("PET_BATTLE_HEALTH_CHANGED")
	local petOwner, petIndex, healthChange = ...;
	local pet_name, pet_speciesName = C_PetBattles.GetName(petOwner, petIndex)
	local pet_icon = C_PetBattles.GetIcon(petOwner, petIndex)
	local pet_currentHealth = C_PetBattles.GetHealth(petOwner, petIndex)
	local pet_maxHealth = C_PetBattles.GetMaxHealth(petOwner, petIndex)
	local pet_healthPercentage = pet_currentHealth / pet_maxHealth * 100
	
	local textColor
	if pet_healthPercentage < 30 then
		textColor = "\124cFFFF0000" -- red
	elseif pet_healthPercentage < 75 then
		textColor = "\124cFFFFFF00" -- yellow
	elseif pet_healthPercentage <= 100 then
		textColor = "\124cFF00FF00" -- green
	end
	
	local textPetOwner
	if petOwner == 1 then
		textPetOwner = "Player: "
	else
		textPetOwner = "Enemy: "
	end
    if mypetbattle_debug then	
	    if healthChange > 0 then 
    --		print("gained " .. healthChange .. " health") 
		    print(textPetOwner.."\124T"..pet_icon..":0\124t |cFF0066FF[" .. pet_name .. "]|r gained \124cFF00FF00" .. healthChange .. "\124r health. Current health: " .. textColor .. pet_currentHealth .. "/" .. pet_maxHealth .. string.format(" (%2.0f%%)", pet_healthPercentage)) 
	    elseif healthChange < 0 then
    --		print("lost " .. abs(healthChange) .. " health") 
		    print(textPetOwner.."\124T"..pet_icon..":0\124t |cFF0066FF[" .. pet_name .. "]|r lost \124cFFFF0000" .. abs(healthChange) .. "\124r health. Current health: " .. textColor .. pet_currentHealth .. "/" .. pet_maxHealth .. string.format(" (%2.0f%%)", pet_healthPercentage)) 
	    end
    end
	
--	print(textPetOwner.."\124T"..pet_icon..":0\124t |cFF0066FF[" .. pet_name .. "]|r current health: " .. textColor .. pet_currentHealth .. "/" .. pet_maxHealth .. string.format(" (%2.0f%%)", pet_healthPercentage) .. " point") 

--	print("Pet number "..petIndex .. " health is: " .. C_PetBattles.GetHealth(petOwner, petIndex))

	currentPetID = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY)
	currentPet_Health = C_PetBattles.GetHealth(LE_BATTLE_PET_ALLY, currentPetID)
	currentPet_MAX_Health = C_PetBattles.GetMaxHealth(LE_BATTLE_PET_ALLY, currentPetID)
	currentPet_Health_percentage = currentPet_Health / currentPet_MAX_Health * 100
	
--	currentPetID = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY)
--	currentPet_Health = C_PetBattles.GetHealth(LE_BATTLE_PET_ALLY, currentPetID)
--	currentPet_MAX_Health = C_PetBattles.GetMaxHealth(LE_BATTLE_PET_ALLY, currentPetID)
--	currentPet_Health_percentage = currentPet_Health / currentPet_MAX_Health * 100
	
	
--	print("|cff00ff00 Current pets health: " .. currentPet_Health .. "/" .. currentPet_MAX_Health .. string.format(" (%2.0f%%)", currentPet_Health_percentage) .. " points")
end

function events:PET_BATTLE_LEVEL_CHANGED(...)				-- 
--	print("PET_BATTLE_LEVEL_CHANGED")
	local petOwner, petIndex = ...;
	local pet_name, pet_speciesName = C_PetBattles.GetName(petOwner, petIndex)
	local pet_icon = C_PetBattles.GetIcon(petOwner, petIndex)
	local pet_level = C_PetBattles.GetLevel(petOwner, petIndex)
	print("|cFF0066FF\124T"..pet_icon..":16\124t [" .. pet_name .. "]\124r is now level: " .. pet_level .."!") 

	--	print("|cffffff00 Your pet is now level: " .. C_PetBattles.GetLevel(LE_BATTLE_PET_ALLY,1) .. "!")	
end

function events:PET_BATTLE_LOOT_RECEIVED(...)				-- 
--	print("PET_BATTLE_LOOT_RECEIVED")

	local typeIdentifier, itemLink, quantity = ...;
	print("\124cFF00FF00Item won:\124r " .. quantity .. " x " .. itemLink)

	--if ( typeIdentifier == "item" ) then
	--	LootWonAlertFrame_ShowAlert(itemLink, quantity);
	--elseif ( typeIdentifier == "money" ) then
	--	MoneyWonAlertFrame_ShowAlert(quantity);
	--end

end

function events:PET_BATTLE_MAX_HEALTH_CHANGED(...)			-- 
--	print("PET_BATTLE_MAX_HEALTH_CHANGED")
end

function events:PET_BATTLE_OPENING_DONE(...)				-- Opening done and ready to battle
	-- Stopwatch for WT
	if mypetbattle_wintrade_enabled then
		if Stopwatch_IsPlaying() then Stopwatch_Clear() end
		Stopwatch_StartCountdown(0, 0, 60) -- Set Stop Watch to count down from 60 sec
		Stopwatch_Play() -- Starts the Stop Watch
		if mypetbattle_debug then  print("Started Stopwatch") end
	end
		
	--	print("PET_BATTLE_OPENING_DONE")
	print("We have to fight " .. C_PetBattles.GetNumPets(LE_BATTLE_PET_ENEMY) .. " enemy pets")
	-- Auto-select first available pet
	if C_PetBattles.ShouldShowPetSelect() == true and (mypetbattle_enabled or mypetbattle_wintrade_enabled) then
		for i=1,3 do
			if MyPetBattle.hp(i) > 0 then
				C_PetBattles.ChangePet(i)
			end
		end
	end

	-- Setting global variable to false so we will heal after combat if needed
	mypetbattle_hasHealedAfterCombat = false
	
	-- Setting variable that opening is done
	petBattleOpeningIsDone = true
	MPB_timerTotal = 0		-- Reset timer for automatic forfeit
end

function events:PET_BATTLE_OPENING_START(...)				-- 
--	print("PET_BATTLE_OPENING_START")
	print("|cFF00FFFF Game Starting!")

	-- Get pets level
	pet1_level_start = C_PetBattles.GetLevel(LE_BATTLE_PET_ALLY,1)
	pet2_level_start = C_PetBattles.GetLevel(LE_BATTLE_PET_ALLY,2)
	pet3_level_start = C_PetBattles.GetLevel(LE_BATTLE_PET_ALLY,3)

	-- Get pets current xp
	pet1_xp_start, pet1_maxXp_start = C_PetBattles.GetXP(1, 1)
	pet2_xp_start, pet2_maxXp_start = C_PetBattles.GetXP(1, 2)
	pet3_xp_start, pet3_maxXp_start = C_PetBattles.GetXP(1, 3)
	
end

function events:PET_BATTLE_OVER(...)						-- Pet battle over (someone won)
--	print("PET_BATTLE_OVER")
	
	-- Get pet names
	pet1_name, pet1_speciesName = C_PetBattles.GetName(1, 1)
	pet2_name, pet2_speciesName = C_PetBattles.GetName(1, 2)
	pet3_name, pet3_speciesName = C_PetBattles.GetName(1, 3)

	-- Get pet icons
	pet1_icon = C_PetBattles.GetIcon(1, 1)
	pet2_icon = C_PetBattles.GetIcon(1, 2)
	pet3_icon = C_PetBattles.GetIcon(1, 3)

	-- Get xp after combat has ended
	pet1_xp_end, pet1_maxXp_end = C_PetBattles.GetXP(1, 1)
	pet2_xp_end, pet2_maxXp_end = C_PetBattles.GetXP(1, 2)
	pet3_xp_end, pet3_maxXp_end = C_PetBattles.GetXP(1, 3)
	
	-- Calculate xp gain
	pet1_xp_gained = pet1_xp_end - pet1_xp_start
	pet2_xp_gained = pet2_xp_end - pet2_xp_start
	pet3_xp_gained = pet3_xp_end - pet3_xp_start

	-- Print xp change
	if pet1_xp_gained > 0 then print("|cFF0066FF\124T"..pet1_icon..":0\124t [" .. pet1_name .. "] |cFFFFFFFFgained " .. pet1_xp_gained .. " xp") end
	if pet2_xp_gained > 0 then print("|cFF0066FF\124T"..pet2_icon..":0\124t [" .. pet2_name .. "] |cFFFFFFFFgained " .. pet2_xp_gained .. " xp") end
	if pet3_xp_gained > 0 then print("|cFF0066FF\124T"..pet3_icon..":0\124t [" .. pet3_name .. "] |cFFFFFFFFgained " .. pet3_xp_gained .. " xp") end
	
	print("|cFF00FFFF Game Over!")
end

function events:UPDATE_SUMMONPETS_ACTION(...)					-- 
--	print("UPDATE_SUMMONPETS_ACTION")

	-- Set new team after combat if MPB_CONFIG_POST_COMBAT_AUTOMATIC_NEW_RANDOM_TEAM_AFTER_COMBAT is true
	if MPB_CONFIG_POST_COMBAT_AUTOMATIC_NEW_RANDOM_TEAM_AFTER_COMBAT then
		local desiredPetLevel = EditBox_PetLevel:GetText()  -- Get user input for desired pet level
		MyPetBattle.setTeam(desiredPetLevel)                -- Setup our team
		-- Save desired pet level for next time we log in
		MPB_EDITBOX_DESIRED_PET_LEVEL = desiredPetLevel
		-- Clear focus from the editbox
		EditBox_PetLevel:ClearFocus()
	end

	-- Setting global variable to false so we will heal after combat if needed
	if mypetbattle_hasHealedAfterCombat == false then
		MyPetBattle.revive_and_heal_Pets() -- function in MyPetBattle_data.lua
		mypetbattle_hasHealedAfterCombat = true
	end
end

function events:COMPANION_UPDATE(...)					-- 
--	print("COMPANION_UPDATE")
end

function events:PET_JOURNAL_LIST_UPDATE(...)
--	print(PET_JOURNAL_LIST_UPDATE)
end

function events:PET_BATTLE_PET_CHANGED(...)					-- 
--	print("PET_BATTLE_PET_CHANGED")
end

function events:PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE(...)	-- 
--	print("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE")
	local round = ...
--	print(round)
	
	-- Auto-select first available pet
	if C_PetBattles.ShouldShowPetSelect() == true and (mypetbattle_enabled or mypetbattle_wintrade_enabled) then
		for i=1,3 do
			if MyPetBattle.hp(i) > 0 then
				C_PetBattles.ChangePet(i)
			end
		end
	end

	-- Skip turn if polymorphed, stunned etc. by enemy (maybe change pet if low on health)
	if MyPetBattle.buff("Polymorphed") or MyPetBattle.buff("Asleep") or MyPetBattle.buff("Crystal Prison") or MyPetBattle.buff("Stunned") or MyPetBattle.buff("Drowsy") then 
		C_PetBattles.SkipTurn()
	end

	-- Check if we should and can capture rare pets we are fighting
	-- The function canCaptureRare() in MyPetBattle_data.lua will check if we can capture the rare we are fighting
	if mypetbattle_capture_rares and MyPetBattle.canCaptureRare() and mypetbattle_enabled then
		print("|cFF8A2BE2 We are trying to capture a rare!")
		C_PetBattles.UseTrap() -- Use the trap
	end

	-- Check if we should capture common/uncommon if we do not own the pet
	if mypetbattle_capture_common_uncommon and MyPetBattle.canCaptureCommon() and mypetbattle_enabled then
		print("|cFF00FF00 We do not have this pet (0/3), let us capture it (common/uncommon)!")
		C_PetBattles.UseTrap() -- Use the trap
	end

	local spell = nil
	local petOwner = LE_BATTLE_PET_ALLY
	local petIndex = C_PetBattles.GetActivePet(petOwner)
	local petType = C_PetBattles.GetPetType(petOwner, petIndex)

	if petType == 1 then 		-- HUMANOID
		spell = humanoid()		
	elseif petType == 2 then 	-- DRAGONKIN
		spell = dragonkin()
	elseif petType == 3 then 	-- FLYING
		spell = flying()
	elseif petType == 4 then 	-- UNDEAD
		spell = undead()
	elseif petType == 5 then 	-- CRITTER
		spell = critter()
	elseif petType == 6 then 	-- MAGIC
		spell = magic()
	elseif petType == 7 then 	-- ELEMENTAL
		spell = elemental()
	elseif petType == 8 then 	-- BEAST
		spell = beast()
	elseif petType == 9 then 	-- WATER / AQUATIC
		spell = aquatic()
	elseif petType == 10 then 	-- MECHANICAL
		spell = mechanical()
	end

	if mypetbattle_enabled or (mypetbattle_wintrade_enabled and round <= math.random(1,3)) then -- Attack a random number of times between 2-4 if we are doing wt (1 and 3 since round 0 exists)
		-- Switch pet at health threshold before it dies. CAN BE SET FROM CONFIG MENU
		if MyPetBattle.hp(petIndex) < MPB_CONFIG_COMBAT_SWAP_PET_HEALTH_THRESHOLD then
			for j=1,3 do
				if MyPetBattle.hp(j) >= MPB_CONFIG_COMBAT_SWAP_PET_HEALTH_THRESHOLD then
					C_PetBattles.ChangePet(j)
					print("|cFFFF3300.. Changing pet due to low health! ..")
				end
			end
		end	

		-- If we have spell we can cast, then cast!
		if spell ~= nil then	
			actionIndex = MyPetBattle.getSpellSlotIndex(spell)
			print("|cffFF4500 Casting: ", spell)
--			print("actionIndex: ", actionIndex)
			C_PetBattles.UseAbility(actionIndex)	-- Use pet ability 
		end
    elseif mypetbattle_debug then
        -- if we're not enabled but in debug mode then show what we would have cast
		print("|cffFF4500 Would be Casting: ", spell)

	end
end

function events:PET_BATTLE_PET_ROUND_RESULTS(...)			-- 
--	print("PET_BATTLE_PET_ROUND_RESULTS")
	local roundNumber = ...
	if roundNumber ~= 0 and mypetbattle_debug then
		print("Round "..roundNumber)
	end
end

function events:PET_BATTLE_PVP_DUEL_REQUESTED(...)			-- 
	print("PET_BATTLE_PVP_DUEL_REQUESTED")
end

function events:PET_BATTLE_PVP_DUEL_REQUEST_CANCEL(...)		-- 
	print("PET_BATTLE_PVP_DUEL_REQUEST_CANCEL")
end

function events:PET_BATTLE_QUEUE_PROPOSAL_ACCEPTED(...)		-- 
--	print("PET_BATTLE_QUEUE_PROPOSAL_ACCEPTED")
	if mypetbattle_debug then  print("Pet Battle PvP queue accepted") end
end

function events:PET_BATTLE_QUEUE_PROPOSAL_DECLINED(...)		-- 
--	print("PET_BATTLE_QUEUE_PROPOSAL_DECLINED")
	print("Removed from pet battle PvP queue")
end

function events:PET_BATTLE_QUEUE_PROPOSE_MATCH(...)			-- 
--	print("PET_BATTLE_QUEUE_PROPOSE_MATCH")

	-- Sync setup for wt
	local MPB_SyncTimeSent = GetTime()
	SendAddonMessage("MPB", MPB_SyncTimeSent, "PARTY")
	
	if MPB_SyncTimeReceived == nil then MPB_SyncTimeReceived = 0 end
	if MPB_SyncTimeReceived > 0 then
		local delay = abs(MPB_SyncTimeSent - MPB_SyncTimeReceived)
		print("Current delay: "..delay)
	end
	
	-- Automatic accept PvP queue popup if enabled	
	if mypetbattle_join_pvp then
		if mypetbattle_debug then  print("Auto-accepting pet PvP match!") end
		C_PetBattles.AcceptQueuedPVPMatch()
	end
end

function events:PET_BATTLE_QUEUE_STATUS(...)				-- 
--	print("PET_BATTLE_QUEUE_STATUS")
end

function events:PET_BATTLE_TURN_STARTED(...)				-- 
	print("PET_BATTLE_TURN_STARTED")
end

function events:PET_BATTLE_XP_CHANGED(...)					-- 
--	print("PET_BATTLE_XP_CHANGED")
end

function events:CHAT_MSG_ADDON(...)							-- 
--	print("PET_BATTLE_XP_CHANGED")
	local prefix, message, channel, sender = ...

	-- Check if message comes from MPB addon
	if prefix == "MPB" and channel == "PARTY" and sender ~= UnitName("player") then
--		print(prefix .. ". We received: " .. message)
--		print("Local time: "..GetTime())
				
		local syncThreshold = 1
		local queueState, estimatedTime, queuedTime = C_PetBattles.GetPVPMatchmakingInfo() -- Get PvP queue info
		-- Check that we are ready to accept when receiving the message from our partner
		if queueState == "proposal" and tonumber(message) > 0 then
--			local my_message = abs(tonumber(queuedTime)-tonumber(message))
			local my_message = abs(GetTime()-tonumber(message))
			print(prefix .. " sync: " .. my_message)
			-- If sync time is less than 'syncThreshold' then accept battle
			if my_message < syncThreshold then
				print("Sync is ok, accepting battle")
				C_PetBattles.AcceptQueuedPVPMatch()
			else
				print("Not in sync, declining battle")
				C_PetBattles.DeclineQueuedPVPMatch()
			end
		else
			MPB_SyncTimeReceived = tonumber(message)
		end

	end
end

mypetbattle_frame:SetScript("OnEvent", function(self, event, ...)
 events[event](self, ...); -- call one of the functions above
end);

-- Register all events for which handlers have been defined
for k, v in pairs(events) do
 mypetbattle_frame:RegisterEvent(k); 
end

--------------------
--- Timer frame ----
--------------------
MPB_timerTotal = 0 -- Timer init for automatic forfeit
MPB_timerOneSec = 0 -- 1 sec timer init for different mechanics e.g. auto re-queue PvP
MPB_petguids = {0,0,0}

local function MPB_onUpdate(self,elapsed)
	-- Automatic forfeit timer
	if petBattleOpeningIsDone then
	    MPB_timerTotal = MPB_timerTotal + elapsed
		if MPB_timerTotal >= 55 then -- 55
			if mypetbattle_debug then  print("60 sec. almost up!") end
			MPB_timerTotal = 0
			petBattleOpeningIsDone = false
    	    -- Forfeit
    	    if mypetbattle_auto_forfeit then
    	    	if mypetbattle_debug then  print("Forfeiting!") end
	    	    C_PetBattles.ForfeitGame()
	    	end
	    end
	else
		MPB_timerTotal = 0
    end

	-- 1 sec timer check
	MPB_timerOneSec = MPB_timerOneSec + elapsed
	if MPB_timerOneSec >= 1 then
		-- Check if we should be in the PvP matchmaking queue, but we are not
		if not C_PetBattles.IsInBattle() and (C_PetBattles.GetPVPMatchmakingInfo() == nil) and mypetbattle_join_pvp then
			C_PetBattles.StartPVPMatchmaking()
		end
		-- Dismiss pet so we do not have it running around
        local petGUID = C_PetJournal.GetSummonedPetGUID()
        if petGUID and petGUID == C_PetJournal.GetPetLoadOutInfo(1) then -- Check if we have a pet summoned already, or we will get an error
            C_PetJournal.SummonPetByGUID(petGUID) -- Dismiss pet
        end
		-- Set UI textures for current pet team when the UI is loaded -- IS NOT NEEDED ANYMORE SINCE setTeam() IS CALLED ABOVE, AND THAT FUNCTION SETS THE TEXTURES
		-- MIGHT BE NEEDED ANYWAY, IF AUTO NEW TEAM IS ACTIVE, THEN THE TEXTURE WILL NOT BE LOADED ON LOGIN
		-- Moved texture updates to the timer, because the events used before, we cannot be sure they are always called when we want to update
		for i_ = 1, 3 do
			local petGUID = C_PetJournal.GetPetLoadOutInfo(i_)
			if not petGUID then  break end -- Break the loop if there are no pets yet or we will get an error

			local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, obtainable = C_PetJournal.GetPetInfoByPetID(petGUID) 

			if MPB_petguids[i_] ~= petGUID then -- Check if we already have the pet, then no need to set the texture
				MPB_petguids[i_] = petGUID
				-- Set pet 1 UI texture
				if i_ == 1 then 
					Pet1_texture:SetTexture(icon) 
					Pet1_level_string:SetText(level)
				end
				-- Set pet 2 UI texture
				if i_ == 2 then 
					Pet2_texture:SetTexture(icon) 
					Pet2_level_string:SetText(level)
				end
				-- Set pet 3 UI texture
				if i_ == 3 then 
					Pet3_texture:SetTexture(icon) 
					Pet3_level_string:SetText(level)
				end
			end
		end
		-- Reset the timer
		MPB_timerOneSec = 0
	end

end
 
local f = CreateFrame("frame")
f:SetScript("OnUpdate", MPB_onUpdate)

--------------------
-- SLASH COMMANDS --
--------------------
SLASH_MYPETBATTLE1 = '/mypetbattle'
function SlashCmdList.MYPETBATTLE(msg, editbox)
	if msg == "" then
		mypetbattle_enabled = not mypetbattle_enabled
		if mypetbattle_enabled then status = "\124cFF00FF00Enabled" else status = "\124cFFFF0000Disabled" end
	    print("My pet battle:", status)
		CheckButton1:SetChecked(mypetbattle_enabled)
	elseif msg == "join_pvp" then
		mypetbattle_join_pvp = not mypetbattle_join_pvp
		if mypetbattle_join_pvp then 
			status = "\124cFF00FF00PvP enabled"
			-- if C_PetBattles.GetPVPMatchmakingInfo == nil then
				C_PetBattles.StartPVPMatchmaking()
			-- end
		else 
			status = "\124cFFFF0000PvP disabled"
			-- if C_PetBattles.GetPVPMatchmakingInfo ~= nil then
				C_PetBattles.StopPVPMatchmaking()
			-- end
		end
	    print("My pet battle:", status)
	elseif msg == "capture_rares" then
		mypetbattle_capture_rares = not mypetbattle_capture_rares
		if mypetbattle_capture_rares then status = "\124cFF00FF00Automatic capture rare pets enabled" else status = "\124cFFFF0000Automatic capture rare pets disabled" end
	    print("My pet battle:", status)
		CheckButton3:SetChecked(mypetbattle_capture_rares)
	elseif msg == "capture_common_uncommon" then
		mypetbattle_capture_common_uncommon = not mypetbattle_capture_common_uncommon
		if mypetbattle_capture_common_uncommon then status = "\124cFF00FF00Automatic capture common/uncommon (0/3 owned) pets enabled" else status = "\124cFFFF0000Automatic capture common/uncommon pets (0/3 owned) disabled" end
	    print("My pet battle:", status)
	elseif msg == "auto_forfeit" then
		mypetbattle_auto_forfeit = not mypetbattle_auto_forfeit
		if mypetbattle_auto_forfeit then status = "\124cFF00FF00Automatic forfeit after 60 sec enabled" else status = "\124cFFFF0000Automatic forfeit after 60 sec disabled" end
	    print("My pet battle:", status)
	elseif msg == "wintrade_enable" then
		mypetbattle_wintrade_enabled = not mypetbattle_wintrade_enabled
		if mypetbattle_wintrade_enabled then status = "\124cFF00FF00Automatic wintrade enabled" else status = "\124cFFFF0000Automatic wintrade disabled" end
	    print("My pet battle:", status)
	elseif msg == "debug" then
        -- turn off debug messages as required
        mypetbattle_debug =  not mypetbattle_debug
		if mypetbattle_debug then status = "\124cFF00FF00Enabled" else status = "\124cFFFF0000Disabled" end
        print("Debugging:",status)
    elseif msg == "ui" then
		-- Show/hide ui
		MPB_SHOW_UI = not MPB_SHOW_UI
		if MPB_SHOW_UI then MyPetBattleForm:Show() else MyPetBattleForm:Hide() end
    end
end
