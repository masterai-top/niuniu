-- @Author: ZhuL
-- @Date:   2017-05-02 11:26:21
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-05-18 16:31:00


local UIer = require_ex("ui.common.UIer")
local M = class("BullView", UIer)

local resPgs1 = "subgame/Niuniu/board/ty_txk1_2.png"
local resPgs2 = "subgame/Niuniu/board/ty_txk2_2.png"

local chipRes = "gameres/general/Icon/DouDiZhu_Icon_Coin_01.png"

local waitTime = 15

local RoomState = {
    Wait        = 0,
    Deal        = 1,
    Running     = 2,
    CmpPoker    = 3,
    AllIn       = 4,
    Settle      = 5
}

local PlayerState = {
    Idle        = 0,
    Prepare     = 1,
    Unlooked    = 2,
    Looked      = 3,
    GiveUp      = 4,
    CmpFail     = 5,
    AllIn       = 6
}

local Behavior = {
    Enter = 0,
    Leave = 1
}

local OpType = {
    Bet     = 0,
    GiveUp  = 1
}

local RfsType = {
    RoomState       = 0,
    OnBet           = 1,
    OnSettle        = 2,
    ChangePlayer    = 3,
    TurnChange      = 4,
    All             = 5
}

function M:ctor(ctrler)
    UIer.ctor(self)

    self._ctrler = ctrler

    self._DB = ctrler:getDB()

    self._root = nil

    self._widget = {}

    self._chips = {}

    -- 是否即将比牌
    self._bCmp = false

    self._betFactor = 1

    -- 用于开始倒计时
    self._time = 0

    self._delayAction = nil

    -- 通过位置索引座位
    self._posTab = {}

    -- 通过id索引座位
    self._idTab = {}

    self:init()
end

function M:init()
    self:initWidget()
    self:initView()
end

function M:onExit()
    self._ctrler:getDB():setRoomId(nil)
    UIer.onExit(self)
end

function M:initWidget()
    self._root = createCsbNode("subgame/Niuniu/bullView.csb")
    self:addChild(self._root)
    local tab = {
        ["panel"] = {key = "panel"},
        ["spine"] = {
            key = "spine" ,
            spine = {
                res = "subgame/Niuniu/spine/vs/vs1/nn_vs",
                x = display.cx,
                y = display.cy,
            },
        },
        ["temp"] = {key = "temp"},

        ["panel/panelHead"] = {key = "panelHead"},
        ["panel/panelHead/cbPack"] = {key = "cbPack"},
        ["panel/panelHead/cbPack/panel/child1"] = {key = "btnExit" , handle = handler(self , self.onClose)},
        ["panel/panelHead/cbPack/panel/child2"] = {key = "btnTrans" , handle = handler(self , self.onTrans)},
        ["panel/panelHead/cbPack/panel/child3"] = {key = "btnSetting" , handle = handler(self , self.onSetting)},
        ["panel/panelHead/btnChat"] = {key = "btnChat" , handle = handler(self , self.onChat)},
        ["panel/panelHead/btnHelp"] = {key = "btnHelp" , handle = handler(self , self.onHelp)},
        ["panel/panelHead/btnRcg"] = {key = "btnRcg" , handle = handler(self , self.onRecharge)},
        ["panel/panelHead/btnRedPack"] = {key = "btnRedPack" , handle = handler(self , self.onRedPack)},
        ["panel/panelHead/btnRanking"] = {key = "btnRanking" , handle = handler(self , self.onRanking)},

        ["panel/betPool"] = {key = "betPool"},
        ["panel/betPool/txtRound"] = {key = "txtRound"},
        ["panel/betPool/txtMinBet"] = {key = "txtMinBet"},
        ["panel/betPool/txtMaxBet"] = {key = "txtMaxBet"},
        ["panel/betPool/txtTotalBet"] = {key = "txtTotalBet"},

        ["panel/seatL"] = {key = "seat1" , handle = handler(self , self.onSeatClicked)},
        ["panel/seatL/pointAnim"] = {
            spine = {
                res = "subgame/Niuniu/spine/xuanze/nn_xuanze",
                anim = "1",
                bLastLoop = true,
                    },
            },
        ["panel/seatL2"] = {key = "seat2" , handle = handler(self , self.onSeatClicked)},
        ["panel/seatL2/pointAnim"] = {
            spine = {
                res = "subgame/Niuniu/spine/xuanze/nn_xuanze",
                anim = "1",
                bLastLoop = true,
                    },
            },
        ["panel/seatL3"] = {key = "seat3" , handle = handler(self , self.onSeatClicked)},
        ["panel/seatL3/pointAnim"] = {
            spine = {
                res = "subgame/Niuniu/spine/xuanze/nn_xuanze",
                anim = "1",
                bLastLoop = true,
                    },
            },

        ["panel/seatR"] = {key = "seat7" , handle = handler(self , self.onSeatClicked)},
        ["panel/seatR/pointAnim"] = {
            spine = {
                res = "subgame/Niuniu/spine/xuanze/nn_xuanze",
                anim = "1",
                bLastLoop = true,
                    },
            },
        ["panel/seatR2"] = {key = "seat6" , handle = handler(self , self.onSeatClicked)},
        ["panel/seatR2/pointAnim"] = {
            spine = {
                res = "subgame/Niuniu/spine/xuanze/nn_xuanze",
                anim = "1",
                bLastLoop = true,
                    },
            },
        ["panel/seatR3"] = {key = "seat5" , handle = handler(self , self.onSeatClicked)},
        ["panel/seatR3/pointAnim"] = {
            spine = {
                res = "subgame/Niuniu/spine/xuanze/nn_xuanze",
                anim = "1",
                bLastLoop = true,
                    },
            },

        ["panel/opPanel"] = {key = "opPanel"},
        ["panel/opPanel/cbAllFollow"] = {key = "cbAllFollow" , handle = handler(self , self.onAllFollow)},
        ["panel/opPanel/btnFollowX"] = {key = "btnFollowX" , handle = handler(self , self.onFollow)},
        ["panel/opPanel/btnAddX"] = {key = "btnAddX" , handle = handler(self , self.onAddX)},
        ["panel/opPanel/btnAddXX"] = {key = "btnAddXX" , handle = handler(self , self.onAddXX)},
        ["panel/opPanel/btnLook"] = {key = "btnLook" , handle = handler(self , self.onLook)},
        ["panel/opPanel/btnCmp"] = {key = "btnCmp" , handle = handler(self , self.onCompare)},
        ["panel/opPanel/btnGiveUp"] = {key = "btnGiveUp" , handle = handler(self , self.onGiveUp)},
        ["panel/opPanel/btnAllIn"] = {key = "btnAllIn" , handle = handler(self , self.onAllIn)},

        ["panel/selfSeat"] = {key = "seat4"},
        ["panel/selfSeat/btnReady"] = {key = "btnReady" , handle = handler(self , self.onReady)},
        ["panel/selfSeat/btnShow"] = {key = "btnShow" , handle = handler(self , self.onShow)},
    }
    bindWidgetList(self._root , tab , self._widget)
    local widget = self._widget
    self._widget.cbPack:setAutoHideBg(true)
    self._widget.cbPack:addPackAttr()
    self._ctrler:addChatView(self)
    self:clonePoker()
    widget.temp:setVisible(false)
    widget.spine:setVisible(false)
    self:initAllSeat()
    self:scheduleUpdate()
end

function M:initAllSeat()
    -- 在游戏开始时，隐藏座位上各种信息
    local widget = self._widget
    for i = 1 , 7 do
        local seat = widget["seat" .. i]
        if i ~= 4 then
            local pointAnim = seat:getChildByName("pointAnim")
            pointAnim:setVisible(false)
            pointAnim:setSwallowTouches(false)
            seat:setVisible(false)
        end
        local fp = seat:getChildByName("flyTxt")
        fp:setChildrenVisible(false)
        fp:setSwallowTouches(false)
    end
end

function M:initAllPoker()
    -- 在游戏开始时，把牌面盖上，牌型隐藏
    local widget = self._widget
    for i = 1 , 7 do
        local seat = widget["seat" .. i]
        local panelPoker = seat:getChildByName("panelPoker")
        panelPoker:setChildrenVisible(false)
        panelPoker:setSwallowTouches(false)
        for i , child in ipairs(panelPoker:getChildren()) do
            if child:getName() ~= "imgPoint" then
                setPokerShow(child , false)
            end
        end
        panelPoker:getChildByName("imgPoint"):setVisible(false)
    end
end

function M:start()
    self._betFactor = 1
    self._chips = {}
    self:initAllPoker()
    self:initAllSeat()
    self:refreshAll()
    self:dispatchPoker()
end

function M:clonePoker()
    local widget = self._widget
    local resPgs

    for i = 1 , 7 do
        local seat = widget["seat" .. i]
        resPgs = i == 4 and resPgs2 or resPgs1
        local pg = cc.ProgressTimer:create(cc.Sprite:create(resPgs))
        seat.pg = pg
        local imgPanel = seat:getChildByName("imgPanel")
        pg:setPosition(imgPanel:getPosition())
        pg:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        seat:addChild(pg)
        local panelPoker = seat:getChildByName("panelPoker")
        local poker = panelPoker:getChildByName("poker")
        local imgPoint = panelPoker:getChildByName("imgPoint")
        imgPoint:setLocalZOrder(10)
        imgPoint:setVisible(false)
        panelPoker:setSwallowTouches(false)
        poker:setSwallowTouches(false)
        poker:setVisible(false)
        local d = 20
        for j = 2 , 5 do
            poker = poker:clone()
            poker:setSwallowTouches(false)
            panelPoker:addChild(poker)
            poker:setName("poker" .. j)
            poker:moveVec2(d * poker:getScale() , 0)
        end
    end
end

function M:initView()
    self:refreshAll()
end

function M:initPosTab()
    self._posTab = {}
    local widget = self._widget
    local myPos = self._ctrler:getDB():getMyPos()
    local offset = myPos - 4
    local function getPos(index , offset)
        local pos = index + offset
        if pos > 7 then
            pos = pos - 7
        elseif pos < 1 then
            pos = pos + 7
        end
        return pos
    end
    for i = 1 , 7 do
        local pos = getPos(i , offset)
        self._posTab[pos] = widget["seat" .. i]
    end
end

function M:initIdTab()
    self._idTab = {}
    local playerLst = self._DB:getPlayerList()
    for __ , val in ipairs(playerLst) do
        local seat = self._posTab[val.pos]
        self._idTab[val.player_id] = seat
        seat.__id = val.player_id
        seat:setVisible(true)
        self:initSeat(seat , val)
    end
end

function M:refresh(rfsType , args)

    if rfsType == RfsType.All then
        -- 整体刷新
        self:refreshAll()
    elseif rfsType == RfsType.OnBet then
        -- 玩家下注刷新
        self:onPlayerBet()
    elseif rfsType == RfsType.OnSettle then
        -- 结算刷新
        self:onResult(args)
    elseif rfsType == RfsType.ChangePlayer then
        -- 刷新单个玩家状态
        self:onPlayerStateChange(args)
    elseif rfsType == RfsType.TurnChange then
        -- 刷新当前回合
        self:onTurnChange(args)
    elseif rfsType == RfsType.RoomState then
        -- 刷新房间状态
        self:onRoomStateChange()
    end
end

function M:onRoomStateChange()
    local roomState = self._DB:getRoomState()
    -- if roomState == RoomState.Deal then
    --     self:start()
    -- end
    self:refreshOpPanel()
end

function M:onPlayerStateChange(uid , val)
    local state = self._DB:getPlayerState(uid)
    local seat = self._idTab[uid]
    local imgState = seat:getChildByName("imgState")
    local roomState = self._DB:getRoomState()
    local res = self._ctrler:getStateRes(state)
    local imgOk = seat:getChildByName("imgOk")
    print("res______________" , res)
    if imgState then
        imgState:setVisible(res ~= nil)
        imgState:loadTexture(res)
    end

    self:setSeatLookOn(seat , state == PlayerState.Idle and
                                roomState == RoomState.Running)

    if state == PlayerState.GiveUp then
        breakCountDown(seat.pg)
    end

    imgOk:setVisible(state == PlayerState.Prepare)

    if uid == Game.playerDB:getPlayerUid() then
        self:refreshOpPanel()
        if state == PlayerState.Looked then
            self._betFactor = 2
        end
    end
end

function M:refreshAll()
    self:initPosTab()
    self:initIdTab()
    self:refreshDesk()
    self:refreshOpPanel()
    self:refreshAllSeat()
end

function M:refreshAllSeat()
    local widget = self._widget
    local roomState = self._DB:getRoomState()
    for i = 1 , 7 do
        local seat = widget["seat" .. i]
        self:refreshSeat(seat)
    end
    if roomState == RoomState.Running then
        local curPlayerPos = self._DB:getCurPlayer()
        local seat = self._posTab[curPlayerPos]
        local remainTime = self._DB:getRemainTime()
        self:onWait(seat , remainTime)
    end

    for uid , seat in pairs(self._idTab) do
        self:onPlayerStateChange(uid)
    end
end

function M:refreshSeat(seat)
    local panelPoker = seat:getChildByName("panelPoker")
    local roomState = self._DB:getRoomState()
    for __ , child in ipairs(panelPoker:getChildren()) do
        if child:getName() ~= "imgPoint" then
            child:setVisible(roomState ~= RoomState.Wait and roomState ~= RoomState.Deal)
        else
            child:setVisible(roomState == RoomState.Settle)
        end
    end
    breakCountDown(seat.pg)
end

function M:onTurnChange(time)
    local roomState = self._DB:getRoomState()
    if roomState == RoomState.Wait then
        return
    end
    self:refreshOpPanel()

    local curPlayerPos = self._DB:getCurPlayer()

    if RoomState.CmpPoker == roomState then
        self._delayAction = performWithDelay(self , function()
            local uid = self._DB:getRandomUid()
            local seat = self._idTab[uid]
            self:onSeatClicked(seat)
        end , time - 2 > 0 and time - 2 or 0)
    end

    self:onWait(self._posTab[curPlayerPos] , time)
end

function M:onPlayerBet()
    self:refreshDesk()
    local uid = self._DB:getBetPlayer()

    local seat = self._idTab[uid]
    local coin = self._DB:getPlayerCoin(uid)
    local bet = self._DB:getPlayerBet(uid)
    local curBet = self._DB:getCurBet()
    local preBet = self._DB:getPreBet()
    seat:getChildByName("txtBet"):setString(bet)
    seat:getChildByName("txtCoin"):setString(coin)
    local seat = self._idTab[uid]
    breakCountDown(seat.pg)
    self:flyChip(seat)
    local str = curBet > preBet and "加注" or "跟注"
    self:runFlyTxt(seat , str .. curBet)
end

function M:refreshDesk()
    local widget = self._widget
    widget.txtMaxBet:setString("封顶" .. self._DB:getMaxBet())
    widget.txtMinBet:setString("底注" .. self._DB:getMinBet())
    widget.txtRound:setString("第" .. self._DB:getCurRound() .. "轮")
    widget.txtTotalBet:setString(self._DB:getTotalBet())
end

function M:refreshOpPanel()
    local widget = self._widget
    local myState = self._DB:getMyState()
    local myPos = self._DB:getMyPos()
    local curRound = self._DB:getCurRound()
    local curPlayerPos = self._DB:getCurPlayer()
    local roomState = self._DB:getRoomState()
    local bAllIn = self._DB:getRoomState() == RoomState.AllIn
    local coin = Game.playerDB:getPlayerCoin()
    local curBet = self._DB:getCurBet()
    local maxBet = self._DB:getMaxBet()
    local myId = Game.playerDB:getPlayerUid()
    local winId = self._DB:getWinner()
    local bLackCoin = self._betFactor * curBet > coin

    local bShowAllIn = bAllIn or
                    bLackCoin or
                    curRound >= 10

    widget.opPanel:setVisible(myState ~= PlayerState.Idle
                        and roomState ~= RoomState.Wait
                        and roomState ~= RoomState.Settle
                        and myState ~= PlayerState.GiveUp)
    self:shieldPanel(widget.opPanel , curPlayerPos ~= myPos or
                                        roomState == RoomState.Wait or
                                        roomState == RoomState.Deal)

    self._time = self._DB:getRemainTime()

    performWithDelay(self , function()
        self:tryToBet()
    end , 1)

    widget.btnAllIn:setVisible(bShowAllIn)
    widget.btnAddX:setVisible(not bShowAllIn)
    widget.btnAddXX:setVisible(not bShowAllIn)


    widget.btnFollowX:changeEnabled(not bAllIn and not bLackCoin)


    widget.btnShow:setVisible(roomState == RoomState.Wait and
                                myId == winId)
    widget.btnLook:setVisible(myState == PlayerState.Unlooked and
                            roomState ~= RoomState.Settle and
                            curRound >= 3)

    widget.btnReady:setVisible(roomState == RoomState.Wait and PlayerState.Idle == myState)


    widget.btnFollowX:setTitleString("跟" .. curBet)
    local bet = curBet * 2 < maxBet and curBet * (2 - 1) or maxBet - curBet
    widget.btnAddX:setTitleString("加" .. bet)
    widget.btnAddX:changeEnabled(curBet < maxBet)

    widget.btnCmp:changeEnabled(curRound >= 2 and
                                    coin > self._betFactor * curBet * 2 and
                                    not bAllIn)

    bet = curBet * 4 < maxBet and curBet * (4 - 1) or maxBet - curBet
    widget.btnAddXX:setTitleString("加" .. bet)
    widget.btnAddXX:changeEnabled(curBet < maxBet)
end

function M:tryToBet()
    local widget = self._widget
    local myPos = self._DB:getMyPos()
    local curRound = self._DB:getCurRound()
    local curPlayerPos = self._DB:getCurPlayer()
    local roomState = self._DB:getRoomState()
    local coin = Game.playerDB:getPlayerCoin()
    local curBet = self._DB:getCurBet()
    local bAllIn = roomState == RoomState.AllIn or
                    self._betFactor * curBet > coin

    if curPlayerPos == myPos and
        roomState == RoomState.Running and
        not self._DB:hasBetCurRound() and
        widget.cbAllFollow:isSelected() then

        print("tryToBet-----------------------------")
        if bAllIn then
            self:onAllIn(widget.btnAllIn)
        else
            self:onFollow(widget.btnFollowX)
        end
    end
end

function M:updateFunc(dt)
    self._time = self._time - dt
    self._widget.btnReady:setTitleString(string.format("准备(%d)" , self._time))
end

function M:shieldPanel(panel , val)
    local children = panel:getChildren()
    for __ , child in ipairs(children) do
        local name = child:getName()
        if name ~= "cbAllFollow"
            and name ~= "btnGiveUp" then
            child:setTouchEnabled(not val)
            child:setOpacity(val and 255 * 0.25 or 255)
        end
    end
end

function M:onGameOver()
    -- body
end

function M:onNoticeCompare(info)
    local loseId = info.succ_id == info.target_id
                and info.source_id
                or info.target_id

    self:playCmpEff(info.source_id , info.target_id , info.succ_id)
end

function M:onCompareFail(info)
    self:showPoker(Game.playerDB:getPlayerUid() , self._DB:getHandCards())
end

------------------------------handle seat start -------------------------------

function M:initSeat(seat , data)
    seat:getChildByName("imgAvatar"):loadTexture(cfg_util.getFacelook(data.facelook))
    seat:getChildByName("txtVip"):setString("VIP" .. data.vip_lv)
    seat:getChildByName("txtName"):setString(data.name)
    seat:getChildByName("txtCoin"):setString(common_util.checkToTenThousand(data.coin))
    seat:getChildByName("txtBet"):setString(data.staked_coin)
    local imgState = seat:getChildByName("imgState")
    if imgState then
        imgState:setVisible(false)
    end
end

local GroupInterval = 0.2  -- 每组间隔
local SingleInterval = 0.0 -- 单个间隔
local FlyTime = 0.9         -- 飞行时间
local Factor = 0.02          --

function M:dispatchPoker()
    local tab = {4 , 5 , 6 , 7 , 1 , 2 , 3}
    local widget = self._widget
    local count = 0
    local x = 1
    local pokerNum = #self._DB:getPlayerList() * 5
    local pokerLst = {}
    local poker
    for i = 1 , pokerNum do
        if i == 1 then
            poker = widget.temp:clone()
            poker:setVisible(true)
        else
            poker = poker:clone()
        end
        table.insert(pokerLst , 1 , poker)
        self:addChild(poker , i)
        poker:moveVec2(0 , -1)
    end
    local count = 0
    for i , index in ipairs(tab) do
        local seat = widget["seat" .. index]
        if seat:isVisible() then
            local panelPoker = seat:getChildByName("panelPoker")
            local org = count * 5
            performWithDelay(self , function( ... )
                self:flyPoker(panelPoker , pokerLst , org)
            end , GroupInterval * count)
            count = count + 1
        end
    end
end

function M:playCmpEff(id1 , id2 , winId)

    local widget = self._widget
    widget.spine:setVisible(true)
    local actor = widget.spine.__actor
    actor:setVisible(true)

    local anim = winId == id1 and "2" or "1"

    actor:changeAnimation(anim , nil , nil , true)

    local p1 = widget.spine:getChildByName("p1")
    local p2 = widget.spine:getChildByName("p2")
    local pos1 = cc.p(p1:getPosition())
    local pos2 = cc.p(p2:getPosition())
    local seat1 = self._idTab[id1]
    local seat2 = self._idTab[id2]
    local panelPoker1 = seat1:getChildByName("panelPoker")
    local panelPoker2 = seat2:getChildByName("panelPoker")

    self:handlePanelPoker(panelPoker1 , pos1)
    self:handlePanelPoker(panelPoker2 , pos2)

end

function M:handlePanelPoker(panelPoker , pos)

    local delay = 0.166
    local flyTime = 0.3333
    local dur = 1.16666
    local fp = panelPoker:clone()

    local orgPos = panelPoker:getWorldPosition()

    fp:setPosition(orgPos)
    local orgScale = fp:getScale()
    self:addChild(fp , 10)
    panelPoker:setVisible(false)

    local res = "subgame/Niuniu/spine/vs/vs2/nn_vs2"
    local actor = require_ex("ui.common.Actor"):new(res)
    fp:addChild(actor)
    actor:changeAnimation("1" , nil , nil , true)
    local v = cc.pSub(pos , orgPos)
    local mb = cc.MoveBy:create(flyTime , v)
    local sb = cc.ScaleBy:create(flyTime , 1.5 / orgScale)
    local sp = cc.Spawn:create(mb , sb)

    local seq = cc.Sequence:create({
        cc.DelayTime:create(delay),
        sp,
        cc.DelayTime:create(dur),
        sp:reverse(),
        cc.CallFunc:create(function(node)
            panelPoker:setVisible(true)
            node:removeFromParent()
        end)
    })
    fp:runAction(seq)
end

function M:flyPoker(panelPoker , pokerLst , org)
    local dur = FlyTime
    local delay = SingleInterval
    local children = panelPoker:getChildren()
    local widget = self._widget
    for i = 1 , 5 do
        local target = children[6 - i]
        local targetPos = target:getWorldPosition()

        local index = org + i
        local poker = pokerLst[index]
        local sPos = cc.p(poker:getPosition())
        local moveTo = getCurveAction(dur , sPos , targetPos , Factor)
        local callfunc = cc.CallFunc:create(function(node)
            node:removeFromParent()
            target:setVisible(true)
        end)
        local seq = {}
        if i > 1 then
            table.insert(seq , cc.DelayTime:create(delay * (i - 1)))
        end
        table.insert(seq , cc.Spawn:create(moveTo , cc.ScaleTo:create(dur , target:getParent():getScale())))
        table.insert(seq , callfunc)
        poker:runAction(cc.Sequence:create(seq))
    end
end

function M:flyChip(seat)
    breakCountDown(seat.pg)
    local widget = self._widget
    local sPos = seat:getWorldPosition()
    local sp = cc.Sprite:create(chipRes)
    sp:setPosition(sPos)
    self:addChild(sp)
    local x = 200
    local y = 100
    local sPos = cc.p(common_util.rand(display.cx - x , display.cx + x),
                      common_util.rand(display.cy - y , display.cy + y))
    table.insert(self._chips , sp)
    sp:runAction(cc.MoveTo:create(0.3 , sPos))
end

function M:onWait(seat , remainTime , callback)
    remainTime = remainTime or waitTime
    autoCountDown(seat.pg , {
        time = waitTime,
        remainTime = remainTime,
        callback = callback
    })
end

function M:showPoker(uid , cardsData)
    local pokerData = cardsData.cards
    local cardPoint = cardsData.niu
    local seat = self._idTab[uid]
    local panelPoker = seat:getChildByName("panelPoker")
    for i , child in ipairs(panelPoker:getChildren()) do
        if child:getName() ~= "imgPoint" then
            setPokerShow(child , true)
            local data = pokerData[i]
            if data then
                setColorAndNum(child , data.color , data.size)
            end
        end
    end
    local imgPoint = panelPoker:getChildByName("imgPoint")
    local res = self._ctrler:getCardsPointRes(cardPoint)
    imgPoint:loadTexture(res)
    imgPoint:setVisible(true)
end

function M:runFlyTxt(seat , str , index)

    index = index or 1
    local flyTxt = seat:getChildByName("flyTxt")
    flyTxt:setVisible(true)
    local ft = flyTxt:getChildByName("flyTxt" .. index):clone()
    flyTxt:addChild(ft)
    local y = 25
    local t = 0.6
    ft:setVisible(true)
    ft:setString(str)
    local seq = cc.Sequence:create({
        cc.Spawn:create({
            cc.MoveBy:create(t , cc.p(0 , 25)),
            cc.FadeOut:create(t)
        }),
        cc.RemoveSelf:create()
    })
    ft:runAction(seq)
end

function M:onResult(playCardList)
    local winId = self._DB:getWinner()
    local winSeat = self._idTab[winId]
    local targetPos = cc.p(winSeat:getPosition())
    for __ , chip in ipairs(self._chips) do
        local moveTo = cc.MoveTo:create(0.3 , targetPos)
        local seq = cc.Sequence:create(moveTo , cc.RemoveSelf:create())
        chip:runAction(seq)
    end
    self:refreshOpPanel()
    -- for id , seat in pairs(self._idTab) do
    --     local panelPoker = self:getChildByName("panelPoker")
    --     local imgP = panelPoker:getChildByName("imgPoint")
    -- end

    for __ , val in ipairs(playCardList) do
        local uid = val.player_id
        self:showPoker(uid , val.hand_cards)
    end

    for uid , seat in pairs(self._idTab) do
        breakCountDown(seat.pg)
        if self._DB:getPlayerBet(uid) ~= PlayerState.Idle then
            if uid == winId then
                local bet = self._DB:getTotalBet()
                self:runFlyTxt(seat , "+" .. bet)
            else
                local bet = self._DB:getPlayerBet(uid)
                self:runFlyTxt(seat , "-" .. bet , 2)
            end
        end
    end
    self._chips = {}
end

------------------------------handle seat end   -------------------------------

---------------------------base operate start----------------------------

function M:destroy()
    self._ctrler:reqExitGame(function()
        Game:openGameWithIdx(SCENCE_ID.PLATEFORM, MoreGameView)
    end)
    UIer.destroy(self)
end

function M:onTrans(sender , event)
    local widget = self._widget
end

function M:onSetting(sender , event)

end

function M:onRecharge(sender , event)

end

function M:onRedPack(sender , event)
    self:playCmpEff(16456 , Game.playerDB:getPlayerUid() , 16456)
end

function M:onRanking(sender , event)
    -- body
end

function M:onHelp(sender , event)
    -- body
end

function M:onChat(sender , event)
    self:openChatView()
end

---------------------------base operate end----------------------------

---------------------------game operate start----------------------------
function M:onAllFollow(event)
    self:tryToBet()
end

function M:onReady(sender , event)
    self._ctrler:reqReady()
end

function M:onFollow(sender , event)

    local curBet = self._DB:getCurBet()
    local coin = Game.playerDB:getPlayerCoin()
    local bet = coin > curBet and curBet or coin
    self._ctrler:reqBet(bet , function(info)

    end)
end

function M:onAddX(sender , event)
    local curBet = self._DB:getCurBet()
    local coin = Game.playerDB:getPlayerCoin()
    local bet = curBet * 2
    bet = coin > bet and bet or coin
    self._ctrler:reqBet(bet , function(info)

    end)
end

function M:onAddXX(sender , event)
    local curBet = self._DB:getCurBet()
    local coin = Game.playerDB:getPlayerCoin()
    local bet = curBet * 4
    bet = coin > bet and bet or coin
    self._ctrler:reqBet(bet , function(info)

    end)
end

function M:onLook(sender , event)
    local widget = self._widget
    self._ctrler:reqLook(function(hand_cards)
        local cardList = hand_cards.cards
        local panelPoker = widget.seat4:getChildByName("panelPoker")
        local pokerLst = panelPoker:getChildren()
        for i , poker in ipairs(pokerLst) do
            local card = cardList[i]
            setColorAndNum(poker , card.color , card.size)
        end
        turnPoker(pokerLst)
    end)
end

function M:onCompare(sender , event)

    self._ctrler:reqCompare(function()
        for uid , seat in pairs(self._idTab) do
            local state = self._DB:getPlayerState(uid)
            if uid ~= Game.playerDB:getPlayerUid()
                and (state == PlayerState.Unlooked or state == PlayerState.Looked) then
                if seat:getChildByName("pointAnim") == nil then
                    print(uid)
                end
                seat:getChildByName("pointAnim"):setVisible(true)
            end
            print("show pointAnim")
        end
        self._bCmp = true
    end)

end

function M:onGiveUp(sender , event)
    self._ctrler:reqGiveUp()
end

function M:onShow(sender , event)
    self._ctrler:reqShow()
end

function M:onAllIn(sender , event)
    self._ctrler:reqAllIn()
end

function M:onSeatClicked(sender , event)
    if not self._bCmp then
        return
    end
    local widget = self._widget

    table.walk(self._idTab, function(seat , uid)
        if uid ~= Game.playerDB:getPlayerUid() then
            seat:getChildByName("pointAnim"):setVisible(false)
        end
    end)
    if self._delayAction then
        self:stopAction(self._delayAction)
        self._delayAction = nil
    end
    self._ctrler:reqCmpTarget(sender.__id , function()
        self._bCmp = false
    end)
end
---------------------------game operate end----------------------------

function M:setSeatLookOn(seat , bLookOn)
    local g1 = {
        "imgPanel",
        "imgAvatar",
        "Image_3",
        "imgIcon",
        "txtVip",
        "txtName",
        "txtCoin"
    }
    local opacity = bLookOn and 127 or 255
    for __ , name in ipairs(g1) do
        local node = seat:getChildByName(name)
        if node then
            node:setOpacity(opacity)
        end
    end

    local g2 = {
        "Image_4",
        "txtBet",
        "panelPoker",
    }
    for __ , name in ipairs(g2) do
        local node = seat:getChildByName(name)
        if node then
            node:setVisible(not bLookOn)
        end
    end
end


return M