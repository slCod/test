--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       CDMahjongHHLLKGrid
//File Name:    HHLLK_llk_grid.h
//Author:       GostYe
//Start Data:   2016.03.1
//Language:     XCode 4.5
//Target:       IOS, Android
****************************************************************************/
]]

require( REQUIRE_PATH.."DCCBHHLLKBaseLayer")

----------------------------------------------------------------------------
CDMahjongHHLLKGrid = class( "CDMahjongHHLLKGrid", CDCCBHHLLKBaseLayer)
CDMahjongHHLLKGrid.__index = CDMahjongHHLLKGrid

----------------------------------------------------------------------------
function CDMahjongHHLLKGrid:ctor()
    CDMahjongHHLLKGrid.super.ctor(self)
    CDMahjongHHLLKGrid.initialMember(self)
    
    local function onNodeEvent(event)
        if "exit" == event then
            CDMahjongHHLLKGrid.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

----------------------------------------------------------------------------
function CDMahjongHHLLKGrid:onExit()
    self:stopAllActions()
    CDMahjongHHLLKGrid.releaseMember(self)
    self:unregisterScriptHandler()
end

----------------------------------------------------------------------------
CDMahjongHHLLKGrid.m_pHHLLKRoot  = nil
CDMahjongHHLLKGrid.m_nGridIndex  = 0
CDMahjongHHLLKGrid.m_nTouchIndex = 0
CDMahjongHHLLKGrid.m_pRgb  = nil
CDMahjongHHLLKGrid.m_nHHLLKSizeW = 0
CDMahjongHHLLKGrid.m_nHHLLKSizeH = 0
CDMahjongHHLLKGrid.m_nHHLLKType = 0

----------------------------------------------------------------------------
-- ≥ı ºªØ
function CDMahjongHHLLKGrid:initialMember()
    cclog("CDMahjongHHLLKGrid::initialMember")
end

----------------------------------------------------------------------------
function CDMahjongHHLLKGrid:releaseMember()
    cclog("CDMahjongHHLLKGrid::releaseMember")
    CDMahjongHHLLKGrid.super.releaseMember(self)

    if  self.m_pHHLLKRoot then
        self.m_pHHLLKRoot:removeAllChildren(true)
    end
    
    CDMahjongHHLLKGrid.initialMember(self)
end

----------------------------------------------------------------------------
function CDMahjongHHLLKGrid:init()
    cclog("CDMahjongHHLLKGrid::init")
    return true
end

----------------------------------------------------------------------------
function CDMahjongHHLLKGrid:initMahjongWithFile(file_mahjong, type)
    cclog("CDMahjongHHLLKGrid::initMahjongWithFile")

    if  self.m_pHHLLKRoot == nil then
        return
    else
        self.m_pHHLLKRoot:removeAllChildren()
        self.m_pHHLLKDefine = nil
    end

    if  file_mahjong ~= nil then
        self.m_nHHLLKType = type
        self.m_pHHLLKDefine = cc.Sprite:createWithSpriteFrameName( file_mahjong)
        self.m_pHHLLKRoot:addChild(self.m_pHHLLKDefine)
        if  self.m_nHHLLKType == 0 then
            self.m_pHHLLKDefine:setPosition(cc.p(0, 0))
            self.m_pHHLLKDefine:setAnchorPoint(0, 0)
        elseif self.m_nHHLLKType == 1 then
            self.m_pHHLLKDefine:setPosition(cc.p(0, 51))
            self.m_pHHLLKDefine:setAnchorPoint(0, 1)
        end
        self.m_pHHLLKDefine:setVisible(true)
        local size = self.m_pHHLLKDefine:getContentSize()
        self.m_nHHLLKSizeW = size.width
        self.m_nHHLLKSizeH = size.height
    else
        self.m_pHHLLKDefine = nil
    end
end

function CDMahjongHHLLKGrid:setPos(_pos)
    local tmpX = _pos.x - (self.m_nHHLLKSizeW - 51/2 + 102)
    local tmpY = 0
    if  self.m_nHHLLKType == 0 then
        tmpY = _pos.y - (self.m_nHHLLKSizeH / 2 - 51/2)
    elseif self.m_nHHLLKType == 1 then
        tmpY = _pos.y + (self.m_nHHLLKSizeH / 2 - 51/2)
    end

    self:setPosition(cc.p(tmpX, tmpY))
    return cc.p(tmpX, tmpY)
end

----------------------------------------------------------------------------
function CDMahjongHHLLKGrid:setGridIndex(_nIndex)
    self.m_nGridIndex = _nIndex
end

function CDMahjongHHLLKGrid:setTouchIndex(_nIndex)
    self.m_nTouchIndex = _nIndex
end

function CDMahjongHHLLKGrid:setRgb(_rgb)
    if  self.m_pHHLLKDefine then
        self.m_pHHLLKDefine:setColor(_rgb)
    end
    self.m_pRgb = _rgb
end

----------------------------------------------------------------------------
function CDMahjongHHLLKGrid:onAssignCCBMemberVariable(loader)

    self.m_pHHLLKRoot  = loader["sprite_node"]
    return true
end

----------------------------------------------------------------------------
function CDMahjongHHLLKGrid:onResolveCCBCCControlSelector(loader)
end

----------------------------------------------------------------------------
function CDMahjongHHLLKGrid.createCDMahjong( pParent)
    cclog("CDMahjongHHLLKGrid::createCDMahjong")

    if not pParent then
        return nil
    end

    local insLayer = CDMahjongHHLLKGrid.new()
    insLayer:init()
    local loader = insLayer.m_ccBaseLoader
    insLayer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad( "CDMahjong_grid.ccbi",proxy,loader)

    insLayer:setAnchorPoint( node:getAnchorPoint())
    insLayer:setContentSize( node:getContentSize())

    insLayer.m_ccBaseLayer = node
    insLayer:onAssignCCBMemberVariable(loader)
    insLayer:addChild( node)
    pParent:addChild(insLayer)
    return insLayer
end