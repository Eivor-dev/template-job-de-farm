ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

JoueurRecolte = {}
JoueurTraite = {}
JoueurVent = {}
local itemtraite = 1

-- Récolte
local function Recolte(source)
    local _source = source
    SetTimeout(4000, function()

        if JoueurRecolte[_source] == true then

            local xPlayer = ESX.GetPlayerFromId(_source)
            local Quantity = xPlayer.getInventoryItem('bread').count --- remplacez par votre item

            if Quantity >= 100 then
                TriggerClientEvent('esx:showNotification', _source, '~r~Vous n\'avez plus de place~s~')
            else
                xPlayer.addInventoryItem('bread', 1) --- remplacez par votre item et le nomre
                Recolte(_source)
            end
        end
    end)
end

RegisterServerEvent('jobfarm:StartRecolte')
AddEventHandler('jobfarm:StartRecolte', function()
    local _source = source
    JoueurRecolte[_source] = true
    TriggerClientEvent('esx:showNotification', _source, 'Récolte en ~b~cours~s~...')
    Recolte(_source)
end)

RegisterServerEvent('jobfarm:StopRecolte')
AddEventHandler('jobfarm:StopRecolte', function()
    local _source = source
    JoueurRecolte[_source] = false
    TriggerClientEvent('esx:showNotification', _source, 'Vous sortez de la ~r~zone')
end)

-- Traitement
local function Traitement(source)
    local _source = source
    SetTimeout(4000, function()

        if JoueurTraite[_source] == true then

            local xPlayer = ESX.GetPlayerFromId(_source)
            local Quantity = xPlayer.getInventoryItem('bread').count --- remplacez par votre item

            if Quantity == 0 then
                TriggerClientEvent('esx:showNotification', _source, '~r~Vous n\'avez pas assez de pain.')
            else
                xPlayer.removeInventoryItem('bread', 1) --- remplacez par votre item et le nomre
                xPlayer.addInventoryItem('water', 1) --- remplacez par votre item traité et le nomre

                Traitement(_source)
            end
        end
    end)
end

RegisterServerEvent('jobfarm:StartTraitement')
AddEventHandler('jobfarm:StartTraitement', function()
    local _source = source
    JoueurTraite[_source] = true
    TriggerClientEvent('esx:showNotification', _source, '~g~Traitement~s~ en cours..')
    Traitement(_source)
end)

RegisterServerEvent('jobfarm:StopTraitement')
AddEventHandler('jobfarm:StopTraitement', function()
    local _source = source
    JoueurTraite[_source] = false
    TriggerClientEvent('esx:showNotification', _source, 'Vous sortez de la ~r~zone')
end)

-- Vente
local function Sell(source, zone)
    if JoueurVent[source] == true then
        local xPlayer = ESX.GetPlayerFromId(source)

        if zone == 'Vente' then
            if xPlayer.getInventoryItem('water').count <= 0 then --- remplacez par votre item
                itemtraite = 0
            else
                itemtraite = 1
            end

            if itemtraite == 0 then
                TriggerClientEvent('esx:showNotification', source, '~r~Vous n\'avez pas assez de ~s~Bouteille ~r~à vendre.')
                return
            elseif xPlayer.getInventoryItem('water').count <= 0 then --- remplacez par votre item
                TriggerClientEvent('esx:showNotification', source, '~r~Vous n\'avez pas assez de ~s~Bouteille à vendre.')
                itemtraite = 0
                return
            else
                if (itemtraite == 1) then
                    SetTimeout(5000, function()
                        local money = math.random(2, 10) --- remplacez par votre prix ( Le prix est un random donc mettez par ex entre 2 et 10$ )
                        xPlayer.removeInventoryItem('water', 1) --- remplacez par votre item et le nomre
                        xPlayer.addMoney(money)
                        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vendu pour :~g~ $' ..money)
                        Sell(source, zone)
                    end)
                end

            end
        end
    end
end

RegisterServerEvent('jobfarm:StartVente')
AddEventHandler('jobfarm:StartVente', function(zone)
    local _source = source

    if JoueurVent[_source] == false then
        TriggerClientEvent('esx:showNotification', _source, '~r~C\'est pas bien de glitch ~w~')
        JoueurVent[_source] = false
    else
        JoueurVent[_source] = true
        TriggerClientEvent('esx:showNotification', _source, '~g~Vente en cours..')
        Sell(_source, zone)
    end

end)

RegisterServerEvent('jobfarm:StopVente')
AddEventHandler('jobfarm:StopVente', function()
    local _source = source

    if JoueurVent[_source] == true then
        JoueurVent[_source] = false
        TriggerClientEvent('esx:showNotification', _source, 'Vous sortez de la ~r~zone')
    else
        JoueurVent[_source] = true
    end

end)
