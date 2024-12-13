
local UIer = require_ex("ui.common.UIer")
local BullBankerUI = class("BullBankerUI", UIer)

function BullBankerUI:ctor(_, closeCallback)
    UIer.ctor(self)
    self:init(closeCallback)
end

local RuleTab = {
    game = 1,
    rule = 2,
}

function BullBankerUI:init(closeCallback)
    self._BindWidget = {
        ["panel_item_waiter"] = {},
        ["panel_center"] = {},
        ["panel_touch"] = {handle = handler(self, self.onBackClicked)},
        ["panel_center/Button_close"] = {key = "btn_close", handle = handler(self, self.onBackClicked)},
        ["panel_center/btn_banker"] = {key = "btn_banker", handle = handler(self, self.onBanker)},
        ["panel_center/btn_banker_down"] = {key = "btn_banker_down", handle = handler(self, self.onBanker)},
        ["panel_center/Panel_wait/Text_wait_tip"] = {key = "txt_wait_tip"},
        ["panel_center/Panel_wait/Text_wait_num"] = {key = "txt_wait_num"},
        ["panel_center/Panel_wait/Text_wait_no"] = {key = "txt_wait_no"},
        ["panel_center/ListView_reward"] = {key = "lv_banker"},
    }

    self._widgets = {}
    self._myIdx = 0
    self._closeCallback = closeCallback
    self:initViews()
end

function BullBankerUI:initViews(initLayer)
    if initLayer == nil then
        local uiNode = createCsbNode("subgame/bull/bull_banker.csb")
        self:addChild(uiNode, 1)

        bindWidgetList(uiNode, self._BindWidget, self._widgets)

        sideScrollBar(self._widgets.lv_banker)
    end

    self:initBankerInfo()
end

-- 上庄列表
function BullBankerUI:initBankerInfo()
    self._widgets.lv_banker:stopAllActions()
    self._widgets.lv_banker:removeAllItems()
    local bankerList = Game.bullDB:getBankerList()
    local myIndex, myUid = 0, Game.playerDB:getPlayerUid()
    for i, v in ipairs(bankerList) do
        local item = self._widgets.panel_item_waiter:clone()
        local txtIdx = item:getChildByName("Text_idx")
        local txtName = item:getChildByName("Text_name")
        txtIdx:setString(i)
        txtName:setString(v.name)
        if myIndex == 0 and v.player_id == myUid then
            myIndex = i
            txtIdx:setColor(cc.c3b(255,0,0))
            txtName:setColor(cc.c3b(255,0,0))
        end
        item:setVisible(true)
        self._widgets.lv_banker:pushBackCustomItem(item)
    end
    self._widgets.lv_banker:jumpToTop()

    -- if myIndex == 0 and Game.bullDB:isBanker() then
    --     myIndex = 999
    -- end
    self:setMyWaitting(myIndex)
end

function BullBankerUI:updateBankerInfo()
    self:initBankerInfo()
end

function BullBankerUI:setMyWaitting(idx)
    self._myIdx = checknumber(idx)
    if self._myIdx == 0 then
        self._widgets.txt_wait_no:setVisible(true)
        self._widgets.txt_wait_num:setVisible(false)
        self._widgets.txt_wait_tip:setVisible(false)
        self._widgets.btn_banker:setVisible(true)
        self._widgets.btn_banker_down:setVisible(false)
    else
        -- if idx == 999 then
        --     idx = 0
        -- end
        self._widgets.txt_wait_num:setString(idx)
        self._widgets.txt_wait_no:setVisible(false)
        self._widgets.txt_wait_num:setVisible(true)
        self._widgets.txt_wait_tip:setVisible(true)
        self._widgets.btn_banker:setVisible(false)
        self._widgets.btn_banker_down:setVisible(true)
    end
end

-------------------------------
function BullBankerUI:onBackClicked()
    
    if self._closeCallback then
        self._closeCallback()
    end
    self:destroy()
end

function BullBankerUI:onBankerCallback(up, info)
    local key = up and "bull_banker_up" or "bull_banker_down"
    if not up and Game.bullDB:isBanker() then
        key = "bull_banker_down2"
    end
    local tip = stringCfgCom.content(key)
    Game:tipMsg(tip, 1.5)
    self:updateBankerInfo()
end

function BullBankerUI:onBanker(sender)
    local cost = 0 --5000000
    Game.rechargeCom:checkCoinEnough(cost, 3, function ()
        common_util.playSoundConfig("BullUI", "btn_banker")
        Game.bullCom:onBanker(self._myIdx, handler(self, self.onBankerCallback))
    end)
end

return BullBankerUI
