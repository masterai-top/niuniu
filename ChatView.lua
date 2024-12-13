-- @Author: ZhuL
-- @Date:   2017-05-04 14:44:30
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-05-19 16:16:08


local UIer = require_ex("ui.common.UIer")
local M = class("ChatView", UIer)

local State = {
    pack = 0,
    moving = 1,
    open = 2
}
local Dur = 0.3
local Interval = 0.5
local emojiLim = 6

local MaxV = 60
local MinV = 40

function M:ctor(ctrler)
    UIer.ctor(self)

    self._ctrler = ctrler or require("games.niu2.models.CommonCtrler")

    self._emojiQueue = require("lib.Queue").new()

    self._root = nil

    self._widget = {}

    self._posPack = cc.p(display.width , display.cy)

    self._posOpen = cc.p(0 , display.cy)

    self._state = State.pack

    self._msgCount = 0

    self._time = 0

    self:init()
end

function M:onEnter()

    UIer.onEnter(self)
end

function M:onExit()

    UIer.onExit(self)
end

function M:init()
    self:initWidget()
    self:initView()
end

function M:initWidget()
    self._root = createCsbNode("subgame/Niuniu/chatView.csb")
    self:addChild(self._root)
    local tab = {
        ["panel"] = {key = "panel"},
        ["panel/btn1"] = {key = "btn1" , handle = handler(self , self.onEmoji)},
        ["panel/btn2"] = {key = "btn2" , handle = handler(self , self.onPhrase)},
        ["panel/lv"] = {key = "lv"},
        ["item1"] = {key = "item1"},
        ["item2"] = {key = "item2"},
        ["barrage"] = {key = "barrage"},
        ["barrageLayer"] = {key = "barrageLayer"},
    }
    bindWidgetList(self._root , tab , self._widget)
    local widget = self._widget
    self._posOpen.x = display.width - widget.panel:getContentSize().width
    self:addTouchListener(false)

    self._touchShield = createCsbNode("res/ui/common/bgRevTouch.csb")
    local bgPan = self._touchShield:getChildByName("main")
    bgPan:setTouchEnabled(true)
    self:addChild(self._touchShield , -1)
    bindClickFunc(bgPan , function()
        if self._state == State.open then
            self:pack()
        end
    end)
    self:setTouchMask(false)
    self:scheduleUpdate()
end

function M:initView()
    self:onEmoji()
end

function M:updateFunc(dt)

    self:tryToShowMsg()

    local queue = self._emojiQueue
    if queue:empty() then
        return
    end
    self._time = self._time + dt
    if self._time >= Interval then
        self:outputEmoji()
    end
end

function M:outputEmoji()
    local queue = self._emojiQueue
    local emojiLst = {}
    while (not queue:empty()) do
        table.insert(emojiLst , queue:pop())
    end

    self._ctrler:reqSendEmoji(emojiLst)

    -- for test
    local str = ""
    for __ , emoji in ipairs(emojiLst) do
        str = str .. "  " .. emoji
    end
    print(str)
end

function M:pushEmoji(val)
    if self._emojiQueue:length() >= emojiLim then
        return
    end
    self._time = 0
    self._emojiQueue:push(val)
end

function M:setTouchMask(bEnabled)
    self._touchShield:setVisible(bEnabled)
end

function M:onPhrase(sender , event)
    local widget = self._widget
    widget.lv:removeAllItems()
    local ids = PhraseConfig.getIds()
    local width = widget.item2:getContentSize().width * 0.8
    for __ , id in ipairs(ids) do
        local item = widget.item2:clone()
        local txt = item:getChildByName("txt")
        local str = phraseCfgCom.content(id)
        txt:setString(str)
        widget.lv:pushBackCustomItem(item)
        txtAdapteSize(txt , width , 10)
        item:setXData(str)
        bindClickFunc(item , handler(self , self.onPhraseClicked))
    end
end

function M:onPhraseClicked(sender , event)
    self._ctrler:reqSendMsg(sender:getXData())
end

function M:onEmoji(sender , event)
    local widget = self._widget
    widget.lv:removeAllItems()
    local ids = EmojiConfig.getIds()
    local colNum = 3
    local d = 65
    local item
    local imgCell
    for i , id in ipairs(ids) do
        local index = i - 1
        if index % colNum == 0 then
            item = widget.item1:clone()
            widget.lv:pushBackCustomItem(item)
            imgCell = item:getChildByName("imgCell")
        else
            imgCell = imgCell:clone()
            item:addChild(imgCell)
            imgCell:moveVec2(d , 0)
        end
        bindClickFunc(imgCell , handler(self , self.onEmojiSendClicked))
        imgCell:loadTexture(EmojiConfig.res(id))
    end
end

function M:onEmojiSendClicked(sender , event)
    self:pushEmoji("emoji")
end

function M:onTouchEnded(touch , event)
    if self._state == State.open then
        self:pack()
    end
end

function M:open()
    if self._state ~= State.pack then
        return
    end
    self._state = State.moving
    local panel = self._widget.panel
    local moveTo = cc.MoveTo:create(Dur , self._posOpen)
    local callFunc = cc.CallFunc:create(function()
        self._state = State.open
        self:setTouchMask(true)
    end)
    local seq = cc.Sequence:create({cc.EaseBackOut:create(moveTo) , callFunc})
    panel:runAction(seq)
end

function M:pack()
    if self._state ~= State.open then
        return
    end
    self._state = State.moving
    local panel = self._widget.panel
    local moveTo = cc.MoveTo:create(Dur , self._posPack)
    local callFunc = cc.CallFunc:create(function()
        self._state = State.pack
        self:setTouchMask(false)
    end)
    local seq = cc.Sequence:create({cc.EaseBackIn:create(moveTo) , callFunc})
    panel:runAction(seq)
end

------------------------------处理弹幕逻辑 start------------------------------

function M:tryToShowMsg()
    if self._msgCount > 10 then
        return
    end
    local msg = self._ctrler:popMsg()
    if not msg then
        return
    end
    self:showMsg(msg.type , msg.data)
end

function M:initMsg(item , msgType , data)

    local txt = item:getChildByName("child3")
    local img = item:getChildByName("child2")
    if msgType == 1 then
        txt:setVisible(false)
        for i , emoji in ipairs(data) do
            local index = i + 2
            if i > 1 then
                img = img:clone()
                img:setName("child" .. index)
                item:addChild(img)
            end
            img:loadTexture(GoodsConfig.icon(100010001))
        end
    elseif msgType == 2 then
        img:setVisible(false)
        txt:setString(data)
    end
    item:switchAlign()
    item:forceRemedy()
end

function M:showMsg(msgType , data)
    self._msgCount = self._msgCount + 1
    local widget = self._widget
    local layer = widget.barrageLayer
    local layerSize = layer:getContentSize()
    local barrage = widget.barrage:clone()
    self:initMsg(barrage , msgType , data)
    local barrageSize = barrage:getContentSize()
    local a = barrage:getAnchorPoint()
    local maxY = layerSize.height - barrageSize.height * (1 - a.y)
    local minY = barrageSize.height * a.y
    local minX = 0 - barrageSize.width * (1 - a.x)
    local maxX = layerSize.width + barrageSize.width * a.x
    local y = common_util.rand(minY , maxY)
    barrage:setPosition(maxX , y)
    local velo = common_util.rand(MinV , MaxV)
    local dur = (maxX - minX) / velo
    local moveTo = cc.MoveTo:create(dur , cc.p(minX , y))
    local callFunc = cc.CallFunc:create(function(args)
        self._msgCount = self._msgCount - 1
        args:removeFromParent()
    end)
    local seq = cc.Sequence:create(moveTo , callFunc)
    barrage:runAction(seq)
    layer:addChild(barrage)
end

------------------------------处理弹幕逻辑 start------------------------------

return M