ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--==============================================
--==          Character Name                  ==
--==============================================
ESX.RegisterServerCallback('bank:getname',function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier=@identifier",{['@identifier'] = xPlayer.getIdentifier()}, function(data)
        for _,v in pairs(data) do
            first = v.firstname
            last = v.lastname
        end
        cb(first, last)
    end)
end)
--==============================================
--==          Quick Withdraws                 ==
--==============================================
RegisterServerEvent('bank:fastdep')
AddEventHandler('bank:fastdep', function(base)

    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local mcount = xPlayer.getMoney()
    
    if mcount == nil or mcount < 100 then
        TriggerClientEvent('mythic_notify:client:SendAlert',  src, { type = 'error', text = 'You dont have a money!'})
    else

    xPlayer.addAccountMoney('bank', 100)
    xPlayer.removeMoney(100)
    end
end)

RegisterServerEvent('bank:fastw')
AddEventHandler('bank:fastw', function(base)

    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local mcount = xPlayer.getAccount('bank').money
    
    if mcount == nil or mcount <= 0 then
        TriggerClientEvent('mythic_notify:client:SendAlert',  src, { type = 'error', text = 'Your account is empty!'})
    else

    xPlayer.addMoney(100)
    xPlayer.removeAccountMoney('bank', 100) 
    end
end)

RegisterServerEvent('bank:fastwt')
AddEventHandler('bank:fastwt', function(base)

    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local mcount = xPlayer.getAccount('bank').money
    
    if mcount == nil or mcount <= 0 then
        TriggerClientEvent('mythic_notify:client:SendAlert',  src, { type = 'error', text = 'Your account is empty!'})
    else

    xPlayer.addMoney(500)
    xPlayer.removeAccountMoney('bank', 500) 
    end
end)

--================================================
--==          Deposit Events                  --==  
--================================================

RegisterServerEvent('bank:deposit')
AddEventHandler('bank:deposit', function(amount)

    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local mcount = xPlayer.getMoney()

    if amount == nil or amount <= 0 then
        TriggerClientEvent('mythic_notify:client:SendAlert',  src, { type = 'error', text = 'Invalid amount!'})
    else
        if amount > mcount then
            amount = mcount
        end

        xPlayer.removeMoney(amount)
        xPlayer.addAccountMoney('bank', tonumber(amount))
    end
end)

RegisterServerEvent('bank:withdraw')
AddEventHandler('bank:withdraw', function(amount)

    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    amount = tonumber(amount)
    local mcount = xPlayer.getAccount('bank').money

    if amount == nil or amount <= 0 then
        TriggerClientEvent('mythic_notify:client:SendAlert',  src, { type = 'error', text = 'Invalid amount!'})
    else
        if amount > mcount then
            amount = mcount
        end

        xPlayer.removeAccountMoney('bank', amount)
        xPlayer.addMoney(amount)
    end
end)

RegisterServerEvent('bank:balance')
AddEventHandler('bank:balance', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
  
    balance = ESX.Math.GroupDigits(xPlayer.getAccount('bank').money)
    TriggerClientEvent('currentbalance1', src, balance)

end)

RegisterServerEvent('bank:transfer')
AddEventHandler('bank:transfer', function(to, amountt)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local zPlayer = ESX.GetPlayerFromId(to)

    local balance = 0
    if zPlayer ~= nil and GetPlayerEndpoint(to) ~= nil then
        balance = xPlayer.getAccount('bank').money
        zbalance = zPlayer.getAccount('bank').money

        if tonumber(src) == tonumber(to) then
            TriggerClientEvent('mythic_notify:client:SendAlert',  src, { type = 'error', text = 'You cannot transfer to yourself!'})
        else
            if balance <= 0 or balance < tonumber(amountt) or tonumber(amountt) <= 0 then
                    TriggerClientEvent('mythic_notify:client:SendAlert',  src, { type = 'error', text = 'You dont have a money!'})
            else
                xPlayer.removeAccountMoney('bank', tonumber(amountt))
                zPlayer.addAccountMoney('bank', tonumber(amountt))

                TriggerClientEvent('mythic_notify:client:SendAlert',  src, { type = 'inform', text = 'Transfer is successful.'})

                TriggerClientEvent('mythic_notify:client:SendAlert', to, { type = 'inform', text = 'You received ' .. amountt .. '$.'})     
            end
        end
    end
end)
