--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       CDMahjongHHLLKLlkItem
//File Name:    HHLLK_llk_item.h
//Author:       GostYe
//Start Data:   2016.03.1
//Language:     XCode 4.5
//Target:       IOS, Android
****************************************************************************/
]]

require( REQUIRE_PATH.."DCCBHHLLKBaseLayer")

----------------------------------------------------------------------------
CDMahjongHHLLKLlkItem = class( "CDMahjongHHLLKLlkItem", CDCCBHHLLKBaseLayer)
CDMahjongHHLLKLlkItem.__index = CDMahjongHHLLKLlkItem

----------------------------------------------------------------------------
function CDMahjongHHLLKLlkItem:ctor()
    CDMahjongHHLLKLlkItem.super.ctor(self)
    CDMahjongHHLLKLlkItem.initialMember(self)
    
    local function onNodeEvent(event)
        if "exit" == event then
            CDMahjongHHLLKLlkItem.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

----------------------------------------------------------------------------
function CDMahjongHHLLKLlkItem:onExit()
    self:stopAllActions()
    CDMahjongHHLLKLlkItem.releaseMember(self)
    self:unregisterScriptHandler()
end

----------------------------------------------------------------------------
CDMahjongHHLLKLlkItem.m_pHHLLKTouch = nil
CDMahjongHHLLKLlkItem.m_pHHLLKGridColor = nil 
CDMahjongHHLLKLlkItem.m_pHHLLKSelect = nil

CDMahjongHHLLKLlkItem.m_nHHLLKSizeW = 0         
CDMahjongHHLLKLlkItem.m_nHHLLKSizeH = 0     

CDMahjongHHLLKLlkItem.m_pHHLLKEffect = nil      

----------------------------------------------------------------------------
-- ³õÊ¼»¯
function CDMahjongHHLLKLlkItem:initialMember()
    cclog("CDMahjongHHLLKLlkItem::initialMember")

    self.m_pHHLLKTouch = nil
    self.m_pHHLLKGridColor = nil
    self.m_pHHLLKSelect = nil

    self.m_pHHLLKBack = nil

    self.m_nHHLLKSizeW = nil
    self.m_nHHLLKSizeH = nil
    self.m_pHHLLKEffect = nil
end

----------------------------------------------------------------------------
function CDMahjongHHLLKLlkItem:releaseMember()
    cclog("CDMahjongHHLLKLlkItem::releaseMember")
    CDMahjongHHLLKLlkItem.super.releaseMember(self)

    if  self.m_pHHLLKEffect ~= nil then
        self.m_pHHLLKEffect:stopAllActions()
        self:removeChild( self.m_pHHLLKEffect)
        self.m_pHHLLKEffect = nil
    end

    self.m_pHHLLKTouch = nil
    self.m_pHHLLKSelect = nil

    CDMahjongHHLLKLlkItem.initialMember(self)
end

----------------------------------------------------------------------------
function CDMahjongHHLLKLlkItem:init()
    cclog("CDMahjongHHLLKLlkItem::init")
    return true
end

----------------------------------------------------------------------------
-- 颜色设定
function CDMahjongHHLLKLlkItem:setColor(_rgb)
    if  self.m_pHHLLKGridColor == nil then
        return
    end

    self.m_pHHLLKGridColor:setColor(_rgb)
    self.m_pHHLLKEffect:setColor(_rgb)
    self.m_pHHLLKGridColor:setVisible(true)
end

function CDMahjongHHLLKLlkItem:closeColorShow()
    self.m_pHHLLKGridColor:setVisible(false)
end

----------------------------------------------------------------------------
-- 选择图片显隐设置
function CDMahjongHHLLKLlkItem:setSelectVisible(_select)
    if  self.m_pHHLLKSelect == nil then
        return
    end

    if  _select == nil then
        _select = false
    end

    self.m_pHHLLKSelect:setVisible(_select)
end

----------------------------------------------------------------------------
-- 积分设置显示
function CDMahjongHHLLKLlkItem:setScoreNum(_num)
    if  self.m_pHHLLKEffect == nil or _num == nil then
        return
    end

    local tmpStr = "+".._num
    self.m_pHHLLKEffect:setString(tmpStr)
end

function CDMahjongHHLLKLlkItem:setScoreAction(_delayTime)
    if  self.m_pHHLLKEffect == nil then
        return
    end
    self.m_pHHLLKEffect:setVisible(false)
    self.m_pHHLLKEffect:setScale(1.0)
    self.m_pHHLLKEffect:setOpacity(255)
    self.m_pHHLLKEffect:setVisible(true)
    self.m_pHHLLKEffect:runAction(cc.Sequence:create(cc.DelayTime:create(_delayTime), cc.Spawn:create(cc.ScaleTo:create(0.5, 1.5), cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
        self.m_pHHLLKEffect:setVisible(false)
    end))), cc.FadeOut:create(0.6)))
end

----------------------------------------------------------------------------
function CDMahjongHHLLKLlkItem:checkWithTouchPoint(point)
    if  self.m_pHHLLKTouch == nil then
        return false
    end

    local sPoint = self.m_pHHLLKTouch:getParent():convertToNodeSpace(point)
    local rect = self.m_pHHLLKTouch:getBoundingBox()
    if cc.rectContainsPoint(rect, sPoint) then
        return true
    end
    return false
end

----------------------------------------------------------------------------
function CDMahjongHHLLKLlkItem:getMahjongSize()
    if  self.m_pHHLLKTouch ~= nil then
        local size = self.m_pHHLLKTouch:getContentSize()
        self.m_nHHLLKSizeW = size.width
        self.m_nHHLLKSizeH = size.height
    end
end

---------------------------------------------------------------------------
function CDMahjongHHLLKLlkItem:onAssignCCBMemberVariable(loader)

    self.m_pHHLLKTouch = loader["gauge_point_node"]
    self.m_pHHLLKGridColor = loader["change_color"]
    self.m_pHHLLKSelect = loader["select_eff"]
    self.m_pHHLLKEffect = loader["score_label"]

    return true
end

----------------------------------------------------------------------------
function CDMahjongHHLLKLlkItem:onResolveCCBCCControlSelector(loader)
end


----------------------------------------------------------------------------
function CDMahjongHHLLKLlkItem.createCDMahjong( pParent)
    cclog("CDMahjongHHLLKLlkItem::createCDMahjong")

    if not pParent then
        return nil
    end

    local insLayer = CDMahjongHHLLKLlkItem.new()
    insLayer:init()
    local loader = insLayer.m_ccBaseLoader
    insLayer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad( "CDMahjong_item.ccbi",proxy,loader)

    insLayer:setAnchorPoint( node:getAnchorPoint())
    insLayer:setContentSize( node:getContentSize())

    insLayer.m_ccBaseLayer = node
    insLayer:onAssignCCBMemberVariable(loader)
    insLayer:addChild( node)
    pParent:addChild(insLayer)
    insLayer:getMahjongSize()
    return insLayer
end