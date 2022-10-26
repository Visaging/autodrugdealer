script_name("Auto Drug Dealer")
script_author("Visage")

local script_version = 1.1
local script_version_text = '1.1'

require"lib.moonloader"
require"lib.sampfuncs"
local https = require 'ssl.https'
local dlstatus = require('moonloader').download_status
local script_path = thisScript().path
local script_url = "https://raw.githubusercontent.com/Visaging/autodrugdealer/main/autodrugdealer.lua"
local update_url = "https://raw.githubusercontent.com/Visaging/autodrugdealer/main/autodrugdealer.txt"
local sampev = require "lib.samp.events"
local inicfg = require 'inicfg'

ddenable = false

local adrd = inicfg.load({
    main = 
    {
      ddproduct = "pot",
      ddid = 0,
      dddelay = 12,
      ddoffered = 0,
      ddaccepted = 0,
    }
}, 'drug_dealer.ini')

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand("ddsetid", cmd1)
	sampRegisterChatCommand("ddsetproduct", cmd2)
	sampRegisterChatCommand("ddtog", cmd3)
    sampRegisterChatCommand("ddsetdelay", cmd4)
    sampRegisterChatCommand("ddhelp", cmd5)
    sampRegisterChatCommand("dddeals", cmd6)
    sampRegisterChatCommand("ddreset", cmd7)
    sampRegisterChatCommand("ddupdate", update_script)
    sampRegisterChatCommand("ddversion", function()
    lua_thread.create(function()
            sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} Current version: {00b7ff}[%s]{FFFFFF}. Use {00b7ff}[/ddupdate]{FFFFFF} to check for updates.", script.this.name, script_version_text))
        end)
    end)
sampAddChatMessage("{DFBD68}Auto Drug Dealer by {FFFF00}Visage. {FF0000}[/ddhelp].")
	while true do wait(0)
        if ddenable then
            sampSendChat("/sell"..adrd.main.ddproduct.." "..adrd.main.ddid.." 1 1")
            wait(adrd.main.dddelay * 1000)
        end
	end	
end

function cmd1(id)
    if (id == nil or not string.match(id, ".+")) then
        ddenable = not ddenable
        if ddenable then
            sampAddChatMessage("Auto Drug Dealer is {00ff18}Enabled{ffffff}.", -1)
        else
            sampAddChatMessage("Auto Drug Dealer is {ff0000}Disabled{ffffff}.", -1)
        end
    else
        if tonumber(id) ~= nil then
            if sampIsPlayerConnected(id) then
                local playername = sampGetPlayerNickname(id)
                local playernamegsub = string.gsub(playername, '_', ' ')
                adrd.main.ddid = id
                sampAddChatMessage("Auto Drug Dealer is {00ff18}Enabled{ffffff} | locked on {44bbff}"..playernamegsub.." {ffffff}| ID: {44bbff}("..id..")", -1)
                ddenable = true
            else
                sampAddChatMessage("Player is {ff0000}not connected.", -1)
            end
        else
            idsub = string.gsub(id, '_', ' ')
            adrd.main.ddid = id
            sampAddChatMessage("Auto Drug Dealer is {00ff18}Enabled{ffffff} | locked on {44bbff}"..idsub, -1)
            ddenable = true
        end
    end
    SaveIni()
end

function cmd2(args)
    args = string.lower(args)
    if #args == 0 then
		sampAddChatMessage("USAGE: /setproduct [Name]", -1)
		sampAddChatMessage("{9E9E9E}Available names: Pot, Crack", -1)
    elseif (args == "pot") then
        adrd.main.ddproduct = "pot"
        sampAddChatMessage("Product is now set to {44bbff}Pot.", -1)
    elseif (args == "crack") then
        adrd.main.ddproduct = "crack"
        sampAddChatMessage("Product is now set to {44bbff}Crack.", -1)
    end
    SaveIni()
end

function cmd3()
    ddenable = not ddenable
    if ddenable then
        sampAddChatMessage("Auto Drug Dealer is {00ff18}Enabled{ffffff}.", -1)
    else
        sampAddChatMessage("Auto Drug Dealer is {ff0000}Disabled{ffffff}.", -1)
    end
end

function cmd4(delay)
    if (delay ~= nil and string.match(delay, "%d+") and tonumber(delay) ~= nil) then
        adrd.main.dddelay = delay
        sampAddChatMessage("Auto Drug Dealer Delay has been changed to {44bbff}"..delay.."{ffffff} seconds.", -1)
        SaveIni()
    else
        sampAddChatMessage("USAGE: /ddsetdelay [Amount in seconds]", -1)
    end
end

function cmd5()
    sampAddChatMessage("{FFFFFF}==============================")
	sampAddChatMessage("{FFFFFF}              ---> {7700FF}Auto Drug Dealer {FFFFFF}<---")
	sampAddChatMessage("{FFFFFF}/ddtog{FFFF00} - {00FF00}Enables {FFFFFF}/ {FF0000}Disables{FFFF00} auto drug dealer.")
	sampAddChatMessage("{FFFFFF}/ddsetid{FFFF00} - Sets a specific player ID or name to interact with.")
	sampAddChatMessage("{FFFFFF}/ddsetproduct{FFFF00} - Sets sell product.")
    sampAddChatMessage("{FFFFFF}/ddsetdelay{FFFF00} - Sets delay between commands (in seconds).")
    sampAddChatMessage("{FFFFFF}/dddeals{FFFF00} - Displays total deals done.")
    sampAddChatMessage("{FFFFFF}/ddreset{FFFF00} - resets total deals.")
    sampAddChatMessage("{FFFFFF}/ddupdate{FFFF00} - Updates the script to the latest version.")
    sampAddChatMessage("  {FFFF00}[INFO]    Default sell product is pot.")
    sampAddChatMessage("  {FFFF00}[INFO]    Default delay is 12 seconds.")
    sampAddChatMessage("{FFFFFF}======= {7700FF}Credits {FFFFFF}=======")
    sampAddChatMessage("{FF0000}Visage A.K.A. Ishaan Dunne")
	sampAddChatMessage("{FFFFFF}==============================")
end

function cmd6()
    sampAddChatMessage(string.format("Total Deals Offered: {44bbff}%s{ffffff} | Accepted: {44bbff}%s", adrd.main.ddoffered, adrd.main.ddaccepted), -1)
end

function cmd7()
    adrd.main.ddoffered = 0
    adrd.main.ddaccepted = 0
    sampAddChatMessage("Total deals have been reset.", -1)
    SaveIni()
end

function sampev.onServerMessage(clr, msg)
    if ddenable then
        if msg:find("* Drug Dealer.+wants to sell you 1 gram%(s%) for $1, %(type /accept.+%) to buy") then
            msgv = msg:match("%(type /accept.+%) to buy")
            if msgv == msg:match("%(type /accept pot%) to buy") then
                sampSendChat("/accept pot")
                adrd.main.ddaccepted = adrd.main.ddaccepted + 1
                sampAddChatMessage("Deals accepted: {44bbff}"..adrd.main.ddaccepted, -1)
                return false
            elseif msgv == msg:match("%(type /accept crack%) to buy") then
                sampSendChat("/accept crack")
                adrd.main.ddaccepted = adrd.main.ddaccepted + 1
                sampAddChatMessage("Deals accepted: {44bbff}"..adrd.main.ddaccepted, -1)
                return false
            end
        end
        if msg:find("* You offered.+to buy 1 gram%(s%) of.+for $1") then
            return false
        end
        if msg:find("* You bought 1 gram%(s%) for $1 from Drug Dealer.+") then
            return false
        end
        if msg:find("* .+has bought your 1 gram%(s%), the $1 was added to your money") then
            adrd.main.ddoffered = adrd.main.ddoffered + 1
            sampAddChatMessage("Deals offered: {44bbff}"..adrd.main.ddoffered, -1)
            return false
        end
        SaveIni()
    end
end

function update_script(noupdatecheck)
	local update_text = https.request(update_url)
	if update_text ~= nil then
		update_version = update_text:match("version: (.+)")
		if update_version ~= nil then
			if tonumber(update_version) > script_version then
				sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} New version found! The update is in progress.", script.this.name), 10944256)
				downloadUrlToFile(script_url, script_path, function(id, status)
					if status == dlstatus.STATUS_ENDDOWNLOADDATA then
						sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} The update was successful!", script.this.name), 10944256)
						lua_thread.create(function()
							wait(500) 
							thisScript():reload()
						end)
					end
				end)
			else
				if noupdatecheck then
					sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} No new version found.", script.this.name), 10944256)
				end
			end
		end
	end
end

function onScriptTerminate(scr, quitGame) 
	if scr == script.this then 
		showCursor(false) 
		SaveIni()
	end
end

function SaveIni()
    inicfg.save(adrd, 'drug_dealer.ini')
end
