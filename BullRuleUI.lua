
local UIer = require_ex("ui.common.UIer")
local BullRuleUI = class("BullRuleUI", UIer)

function BullRuleUI:ctor()
    UIer.ctor(self)
    self:init()
end

local RuleTab = {
    game = 1,
    rule = 2,
}

function BullRuleUI:init( )
    self._BindWidget = {
        ["panel_center"] = {},
        ["panel_touch"] = {handle = handler(self, self.onBackClicked)},
        ["panel_center/ScrollView_rule"] = {key = "sv_rule"},
        ["panel_center/Button_close"] = {key = "btn_close", handle = handler(self, self.onBackClicked)},
    }

    self._widgets = {}

    self:initViews()
end

function BullRuleUI:initViews(initLayer)
    if initLayer == nil then
        local uiNode = createCsbNode("subgame/bull/bull_rule.csb")
        self:addChild(uiNode, 1)

        bindWidgetList(uiNode, self._BindWidget, self._widgets)

        sideScrollBar(self._widgets.sv_rule)
    end
end

-------------------------------
function BullRuleUI:onBackClicked()
    
    self:destroy()
end

return BullRuleUI
