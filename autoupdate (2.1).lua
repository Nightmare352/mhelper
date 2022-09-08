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
    --autoupdate("", '['..string.upper(thisScript().name)..']: ', "http://vk.com/qrlk.mods")
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
            imgui.Text(u8'а это уже версия 2.1')
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
                    sampAddChatMessage((prefix..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
                    wait(250)
                    downloadUrlToFile(updatelink, thisScript().path,
                    function(id3, status1, p13, p23)
                        if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                        print(string.format('Загружено %d из %d.', p13, p23))
                        elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                        print('Загрузка обновления завершена.')
                        sampAddChatMessage((prefix..'Обновление завершено!'), color)
                        goupdatestatus = true
                        lua_thread.create(function() wait(500) thisScript():reload() end)
                        end
                        if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                        if goupdatestatus == nil then
                            sampAddChatMessage((prefix..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                            update = false
                        end
                        end
                    end
                    )
                    end, prefix
                )
                else
                update = false
                print('v'..thisScript().version..': Обновление не требуется.')
                end
            end
            else
            print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
            update = false
            end
        end
        end
    )
    while update ~= false do wait(100) end
end


