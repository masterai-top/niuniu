-- @Author: ZhuL
-- @Date:   2017-05-02 11:03:16
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-05-18 14:24:45

local M = class("NiuDB")

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

function M:ctor()
    self:init()
end

function M:init()
    self._curRoomId = nil

    self._curRoomType = nil

    self._playerLst = {
        {
            player_id = 16456,
            special_id = 15456456,
            facelook = 10001,
            vip_lv = 5,
            name = "SB",
            coin = 1561,
            pos = 3,
            staked_coin = 50450,
            state = 3
        },
        {
            player_id = Game.playerDB:getPlayerUid(),
            special_id = 15456456,
            facelook = 10002,
            vip_lv = 4,
            name = "SB",
            coin = 153261,
            pos = 7,
            staked_coin = 5040,
            state = 3
        },
        {
            player_id = 456656,
            special_id = 15456456,
            facelook = 10003,
            vip_lv = 5,
            name = "SB",
            coin = 15461,
            pos = 5,
            staked_coin = 5030,
            state = 3
        },
        {
            player_id = 3213254564,
            special_id = 15456456,
            facelook = 10004,
            vip_lv = 7,
            name = "SB",
            coin = 156761,
            pos = 6,
            staked_coin = 5700,
            state = 3
        },
    }

    -- 用于储存当前轮是否押注
    self._betLst = {}

    -- 当前注
    self._curBet = 234

    self._remainTime = 0

    -- 下注的玩家
    self._betPlayer = nil

    self._handCards = {}

    -- 房间状态
    self._roomState = 2

    self._preBet = 10

    -- 最大轮数
    self._maxRound = 10

    self._minBet = 100

    self._maxBet = 1000

    self._curRound = 1

    self._bAllIn = false

    -- 当前回合玩家
    self._curPlayerPos = 7

    -- 总下注金币
    self._totalBet = 456456

    self._winner = nil
end

function M:setTotalBet(val)
    print("setTotalBet---------------------" , val)
    self._totalBet = val
end

function M:hasBetCurRound()
    return self._betLst[self._curRound] ~= nil
end

function M:onBet()
    self._betLst[self._curRound] = true
end

function M:onStart()
    self._betLst = {}
end

function M:addTotalBet(val)
    self._totalBet = self._totalBet + val
end

function M:getTotalBet()
    return self._totalBet
end

function M:setCurRound(val)
    self._curRound = val
end

function M:getCurRound()
    return self._curRound
end

function M:setMaxRound(val)
    self._maxRound = val
end

function M:getMaxRound()
    return self._maxRound
end

function M:setMinBet(val)
    self._minBet = val
    self._preBet = self._minBet
end

function M:getMinBet()
    return self._minBet
end

function M:setMaxBet(val)
    self._maxBet = val
end

function M:getMaxBet()
    return self._maxBet
end

function M:getRoomId()
    return self._curRoomId
end

function M:setRoomId(id)
    self._curRoomId = id
end

function M:getRoomType()
    return self._curRoomType
end

function M:setRoomType(val)
    self._curRoomType = val
end

function M:setCurBet(bet)
    self._preBet = self._curBet
    self._curBet = bet
end

function M:getPreBet()
    return self._preBet
end

function M:getCurBet()
    return self._curBet
end

function M:setBetPlayer(uid)
    self._betPlayer = uid
end

function M:getBetPlayer()
    return self._betPlayer
end

function M:setRoomInfo(info)
    self._info = info
    self:setRoomState(info.room_state)
    self:setPlayerList(info.room_players)
    self:setMaxRound(info.round_time)
    self:setMaxBet(info.max_gocall_coin)
    self:setMinBet(info.min_gocall_coin)
    self:setCurRound(info.now_round)
    self:setCurPlayer(info.now_turn_pos)
    self:setRemainTime(info.turn_left_time)
    self:setCurBet(info.room_gocall_coin)
    self:setTotalBet(info.room_staked_coin)
    print("setRoomInfo")
    dump(self._playerLst)
end

function M:setRemainTime(time)
    self._remainTime = time
end

function M:getRemainTime()
    return self._remainTime
end

function M:setWinner(val)
    self._winner = val
end

function M:getWinner()
    return self._winner
end

function M:setRoomState(state)
    print("-----------------setRoomState" , state)
    self._roomState = state
end

function M:getRoomState()
    return self._roomState
end

function M:setAllPlayerState(state)
    for __ , data in ipairs(self._playerLst) do
        data.state = state
    end
end

function M:getRandomUid()
    local list = self._playerLst
    for __ , val in ipairs(list) do
        if val.player_id ~= Game.playerDB:getPlayerUid() and
            (val.state == PlayerState.Unlooked or val.state == PlayerState.Looked) then
            print("bindWidgetList------------------------")
            dump(val)
            dump(list)
            return val.player_id
        end
    end
end

function M:setHandCards(val)
    self._handCards = val
end

function M:getHandCards()
    return self._handCards
end

function M:setCurPlayer(val)
    self._curPlayerPos = val
end

function M:getCurPlayer()
    return self._curPlayerPos
end

function M:setPlayerList(list)
    self._playerLst = list
end

function M:getPlayerList()
    return self._playerLst
end

function M:setPlayerState(uid , state)
    if not self._playerLst then
        return
    end
    for __ , val in ipairs(self._playerLst) do
        if val.player_id == uid then
            val.state = state
            return
        end
    end
end

function M:getPlayerState(uid)
    return self:getPlayerData(uid).state
end

function M:getPlayerData(uid)
    if not self._playerLst then
        return
    end
    for __ , val in ipairs(self._playerLst) do
        if val.player_id == uid then
            return val
        end
    end
end

function M:changePlayerBet(uid , bet)
    local data = self:getPlayerData(uid)
    data.staked_coin = bet
end

function M:getPlayerBet(uid)
    return self:getPlayerData(uid).staked_coin
end

function M:addPlayerData(data)
    self._playerLst = self._playerLst or {}
    table.insert(self._playerLst , data)
end

function M:randPlayerData()
    for __ , val in ipairs(self._playerLst) do
        if val.player_id ~= Game.playerDB:getPlayerUid() then
            return val
        end
    end
end

function M:erasePlayerData(uid)
    self._playerLst = self._playerLst or {}
    for i , data in ipairs(self._playerLst) do
        if data.player_id == uid then
            table.remove(self._playerLst , i)
            return
        end
    end
end

function M:cutPlayerCoin(uid , coin)
    local data = self:getPlayerData(uid)
    data.coin = data.coin - coin
end

function M:addPlayerCoin(uid , coin)
    local data = self:getPlayerData(uid)
    data.coin = data.coin + coin
end

function M:getPlayerCoin(uid)
    local data = self:getPlayerData(uid)
    return data.coin
end

function M:addPlayerBet(uid , val)
    local data = self:getPlayerData(uid)
    data.staked_coin = data.staked_coin + val
end

function M:getPlayerPos(uid)
    if not self._playerLst then
        return
    end
    local data = self:getPlayerData(uid)
    if not data then
        return
    end
    return data.pos
end

function M:getWinPos()
    return self:getPlayerPos(self._winner)
end

function M:getMyData()
    local uid = Game.playerDB:getPlayerUid()
    return self:getPlayerData(uid)
end

function M:getMyState()
    local uid = Game.playerDB:getPlayerUid()
    return self:getPlayerState(uid)
end

function M:getLeastCoin()
    local coin = self._playerLst[1].coin
    for __ , data in ipairs(self._playerLst) do
        if data.coin < coin and
            data.state ~= PlayerState.Idle and
            data.state ~= PlayerState.Prepare and
            data.state ~= PlayerState.GiveUp and
            data.state ~= PlayerState.CmpFail then
            coin = data.coin
        end
    end
    return coin
end

function M:getMyPos()
    local uid = Game.playerDB:getPlayerUid()
    local pos = self:getPlayerPos(uid)
    if not pos then
        return 4
    end
    return pos
end

return M.new()