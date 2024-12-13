-- @Author: ZhuL
-- @Date:   2017-05-02 11:03:07
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-05-19 16:39:35

--[[
    处理逻辑，表情，弹幕等等
]]

local BaseCom = require_ex("data.BaseCom")
local M = class("NiuCom" , BaseCom)

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

local RfsType = {
    RoomState       = 0,
    OnBet           = 1,
    OnSettle        = 2,
    ChangePlayer    = 3,
    TurnChange      = 4,
    All             = 5
}


function M:ctor()
    BaseCom.ctor(self)

    self._gameCallbacks = nil

    self._chatCallbacks = nil

    self._msgQueue = require("lib.Queue").new()

    self._DB = require("games.niuniu.models.NiuDB")

    self:init()
end

function M:init()
    self._gameCallbacks = {
        [60008] = function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_bc_player_state")
            print("-- 60008 广播玩家状态")
            dump(info)
            self:onPlayerStateChange(info)
        end,
        [60009] = function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_bc_player_gocall")
            -- 60009 广播玩家跟注
            dump(info)
            self:onPlayerBet(info)
        end,
        [60010] = function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_bc_room_state")
            -- 60010 广播房间状态
            print("60010------------------")
            dump(info)
            self:onRoomState(info)
        end,
        [60011] = function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_bc_settle_data")
            -- 60011 广播房间胜利玩家
            print("60011++++++++++++++++++++++------------------")
            dump(info)
            self:onRoomWinner(info)
        end,
        [60012] = function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_bc_now_turn_player")
            -- 60012 广播当前回合玩家
            dump(info)
            print("60012 广播当前回合玩家--------------")
            self:onTurnChange(info)
        end,
        [60013] = function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_sync_goldniu_room_data")
            -- 60013 同步房间信息
            dump(info)
            self:refreshRoomInfo(info)
        end,
        [60014] = function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_bc_compare_data")
            -- 60014 广播玩家比牌数据
            dump(info)
            self:onNoticeCompare(info)
        end,
        [60015] = function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_bc_compare_fail")
            -- 60015 通知玩家比牌失败 仅失败者接收到此信息
            dump(info)
            print("60015 通知玩家比牌失败 仅失败者接收到此信息")
            self:onCompareFail(info)
        end,
        [60016] = function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_bc_show")
            -- 60016 广播玩家亮牌
            dump(info)
            self:onPlayerShow(info)
        end,
        [60017] = function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_bc_player_enterleft")
            -- 60017 广播玩家进入和离开
            dump(info)
            self:onPlayerEnterOrLeave(info)
        end,
        [60020] = function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_bc_room_round")

            dump(info)
            self:onRoundChange(info.now_round)
        end
    }

    self._chatCallbacks = {

    }
end

-----------------------game logic start-------------------------------


function M:onPlayerStateChange(info)
    self._DB:setPlayerState(info.player_id , info.state)
    self:refreshView("BullView" , RfsType.ChangePlayer , info.player_id)
end

function M:onPlayerBet(info)
    self._DB:setCurBet(info.coin)
    self._DB:setBetPlayer(info.player_id)
    self._DB:addTotalBet(info.coin)
    self._DB:cutPlayerCoin(info.player_id , info.coin)
    self._DB:addPlayerBet(info.player_id , info.coin)
    self:refreshView("BullView" , RfsType.OnBet)
end

function M:onRoomState(info)
    self._DB:setRoomState(info.room_state)
    if info.room_state == RoomState.Deal then
        self:start()
        return
    end
    self:refreshView("BullView" , RfsType.RoomState)
end

function M:start()
    self:closeView("GoldNiuRslt")
    self._DB:setAllPlayerState(PlayerState.Unlooked)
    self._DB:onStart()
    local bullView = self._viewMap["BullView"]
    if bullView then
        bullView:start()
    end
end

function M:onRoundChange(val)
    self._DB:setCurRound(val)
end

function M:onRoomWinner(info)
    self._DB:setWinner(info.player_id)
    self._DB:addPlayerCoin(info.player_id , info.win_coin)

    self:refreshView("BullView" , RfsType.OnSettle , info.player_hand_cards_list)
end

function M:onTurnChange(info)
    self._DB:setCurPlayer(info.now_turn_pos)
    self:refreshView("BullView" , RfsType.TurnChange , info.left_time)
end

function M:refreshRoomInfo(info)
    self._DB:setRoomInfo(info)
    if not self:isInRoom() then
        Game:tipMsg("金币不足，自动退出" , 2 , function()
            self:closeView("BullView")
        end)
    end
    self:refreshView("BullView" , RfsType.All)
end

function M:isInRoom()
    local playerLst = self._DB:getPlayerList()
    local uid = Game.playerDB:getPlayerUid()
    for __ , val in ipairs(playerLst) do
        if val.player_id == uid then
            return true
        end
    end
    print("---------------quit-----------------")
    dump(playerLst)
    return false
end

function M:onNoticeCompare(info)
    local bullView = self._viewMap["BullView"]
    if not bullView then
        return
    end
    bullView:onNoticeCompare(info)
end

function M:onCompareFail(info)
    self._DB:setHandCards(info.hand_cards)
end

function M:onPlayerShow(info)
    local bullView = self._viewMap["BullView"]
    if not bullView then
        return
    end
    -- 打开亮牌界面
    require_ex("games.niuniu.views.GoldNiuRslt").new(self , info.player_hand_cards):addToScene()
end

function M:onPlayerEnterOrLeave(info)
    if info.type == Behavior.Enter then
        self._DB:addPlayerData(info.player)
    elseif info.type == Behavior.Leave then
        self._DB:erasePlayerData(info.player.player_id)
        local uid = Game.playerDB:getPlayerUid()
        if uid == info.player.player_id then
            Game:tipMsg("金币不足，自动退出" , 2 , function()
                self:closeView("BullView")
            end)
            return
        end
    end
    self:refreshView("BullView" , RfsType.All)
end

function M:openEntry()
    require_ex("games.niuniu.views.Entry").new(self):addToScene()
end

function M:registerGameEvent()
    for key , func in pairs(self._gameCallbacks) do
        netCom.registerCallBack(key , func , true)
    end
end

function M:unRegisterGameEvent()
    for key , func in pairs(self._gameCallbacks) do
        netCom.unRegisterCallBack(key)
    end
end

function M:enterGame(roomId)
    self._DB:setRoomId(roomId)
    require_ex("games.niuniu.views.BullView").new(self , roomId):addToScene()
end

function M:reqEnterGame(roomId , callback)
    print("req  60000---------------------")
    self:registerGameEvent()
    netCom.send({201} , 60000 , function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_enter_goldniu")
            dump(info)
            if info.ret_code == 0 then
                self:enterGame(roomId)
                execute(callback)
            else
                Game:tipError(info.ret_code , 2 , function()
                    Game:openGameWithIdx(SCENCE_ID.PLATEFORM, MoreGameView)
                end)
            end
    end)
end

function M:reqExitGame(callback)
    local uid = Game.playerDB:getPlayerUid()
    netCom.send({uid} , 60001 , function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_leave_goldniu")
            if info.ret_code == 0 then
                self:exitGame()
                execute(callback)
            else
                Game:tipError(info.ret_code)
            end
    end)
    self:unRegisterGameEvent()
end

function M:exitGame()
    -- self:unRegisterGameEvent()
end

function M:reqReady(callback)
    local uid = Game.playerDB:getPlayerUid()
    netCom.send({uid} , 60002 , function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_prepare")
            if info.ret_code == 0 then
                self:ready()
                execute(callback)
            else
                Game:tipError(info.ret_code)
            end
    end)
end

function M:ready()
    -- body
end

function M:reqBet(coin , callback)
    local maxBet = self._DB:getMaxBet()
    coin = coin > maxBet and maxBet or coin
    print("reqBet++++++++++++++++++++++" , coin , self._DB:getCurBet())
    netCom.send({coin} , 60003 , function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_gocall")
            if info.ret_code == 0 then
                self:respBet(info.coin)
                execute(callback , info.coin)
            else
                Game:tipError(info.ret_code)
            end
    end)
    self._DB:onBet()
end

function M:respBet(coin)

end

function M:reqGiveUp(callback)
    local uid = Game.playerDB:getPlayerUid()
    netCom.send({uid} , 60004 , function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_giveup")
            if info.ret_code == 0 then
                self:respGiveUp()
                execute(callback)
            else
                Game:tipError(info.ret_code)
            end
    end)
end

function M:respGiveUp()
    -- body
end

function M:reqCompare(callback)
    local uid = Game.playerDB:getPlayerUid()
    netCom.send({uid} , 60019 , function(pack)
        local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_begin_compare")
        if info.ret_code == 0 then
            self:respCompare(info)
            execute(callback)
        else
            Game:tipError(info.ret_code)
        end
    end)
end

function M:respCompare(info)
    -- body
end

function M:reqCmpTarget(targetId , callback)
    netCom.send({targetId} , 60005 , function(pack)
        local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_compare")
        if info.ret_code == 0 then
            self:respCmpTarget(info)
            execute(callback)
        else
            Game:tipError(info.ret_code)
        end
    end)
    self._DB:onBet()
end

function M:respCmpTarget(info)
    -- body
end

-- 看牌
function M:reqLook(callback)
    local uid = Game.playerDB:getPlayerUid()
    netCom.send({uid} , 60006 , function(pack)
            local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_look")
            if info.ret_code == 0 then
                self:respLook(info.hand_cards)
                execute(callback , info.hand_cards)
            else
                Game:tipError(info.ret_code)
            end
    end)
end

function M:respLook(handCards)

end

-- 亮牌
function M:reqShow(callback)
    local uid = Game.playerDB:getPlayerUid()
    netCom.send({uid} , 60007 , function(pack)
        local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_show")
        if info.ret_code == 0 then
            self:respShow(info)
            execute(callback)
        else
            Game:tipError(info.ret_code)
        end
    end)
end

function M:respShow(info)
    -- body
end

function M:reqAllIn(callback)
    local roomState = self._DB:getRoomState()
    local curBet = self._DB:getCurBet()
    local coin = roomState == RoomState.AllIn and curBet or self._DB:getLeastCoin()

    print(coin , "wocao ------------------------------")
    netCom.send({coin} , 60018 , function(pack)
        local info , cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_goldniu_allin")
        if info.ret_code == 0 then
            self:respAllIn(info)
            execute(callback)
        else
            Game:tipError(info.ret_code)
        end
    end)
    self._DB:onBet()
end

function M:respAllIn(info)

end

local stateToStr = {
    [PlayerState.Looked] = "looked",
    [PlayerState.CmpFail] = "cmpFail",
    [PlayerState.GiveUp] = "discard",
}

function M:getStateRes(state)
    local str = stateToStr[state]
    if not str then
        return
    end
    return NiuResConfig.res(str)
end

function M:getCardsPointRes(val)
    local key = "niu" .. val
    return NiuResConfig.res(key)
end

-----------------------game logic end-------------------------------



-----------------------处理聊天弹幕 start-------------------------------

function M:onReceiveMsg(msgType , data)
    local chatView = self._viewMap["ChatView"]
    if not chatView then
        return
    end
    self:pushMsg({type = msgType , data = data})
    chatView:tryToShowMsg()
end

function M:getMsgCount()
    return self._msgQueue:length()
end

function M:pushMsg(msg)
    self._msgQueue:push(msg)
end

function M:popMsg()
    return self._msgQueue:pop()
end

function M:addChatView(parent)
    local chatView = require_ex("games.niuniu.views.ChatView").new(self)
    parent:addChatView(chatView)
end

function M:reqSendEmoji(emojiLst)
    -- body
    self:onReceiveMsg(1 , emojiLst)
end

function M:reqSendMsg(msg)
    -- body
    self:onReceiveMsg(2 , msg)
end

-----------------------处理聊天弹幕 end-------------------------------


return M.new()