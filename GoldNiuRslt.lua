-- @Author: ZhuL
-- @Date:   2017-05-17 13:22:34
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-05-18 10:37:12


local UIer = require_ex("ui.common.UIer")
local M = class("GoldNiuRslt", UIer)

function M:ctor(ctrler , data)
    UIer.ctor(self)

    self._root = nil

    self._ctrler = ctrler

    self._DB = ctrler:getDB()

    self._widget = {}

    self._data = data

    self:init()
end

function M:init()
    self:initWidget()
    self:initView()
end

function M:initView()
    local widget = self._widget
    local data = self._data
    dump(data)
    local playerData = self._DB:getPlayerData(data.player_id)
    widget.txtName:setString(playerData.name)
    widget.txtCoin:setString(playerData.coin)
    widget.txtVip:setString("vip" .. playerData.vip_lv)
    widget.imgAvatar:loadTexture(cfg_util.getFacelook(playerData.facelook))

    showPokers(widget.panelPoker , data.hand_cards)
end

function M:initWidget()
    self._root = createCsbNode("subgame/Niuniu/settlement.csb")
    self:addChild(self._root)

    local tab = {
        ["panel"] = {key = "panel" , handle = handler(self , self.onClose)},
        ["panel/pointAnim"] = {key = "pointAnim"},
        ["panel/imgAvatar"] = {key = "imgAvatar"},
        ["panel/txtCoin"] = {key = "txtCoin"},
        ["panel/txtName"] = {key = "txtName"},
        ["panel/txtVip"] = {key = "txtVip"},
        ["panel/panelPoker"] = {key = "panelPoker"}
    }

    bindWidgetList(self._root , tab , self._widget)

    clonePoker(self._widget.panelPoker)
end


return M