
local UIer = require_ex("ui.common.UIer")
local BullUI = class("BullUI", UIer)

local GetBox = require_ex("ui.common.GetBox")
local Actor = require_ex("ui.common.Actor")
local DefaultHead = "subgame/bull/button/BaiRenNiuNiu_BattleButton_06.png"
local MarqueeSpeed = 50
local ChipsLimit = 50
local CARD_PAD = 30
local PICKUP_PAD = 20
local SpineChipSelect = {res="subgame/bull/spine/bairenniuniu_choumaxuanzhong", ani="choumaxuanzhong", isLoop=true}
local SpineTimeCount = {res="subgame/bull/spine/xyx_naozhong", ani="naozhong", isLoop=true}
-- local EffChips = "ManyNode"
local EffPokeDraw = "unfold" -- flop/reveal/unfold

function BullUI:ctor()
    UIer.ctor(self)
    self:registerNodeEvent()
    self:registerListenEvent()
    self:init()
end

function BullUI:init( )
    self._spine = {}
    self._SpineBanner = {
        bet_start = {res="subgame/bull/spine/bairenniuniu_kaishixiazhu", zorder=100, x=display.cx, y=display.cy, isLoop=false, ani="animation",
                    handle = {
                        [sp.EventType.ANIMATION_COMPLETE] = handler(self, self.spineBannerCompleteLsn),
                    }},
        bet_stop = {res="subgame/bull/spine/bairenniuniu_tingzhixiazhu", zorder=100, x=display.cx, y=display.cy, isLoop=false, ani="animation",
                    handle = {
                        [sp.EventType.ANIMATION_COMPLETE] = handler(self, self.spineBannerCompleteLsn),
                    }},
    }
    self._BindWidget = {
        ["btn_back"] = {handle = handler(self, self.onBackClicked)},
        ["btn_help"] = {handle = handler(self, self.onHelp)},
        ["btn_set"] = {handle = handler(self, self.onSet)},
        ["panel_bet/btn_record"] = {key = "btn_record", handle = handler(self, self.onRecord)},
        ["panel_center/btn_banker"] = {key = "btn_banker",handle = handler(self, self.onBankerList)},
        ["panel_bet/btn_recharge"] = {key = "btn_recharge", handle = handler(self, self.onRecharge)},
        ["panel_center/img_other"] = {key = "img_other"},
        ["panel_center/panel_draw_b"] = {key = "panel_draw_b"},
        -- 房间信息
        ["panel_roominfo/Text_banker"] = {key = "txt_banker_wait"},
        ["panel_roominfo/Text_cost"] = {key = "txt_banker_cost"},
        -- 个人信息
        ["panel_bet/panel_myinfo"] = {key = "panel_myinfo"},
        ["panel_bet/panel_myinfo/img_icon"] = {key = "my_img_icon"},
        ["panel_bet/panel_myinfo/Text_name"] = {key = "my_txt_name"},
        ["panel_bet/panel_myinfo/Text_gold"] = {key = "my_txt_gold"},
        -- 奖池布局
        ["panel_center/panel_bet_1"] = {key = "panel_bet_1", tag = 1, handle = handler(self, self.onTouchBet)},
        ["panel_center/panel_bet_2"] = {key = "panel_bet_2", tag = 2, handle = handler(self, self.onTouchBet)},
        ["panel_center/panel_bet_3"] = {key = "panel_bet_3", tag = 3, handle = handler(self, self.onTouchBet)},
        ["panel_center/panel_bet_4"] = {key = "panel_bet_4", tag = 4, handle = handler(self, self.onTouchBet)},
        -- 庄家信息
        ["panel_center/panel_binfo"] = {key = "panel_binfo", tag = 0, handle = handler(self, self.onTouchBanker)},
        ["panel_center/panel_binfo/img_head"] = {key = "img_bhead"},
        ["panel_center/panel_binfo/Text_name"] = {key = "txt_bname"},
        ["panel_center/panel_binfo/Text_gold"] = {key = "txt_bgold"},
        ["panel_center/panel_binfo/Image_116"] = {key = "img_bnumbg"},
        ["panel_center/panel_binfo/Text_num"] = {key = "txt_bnum"},
        -- 有钱人
        ["panel_center/panel_rich_1"] = {key = "panel_rich_1", tag = 1, handle = handler(self, self.onTouchSeat)},
        ["panel_center/panel_rich_2"] = {key = "panel_rich_2", tag = 2, handle = handler(self, self.onTouchSeat)},
        ["panel_center/panel_rich_3"] = {key = "panel_rich_3", tag = 3, handle = handler(self, self.onTouchSeat)},
        ["panel_center/panel_rich_4"] = {key = "panel_rich_4", tag = 4, handle = handler(self, self.onTouchSeat)},
        ["panel_center/panel_rich_5"] = {key = "panel_rich_5", tag = 5, handle = handler(self, self.onTouchSeat)},
        ["panel_center/panel_rich_6"] = {key = "panel_rich_6", tag = 6, handle = handler(self, self.onTouchSeat)},
        -- 押注筹码区
        ["panel_bet"] = {},
        -- ["panel_bet/Image_select"] = {key = "img_bet_select"},
        ["panel_bet/Image_betted"] = {key = "img_betted"},
        ["panel_bet/Button_bet"] = {key = "btn_bet_auto", handle = handler(self, self.onBetAuto)},
        ["panel_bet/Button_bet_1"] = {key = "btn_bet1", tag = 1, handle = handler(self, self.onBet)},
        ["panel_bet/Button_bet_2"] = {key = "btn_bet2", tag = 2, handle = handler(self, self.onBet)},
        ["panel_bet/Button_bet_3"] = {key = "btn_bet3", tag = 3, handle = handler(self, self.onBet)},
        ["panel_bet/Button_bet_4"] = {key = "btn_bet4", tag = 4, handle = handler(self, self.onBet)},
        ["panel_bet/Button_bet_5"] = {key = "btn_bet5", tag = 5, handle = handler(self, self.onBet)},
        ["panel_bet/Image_fg"] = {key = "img_bet_fg"},
        -- 倒计时
        ["panel_center/panel_time"] = {key = "panel_time"},
        ["panel_center/panel_time/Image_22"] = {key = "img_time"},
        ["panel_center/panel_time/txt_state"] = {key = "txt_state"},
        ["panel_center/panel_time/txt_time"] = {key = "txt_time"},
        -- 查看有钱人信息
        ["panel_viewinfo"] = {},
        ["panel_viewinfo/Text_name"] = {key = "view_txt_name"},
        ["panel_viewinfo/Text_vip"] = {key = "view_txt_vip"},
        ["panel_viewinfo/Text_uid"] = {key = "view_txt_uid"},
        ["panel_viewinfo/Text_coin"] = {key = "view_txt_coin"},

        ["node_poke"] = {},
        ["panel_marquee"] = {},
        ["panel_marquee/Panel_container"] = {key = "marquee_container"},
        ["panel_marquee/Text_tip"] = {key = "marquee_tip"},
        ["temp_fly_coin"] = {},
        ["temp_poke"] = {},
        ["temp_rate_text"] = {},

    }

    self._widgets = {}
    self._allPoke = {}
    self._drawPanel = {}
    self._allChipTxt = {}
    self._myChipTxt = {}
    self._curBetIdx = 1
    self._autoBet = false
    self._autoBetted = false
    self._savedMyChip = 0
    self._myChipLimit = math.floor(Game.playerDB:getPlayerCoin() * 0.2)

    self._lotStep = 0
    self._lastCT = 300

    -- 存放桌面所有筹码
    self._allChips = {{},{},{},{}}
    self._colorChips = {}

    self._getbox_queue = require("lib.Queue").new()
end

function BullUI:initCanOpenView()
    if Game:funcIsOpen(GAME_OPEN_FUNC_CFG.RECHARGE)  == false then
        self._widgets.btn_recharge:setVisible(false)
    end
end

function BullUI:checkCardPickUp(data, list)
    for i,v in ipairs(list) do
        if data.color == v.color and data.size == v.size then
            return i
        end
    end
    return nil
end

function BullUI:initViews(initLayer)
    if initLayer == nil then
        local uiNode = createCsbNode("subgame/bull/bull_main.csb")
        self:addChild(uiNode, 1)

        bindWidgetList(uiNode, self._BindWidget, self._widgets)

        self._marqueeSize = self._widgets.marquee_container:getContentSize()
        self._betChipY0 = self._widgets.btn_bet2:getPositionY()
        self._betChipY1 = self._widgets.btn_bet1:getPositionY()

        for i=1,5 do
            local labTitle = self._widgets["btn_bet"..i]:getChildByName("fnt_btnAdd")
            if labTitle then
                self._colorChips[i] = {label = labTitle, color = labTitle:getTextColor()}
            end
        end

        self._spineChipSelect = require_ex("ui.common.Actor"):new(SpineChipSelect.res, SpineChipSelect)
        local x, y = self._widgets.btn_bet1:getPosition()
        self._spineChipSelect:setPosition(x, y)
        self._widgets.panel_bet:addChild(self._spineChipSelect, 10)

        self._widgets.img_bet_fg:setLocalZOrder(11)

        CARD_PAD = self._widgets.temp_poke:getTag()

        if SpineTimeCount then
            self._spineTimecount = Actor:new(SpineTimeCount.res, SpineTimeCount)
            local size = self._widgets.img_time:getContentSize()
            self._spineTimecount:setPosition(size.width / 2, size.height / 2)
            self._widgets.img_time:addChild(self._spineTimecount)
            self._spineTimecount:setVisible(false)
        end
    end

    self:initRoomInfo()
    self:initMyInfo()
    self:initRichPanel()
    self:initPondBetList()
    self:initBankerInfo()
    self:initBetChips()
    self:onBankerListCallback(true)
    self:initCanOpenView()
    -- self:onSyncStateAndTime()
end

-- 房间信息
function BullUI:initRoomInfo(bankerWaiting, bankerCost)
    self._widgets.txt_banker_wait:setString(checknumber(bankerWaiting))
    self._widgets.txt_banker_cost:setString(common_util.getShortString(checknumber(bankerCost)))
end

function BullUI:updateRoomInfo(bankerWaiting, bankerCost)
    if type(bankerWaiting) == "number" then
        self._widgets.txt_banker_wait:setString(bankerWaiting)
    end
    if type(bankerCost) == "number" then
        self._widgets.txt_banker_cost:setString(common_util.getShortString(checknumber(bankerCost)))
    end
end

-- 个人信息
function BullUI:initMyInfo()
    local facelook = Game.playerDB:getFacelook()
    local icon = cfg_util.getFacelook(facelook)
    fitIconSize(self._widgets.my_img_icon, icon)
    self._widgets.my_txt_name:setString(Game.playerDB:getPlayerNick())
    self._widgets.my_txt_gold:setString(common_util.getShortString(Game.playerDB:getPlayerCoin()))
end

function BullUI:updateMyInfo()
    local myGold = Game.playerDB:getPlayerCoin()
    self._widgets.my_txt_gold:setString(common_util.getShortString(myGold))
    if Game.betMng:getState() ~= BetState.betting then
        self._myChipLimit = math.floor(myGold * 0.2)
    end
end

-- 有钱人信息
function BullUI:initRichPanel(idx, isUpdate)
    local i, seatInfo, img_head, txt_gold, txt_name = idx or 1
    local panel = self._widgets["panel_rich_"..i]
    while panel do
        img_head = panel:getChildByName("img_head")
        txt_gold = panel:getChildByName("Text_gold")
        txt_name = panel:getChildByName("Text_name")
        seatInfo = Game.bullDB:getPlayerList(i)
        if seatInfo then
            local icon = FacelookConfig.icon(checknumber(seatInfo.facelook))
            if icon then
                fitIconSize(img_head, icon)
            end
            txt_name:setString(seatInfo.name)
            txt_gold:setString(seatInfo.coin)
        elseif isUpdate then
            fitIconSize(img_head, DefaultHead, 1)
            txt_name:setString(stringCfgCom.content("dianji_ruzuo"))
            txt_gold:setString("0")
        end

        if idx then
            panel = nil
        else
            i = i + 1
            panel = self._widgets["panel_rich_"..i]
        end
    end
end

function BullUI:updatePlayerList(idx)
    self:initRichPanel(idx, true)
end

function BullUI:insertToAllChip(list, chip)
    table.insert(list, chip)
    if ChipsLimit > 0 and #list > ChipsLimit then
        chip = table.remove(list, 1)
        chip:removeFromParent(true)
    end
end

-- 奖池下注列表
function BullUI:initPondBetList()
    local i = 1
    local panel = self._widgets["panel_bet_"..i]
    while panel do
        local panDraw = panel:getChildByName("panel_draw")
        local txtAChip = panel:getChildByName("Text_allbet")
        local txtMChip = panel:getChildByName("Text_mybet")
        txtAChip:setString(0)
        txtAChip:setTag(0)
        txtMChip:setString(0)
        txtMChip:setTag(0)
        txtMChip:setVisible(false)
        self._drawPanel[i] = panDraw
        self._allChipTxt[i] = txtAChip
        self._myChipTxt[i] = txtMChip

        i = i + 1
        panel = self._widgets["panel_bet_"..i]
    end
    self._drawPanel[0] = self._widgets.panel_draw_b
end

function BullUI:updatePondBetList()
    local betInfo = Game.bullDB:getAllBetData() or {}
    for i, v in ipairs(betInfo) do
        local idx = v.area or i
        if self._allChipTxt[idx] then
            local curr = self._allChipTxt[idx]:getTag()
            local chipList = Game.bullDB:getChipList()
            self._allChipTxt[idx]:setString(common_util.getShortString(v.coin))
            -- scrollToNum(self._allChipTxt[idx], v.coin, nil, nil, 100)
            self._allChipTxt[idx]:setTag(v.coin)
            if curr < v.coin and v.coin - curr >= chipList[1] then
                local toNode = self._allChipTxt[idx]:getParent()
                local chipIdx = #chipList
                while v.coin - curr < chipList[chipIdx] do
                    chipIdx = chipIdx - 1
                end
                local chip = self:flyChip(self._widgets.img_other, toNode, nil, common_util.randomFloat(0, 0.9, 2), chipIdx)
                self:insertToAllChip(self._allChips[idx], chip)
                -- local chipList = common_util.packageList(v.coin - curr, Game.bullDB:getChipList(), 5)
                -- for _, chipType in ipairs(chipList) do
                --     local chip = self:flyChip(self._widgets.img_other, toNode, nil, common_util.randomFloat(0, 0.9, 2), chipType)
                --     self:insertToAllChip(self._allChips[idx], chip)
                -- end
            end
        end
    end
end

-- 庄家信息
function BullUI:initBankerInfo()
    local bankerInfo = Game.bullDB:getBankerInfo()
    self._widgets.txt_bname:setString(tostring(bankerInfo.name))
    self._widgets.txt_bnum:setString(checknumber(bankerInfo.left_times))
    self._widgets.txt_bgold:setString(common_util.getShortString(bankerInfo.coin))
    local icon = FacelookConfig.icon(checknumber(bankerInfo.facelook))
    if icon then
        fitIconSize(self._widgets.img_bhead, icon)
    end
    -- 电脑庄不显示名字和金币和连庄次数
    if bankerInfo.player_id == 1 then
        self._widgets.txt_bname:setVisible(false)
        self._widgets.txt_bgold:setVisible(false)
        self._widgets.txt_bnum:setVisible(false)
        self._widgets.img_bnumbg:setVisible(false)
    else
        self._widgets.txt_bname:setVisible(true)
        self._widgets.txt_bgold:setVisible(true)
        self._widgets.txt_bnum:setVisible(true)
        self._widgets.img_bnumbg:setVisible(true)
    end
    -- if bankerInfo.player_id == Game.playerDB:getPlayerUid() then
    --     self._widgets.my_txt_gold:setString(common_util.getShortString(bankerInfo.coin))
    -- end
end

function BullUI:updateBankerInfo()
    self:updateMyInfo()
    self:initBankerInfo()
end

-- 押注筹码
function BullUI:initBetChips(ignoreCheckAuto)
    local chipList = Game.bullDB:getChipList()
    local isBanker = Game.bullDB:isBanker()
    local maxChipIdx = math.max(1, self._curBetIdx)
    for i=#chipList,1,-1 do
        local widgets = self._widgets["btn_bet"..i]
        if widgets then
            if self._myChipLimit < chipList[i] then
                maxChipIdx = i - 1
                widgets:setEnabled(false)
                if self._colorChips[i] then
                    self._colorChips[i].label:setTextColor(cc.c3b(77,77,77))
                end
            else
                widgets:setEnabled(true and isBanker == false)
                if self._colorChips[i] then
                    self._colorChips[i].label:setTextColor(self._colorChips[i].color)
                end
            end
        end
    end
    if self._curBetIdx == 0 or self._curBetIdx > maxChipIdx then
        self:changeBetChip(maxChipIdx)
    elseif isBanker then
        self:changeBetChip(0)
    else
        self:changeBetChip(math.max(1, self._curBetIdx), true)
    end
    if not ignoreCheckAuto then
        if self._autoBet and self._savedMyChip > self._myChipLimit then
            self._autoBet = false
        end
        self._widgets.img_betted:setVisible(self._autoBet)
    end
    self._spineChipSelect:setVisible(self._widgets["btn_bet1"]:isEnabled())
    if isBanker then
        self._lastCT = 500
    end
end

function BullUI:updateBetChips(ignoreCheckAuto)
    self:initBetChips(ignoreCheckAuto)
end

function BullUI:updateTimePanel(state, timeleft)
    self._widgets.txt_state:setString(stringCfgCom.content(BetStateStr[state]))
    self._widgets.txt_time:setString(math.max(1, timeleft))
    if timeleft > 5 or state ~= BetState.betting then
        self._widgets.txt_time:setColor(cc.c3b(255,255,255))
        if self._spineTimecount then
            self._spineTimecount:setVisible(false)
            self._widgets.img_time:setOpacity(255)
        end
    elseif timeleft > 1 then
        if self._spineTimecount then
            self._spineTimecount:setVisible(true)
            self._widgets.img_time:setOpacity(0)
        end
        if timeleft < 4 then
            common_util.playSoundConfig(self, "countdown")
        end
        self._widgets.txt_time:setColor(cc.c3b(255,255,0))
    else
        if self._spineTimecount then
            self._spineTimecount:setVisible(true)
            self._widgets.img_time:setOpacity(0)
        end
        self._widgets.txt_time:setColor(cc.c3b(255,74,83))
        if timeleft == 1 then
            common_util.playSoundConfig(self, "countdown2")
            self:tipSpineBanner("bet_stop")
        end
    end
end

--------------------------
function BullUI:refreshListView(info)
    self:updateSeatInfo()
    self:onSyncStateAndTime()
    self:updateRoomInfo(info.banker_len, info.banker_need_coin)
end

function BullUI:initlistView(initLayer, data)
    Game.bullCom:onBankerList(true)
    Game.bullCom:onSync(true)
end

function BullUI:registerNodeEvent()
    local eventDispatcher = self:getEventDispatcher()
    local function onEnter()
        UIer.onEnter(self)
        common_util.playSoundConfig(self)
    end

    local function onExit()
        UIer.onExit(self)
        common_util.playMusic(SoundConfig.file("BACK_HALL"), true)
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

function BullUI:registerListenEvent()
    self:listenCustomEvent(GlobalEvent.GAME_MONEY_MODIFY_EVENT, handler(self, self.onGoldChanged))
    self:listenCustomEvent(BetEvent.BET_STATE_CHANGE_EVENT, handler(self, self.onStateChanged))
    self:listenCustomEvent(BetEvent.BET_TIME_CHANGE_EVENT, handler(self, self.onTimeChanged))
    self:listenCustomEvent(cc.EVENT_COME_TO_FOREGROUND, handler(self, self.onComeToForeGround))
    self:listenCustomEvent(cc.EVENT_COME_TO_BACKGROUND, handler(self, self.onComeToBackGround))
end

-------------------------------
function BullUI:onKickOut(msg)
    self:destroy()
    Game.bullCom:onExit()
    Game:openGameWithIdx(SCENCE_ID.PLATEFORM, MoreGameView)
    if msg then
        showConfirmTip({
            blankClose = true,
            sTip = msg,
            boBtn2NotVisible = true,
        })
    end
end

function BullUI:onBackClicked()
    if SYS_LIMITED then
        local quickEnable = true
        for i,v in ipairs(self._myChipTxt) do
            if v:isVisible() then
                quickEnable = false
                break
            end
        end
        if not quickEnable and Game.betMng:getState() > BetState.lottery then
            quickEnable = true
        end
        if not quickEnable or Game.bullDB:isBanker() then
            self:showBanner(stringCfgCom.content("exit_limit"))
            common_util.playSoundConfig("all", "error")
            return
        end
    end
    common_util.playSoundConfig("all", "back")
    showConfirmTip({fontSize=45}, function()
        self:removeAllChip()
        self:onKickOut()
    end)
end

function BullUI:onHelp()
    require("games.brnn.views.BullRuleUI"):new():addToScene(UIZorder.UILayer-10)
end

function BullUI:onSet()
    Game.settingCom:openSettingUi("subgame/bull/bull_setting.csb", 5)
end

function BullUI:onRecord()
    require("games.brnn.views.BullRecordUI"):new():addToScene(UIZorder.UILayer-10)
end

function BullUI:onBankerListCallback(ignoreLayer, tipBeBanker)
    if Game.bullDB:getMyBankerIndex() or tipBeBanker or Game.bullDB:isBanker(true) then
        self._widgets.btn_banker:setTitleText(stringCfgCom.content("anim_title_banker_down"))
    else
        self._widgets.btn_banker:setTitleText(stringCfgCom.content("anim_title_banker_up"))
    end
    if not ignoreLayer then
        self._bankerListUI = require("games.brnn.views.BullBankerUI"):new(function ()
            self._bankerListUI = nil
            self:onBankerListCallback(true)
        end):addToScene(UIZorder.UILayer-10)
    elseif not tolua.isnull(self._bankerListUI) then
        self._bankerListUI:onBackClicked()
        self._bankerListUI = nil
    end
    if tipBeBanker then
        self:showBanner(stringCfgCom.content("bull_bankering"))
    end
end

function BullUI:onBankerList(sender)
    common_util.playSoundConfig(self, sender)
    if sender and sender:getTitleText() == stringCfgCom.content("anim_title_banker_down") then
        local function _bankerDown()
            Game.bullCom:onBanker(1, function ()
                if Game.bullDB:isBanker() then
                    Game:tipMsg(stringCfgCom.content("bull_banker_down2"))
                else
                    Game:tipMsg(stringCfgCom.content("bull_banker_down"))
                end
                sender:setTitleText(stringCfgCom.content("anim_title_banker_up"))
                Game.bullDB:setBankerOn(1)
            end)
        end
        if Game.bullDB:isBanker(true) then
            local tip = stringCfgCom.content("bull_banker_down_tip")
            showConfirmTip(tip, _bankerDown)
        else
            _bankerDown()
        end
    else
        Game.bullCom:onBankerList()
    end
end

function BullUI:onRecharge()
    print("onRecharge")

    Game.rechargeCom:onEnterRechargeUI()
end

function BullUI:onBetCallback(info)
    Game.bullDB:appendSavedBet(info.yazhu_list)
    for i,v in ipairs(info.yazhu_list) do
        local area = v.area or v[1] or 1
        local coin = v.coin or v[2] or 1000
        if coin > 0 then
            local chipNode, chipType = self:getBetChipNode(coin)
            local chip = self:flyChip(chipNode, self:getPondBetNode(area), coin, nil, chipType)
            self:insertToAllChip(self._allChips[area], chip)
            self._myChipLimit = self._myChipLimit - coin
        end
    end
    self:updateBetChips(true)
    self._lastCT = 300
end

function BullUI:onBetAuto(sender)
    common_util.playSoundConfig(self, "Button_bet")
    if Game.bullDB:getSavedBetCount() == 0 and Game.bullDB:getSavedBetCount(2) == 0 then
        self:showBanner(stringCfgCom.content("bull_auto_limit"))
    else
        self._autoBet = not self._autoBet
        self._widgets.img_betted:setVisible(self._autoBet)
    end
end

function BullUI:autoBetIn()
    local savedBet = Game.bullDB:getSavedBet()
    local temp = {}
    for i,v in ipairs(savedBet) do
        temp[i] = {v.area, v.coin}
    end
    Game.bullCom:onBet(temp)
end

function BullUI:onBet(sender)
    -- if Game.betMng:getState() == BetState.betting then
        self:changeBetChip(sender:getTag())
    -- end
end

function BullUI:changeBetChip(chipIdx, force)
    if not chipIdx or (self._curBetIdx == chipIdx and not force) then return end
    local chipNode, x = self._widgets["btn_bet"..self._curBetIdx]
    if chipNode then
        x = chipNode:getPositionX()
        chipNode:stopAllActions()
        chipNode:runAction(cc.MoveTo:create(0.1, cc.p(x, self._betChipY0)))
    end
    chipNode = self._widgets["btn_bet"..chipIdx]
    if chipNode then
        x = chipNode:getPositionX()
        self._spineChipSelect:setPosition(x, self._betChipY1)
        chipNode:stopAllActions()
        chipNode:runAction(cc.MoveTo:create(0.1, cc.p(x, self._betChipY1)))
    end
    self._curBetIdx = chipIdx
end

function BullUI:onTouchBet(sender, eventType)
    if Game.betMng:getState() == BetState.betting and self._curBetIdx > 0 then
        if Game.betMng:getTimeLeft() > 0 then
            -- common_util.playSoundConfig(self, "chip", nil, true)
            local betToIdx = sender:getTag()
            local chips = Game.bullDB:getChipList(self._curBetIdx)
            Game.bullCom:onBet({{betToIdx, chips}})
        end
    end
end

function BullUI:onTouchBanker(sender, eventType)
    local seatPlayer = Game.bullDB:getBankerInfo()
    if seatPlayer and seatPlayer.player_id and seatPlayer.player_id ~= 1 then
        self:viewRicher(seatPlayer, sender)
    end
    common_util.playSoundConfig("all", "click")
end

function BullUI:onTouchSeat(sender, eventType)
    local seatIdx = sender:getTag()
    local seatPlayer = Game.bullDB:getPlayerList(seatIdx)
    if seatPlayer and seatPlayer.player_id then
        if seatPlayer.player_id == Game.playerDB:getPlayerUid() then
            -- 起立
            Game.bullCom:onStandUp(seatIdx)
        elseif not Game:funcIsOpen(GAME_OPEN_FUNC_CFG.IOS_CHECK) then
            -- 查看在座玩家信息
            -- Game.bullCom:onViewPlayerInfo(seatPlayer.player_id)
            self:viewRicher(seatPlayer, sender)
        end
    else
        -- 空座入座
        Game.bullCom:onSitDown(seatIdx)
    end
    common_util.playSoundConfig("all", "click")
end

-------------- 数据更新监听 --------------
function BullUI:onComeToForeGround()
    if self._background then
        self._background = false
        self:removeAllChip()
        self:destroy()
        Game:openGameWithIdx(SCENCE_ID.GAME1)
    end
end

function BullUI:onComeToBackGround()
    if not self._background then
        self._background = true
        Game:destroyWaitUI()
        -- Game.bullCom:onExit()
    end
end

-- 更新同步信息（20011）
function BullUI:updateSeatInfo(info)
    self:updateBankerInfo()
    self:updatePlayerList()
end

function BullUI:updateSeatBet(info)
    info = info or Game.bullDB:getSeatBetInfo()
    local chipList = Game.bullDB:getChipList()
    for k, betList in pairs(info) do
        local seat = self:getSeatByPid(k)
        if seat and self._widgets["panel_rich_"..seat] then
            for i,v in ipairs(betList) do
                if checknumber(v.add) >= chipList[1] then
                    local chipIdx = #chipList
                    while v.add < chipList[chipIdx] do
                        chipIdx = chipIdx - 1
                    end
                    v.add = 0
                    local chip = self:flyChip(self._widgets["panel_rich_"..seat], self:getPondBetNode(i), nil,
                                            common_util.randomFloat(0.05, 0.2, 2), chipIdx)
                    self:insertToAllChip(self._allChips[i], chip)
                end
            end
        end
    end
end

-- 金币更新
function BullUI:onGoldChanged()
    self:updateMyInfo()
    self:updateBetChips()
end

-- 状态更新
function BullUI:onStateChanged(event)
    self:updateTimePanel(event.data.state, event.data.timeleft)
    if event.data.state == BetState.waitbet then
        self:doStateWaitbet()
    elseif event.data.state == BetState.betting then
        self:doStateBetting()
    elseif event.data.state == BetState.lottery then
        self:doStateLottery()
    elseif event.data.state == BetState.reward then
        if self._rewardState == 1 then
            self:doStateReward()
        else
            self._rewardState = 1
        end
    end
end

-- 计时器更新
function BullUI:onTimeChanged(event)
    self:updateTimePanel(event.data.state, event.data.timeleft)
    if event.data.state == BetState.betting then
        Game.bullCom:onSync()
    end
    -- 三分钟不下注自动退出
    if self._lastCT < 400 then
        self._lastCT = math.max(0, self._lastCT - 1)
        if self._lastCT == 0 then
            self:onKickOut(stringCfgCom.content("bull_kick"))
        end
    end
    -- 宝箱掉落
    if self._getbox_queue and not self._getbox_queue:empty() then
        self:showObtainBox(self._getbox_queue:pop())
    end
end

function BullUI:onSyncStateAndTime(state, timeleft)
    state = state or Game.betMng:getState()
    timeleft = timeleft or Game.betMng:getTimeLeft()

    self:updateTimePanel(state, timeleft)

    if not self._betIn and state > BetState.betting then
        self:showBanner(stringCfgCom.content("bull_waiting"), true)
    else
        self._betIn = true
        if state == BetState.lottery then
            self:doStateLottery(timeleft)
        elseif state == BetState.reward then
            if self._rewardState == 1 then
                self:doStateReward()
            else
                self._rewardState = 1
            end
        end
    end
end

function BullUI:viewRicher(richer, seatNode)
    if type(richer) ~= "table" or not seatNode then return end

    local coin = richer.coin
    local seatBetInfo = Game.bullDB:getSeatBetInfo(richer.player_id)
    if seatBetInfo then
        for i,v in ipairs(seatBetInfo) do
            coin = coin - v.coin
        end
    end

    self._widgets.view_txt_name:setString(richer.name)
    self._widgets.view_txt_vip:setString(richer.vip_lv)
    self._widgets.view_txt_uid:setString(richer.special_id)
    self._widgets.view_txt_coin:setString(common_util.getShortString(coin))

    local anchor = seatNode:getAnchorPoint()
    local seatSize = seatNode:getContentSize()
    local pos = seatNode:convertToWorldSpace(cc.p(anchor.x * seatSize.width, anchor.y * seatSize.height))
    local x, y = pos.x, pos.y
    local size = self._widgets.panel_viewinfo:getContentSize()
    -- 方案1：缩放
    self._widgets.panel_viewinfo:stopAllActions()
    self._widgets.panel_viewinfo:setAnchorPoint(cc.p(anchor.x, 1 - anchor.y))
    self._widgets.panel_viewinfo:setPosition(x, y)
    self._widgets.panel_viewinfo:setScale(0)
    local seq = {
        cc.Show:create(),
        cc.ScaleTo:create(0.15, 1.1),
        cc.ScaleTo:create(0.05, 1.0),
        cc.DelayTime:create(2),
        cc.ScaleTo:create(0.1, 0),
        cc.Hide:create()
    }
    -- 方案2：渐入
    -- x = x - anchor.x * size.width
    -- y = y - size.height + anchor.y * size.height
    -- self._widgets.panel_viewinfo:stopAllActions()
    -- self._widgets.panel_viewinfo:setPosition(x, y)
    -- self._widgets.panel_viewinfo:setOpacity(0)
    -- local seq = {
    --     cc.Show:create(),
    --     cc.FadeIn:create(0.1),
    --     cc.DelayTime:create(2),
    --     cc.FadeOut:create(0.1),
    --     cc.Hide:create()
    -- }

    self._widgets.panel_viewinfo:runAction(transition.sequence(seq))
end

------------------ 动态表现 ------------------
function BullUI:getSeatByPid(pid)
    if not pid or pid == Game.playerDB:getPlayerUid() then
        return nil
    end
    local playerList = Game.bullDB:getPlayerList()
    for i,v in pairs(playerList) do
        if v.player_id == pid then
            return i
        end
    end
    return nil
end

function BullUI:getPondBetNode(betToIdx)
    betToIdx = betToIdx or 1
    return self._widgets["panel_bet_"..betToIdx]
end

function BullUI:getBetChipNode(coin)
    local chipList = Game.bullDB:getChipList()
    for i,v in ipairs(chipList) do
        if v == coin then
            return self._widgets["btn_bet"..i], i
        end
    end
    return self._widgets["btn_bet1"], 1
end

function BullUI:createPoke(v)
    if type(v) ~= "table" then
        v = {color = 1, size = 1}
    end
    local pokeViewStr = {"card_num", "type_small", "type_big", "bg_jqk"}

    local nPoke = self._widgets.temp_poke:clone()
    nPoke.data = v
    nPoke.fg = nPoke
    nPoke.bg = nPoke:getChildByName("back")
    nPoke.bg:setVisible(not v.show)
    for kStr, vStr in pairs(pokeViewStr) do
        local img = nPoke:getChildByName(vStr)
        local imgStr = "subgame/bull/poke/"
        local colour = v.color
        if vStr == "type_small" then
            imgStr = imgStr.."HS1"..colour..".png"
        elseif vStr == "type_big" then
            imgStr = imgStr.."HS"..colour..".png"
        elseif vStr == "card_num" then
            local color = "R"
            if colour == 1 or colour == 3 then
                color = "B"
            end
            local num = v.size
            imgStr = imgStr..color..num..".png"
        elseif vStr == "bg_jqk" then
            local num = v.size
            if num > 10 then
                local color = 8
                if colour == 1 or colour == 3 then
                    color = 5
                end
                imgStr = imgStr.."HS"..(color+num-11)..".png"
                img:setVisible(true)
            else
                imgStr = imgStr.."HS5.png"
                img:setVisible(false)
            end
        end
        -- img:loadTexture(imgStr, 1)
        -- img:ignoreContentAdaptWithSize(true)
        fitIconSize(img, imgStr)
    end
    nPoke:setVisible(true)
    return nPoke
end

function BullUI:createDraw(pIdx, v, delay)
    local panel = self._drawPanel[pIdx - 1]
    if panel then
        local size = panel:getContentSize()
        local pos = panel:convertToWorldSpace(cc.p(size.width/2,size.height/4))
        local cfg, widget = NiuConfig[v]
        if cfg and string.find(cfg.icon, "%.") then
            widget = display.newSprite(cfg.icon)
        else
            widget = self._widgets.temp_rate_text:clone()
            widget:setString(cfg.name.." "..cfg.times..stringCfgCom.content("ddz_bei"))
        end
        widget:setPosition(pos)
        if delay then
            widget:setVisible(false)
            local seq = {
                cc.DelayTime:create(delay),
                cc.CallFunc:create(function () common_util.playSoundConfig(self, tostring(v)) end),
                cc.Show:create(),
            }
            widget:runAction(transition.sequence(seq))
        end
        self:addChild(widget, 110)
        return widget
    end
    return nil
end

function BullUI:getFlyParams(fromNode, chipType)
    local size = fromNode:getContentSize()
    local fp = fromNode:convertToWorldSpace(cc.p(size.width/2,size.height/2))
    local imgChip = self._widgets.temp_fly_coin:clone()
    if chipType and ChipIcon[chipType] then
        imgChip:loadTexture(ChipIcon[chipType])
        imgChip.chipType = chipType
    end
    imgChip:setVisible(false)
    imgChip:setPosition(fp)
    self:addChild(imgChip, 70)

    return imgChip
end

function BullUI:flyChip(fromNode, toNode, coin, delayTime, chipType)
    local size = fromNode:getContentSize()
    local fp = fromNode:convertToWorldSpace(cc.p(size.width/2,size.height/2))
    size = toNode:getContentSize()
    local tp = toNode:convertToWorldSpace(cc.p(size.width/2,size.height/2))
    tp.x = tp.x + math.random(-size.width*0.3, size.width*0.3)
    tp.y = tp.y + math.random(-size.height*0.2, size.height*0.2)
    local imgChip = self._widgets.temp_fly_coin:clone()
    if chipType and ChipIcon[chipType] then
        imgChip:loadTexture(ChipIcon[chipType])
        imgChip.chipType = chipType
    end
    local scale = imgChip:getScale()
    imgChip:setVisible(false)
    imgChip:setPosition(fp)
    self:addChild(imgChip, 70)

    if EffChips and coin then
        local effChipsParam = {duration = 0.3, maxDalay = delayTime, rect = tp, endAction={ActionType.Ripple}}
        if coin then
            local txtMyCoin = toNode:getChildByName("Text_mybet")
            if txtMyCoin then
                txtMyCoin:setTag(coin)
                effChipsParam.endCallback = function ()
                    common_util.playSoundConfig(self, "chip", nil, true)
                    local count = checknumber(txtMyCoin:getString())
                    txtMyCoin:setString(count + coin)
                    txtMyCoin:setVisible(true)
                end
            end
        end
        self:createEffect(EffChips, {imgChip}, effChipsParam, effChipsParam.endCallback):run()
    else
        local seq = {
            cc.Show:create(),
            cc.GamePhysicMoveTo:create(0.3, tp),
            cc.CallFunc:create(function () common_util.playSoundConfig(self, "chip", nil, true) end),
            cc.ScaleTo:create(0.1, scale*1.1),
            cc.ScaleTo:create(0.1, scale*1.0),
        }
        if delayTime then
            table.insert(seq, 1, cc.DelayTime:create(delayTime))
        end
        if coin then
            local txtMyCoin = toNode:getChildByName("Text_mybet")
            if txtMyCoin then
                txtMyCoin:setTag(coin)
                seq[#seq + 1] = cc.CallFunc:create(function ()
                    local count = checknumber(txtMyCoin:getString())
                    txtMyCoin:setString(count + coin)
                    txtMyCoin:setVisible(true)
                end)
            end
        end
        imgChip:runAction(transition.sequence(seq))
    end

    return imgChip
end

function BullUI:removeChip(fromArea, toNode, delay, all)
    if fromArea and self._allChips[fromArea] and #self._allChips[fromArea] > 1 then
        delay = delay or 0.01
        local size = toNode:getContentSize()
        local tp = toNode:convertToWorldSpace(cc.p(size.width/2,size.height/2))
        if all then
            local EffChips = nil
            if EffChips then
                local args = {duration=common_util.randomFloat(0.05, 0.2, 2), rect=tp, endAction={ActionType.Remove}, bBack=true}
                self:createEffect(EffChips, self._allChips[fromArea], args, function ()
                    self._allChips[fromArea] = {}
                end):run(delay)
            else
                for i, imgChip in ipairs(self._allChips[fromArea]) do
                    local seq = {
                        cc.DelayTime:create(delay+common_util.randomFloat(0.05, 0.2, 2)),
                        cc.EaseBackIn:create(cc.GamePhysicMoveTo:create(0.5, tp)),
                        cc.FadeOut:create(0.2),
                        cc.RemoveSelf:create()
                    }
                    imgChip:runAction(transition.sequence(seq))
                end
                self._allChips[fromArea] = {}
            end
        else
            local imgChip = table.remove(self._allChips[fromArea])
            if EffChips then
                self:createEffect(EffChips, {imgChip}, {duration=common_util.randomFloat(0.05, 0.2, 2), rect=tp, endAction={ActionType.Remove}, bBack=true}):run(delay)
            else
                local seq = {
                    cc.DelayTime:create(delay+common_util.randomFloat(0.05, 0.2, 2)),
                    cc.EaseBackIn:create(cc.GamePhysicMoveTo:create(0.5, tp)),
                    cc.FadeOut:create(0.2),
                    cc.RemoveSelf:create()
                }
                imgChip:runAction(transition.sequence(seq))
            end
        end
    end
end

function BullUI:removeAllChip()
    for i, seatChip in ipairs(self._allChips) do
        for _, chip in ipairs(seatChip) do
            if not tolua.isnull(chip) then
                chip:removeFromParent()
            end
        end
        self._allChips[i] = {}
    end
end

function BullUI:flyPoke(poke, pIdx, cIdx, delay)
    local toNode = self._drawPanel[pIdx - 1]
    local size = toNode:getContentSize()
    -- local pos = cc.p((size.width-CARD_WIDTH/2)*(6-cIdx)/5-CARD_WIDTH/2, size.height/2)
    local pos = cc.p(CARD_PAD*(5-cIdx), size.height/2)
    if EffPokeDraw == "reveal" or EffPokeDraw == "unfold" then
        pos.x = CARD_PAD*(cIdx-1)
    end
    local tp = toNode:convertToWorldSpace(pos)
    local acMove = cc.EaseSineInOut:create(cc.GamePhysicMoveTo:create(0.3, tp))
    local acRotate = cc.RotateBy:create(0.2, 360)
    local seq = {
        cc.CallFunc:create(function() common_util.playSoundConfig(self, "deal", nil, true) end),
        cc.Spawn:create(acMove, acRotate),
        cc.CallFunc:create(function ()
            poke:setLocalZOrder(40 + 5 * pIdx + cIdx)
        end)
    }
    if delay then
        table.insert(seq, 1, cc.DelayTime:create(delay))
    end
    poke:runAction(transition.sequence(seq))
end

--翻牌效果(自带背景图(bg))
function BullUI:flopPoke(poke, delay, fz)
    if not poke or not poke.bg then return end
    local seq = {
        cc.OrbitCamera:create(0.3, 1, 0, 0, -90, 0, 0),
        cc.CallFunc:create(function ()
            poke.bg:setVisible(false)
            poke:setLocalZOrder(fz)
        end),
        cc.OrbitCamera:create(0.2, 1, 0, -90, -90, 0, 0),
    }
    if delay then
        table.insert(seq, 1, cc.DelayTime:create(delay))
    end
    poke:runAction(transition.sequence(seq))
end

-- 3D翻牌
-- cc.DIRECTOR_PROJECTION3_D necessary
function BullUI:revealPoke(poke, delay, duration)
    if not poke or not poke.bg then return end
    duration = duration or 0.2
    local scaleX, scaleY = poke:getScaleX(), poke:getScaleY()
    local size = poke:getContentSize()
    local anchor = poke:getAnchorPoint()
    local sw = size.width * math.abs(scaleX)
    local actMove = cc.MoveBy:create(duration, cc.p(-sw*0.75, 0))
    local actScale = cc.ScaleTo:create(duration, 1.1 * scaleX, 1.1 * scaleY)
    local actFlop = cc.OrbitCamera:create(duration, 1, 0, 0, -95, 0, 0)
    local actMove2 = cc.MoveBy:create(duration-0.05, cc.p(sw*0.75, 0))
    local actScale2 = cc.ScaleTo:create(duration-0.05, 1.25 * scaleX, 1.25 * scaleY)
    local actFlop2 = cc.OrbitCamera:create(duration-0.05, 1, 0, -95, -85, 0, 0)
    local seq = {
        cc.CallFunc:create(function() poke:setAnchorPoint(cc.p(0.5, 0.5)) end),
        cc.Spawn:create(actMove, actScale, actFlop),
        cc.CallFunc:create(function() poke.bg:setVisible(false) end),
        cc.Spawn:create(actMove2, actScale2, actFlop2),
        -- cc.DelayTime:create(0.05),
        cc.ScaleTo:create(0.035, 1.3 * scaleX, 1.3 * scaleY),
        cc.ScaleTo:create(0.01, 1.0 * scaleX, 1.0 * scaleY),
        cc.CallFunc:create(function() poke:setAnchorPoint(anchor) end),
    }
    if delay then
        table.insert(seq, 1, cc.DelayTime:create(delay))
    end
    poke:runAction(transition.sequence(seq))
end

-- 收拢->摊开
function BullUI:foldUnfold(pokeList, delay, duration, hideIdx, pIdx)
    duration = duration or 0.3
    hideIdx = hideIdx or #pokeList

    local pxCenter = CARD_PAD * math.floor(#pokeList / 2)
    local toNode = self._drawPanel[pIdx - 1]
    local pos = cc.p(pxCenter, 0)
    local tp = toNode:convertToWorldSpace(pos)
    pxCenter = tp.x

    for i, poke in ipairs(pokeList) do
        local x, y = poke:getPosition()
        local anchor = poke:getAnchorPoint()
        local seq = {
            cc.MoveTo:create(duration / 2, cc.p(pxCenter, y)),
            cc.DelayTime:create(0.05),
            cc.CallFunc:create(function()
                poke:setAnchorPoint(cc.p(0.5, 0.5))
                poke:setScaleX(-poke:getScaleX())
                poke:setAnchorPoint(cc.p(1-anchor.x, anchor.y))
                poke.bg:setVisible(false)
            end),
            cc.MoveTo:create(duration / 2, cc.p(x, y)),
        }
        if i == hideIdx then
            table.remove(seq, 3)
        end
        if delay then
            table.insert(seq, 1, cc.DelayTime:create(delay))
        end
        poke:runAction(transition.sequence(seq))
    end
end

-- 收拢->摊开最后一张
function BullUI:foldUnfoldLast(pokeList, delay, duration, hideIdx, pIdx)
    duration = duration or 0.3
    hideIdx = hideIdx or #pokeList

    local pxCenter = CARD_PAD * (hideIdx - 1)
    local toNode = self._drawPanel[pIdx - 1]
    local pos = cc.p(pxCenter, 0)
    local tp = toNode:convertToWorldSpace(pos)
    pxCenter = tp.x

    for i, poke in ipairs(pokeList) do
        local x, y = poke:getPosition()
        local seq = {
            cc.MoveTo:create(duration / 2, cc.p(pxCenter, y)),
            cc.DelayTime:create(0.05),
            cc.MoveTo:create(duration / 2, cc.p(x, y)),
        }
        if i == hideIdx then
            local anchor = poke:getAnchorPoint()
            table.insert(seq, 3, cc.CallFunc:create(function()
                poke:setAnchorPoint(cc.p(0.5, 0.5))
                poke:setScaleX(-poke:getScaleX())
                poke:setAnchorPoint(cc.p(1-anchor.x, anchor.y))
                poke.bg:setVisible(false)
            end))
        end
        if delay then
            table.insert(seq, 1, cc.DelayTime:create(delay))
        end
        poke:runAction(transition.sequence(seq))
    end
end

function BullUI:turnReward(step)
    if self._lotStep > 0 and self._lotStep ~= step then
        -- TODO: clean
    end
    self._lotStep = step
    if self._lotStep == 1 then
        -- 第1步：备牌
        -- self:showBanner(stringCfgCom.content("bull_bet_stop"))
        -- self:tipSpineBanner("bet_stop")
        local handCard, count, poke = Game.bullDB:getHandCard(), 1
        local px, py = 130, 630
        if self._widgets.node_poke then
            px, py = self._widgets.node_poke:getPosition()
        end
        self._allPoke = {}
        if handCard and #handCard == 5 then
            for j=1,5 do
                for i=1,5 do
                    poke = self:createPoke(handCard[i].cards and handCard[i].cards[j] or handCard[i][j])
                    if poke then
                        poke:setPosition(px - count, py)
                        self:addChild(poke, 100-count)
                        self._allPoke[count] = poke
                        count = count + 1
                    end
                end
            end
        end

        performWithDelay(self, function ()
            self:turnReward(self._lotStep + 1)
        end, 0.3)

    elseif self._lotStep == 2 then
        -- 第2步：发牌
        for i, poke in ipairs(self._allPoke) do
            local pIdx = (i - 1) % 5 + 1
            local cIdx = math.ceil(i / 5)
            self:flyPoke(poke, pIdx, cIdx, i * 0.1)
        end

        performWithDelay(self, function ()
            self:turnReward(self._lotStep + 1)
        end, 3)

    elseif self._lotStep == 3 then
        -- 第3步：翻拍(先同时翻四张)
        local delay = 1
        if EffPokeDraw == "flop" then
            for i=6,25 do
                self:flopPoke(self._allPoke[i], 0.05*(math.floor(i/5)), 70-i)
            end
        else
            local hideIdx = nil
            if EffPokeDraw == "unfold" then
                hideIdx = 4
            end
            for i=1,5 do
                local list = {}
                for j=1,5 do
                    list[j] = self._allPoke[(j - 1) * 5 + i]
                end
                self:foldUnfold(list, 0.18*(math.floor(i/5)), nil, hideIdx, i)
            end
            delay = 1.0
        end
        performWithDelay(self, function ()
            self:turnReward(self._lotStep + 1)
        end, delay)

    elseif self._lotStep == 4 then
        -- 第4步：统计(依次翻最后一张并提牌统计)
        local drawInfo, drawImg = Game.bullDB:getDrawNiu()
        local handCard = Game.bullDB:getHandCard()
        local delay = 0
        for i,v in ipairs(drawInfo) do
            if EffPokeDraw == "flop" then
                cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION3_D)
                self:flopPoke(self._allPoke[i], delay, 70-i)
                for j = 1, 5 do
                    local poke = self._allPoke[i + (j - 1) * 5]
                    if poke then
                        local seq = {
                            cc.DelayTime:create(delay + 0.55),
                            cc.MoveBy:create(0.1, cc.p(64, 0))
                        }
                        poke:runAction(transition.sequence(seq))
                    end
                end
            elseif EffPokeDraw == "reveal" then
                cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION3_D)
                self:revealPoke(self._allPoke[i+20], delay)
            elseif EffPokeDraw == "unfold" then
                local list = {}
                for j=1,5 do
                    list[j] = self._allPoke[(j - 1) * 5 + i]
                end
                self:foldUnfoldLast(list, delay + 0.3, nil, 4, i)
            end
            -- 提牌统计
            if self._allPoke[i] and self._allPoke[i]:isVisible() then
                if handCard and handCard[i] and handCard[i].value_cards then
                    for j = 1, 5 do
                        local poke = self._allPoke[i + (j - 1) * 5]
                        if poke and poke.data and self:checkCardPickUp(poke.data, handCard[i].value_cards) then
                            local seq = {
                                cc.DelayTime:create(delay + 0.7),
                                cc.MoveBy:create(0.1, cc.p(0, PICKUP_PAD))
                            }
                            poke:runAction(transition.sequence(seq))
                        end
                    end
                end
                drawImg = self:createDraw(i, v, delay + 0.8)
                if drawImg then
                    self._allPoke[#self._allPoke + 1] = drawImg
                end
            end
            delay = delay + 0.9
        end

        performWithDelay(self, function ()
            cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)
            self:turnReward(self._lotStep + 1)
        end, delay + 0.5)

    elseif self._lotStep == 5 then
        -- 第5步：倍率
        local resultInfo = Game.bullDB:getDrawResult()
        local allBetInfo = Game.bullDB:getAllBetData()
        local rateInfo, rating = Game.bullDB:getDrawRate(), false
        for i, v in ipairs(rateInfo) do
            if v > 1 and resultInfo[i] ~= 0 and allBetInfo[i].coin > 0 then
                local toNode = self._widgets["panel_bet_"..i]
                local chipEffList, rect, chip = {}
                if EffChips then
                    local size = toNode:getContentSize()
                    rect = toNode:convertToWorldSpace(cc.p(size.width/2,size.height/2))
                    rect.width = size.width*0.6
                    rect.height = size.width*0.2
                end
                -- 其他玩家赔
                for j=#self._allChips[i],1,-1 do
                    if EffChips then
                        chip = self:getFlyParams(self._widgets.img_other, self._allChips[i][j].chipType)
                        table.insert(chipEffList, chip)
                    else
                        chip = self:flyChip(self._widgets.img_other, toNode, nil, common_util.randomFloat(0.05, 0.1, 2), self._allChips[i][j].chipType)
                    end
                    self:insertToAllChip(self._allChips[i], chip)
                end
                if EffChips then
                    self:createEffect(EffChips, chipEffList, {duration=common_util.randomFloat(0.05, 0.1, 2), rect=rect, endAction={ActionType.Ripple}}):run()
                end
                -- 在座玩家赔
                local seatInfo = Game.bullDB:getSeatBetInfo()
                for k, betList in pairs(seatInfo) do
                    local seat = self:getSeatByPid(k)
                    if seat and self._widgets["panel_rich_"..seat] then
                        for _, c in ipairs(betList) do
                            if c.area == i and c.coin > 0 then
                                local chipList = common_util.packageList(c.coin, Game.bullDB:getChipList(), 5)
                                for _, chipType in ipairs(chipList) do
                                    if EffChips then
                                        chip = self:getFlyParams(self._widgets["panel_rich_"..seat], chipType)
                                        table.insert(chipEffList, chip)
                                    else
                                        chip = self:flyChip(self._widgets["panel_rich_"..seat], toNode, nil, common_util.randomFloat(0.05, 0.1, 2), chipType)
                                    end
                                    self:insertToAllChip(self._allChips[i], chip)
                                end
                                if EffChips then
                                    self:createEffect(EffChips, chipEffList, {duration=common_util.randomFloat(0.05, 0.1, 2), rect=rect, endAction={ActionType.Ripple}}):run()
                                end
                            end
                        end
                    end
                end
                -- 自己赔
                if self._myChipTxt[i]:isVisible() then
                    local chipEffList = {}
                    local count = checknumber(self._myChipTxt[i]:getString())
                    local chipList = common_util.packageList(count, Game.bullDB:getChipList(), 5)
                    for _, chipType in ipairs(chipList) do
                        if EffChips then
                            chip = self:getFlyParams(self._widgets["btn_bet"..chipType], chipType)
                            table.insert(chipEffList, chip)
                        else
                            chip = self:flyChip(self._widgets["btn_bet"..chipType], toNode, nil, common_util.randomFloat(0.05, 0.1, 2), chipType)
                        end
                        self:insertToAllChip(self._allChips[i], chip)
                    end
                    if EffChips then
                        self:createEffect(EffChips, chipEffList, {duration=common_util.randomFloat(0.05, 0.1, 2), rect=rect, endAction={ActionType.Ripple}}):run()
                    end
                end
                rating = true
            end
        end
        if rating then
            common_util.playSoundConfig(self, "chipdown")
            performWithDelay(self, function ()
                self:turnReward(self._lotStep + 1)
            end, 0.7)
        else
            self:turnReward(self._lotStep + 1)
        end

    elseif self._lotStep == 6 then
        -- 第6步：输赢
        local resultInfo = Game.bullDB:getDrawResult()
        local seatInfo = Game.bullDB:getSeatBetInfo()
        local function _playSound()
            common_util.playSoundConfig(self, "chipdown", nil, true)
        end
        local seqSound = {
            cc.DelayTime:create(0.05),
            cc.DelayTime:create(0.05),
            cc.DelayTime:create(0.9),
            cc.DelayTime:create(0.05),
            cc.DelayTime:create(0.8),
            cc.DelayTime:create(0.05),
        }
        for i, v in ipairs(resultInfo) do
            if v == 0 then
                -- 赢
                local toNode = self._widgets["panel_bet_"..i]
                local chipEffList, rect, chip = {}
                for j=#self._allChips[i],1,-1 do
                    if EffChips then
                        chip = self:getFlyParams(self._widgets.panel_binfo, self._allChips[i][j].chipType)
                        table.insert(chipEffList, chip)
                    else
                        chip = self:flyChip(self._widgets.panel_binfo, toNode, nil, common_util.randomFloat(0.9, 1.1, 2), self._allChips[i][j].chipType)
                    end
                    self:insertToAllChip(self._allChips[i], chip)
                end
                if EffChips then
                    local size = toNode:getContentSize()
                    rect = toNode:convertToWorldSpace(cc.p(size.width/2,size.height/2))
                    rect.width = size.width*0.6
                    rect.height = size.width*0.2
                    local args = {duration=common_util.randomFloat(0.1, 0.3, 2), rect=rect, endAction={ActionType.Ripple}}
                    self:createEffect(EffChips, chipEffList, args):run(0.9)
                end

                if self._myChipTxt[i]:isVisible() then
                    local j = math.max(1, math.random(2, #self._allChips[i]/10))
                    while j > 0 do
                        self:removeChip(i, self._widgets.my_txt_gold, 1.7)
                        j = j - 1
                    end
                end
                for k, betList in pairs(seatInfo) do
                    local seat = self:getSeatByPid(k)
                    if seat and self._widgets["panel_rich_"..seat] then
                        for _, c in ipairs(betList) do
                            if c.coin > 0 then
                                local j = math.max(1, math.random(2, #self._allChips[i]/10))
                                while j > 0 do
                                    self:removeChip(i, self._widgets["panel_rich_"..seat], 1.7)
                                    j = j - 1
                                end
                            end
                        end
                    end
                end
                self:removeChip(i, self._widgets.img_other, 1.7, true)
                seqSound[4] = cc.CallFunc:create(_playSound)
                seqSound[6] = cc.CallFunc:create(_playSound)
            else
                -- 输
                self:removeChip(i, self._widgets.panel_binfo, nil, true)
                seqSound[2] = cc.CallFunc:create(_playSound)
            end
        end
        Game.bullDB:appendRecord(resultInfo)

        self:runAction(transition.sequence(seqSound))

        performWithDelay(self, function ()
            self:turnReward(self._lotStep + 1)
        end, 2.5)

    elseif self._lotStep == 7 then
        -- 第7步：结算
        self:turnRewardFinish()
        self._lotStep = self._lotStep + 1
    end
end

function BullUI:turnRewardFinish()
    if self._rewardState == 1 then
        self:doStateReward()
    else
        self._rewardState = 1
    end
end

----------- 状态控制接口 --------------
function BullUI:doStateWaitbet()
    if spine_util.release then
        spine_util.release()
    end
    self:hideBanner()

    Game.bullDB:resetDataNext()
    self:onGoldChanged()
    for i=1,4 do
        self._allChipTxt[i]:setString(0)
        self._myChipTxt[i]:setString(0)
        self._myChipTxt[i]:setVisible(false)
    end

    for i, poke in ipairs(self._allPoke) do
        local seq = {
            cc.FadeOut:create(0.2),
            cc.RemoveSelf:create()
        }
        poke:runAction(transition.sequence(seq))
        self._allPoke[i] = nil
    end
    self._allPoke = {}

    self:removeAllChip()

    if not tolua.isnull(self._resultLayer) then
        self._resultLayer:onBackClicked()
        self._resultLayer = nil
    end

    self._widgets.panel_time:setVisible(true)
    Game.bullCom:onBankerList(true)

    common_util.playSoundConfig(self, "betstart")

    if Game.bullDB:isBanker() then
        common_util.playSoundConfig(self, "bgm2")
    else
        common_util.playSoundConfig(self)
    end
end

function BullUI:doStateBetting()
    self:doStateWaitbet()
    -- self:showBanner(stringCfgCom.content("bull_bet_start"))
    self:tipSpineBanner("bet_start")
    if self._autoBet and not self._autoBetted then
        self._autoBetted = true
        -- self:autoBetIn()
        performWithDelay(self, handler(self, self.autoBetIn), 1)
    end
end

function BullUI:doStateLottery(timeleft)
    self._autoBetted = false
    Game.bullDB:roleSavedBet()
    common_util.playSoundConfig(self, "betstop")
    Game.bullCom:onSync()
    self._widgets.panel_time:setVisible(false)
    self._rewardState = 0
    local step = 1 -- FIXME: timeleft
    self:turnReward(step)
end

function BullUI:doStateReward()
    self._autoBetted = false
    Game.bullDB:roleSavedBet()
    local myChip = 0 --Game.bullDB:getMyChip()
    for i,v in ipairs(self._myChipTxt) do
        if v:isVisible() then
            myChip = myChip + checknumber(v:getString())
        end
    end
    if myChip > 0 then
        self._savedMyChip = myChip
    end

    Game.rechargeCom:checkCoinEnough(100, RechargeType.SubGame)
    self._resultLayer = require("games.brnn.views.BullResultUI"):new():addToScene(UIZorder.UILayer-10)

    -- self:testMarqueeTip()
end

-- 横幅提示
function BullUI:showBanner(content, wait)
    if wait then
        Game:showWaitUI(content, _, _, true)
    else
        Game:tipMsg(content)
    end
end

function BullUI:hideBanner()
    Game:destroyWaitUI()
end

function BullUI:tipSpineBanner(key)
    if self._SpineBanner[key] then
        if not self._spine[key] then
            self._spine[key] = Actor:new(self._SpineBanner[key].res, self._SpineBanner[key])
            self:addChild(self._spine[key])
        else
            self._spine[key]:setVisible(true)
            self._spine[key]._state = ""
            self._spine[key]:changeAnimation(self._SpineBanner[key].ani, self._SpineBanner[key].isLoop, nil, true)
        end
    end
end

function BullUI:spineBannerCompleteLsn(event)
    for k,v in pairs(self._spine) do
        v:setVisible(false)
    end
end

-- 跑马灯
function BullUI:addMarqueeTip(content, style)
    local richText = ccui.RichText:createWithXML(content, {})
    richText:setAnchorPoint(cc.p(0, 0.5))
    richText:formatText()
    local size = richText:getContentSize()
    local px, py = self._marqueeSize.width + 100, self._marqueeSize.height / 2
    if not tolua.isnull(self._lastMarquee) then
        px = math.max(px, self._lastMarquee:getPositionX() + self._lastMarquee:getContentSize().width + 100)
    end
    richText:setPosition(px, py)
    self._widgets.marquee_container:addChild(richText)

    local len = px + size.width + 100
    local duration = len / MarqueeSpeed
    local seq = {
        cc.MoveBy:create(duration, cc.p(-len, 0)),
        cc.RemoveSelf:create()
    }
    richText:runAction(transition.sequence(seq))

    self._lastMarquee = richText
end

function BullUI:testMarqueeTip()
    local data, tipContent = Game.bullDB:getWinnerList() or {}
    for i,v in ipairs(data) do
        if checknumber(v.ret_coin) > 100000 then
            -- tipContent = "<font size='18'>"
            -- tipContent = tipContent.."恭喜<font color='#00ffff'><b>【"..v.name.."】</b></font>"
            -- tipContent = tipContent.."在<font color='#ffff00'>百人牛牛</font>游戏中"
            -- tipContent = tipContent.."赢得<font color='#ff0000'><b>"..common_util.getShortString(v.ret_coin).."</b></font>金币"
            -- tipContent = tipContent.."</font>"
            -- self:addMarqueeTip(tipContent, 1)

            tipContent = "恭喜"..tostring(v.name).."在百人牛牛游戏中赢得"..common_util.getShortString(v.ret_coin).."金币"
            Game.chatCom:onReceiveMsg({content = tipContent, type = 1})
            break
        end
    end
end

function BullUI:getPlayerPos(idx)
    if not self._posTag then
        self._posTag = {}
        local widget = {
            "panel_rich_1",
            "panel_rich_2",
            "panel_rich_3",
            "panel_rich_4",
            "panel_rich_5",
            "panel_rich_6",
            {x = display.cx, y = display.cy},
            "panel_binfo",
            {x = 250, y = 50},
            "img_other",
        }
        local n, x, y, a, s
        for i,v in ipairs(widget) do
            if type(v) == "table" then
                self._posTag[i] = v
            elseif self._widgets[v] then
                x, y = self._widgets[v]:getPosition()
                a = self._widgets[v]:getAnchorPoint()
                s = self._widgets[v]:getContentSize()
                x = x + s.width * (0.5 - a.x)
                y = y + s.height * (0.5 - a.y)
                self._posTag[i] = {x = x, y = y}
            end
        end
    end
    if idx then
        return self._posTag[idx]
    else
        return self._posTag
    end
end

function BullUI:getBox(player_id, box_id)
    if not self._getbox_queue or self._getbox_queue:empty() then
        self:showObtainBox(player_id, box_id)
    else
        self._getbox_queue:push({player_id, box_id})
    end
end

function BullUI:showObtainBox(player_id, box_id)
    if type(player_id) == "table" then
        box_id = player_id[2]
        player_id = player_id[1]
    end
    local target, pos = 0
    if player_id == Game.playerDB:getPlayerUid() then
        pos = self:getPlayerPos(9)
        target = 1
    else
        local banker = Game.bullDB:getBankerInfo()
        if player_id == banker.player_id then
            pos = self:getPlayerPos(8)
        else
            local seat = self:getSeatByPid(player_id) or 10
            pos = self:getPlayerPos(seat)
        end
    end

    GetBox:setPlayInfo(self, pos, target, box_id, true)
end

return BullUI
