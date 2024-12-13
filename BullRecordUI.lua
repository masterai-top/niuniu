
local UIer = require_ex("ui.common.UIer")
local BullRecordUI = class("BullRecordUI", UIer)

local SpineHL = {res="subgame/bull/spine/bairenniuniu_shengfuzoushi", ani="animation", isLoop=true}

function BullRecordUI:ctor()
    UIer.ctor(self)
    self:init()
end

local ResultIcon = {
    [0] = "subgame/bull/icon/BaiRenNiuNiu_Board_18.png", -- 胜
    [1] = "subgame/bull/icon/BaiRenNiuNiu_Board_17.png", -- 负
    [2] = "subgame/bull/icon/BaiRenNiuNiu_Board_15.png", -- 胜(高亮)
    [3] = "subgame/bull/icon/BaiRenNiuNiu_Board_16.png", -- 负(高亮)
}

function BullRecordUI:init( )
    self._BindWidget = {
        ["panel_item_rec"] = {},
        ["panel_item_rec_01"] = {key = "panel_item_reced"},
        ["panel_center"] = {},
        ["panel_touch"] = {handle = handler(self, self.onBackClicked)},
        ["panel_center/Button_close"] = {key = "btn_close", handle = handler(self, self.onBackClicked)},
        ["panel_center/ListView_reward"] = {key = "lv_record"},
        ["panel_center/Image_hl"] = {key = "img_hl"},
    }

    self._widgets = {}

    self:initViews()
end

function BullRecordUI:initViews(initLayer)
    if initLayer == nil then
        local uiNode = createCsbNode("subgame/bull/bull_record.csb")
        self:addChild(uiNode, 1)

        bindWidgetList(uiNode, self._BindWidget, self._widgets)
    end

    if self._widgets.img_hl then
        local size = self._widgets.img_hl:getContentSize()
        local spineHL = require_ex("ui.common.Actor"):new(SpineHL.res, SpineHL)
        spineHL:setPosition(size.width / 2 + 3, size.height / 2)
        spineHL:setScaleX(1.1)
        self._widgets.img_hl:addChild(spineHL)
    end

    self:initRecordInfo()
end

-- 历史记录
function BullRecordUI:initRecordInfo()
    self._widgets.lv_record:stopAllActions()
    self._widgets.lv_record:removeAllItems()
    local recordList = Game.bullDB:getRecordList()
    for ridx, record in ipairs(recordList) do
        record = record.ret_list or record
        local item
        if ridx == 1 then
            item = self._widgets.panel_item_rec:clone()
        else
            item = self._widgets.panel_item_reced:clone()
        end
        local idx, result
        for i, v in ipairs(record) do
            idx, result = i, v
            if type(v) == "table" then
                idx, result = v.area, v.result
            end
            local imgIcon = item:getChildByName("Image_r"..idx)
            if imgIcon and ResultIcon[result] then
                if ridx == 1 then
                    result = result + 2
                end
                fitIconSize(imgIcon, ResultIcon[result])
            end
        end
        item:setVisible(true)
        self._widgets.lv_record:pushBackCustomItem(item)
    end
    self._widgets.lv_record:jumpToLeft()
end

function BullRecordUI:updateRecordInfo()
    self:initRecordInfo()
end

-------------------------------
function BullRecordUI:onBackClicked()
    
    self:destroy()
end

return BullRecordUI
