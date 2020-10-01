--================================================================================================--
--==                                VARIABLES - DO NOT EDIT                                     ==--
--================================================================================================--

ESX                         = nil
inMenu                      = true
local atbank = false
local bankMenu = true

--================================================================================================--
--==                                  Keys & Animation & Other Functions                        ==--
--================================================================================================--

local keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

function playAnim(animDict, animName, duration)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
	TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
	RemoveAnimDict(animDict)
end

--===============================================
--==           Base ESX Threading              ==
--===============================================

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--===============================================
--==             Core Threading                ==
--===============================================

RegisterCommand('atm', function()
	if bankMenu then
		   Wait(0)
			if nearATM() then
				openUI()
				TriggerServerEvent('bank:balance')
			end
		end
		if IsControlJustPressed(1, keys[Config.Keys.Close]) then
			if nearATM() then
				closeUI()
		end	
	end
end)

TriggerEvent('chat:addSuggestion', '/atm', 'You can access atm\'s while using this command.')

if bankMenu then
	Citizen.CreateThread(function()
		while true do
			Wait(0)
			if nearBank() then
				if IsControlJustPressed(1, keys[Config.Keys.Open]) then
					openUI()
					TriggerServerEvent('bank:balance')
					local ped = PlayerPedId()
				end
			end
			if IsControlJustPressed(1, keys[Config.Keys.Close]) then
				if nearBank() then
					closeUI()
				end
			end
		end
	end)
end

--===============================================
--==             Map Blips	                 --== 
--===============================================

function CreateBank(coords)
	local blip = AddBlipForCoord(coords)
	SetBlipSprite(blip, 108)
	SetBlipScale(blip, 0.6)
	SetBlipColour(blip, 2)
	SetBlipDisplay(blip, 2)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Banka")
	EndTextCommandSetBlipName(blip)
	return blip
end

--===============================================
--==            Blip Functions	             --==
--===============================================

if Config.ShowNearestBanks then
	Citizen.CreateThread(function()
		local currentBankBlip = 0

		while true do
			local coords = GetEntityCoords(PlayerPedId())
			local closest = 1000
			local closestCoords

			for _, bankCoords in pairs(Config.Bank) do
				local dstcheck = GetDistanceBetweenCoords(coords, bankCoords)

				if dstcheck < closest then
					closest = dstcheck
					closestCoords = bankCoords
				end
			end

			if DoesBlipExist(currentBankBlip) then
				RemoveBlip(currentBankBlip)
			end

			currentBankBlip = CreateBank(closestCoords)
			Citizen.Wait(10000)
		end
   end)
end

--===============================================
--==           DrawText3D                    --==
--===============================================

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local factor = (string.len(text)) / 370
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
	AddTextComponentString(text)
	DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
    DrawText(_x,_y)
end

--===============================================
--==           Deposit Event                 --==
--===============================================

RegisterNetEvent('currentbalance1')
AddEventHandler('currentbalance1', function(balance)
	local id = PlayerId()

	ESX.TriggerServerCallback('bank:getname', function(name, lastname)

	SendNUIMessage({
		type = "balanceHUD",
		balance = balance,
		player = name .. " " .. lastname
		})
	end)
end)

--===============================================
--==           Deposit Event                 --==
--===============================================

RegisterNUICallback('deposit', function(data)
	TriggerServerEvent('bank:deposit', tonumber(data.amount))
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==          Withdraw Event                 --==
--===============================================

RegisterNUICallback('withdrawl', function(data)
	TriggerServerEvent('bank:withdraw', tonumber(data.amountw))
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==          Quick Events                   --==
--===============================================

RegisterNUICallback('quickCash', function()
	TriggerServerEvent('bank:fastw')
	TriggerServerEvent('bank:balance')
end)

RegisterNUICallback('cash', function()
	TriggerServerEvent('bank:fastwt')
	TriggerServerEvent('bank:balance')
end)

RegisterNUICallback('depfast', function()
	TriggerServerEvent('bank:fastdep')
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==         Balance Event                   --==
--===============================================

RegisterNUICallback('balance', function()
	TriggerServerEvent('bank:balance')
end)

RegisterNetEvent('balance:back')
AddEventHandler('balance:back', function(balance)
	SendNUIMessage({type = 'balanceReturn', bal = balance})
end)

--===============================================
--==         Transfer Event                  --==
--===============================================

RegisterNUICallback('transfer', function(data)
	TriggerServerEvent('bank:transfer', data.to, data.amountt)
	TriggerServerEvent('bank:balance')
end)

--===============================================
--==         Result   Event                  --==
--===============================================

RegisterNetEvent('bank:result')
AddEventHandler('bank:result', function(type, message)
	SendNUIMessage({type = 'result', m = message, t = type})
end)
--===============================================
--==               NUIFocusoff               --==
--===============================================
function ResourceStop()
	inMenu = false
	SetNuiFocus(false, false)
	SendNUIMessage({type = 'closeAll'})
end

RegisterNUICallback('NUIFocusOff', function()
	closeUI()
end)

AddEventHandler('onResourceStop', function (resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
	ResourceStop()
end)

AddEventHandler('onResourceStart', function (resourceName)
	if(GetCurrentResourceName() ~= resourceName) then
		return
	end
	ResourceStop()
end)

--===============================================
--==            Capture Bank Distance        --==
--===============================================

function nearBank()
	local player = GetPlayerPed(-1)
	local playerloc = GetEntityCoords(player, 0)

	for _, search in pairs(Config.Bank) do
		local distance = GetDistanceBetweenCoords(search.x, search.y, search.z, playerloc['x'], playerloc['y'], playerloc['z'], true)
	
		if distance <= 1.0 then
			DrawText3D(search.x, search.y, search.z, "~g~[E]~w~ Use Bank") 
			return true
		end
	end
end

function nearATM()
	for i = 1, #Config.ATMs do

		local objFound = GetClosestObjectOfType( GetEntityCoords(PlayerPedId()), 0.75, Config.ATMs[i], 0, 0, 0)
		
		if DoesEntityExist(objFound) then
		  TaskTurnPedToFaceEntity(PlayerPedId(), objFound, 3.0)
		  return true
		end
	end
	return false
end


--===============================================
--==            Animations                   --==
--===============================================

function closeUI()
	inMenu = false
	SetNuiFocus(false,false)

	if Config.Animation == true and nearATM() then
		playAnim('amb@prop_human_atm@male@exit', 'exit', Config.AnimationTime)
		exports['progressBars']:startUI(Config.AnimationTime, "Retrieving Card..")
	end
	
	SendNUIMessage({type = 'closeAll'})
end

function openUI()
	local player = GetPlayerPed(-1)

	if Config.Animation == true and nearBank() then
		playAnim('mp_common', 'givetake1_a', Config.AnimationTime)
		Citizen.Wait(Config.AnimationTime)
	else
		if nearATM() then
			playAnim('amb@prop_human_atm@male@enter', 'enter', Config.AnimationTime)
			exports['progressBars']:startUI(Config.AnimationTime, "Inserting Card..")
		end
	end

    inMenu = true
    SetNuiFocus(true,true)
    SendNUIMessage({type = 'openGeneral'})
end
