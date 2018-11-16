--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       CDBalloonItem
//File Name:    llk_item.h
//Author:       GostYe
//Start Data:   2016.03.1
//Language:     XCode 4.5
//Target:       IOS, Android
****************************************************************************/
]]

require( REQUIRE_PATH.."DCCBLayer")

----------------------------------------------------------------------------
-- Àà¶¨Òå
CDBalloonItem = class( "CDBalloonItem", CDCCBLayer)
CDBalloonItem.__index = CDBalloonItem

local BalloonSprite = {"Red","Blue","Golden"}
local BalloonSpeed1  ={9,11,13}
local BalloonSpeed2  = {7,9,11}   --挑战模式
local BalloonColor = {["Red"]=1,["Blue"]=2,["Golden"]=3}

local finalScreen = CDGlobalMgr:sharedGlobalMgr():getWinSize()

DEF_SOUND_BALLOON       = "balloon_boom"..DEF_TKD_SOUND        -- 气球爆炸声

----------------------------------------------------------------------------
-- ¹¹Ôìº¯Êý
function CDBalloonItem:ctor()
    CDBalloonItem.super.ctor(self)
    CDBalloonItem.initialMember(self)
    
    local function onNodeEvent(event)
        if "exit" == event then
            CDBalloonItem.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

----------------------------------------------------------------------------
-- ÊÍ·Å
function CDBalloonItem:onExit()
    self:stopAllActions()
    CDBalloonItem.releaseMember(self)
    self:unregisterScriptHandler()
end

----------------------------------------------------------------------------
-- ³ÉÔ±±äÁ¿¶¨Òå
CDBalloonItem.m_pRoot = nil         
CDBalloonItem.m_pTouch = nil       

CDBalloonItem.m_pDefine = nil      

CDBalloonItem.m_nSizeW = 0              
CDBalloonItem.m_nSizeH = 0          

CDBalloonItem.m_pAniManager = nil  
CDBalloonItem.m_pEffect = nil       

CDBalloonItem.m_nSpeed = 0       

CDBalloonItem.m_nColor = 0

CDBalloonItem.schedulerID = nil         --定时器

CDBalloonItem.isDestroy = false    
CDBalloonItem.isBeyondPos = false   --是否超出边界
----------------------------------------------------------------------------
-- ³õÊ¼»¯
function CDBalloonItem:initialMember()
    cclog("CDBalloonItem::initialMember")

    self.m_pRoot = nil
    self.m_pTouch = nil
    self.m_pDefine = nil
    
    self.m_nSizeW = nil
    self.m_nSizeH = nil
    self.m_pAniManager = nil
    self.m_nDelayAniID = 0
    self.m_pEffect = nil

    self.m_nSpeed = 0
    self.m_nColor = 0

    self.schedulerID = nil  
    self.isDestroy = false   
    self.isBeyondPos = false 
    self:destroyTimer()
    self:cleanup() 
      
end

----------------------------------------------------------------------------
-- ÊÍ·Å
function CDBalloonItem:releaseMember()
    cclog("CDBalloonItem::releaseMember")
    --Ä£ÄâÎö¹¹¸¸Àà
    CDBalloonItem.super.releaseMember(self)

    CC_SAFE_RELEASE_NULL(self.m_pAniManager)
    self.m_pAniManager = nil

    if  self.m_pRoot then
        self.m_pRoot:removeAllChildren(true)
    end

    if  self.m_pEffect ~= nil then
        self:removeChild( self.m_pEffect)
        self.m_pEffect = nil
    end

    self.m_pRoot = nil
    self.m_pTouch = nil

    self.m_pDefine = nil

    if DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end
    CDBalloonItem.initialMember(self)
end

----------------------------------------------------------------------------
-- ³õÊ¼»¯
function CDBalloonItem:init()
    cclog("CDBalloonItem::init")
    return true
end

----------------------------------------------------------------------------
-- ÉèÖÃÅÆ
-- ²ÎÊý: Ä¬ÈÏ×´Ì¬
function CDBalloonItem:setBalloon( file_bal,x,y,falg)

    if  self.m_pRoot then

        self.m_pRoot:removeAllChildren()
        self.m_pDefine = nil
    end

    if  file_bal ~= nil then

        self.m_pDefine = cc.Sprite:create( string.format("balloon_"..file_bal..".png"))
        self.m_pRoot:addChild(self.m_pDefine)
        self.m_pDefine:setVisible(true)
    end
   
    --设置速度和颜色
    local chooseSpeedArr 
    if falg == 4 then
        chooseSpeedArr = BalloonSpeed2
    else
        chooseSpeedArr = BalloonSpeed1
    end

    if file_bal == BalloonSprite[1] then
        self:setBalloonSpeed(chooseSpeedArr[1])

    elseif  file_bal == BalloonSprite[2] then
        self:setBalloonSpeed(chooseSpeedArr[2]) 
    else
        self:setBalloonSpeed(chooseSpeedArr[3])
    end

    if  file_bal ~= nil then
        self:setBalloonColor(BalloonColor[file_bal])
    end
    
    self:initTimer(x,y)
    
 
end

--启动定时器
function CDBalloonItem:initTimer(x,y)
    local index = 1
    local speed = self:getBalloonSpeed()
    local function callback()

        local tempY = y+speed*index
        if tempY>= finalScreen.height+50 then
            self.isBeyondPos = true
        else
            if self then
                self:setPosition(cc.p(x,tempY))
            end
        end
        index = index+1

        if self.isDestroy or self.isBeyondPos then
            self:setVisible(false)
            self:destroyTimer()
            self:cleanup()
        end
    end 

    if not self.schedulerID then
        self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback,0.05,false)
    end
end

function CDBalloonItem:destroyTimer( )
    if  self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)   
        self.schedulerID=nil
    end
end


----------------------------------------------------------------------------
-- ÉèÖÃÅÆÊýÖµ
function CDBalloonItem:setBalloonSpeed(speed)
    self.m_nSpeed = speed
end

function CDBalloonItem:getBalloonSpeed()
    return self.m_nSpeed
end

---------------------------------------------------------------------------
function CDBalloonItem:setBalloonColor(color)
    self.m_nColor = color
end

function CDBalloonItem:getBalloonColor( ... )
    return self.m_nColor
end


----------------------------------------------------------------------------
-- ÉèÖÃÅÆËõ·Å
function CDBalloonItem:setMahjongScale( scale)
    if  self.m_pRoot then
        self.m_pRoot:setScale( scale)
    end
end

----------------------------------------------------------------------------
-- ÉèÖÃ±»Ñ¡ÖÐµÄÑÕÉ«ÏÔÊ¾
-- ÊÇ·ñÑ¡ÖÐ
function CDBalloonItem:setSelectedColor(bSelect)
    bSelect = bSelect or false

    if  self.m_pDefine then

        if  bSelect then
            self.m_pDefine:setColor(cc.c3b(255,255,0))
        else
            self.m_pDefine:setColor(cc.c3b(255,255,255))
        end
    end
end

----------------------------------------------------------------------------

function CDBalloonItem:touchInFromPoint(point)
    if  self.m_pTouch == nil then
        return false
    end

    local sPoint = self.m_pTouch:getParent():convertToNodeSpace(point)
    local rect = self.m_pTouch:getBoundingBox()
    if cc.rectContainsPoint( rect, sPoint) then
        self.isDestroy = true
        dtPlaySound(DEF_SOUND_BALLOON)
       
        return true
    end
    return false
end

----------------------------------------------------------------------------
-- »ñÈ¡³ß´ç
function CDBalloonItem:getMahjongSize()
    if  self.m_pTouch ~= nil then
        local size = self.m_pTouch:getContentSize()
        self.m_nSizeW = size.width
        self.m_nSizeH = size.height
    end
end

----------------------------------------------------------------------------
-- function CDBalloonItem:PlayBalloonAnimation()

--     local spfc = cc.SpriteFrameCache:getInstance()
--     spfc:addSpriteFrames("x_balloon.plist")

   
--     local originalSprite = cc.Sprite:createWithSpriteFrameName("0.png")
--     originalSprite:setPosition(cc.p(500,500))
--     self:addChild(originalSprite)

--     local animation = cc.Animation:create()
--     for i = 0, 15 do
--     local frameName = string.format("%d.png",i)
--     cclog("frameName =%s",frameName)
--       animation:addSpriteFrame(spfc:getSpriteFrame(frameName))
--     end
    
--     -- 设置每帧延时
--     animation:setDelayPerUnit(0.04)
--     -- 设置动画播放完成后是否回到起始帧
--     animation:setRestoreOriginalFrame(true)
   
--     -- 根据当前动画配置生成Action
--     local action = cc.Animate:create(animation)
--     --调用Sprite的runAction方法可以看到效果了
--     originalSprite:runAction(cc.Sequence:create(action))

--end

----------------------------------------------------------------------------
-- Ìí¼ÓÌØÐ§
function CDBalloonItem:addEffect( file, time)

    self:stopAllActions()

    if  self.m_pEffect ~= nil then
        self:removeChild( self.m_pEffect)
        self.m_pEffect = nil
    end

    local function removeEffect()

        if  self.m_pEffect ~= nil then
            self:removeChild( self.m_pEffect)
            self.m_pEffect = nil
        end
    end

    self.m_pEffect = CDCCBAniObject.createCCBAniObject( self, file, cc.p( 50,50), 0)
    if  self.m_pEffect then
        self.m_pEffect:setScale( self.m_pRoot:getScaleX())
        self.m_pEffect:endVisible( false)
        self.m_pEffect:endRelease( false)
        self:runAction( cc.Sequence:create( cc.DelayTime:create( time), cc.CallFunc:create( removeEffect)))
    end
end

----------------------------------------------------------------------------
-- ccb´¦Àí-±äÁ¿°ó¶¨
function CDBalloonItem:onAssignCCBMemberVariable(loader)
    cclog("CDBalloonItem::onAssignCCBMemberVariable")

    self.m_pRoot  = loader["scale_root"]
    self.m_pTouch = loader["touch"]

    if  nil ~= loader["mAnimationManager"] then
        local animationMgr = loader["mAnimationManager"]
        self:setAniManager(animationMgr)
    end

    return true
end

----------------------------------------------------------------------------
-- ccb´¦Àí-º¯Êý°ó¶¨
function CDBalloonItem:onResolveCCBCCControlSelector(loader)
    cclog("CDBalloonItem::onResolveCCBCCControlSelector")
end

----------------------------------------------------------------------------
-- ÑÓ³Ù¶¯»­²¥·Å
-- ²ÎÊý: ¶¯»­±àºÅ, ÑÓ³ÙµÄÊ±¼ä
function CDBalloonItem:delayAnimations( delay_ani_id, time)

    function delay_run_animation()

        self:runAnimations( self.m_nDelayAniID, 0)
    end

    if  time <= 0 then
        self:runAnimations( delay_ani_id, 0)
    else
        self.m_nDelayAniID = delay_ani_id
        self:runAction( cc.Sequence:create( cc.DelayTime:create( time), cc.CallFunc:create( delay_run_animation)))
    end
end

----------------------------------------------------------------------------
-- »ñÈ¡¡¢ÉèÖÃ¶¯»­¿ØÖÆÆ÷
function CDBalloonItem:setAniManager( pM)

    CC_SAFE_RELEASE_NULL(self.m_pAniManager)
    self.m_pAniManager = pM;
    if  self.m_pAniManager then
        self.m_pAniManager:retain()
    end
end
function CDBalloonItem:getAniManager()
    return self.m_pAniManager
end

----------------------------------------------------------------------------
-- ²¥·Å¶¯»­¸ù¾ÝË÷ÒýºÅ£¬»òÕß¶¯»­Ãû
function CDBalloonItem:runAnimations( nSeqId, fTweenDuration)
    if  self.m_pAniManager then
        cclog("CDBalloonItem::runAnimations seqid")
        self.m_pAniManager:runAnimationsForSequenceIdTweenDuration( nSeqId, fTweenDuration)
        self:setCompletedCallback(fTweenDuration)
    end
end

----------------------------------------------------------------------------
-- Ìí¼ÓÉèÖÃ¶¯»­²¥·Å½áÊø»Øµ÷·½·¨
function CDBalloonItem:setCompletedCallback(fTweenDuration)
    --cclog("CDCCBAniNode::setCompletedCallback")
    if  self.m_pAniManager then
        local name = self.m_pAniManager:getRunningSequenceName()
        if name == "" then
            cclog("no running animation")
            return
        end
        local duration = self.m_pAniManager:getSequenceDuration(name)
        local function onCompleted()
            self:completedAnimationSequenceNamed(name)
        end
        self:stopAllActions()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(duration + fTweenDuration), cc.CallFunc:create(onCompleted)))
    end
end

----------------------------------------------------------------------------
-- ¶¯»­²¥·ÅÍêµÄ»Øµ÷´¦Àí
function CDBalloonItem:completedAnimationSequenceNamed(name)
    --cclog("CDCCBAniNode::completedAnimationSequenceNamed")
end

----------------------------------------------------------------------------
-- ´´½¨ÅÆ¶ÔÏó
function CDBalloonItem.createCDBalloon( pParent)
    cclog("CDBalloonItem::createCDMahjong")

    if not pParent then
        return nil
    end

    local layer = CDBalloonItem.new()
    layer:init()
    local loader = layer.m_ccbLoader
    layer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad( "CDBalloonItem.ccbi",proxy,loader)

    layer:setAnchorPoint( node:getAnchorPoint())
    layer:setContentSize( node:getContentSize())

    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild( node)
    pParent:addChild(layer)
    layer:getMahjongSize()
    return layer
end