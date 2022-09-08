require 'lib.moonloader'
script_name('autoupdate')
script_version('2.0')

local imgui = require('imgui')
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
        
local window = imgui.ImBool(false)


function main()
    while not isSampAvailable() do wait(200) end
    autoupdate("https://gist.githubusercontent.com/Nightmare352/59f72130dfd20ca72a067c14aae2240f/raw", '['..string.upper(thisScript().name)..']: ', "https://raw.githubusercontent.com/Nightmare352/mhelper/main/autoupdate%20(2.0).lua")
    imgui.Process = false
    window.v = true
    while true do
        wait(0)
        imgui.Process = window.v
    end
end

function imgui.OnDrawFrame()
    if window.v then
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 300, 300
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2 - sizeX / 2, resY / 2 - sizeY / 2), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin('Window Title', window)
            imgui.Text(u8'ýòî âåðñèÿ 2.0')
        imgui.End()
    end
end

function autoupdate(json_url, prefix, url)
    local dlstatus = require('moonloader').download_status
    local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
    if doesFileExist(json) then os.remove(json) end
    downloadUrlToFile(json_url, json,
        function(id, status, p1, p2)
        if status == dlstatus.STATUSEX_ENDDOWNLOAD then
            if doesFileExist(json) then
            local f = io.open(json, 'r')
            if f then
                local info = decodeJson(f:read('*a'))
                updatelink = info.updateurl
                updateversion = info.latest
                f:close()
                os.remove(json)
                if updateversion ~= thisScript().version then
                lua_thread.create(function(prefix)
                    local dlstatus = require('moonloader').download_status
                    local color = -1
                    sampAddChatMessage((prefix..'Îáíàðóæåíî îáíîâëåíèå. Ïûòàþñü îáíîâèòüñÿ c '..thisScript().version..' íà '..updateversion), color)
                    wait(250)
                    downloadUrlToFile(updatelink, thisScript().path,
                    function(id3, status1, p13, p23)
                        if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                        print(string.format('Çàãðóæåíî %d èç %d.', p13, p23))
                        elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                        print('Çàãðóçêà îáíîâëåíèÿ çàâåðøåíà.')
                        sampAddChatMessage((prefix..'Îáíîâëåíèå çàâåðøåíî!'), color)
                        goupdatestatus = true
                        lua_thread.create(function() wait(500) thisScript():reload() end)
                        end
                        if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                        if goupdatestatus == nil then
                            sampAddChatMessage((prefix..'Îáíîâëåíèå ïðîøëî íåóäà÷íî. Çàïóñêàþ óñòàðåâøóþ âåðñèþ..'), color)
                            update = false
                        end
                        end
                    end
                    )
                    end, prefix
                )
                else
                update = false
                print('v'..thisScript().version..': Îáíîâëåíèå íå òðåáóåòñÿ.')
                end
            end
            else
            print('v'..thisScript().version..': Íå ìîãó ïðîâåðèòü îáíîâëåíèå. Ñìèðèòåñü èëè ïðîâåðüòå ñàìîñòîÿòåëüíî íà '..url)
            update = false
            end
        end
        end
    )
    while update ~= false do wait(100) end
end


