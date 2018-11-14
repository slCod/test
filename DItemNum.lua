--[[
	数字消消乐的每个节点
--]]
require( REQUIRE_PATH.."DCCBLayer")
-- 类定义
CDItemNum = class( "CDItemNum", CDCCBLayer)
CDItemNum.__index = CDItemNum

-- 构造函数
function CDItemNum:ctor()
    CDItemNum.super.ctor(self)
    CDItemNum.initialMember(self)
    
    local function onNodeEvent(event)
        if "exit" == event then
            CDItemNum.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

----------------------------------------------------------------------------
-- 释放
function CDItemNum:onExit()
    self:stopAllActions()
    CDItemNum.releaseMember(self)
    self:unregisterScriptHandler()
end

----------------------------------------------------------------------------
-- 初始化
function CDItemNum:initialMember()
    cclog("CDItemNum::initialMember")

    self.m_pSpritebase  = nil
    self.m_nShowNum     = 0
    self.m_pTxtNum      = nil
    self.m_pTouch       = nil

    self.m_pIndex_h     = 0
    self.m_pIndex_v     = 0

    self.m_pTargetPos_h  = 0
    self.m_pTargetPos_v  = 0 

    self.m_pInitPosX   = 29.5
    self.m_pInitPosY   = 410 
    self.m_pInitSpace  = 54.5
end

----------------------------------------------------------------------------
-- 释放
function CDItemNum:releaseMember()
    cclog("CDItemNum::releaseMember")
    --模拟析构父类
    CDItemNum.super.releaseMember(self)

    self:removeAllChildren(true)
    
    CDItemNum.initialMember(self)
end

-- 初始化
function CDItemNum:init()
    cclog("CDItemNum::init")
    return true
end

function CDItemNum:setItemNum( _num )
    self.m_nShowNum = _num
end

function CDItemNum:setShowNum( _num )
    self.m_nShowNum = _num
	self.m_pTxtNum:setString(_num)
end

function CDItemNum:getShowNum( ... )
    return self.m_nShowNum
end

function CDItemNum:setBVisible( b_visible )
	self:setVisible(b_visible)
end

function CDItemNum:setRGBColor( _color )
	self.m_pSpritebase:setColor(cc.c3b(_color.r,_color.g,_color.b))
end

function CDItemNum:setItemInitPosition( _h,_v )
    self.m_pIndex_h     = _h
    self.m_pIndex_v     = _v
    local startPos = cc.p(self.m_pInitSpace*(self.m_pIndex_h-1)+self.m_pInitPosX,self.m_pInitPosY-self.m_pInitSpace*(self.m_pIndex_v-1))
    self:setPosition(startPos)

end

function CDItemNum:getSelfPos( ... )
    local curPos = cc.p(self:getPositionX(),self:getPositionY())
    return curPos
end

function CDItemNum:setItemPosition( _h,_v )
	self.m_pTargetPos_h  = _h
    self.m_pTargetPos_v  = _v
end

function CDItemNum:moveToPos( _isMove,_second )

    local targetPos = cc.p(self.m_pInitSpace*(self.m_pTargetPos_h-1)+self.m_pInitPosX,self.m_pInitPosY-self.m_pInitSpace*(self.m_pTargetPos_v-1))
    if  _isMove then
        if  not _second or _second <= 0 then
            _second = 0.5
        end
	   self:runAction( cc.MoveTo:create( _second, targetPos))
    else
        self:setPosition(targetPos)
    end
end

function CDItemNum:getTargetIndex( ... )
    return self.m_pTargetPos_v,self.m_pTargetPos_h
end
----------------------------------------------------------------------------
-- 是否点中
-- 参数: 点
-- 返回: 是否选中
function CDItemNum:touchInFromPoint( point)

    if  self.m_pTouch == nil then
        return false
    end

    local sPoint = self.m_pTouch:getParent():convertToNodeSpace( point)
    local rect = self.m_pTouch:getBoundingBox()
    if  cc.rectContainsPoint( rect, sPoint) then
        return true
    end
    return false
end
----------------------------------------------------------------------------
-- ccb处理-变量绑定
function CDItemNum:onAssignCCBMemberVariable(loader)
    cclog("CDItemNum::onAssignCCBMemberVariable")

    self.m_pSpritebase  = loader["sprite_base"]
    self.m_pTxtNum      = loader["numTxt"]
    self.m_pTouch       = loader["touch"]

    return true
end

----------------------------------------------------------------------------
-- ccb处理-函数绑定
function CDItemNum:onResolveCCBCCControlSelector(loader)
    cclog("CDItemNum::onResolveCCBCCControlSelector")
end

----------------------------------------------------------------------------
-- 创建卡牌对象
function CDItemNum.createCDItemNum( pParent)
    cclog("CDItemNum::createCDItemNum")

    if not pParent then
        return nil
    end

    local layer = CDItemNum.new()
    layer:init()
    local loader = layer.m_ccbLoader
    layer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad( "CDItemNum.ccbi",proxy,loader)

    layer:setAnchorPoint( node:getAnchorPoint())
    layer:setContentSize( node:getContentSize())

    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild( node)
    pParent:addChild(layer)
    return layer
end