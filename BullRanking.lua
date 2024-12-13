-- @Author: ZhuL
-- @Date:   2017-05-02 15:21:10
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-05-02 15:21:27


local UIer = require_ex("ui.common.UIer")
local M = class("BullRanking", UIer)

function M:ctor(ctrler)
    UIer.ctor(self)

    self._ctrler = ctrler

    self._root = nil

    self._widget = {}

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
    -- body
end

function M:initView()
    -- body
end

return M