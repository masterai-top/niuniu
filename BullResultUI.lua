
local UIer = require_ex("ui.common.UIer")
local BullResultUI = class("BullResultUI", UIer)

local SpineResult = {
    {res="subgame/bull/spine/bairenniuniu_jiesuan_shule", ani="shule_02", x=0, y=0, isLoop=false, pNode = "node_spine_cover"}, -- 庄家通吃
    {res="subgame/bull/spine/bairenniuniu_jiesuan_shengli", ani="shengli01", x=0, y=0, isLoop=true, pNode = "node_spine"}, -- 庄家通赔
    {res="subgame/bull/spine/bairenniuniu_jiesuan_shengli", ani="shengli01", x=0, y=0, isLoop=true, pNode = "node_spine"}, -- 胜利
    {res="subgame/bull/spine/bairenniuniu_jiesuan_shule", ani="shule_02", x=0, y=0, isLoop=true, pNode = "node_spine_cover"}, -- 失败
    {res="subgame/bull/spine/bairenniuniu_jiesuan_pingju", ani="pingju01", x=0, y=0, isLoop=true, pNode = "node_spine"}, -- 平局
}
local Actor = require_ex("ui.common.Actor")

function BullResultUI:ctor()
    UIer.ctor(self)
    self:registerNodeEvent()
    self:registerListenEvent()
    common_util.fadeMusic(0.3)
    self:init()
end

function BullResultUI:init()
    for i,v in ipairs(SpineResult) do
        if v.ani == "shengli01" then
            v.handle = { [sp.EventType.ANIMATION_COMPLETE] = handler(self, self.spineWinCompleteLsn) }
        end
    end

    self._BindWidget = {
        ["panel_item_winner"] = {},
        ["panel_center"] = {},
        ["panel_touch"] = {handle = handler(self, self.onBackClicked)},
        ["panel_center/Button_close"] = {key = "btn_close", handle = handler(self, self.onBackClicked)},
        ["panel_center/Image_bg_win"] = {key = "img_bg_win"},
        ["panel_center/Image_bg_fail"] = {key = "img_bg_fail"},
        ["panel_center/Panel_title/Image_t1"] = {key = "img_t1"},
        ["panel_center/Panel_title/Image_t2"] = {key = "img_t2"},
        ["panel_center/Panel_title/Image_t3"] = {key = "img_t3"},
        ["panel_center/Panel_title/Image_t4"] = {key = "img_t4"},
        ["panel_center/Panel_title/Image_t5"] = {key = "img_t5"},
        ["panel_center/Node_spine"] = {key = "node_spine"},
        ["panel_center/Node_spine_shule"] = {key = "node_spine_cover"},
        ["panel_center/ListView_reward"] = {key = "lv_reward"},
        ["panel_center/Panel_myinfo/Text_gold"] = {key = "txt_my_gold"},
        ["panel_center/Panel_myinfo/Text_bet"] = {key = "txt_my_bet"},
        ["panel_center/Panel_binfo/Text_gold"] = {key = "txt_b_gold"},
        ["panel_center/Panel_binfo/Text_bet"] = {key = "txt_b_bet"},
    }

    self._widgets = {}
    self._isWin = Game.bullDB:getDrawAll()

    self:initViews()
end

function BullResultUI:initViews(initLayer)
    if initLayer == nil then
        local uiNode = createCsbNode("subgame/bull/bull_result.csb")
        self:addChild(uiNode, 1)

        bindWidgetList(uiNode, self._BindWidget, self._widgets)
    end

    self:initMyInfo()
    self:initBankerInfo()
    self:initResult()
    self:initWinnerList()
end

function BullResultUI:initMyInfo()
    local chip, coin = Game.bullDB:getMyResult()
    local color = cc.c3b(255, 255, 255)
    if coin > 0 then
        color = cc.c3b(255, 0, 0)
        coin = "+"..coin
        self._isWin = math.min(self._isWin, 3)
    elseif coin < 0 then
        color = cc.c3b(0, 255, 0)
        self._isWin = math.min(self._isWin, 4)
    end
    self._widgets.txt_my_bet:setString(chip)
    self._widgets.txt_my_gold:setColor(color)
    self._widgets.txt_my_gold:setString(coin)
end

function BullResultUI:initBankerInfo()
    local chip, coin = Game.bullDB:getBankerResult()
    local color = cc.c3b(255, 255, 255)
    if coin > 0 then
        color = cc.c3b(255, 0, 0)
        coin = "+"..coin
    elseif coin < 0 then
        color = cc.c3b(0, 255, 0)
    end
    self._widgets.txt_b_bet:setString(chip)
    self._widgets.txt_b_gold:setColor(color)
    self._widgets.txt_b_gold:setString(coin)
end

function BullResultUI:initResult()
    self._widgets["img_t"..self._isWin]:setVisible(true)
    self._spineResult = Actor:new(SpineResult[self._isWin].res, SpineResult[self._isWin])
    if self._isWin == 3 then
        common_util.playSoundConfig(self, "win")
        if self._widgets.img_bg_win and self._widgets.img_bg_fail then
            self._widgets.img_bg_win:setVisible(true)
            self._widgets.img_bg_fail:setVisible(false)
        end
    else
        if self._isWin == 5 then
            common_util.playSoundConfig(self, "ping")
        else
            common_util.playSoundConfig(self, "lose")
        end
        if self._widgets.img_bg_win and self._widgets.img_bg_fail then
            self._widgets.img_bg_win:setVisible(false)
            self._widgets.img_bg_fail:setVisible(true)
        end
    end
    if self._spineResult then
        local pNode = self._widgets[SpineResult[self._isWin].pNode] or self._widgets.node_spine
        pNode:addChild(self._spineResult, 20)
    end
end

function BullResultUI:initWinnerList()
    local data = Game.bullDB:getWinnerList() or {}
    local facelook, icon, nick, coin
    local item, imgIcon, txtName, txtCoin
    local i = 1
    while (data[i]) do
        item = item or self._widgets.panel_item_winner:clone()
        if i % 2 == 0 then
            item = item:getChildByName("Panel_right")
        else
            self._widgets.lv_reward:pushBackCustomItem(item)
        end
        imgIcon = item:getChildByName("Image_icon")
        txtName = item:getChildByName("Text_name")
        txtCoin = item:getChildByName("Text_coin")

        nick = data[i].name
        coin = data[i].ret_coin
        facelook = data[i].facelook or 10001
        icon = cfg_util.getFacelook(facelook)
        local color = cc.c3b(255, 255, 255)
        if coin > 0 then
            color = cc.c3b(255, 0, 0)
            coin = "+"..coin
        elseif coin < 0 then
            color = cc.c3b(0, 255, 0)
        end

        txtName:setString(nick)
        txtCoin:setColor(color)
        txtCoin:setString(coin)
        if icon and imgIcon then
            fitIconSize(imgIcon, icon)
        end
        item:setVisible(true)

        i = i + 1
        if i % 2 == 1 then
            item = nil
        end
    end

    self._widgets.lv_reward:jumpToTop()
end

function BullResultUI:registerNodeEvent()
    local eventDispatcher = self:getEventDispatcher()
    local function onEnter()
        UIer.onEnter(self)
    end

    local function onExit()
        UIer.onExit(self)
    end

    local function onNodeEvent(event)
        if "enter" == event then
            onEnter()
        elseif "exit" == event then
            onExit()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function BullResultUI:registerListenEvent()
    self:listenCustomEvent(BetEvent.BET_TIME_CHANGE_EVENT, handler(self, self.onTimeChanged))
end

function BullResultUI:spineWinCompleteLsn(event)
    local ani = event.animation
    if ani == "shengli01" and self._spineResult then
        self._spineResult:changeAnimation("shengli02", true)
    end
end

-------------------------------
function BullResultUI:onBackClicked()
    
    common_util.fadeMusic()
    self:destroy()
end

-- 计时器更新
function BullResultUI:onTimeChanged(event)
    if event.data.state ~= BetState.reward or event.data.timeleft == 0 then
        self:onBackClicked()
    end
end

return BullResultUI
