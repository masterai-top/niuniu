-- @Author: ZhuL
-- @Date:   2017-05-02 10:13:52
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-05-02 11:24:28

-- 用于选择难度的界面

local UIer = require_ex("ui.common.UIer")
local M = class("Entry", UIer)

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

function M:initWidget()
    -- body
end

function M:initView()
    -- body
end

return M