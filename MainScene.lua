
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
	local params = {
		icon = "gameres/zhaociji/ZhaoCiJi_Button_04.png",
		gameid = 1,
		version = "1.60.00",
		onenter = function (callback)
			Game.bullDB = require_ex("games.brnn.models.BullDB")
		    Game.bullCom = require_ex("games.brnn.models.BullCom")
		    Game.bullCom:onEnter(callback)
		end,
		onexit = function ()
			if Game.bullCom then
		        Game.bullCom:onExit()
		    end
		end,
	}
	Game:addLayer(require("ui.common.GameEntryUI"):new(params))

	maskScene(self)
end

function MainScene:exitScene()
	if Game.bullCom and Game.bullCom:getBetUI() then
		Game.bullCom:getBetUI():onBackClicked()
	end
end

function MainScene:toString()
    print("BRNN Main scene")
end

return MainScene
