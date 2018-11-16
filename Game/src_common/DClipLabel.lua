--[[
/******************************************************
 //Project:      ProjectMSS
 //Moudle:       CDClipLabel
 //File Name:    DClipLabel.lua
 //Author:       Tuanzi
 //Start Data:   2015.01.15
 //Language:     XCode 6.0
 //Target:       IOS, Android
 
 MSS－范围内显示的文字
 
 ******************************************************/
]]
-----------------------------------------
-- 类定义
CDClipLabel = class("CDClipLabel",
    function()
        return cc.ClippingNode:create()
    end
)

CDClipLabel.__index = CDClipLabel

-- 构造函数
function CDClipLabel:ctor()
    cclog("CDClipLabel::ctor")
end


-----------------------------------------
-- 成员变量定义

CDClipLabel.m_pContent = nil        --文字控件
CDClipLabel.m_sSize = nil           --文字范围
CDClipLabel.m_sTouchContent = nil   --点击起点

-----------------------------------------
-- 初始化
function CDClipLabel:init( sSize)
    --cclog("CDClipLabel::init")
    self.m_sSize = cc.size( sSize.width, sSize.height)
    self:setContentSize( self.m_sSize)
    self.m_pContent = cc.LabelTTF:create("", DEF_FONT_TTF_BOLD, 22)
    self.m_pContent:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    self.m_pContent:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    self.m_pContent:setDimensions(cc.size(self.m_sSize.width, 0))
    self.m_pContent:setContentSize(cc.size(self.m_sSize.width, 0))
    self.m_pContent:setAnchorPoint(cc.p(0.0, 1.0))
    self.m_pContent:setPosition(cc.p(0, self.m_sSize.height))
    
    local shap = cc.DrawNode:create()
    shap:drawPolygon({cc.p(0,0),cc.p(self.m_sSize.width,0),cc.p(self.m_sSize.width,self.m_sSize.height),cc.p(0,self.m_sSize.height)}, 
        4, cc.c4f(1,1,1,1), 2, cc.c4f(1,1,1,1))
    self:setStencil(shap)
    self:addChild(self.m_pContent)
    self.m_sTouchContent = nil
    return true
end

-----------------------------------------
-- 功能函数

-- 点击相关处理
function CDClipLabel:touchBegan( touch)
    self.m_sTouchContent = nil
    if self.m_pContent:getContentSize().height > self.m_sSize.height then
        local sJudge = self:convertToNodeSpace( touch:getLocation());
        local sBox = cc.rect(0, 0, self.m_sSize.width, self.m_sSize.height)
        if cc.rectContainsPoint(sBox, sJudge) then
            self.m_sTouchContent = cc.p(sJudge)
            return true
        end
    end
    return false
end

function CDClipLabel:touchMoved( touch)

    if self.m_sTouchContent then
        local delta = touch:getDelta()
        local newPos = cc.p(0, self.m_pContent:getPositionY() + delta.y)
        if newPos.y < self.m_sSize.height then
            newPos.y = self.m_sSize.height
        elseif newPos.y > self.m_pContent:getContentSize().height then
            newPos.y = self.m_pContent:getContentSize().height
        end
        --cclog("test labelHeight:%d, newPosY:%d", self.m_pContent:getContentSize().height, newPos.y)
        self.m_pContent:setPosition(newPos)
    end
end

function CDClipLabel:touchEnded( touch)

    self.m_sTouchContent = nil
end

-- 设置文字
function CDClipLabel:setLabelString( strContent)
    self.m_pContent:setString( strContent)
    self.m_pContent:setPosition(cc.p(0, self.m_sSize.height))
end

-- 设置范围
function CDClipLabel:setLabelSize( sSize)
    self.m_sSize = cc.size( sSize.width, sSize.height)
    self:setContentSize( self.m_sSize)
    self.m_pContent:setDimensions(cc.size(self.m_sSize.width, 0))
    self.m_pContent:setContentSize(cc.size(self.m_sSize.width, 0))
    self.m_pContent:setPosition(cc.p(0, self.m_sSize.height))

    local shap = cc.DrawNode:create()
    shap:drawPolygon({cc.p(0,0),cc.p(self.m_sSize.width,0),cc.p(self.m_sSize.width,self.m_sSize.height),cc.p(0,self.m_sSize.height)}, 
        4, cc.c4f(1,1,1,1), 2, cc.c4f(1,1,1,1))
    self:setStencil(shap)
end


-----------------------------------------
-- create
function CDClipLabel.createCDClipLabel( pParent, sSize, sAnchor, sPos)
    if sSize == nil then sSize = cc.size(200, 200) end
    if sAnchor == nil then sAnchor = cc.p(0, 0) end
    if sPos == nil then sPos = cc.p(0, 0) end
    if not pParent then
        return nil
    end
    local layer = CDClipLabel.new()
    layer:init( sSize)
    layer:setAnchorPoint( sAnchor)
    layer:setPosition( sPos)
    pParent:addChild( layer)
    return layer
end
