--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       CDBlockItem
//File Name:    block_item.h
//Author:       GostYe
//Start Data:   2016.03.1
//Language:     XCode 4.5
//Target:       IOS, Android
****************************************************************************/
]]

require( REQUIRE_PATH.."DCCBLayer")

----------------------------------------------------------------------------
-- Àà¶¨Òå
CDBlockItem = class( "CDBlockItem", CDCCBLayer)
CDBlockItem.__index = CDBlockItem

local finalScreen = CDGlobalMgr:sharedGlobalMgr():getWinSize()

----------------------------------------------------------------------------
-- ¹¹Ôìº¯Êý
function CDBlockItem:ctor()
    CDBlockItem.super.ctor(self)
    CDBlockItem.initialMember(self)
    
    local function onNodeEvent(event)
        if "exit" == event then
            CDBlockItem.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

----------------------------------------------------------------------------
-- ÊÍ·Å
function CDBlockItem:onExit()
    self:stopAllActions()
    CDBlockItem.releaseMember(self)
    self:unregisterScriptHandler()
end

----------------------------------------------------------------------------
-- 初始化
function CDBlockItem:init()
    cclog("CDBlockItem::init")
    return true
end

----------------------------------------------------------------------------
-- ³ÉÔ±±äÁ¿¶¨Òå
CDBlockItem.m_pRoot = nil         
CDBlockItem.m_pTouch = nil       

CDBlockItem.m_pDefine = nil      

CDBlockItem.m_nSizeW = 0              
CDBlockItem.m_nSizeH = 0          

CDBlockItem.m_pAniManager = nil  
CDBlockItem.m_pEffect = nil       

CDBlockItem.m_nColor = 0

CDBlockItem.m_pLabel = nil

CDBlockItem.m_pSprite = nil

CDBlockItem._LineIndex = -1

CDBlockItem.m_bTouch   = false

CDBlockItem.m_bOverScreen = false
----------------------------------------------------------------------------
-- ³õÊ¼»¯
function CDBlockItem:initialMember()
    cclog("CDBlockItem::initialMember")

    self.m_pRoot = nil
    self.m_pTouch = nil
    self.m_pDefine = nil
    
    self.m_nSizeW = nil
    self.m_nSizeH = nil
    self.m_pAniManager = nil
    self.m_nDelayAniID = 0
    self.m_pEffect = nil

    self.m_pLabel =  nil
    self.m_pSprite = nil

    self.m_nColor = 0

    self._LineIndex = -1    

    self.m_bTouch = false

    self.m_bOverScreen = false
end

----------------------------------------------------------------------------
-- ÊÍ·Å
function CDBlockItem:releaseMember()
    cclog("CDBlockItem::releaseMember")
    --Ä£ÄâÎö¹¹¸¸Àà
    CDBlockItem.super.releaseMember(self)

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

    self.m_pLabel =nil

    self.m_pSprite = nil

    self.m_pLabelStr = nil

    if DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end
    CDBlockItem.initialMember(self)
end

----------------------------------------------------------------------------

--参数 方块颜色，方块大小，字，字体大小，字体颜色
function CDBlockItem:createdBlockItem( ... )
    local layer = CDBlockItem.new()
    layer:init()

    return layer
end

function CDBlockItem:createBlock(blockColor,blockSize,strLabel,fontSize,textColor)
   
    self.m_pSprite = cc.LayerColor:create(blockColor,blockSize.width,blockSize.height)
  
    self.m_pSprite:setAnchorPoint(cc.p(0,0))
    self:addChild(self.m_pSprite)
    
    if  strLabel then 
        if  not self.m_pLabel then
            self.m_pLabel = cc.Label:create()
            self:addChild(self.m_pLabel)
        end

        self.m_pLabel:setString(strLabel)
        self.m_pLabel:setTextColor(textColor)
        self.m_pLabel:setSystemFontSize(fontSize)
        self.m_pLabel:setPosition(cc.p(blockSize.width/2,blockSize.height/2))

    end
    
    self:setContentSize(self.m_pSprite:getContentSize())
    self:setColor(blockColor)

end


function CDBlockItem:initTimer()
    local index = 1
   
    local function callback()

        local tempY = self:getPositionY() - 10*index
        local tempX = self:getPositionX()
        if tempY>= finalScreen.height+50 then
            self.m_bOverScreen = true
        else
            
            self:setPosition(cc.p(tempX,tempY))
        end
        index = index+1

        if  self.m_bOverScreen then
            self:setVisible(false)
            self:destroyTimer()
            self:cleanup()
        end
    end 

    if not self.schedulerID then
        self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback,0.3,false)
    end

end

function CDBlockItem:destroyTimer()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)   
        self.schedulerID=nil
    end
end


function CDBlockItem:setTextBVisible( boolean )

    if  self.m_pLabel then
        self.m_pLabel:setVisible(boolean)
    end
end

function CDBlockItem:setBlockColor(color)
    if self.m_pSprite then

        self.m_pSprite:setColor(color)
    end
end

function CDBlockItem:setRedColor()
     if self.m_pSprite then
        self.m_pSprite:setColor(cc.c3b(255,0,0))
    end
end

function CDBlockItem:clearBlockItem()
    if self.m_pSprite then
        self.m_pSprite:setColor(cc.c3b(255,255,255))
    end
end


--参数 ： 下落占屏幕的比
function CDBlockItem:moveDownAndCleanUp(num)


    local function detailClearOtherBlock( ... )
        if self._LineIndex<0  then

            self:removeFromParent()
            self = nil
        end
    end
    self._LineIndex = self._LineIndex -1

    self:runAction(cc.Sequence:create(cc.MoveTo:create( 0.1, cc.p(self:getPositionX(),self:getPositionY()-finalScreen.height/num)),cc.DelayTime:create( 0.15), cc.CallFunc:create( detailClearOtherBlock)))
   
end


--行号设置
function CDBlockItem:SetLineIndex(index)
    self._LineIndex = index
end

function CDBlockItem:getLineIndex()
    return self._LineIndex
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- ÉèÖÃÅÆËõ·Å
function CDBlockItem:setMahjongScale( scale)
    if  self.m_pRoot then
        self.m_pRoot:setScale( scale)
    end
end

----------------------------------------------------------------------------
-- ÉèÖÃ±»Ñ¡ÖÐµÄÑÕÉ«ÏÔÊ¾
-- ÊÇ·ñÑ¡ÖÐ
function CDBlockItem:setSelectedColor(bSelect)
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

function CDBlockItem:touchInFromPoint(point)
    if  self.m_pTouch == nil then
        return false
    end

    local sPoint = self.m_pTouch:getParent():convertToNodeSpace(point)
    local rect = self.m_pTouch:getBoundingBox()
    if cc.rectContainsPoint( rect, sPoint) then
        return true
    end
    return false
end

----------------------------------------------------------------------------
-- »ñÈ¡³ß´ç
function CDBlockItem:getMahjongSize()
    if  self.m_pTouch ~= nil then
        local size = self.m_pTouch:getContentSize()
        self.m_nSizeW = size.width
        self.m_nSizeH = size.height
    end
end

----------------------------------------------------------------------------

-- Ìí¼ÓÌØÐ§
function CDBlockItem:addEffect( file, time)

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
function CDBlockItem:onAssignCCBMemberVariable(loader)
    cclog("CDBlockItem::onAssignCCBMemberVariable")

    self.m_pRoot  = loader["scale_root"]
    self.m_pTouch = loader["touch"]

    if  nil ~= loader["mAnimationManager"] then
        local animationMgr = loader["mAnimationManager"]
        self:setAniManager(animationMgr)
    end

    return true
end
----------------------------------------------------------------------------
-- ÑÓ³Ù¶¯»­²¥·Å
-- ²ÎÊý: ¶¯»­±àºÅ, ÑÓ³ÙµÄÊ±¼ä
function CDBlockItem:delayAnimations( delay_ani_id, time)

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
function CDBlockItem:setAniManager( pM)

    CC_SAFE_RELEASE_NULL(self.m_pAniManager)
    self.m_pAniManager = pM;
    if  self.m_pAniManager then
        self.m_pAniManager:retain()
    end
end
function CDBlockItem:getAniManager()
    return self.m_pAniManager
end

----------------------------------------------------------------------------
-- ²¥·Å¶¯»­¸ù¾ÝË÷ÒýºÅ£¬»òÕß¶¯»­Ãû
function CDBlockItem:runAnimations( nSeqId, fTweenDuration)
    if  self.m_pAniManager then
        cclog("CDBlockItem::runAnimations seqid")
        self.m_pAniManager:runAnimationsForSequenceIdTweenDuration( nSeqId, fTweenDuration)
        self:setCompletedCallback(fTweenDuration)
    end
end

----------------------------------------------------------------------------
-- Ìí¼ÓÉèÖÃ¶¯»­²¥·Å½áÊø»Øµ÷·½·¨
function CDBlockItem:setCompletedCallback(fTweenDuration)
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
function CDBlockItem:completedAnimationSequenceNamed(name)
    --cclog("CDCCBAniNode::completedAnimationSequenceNamed")
end

----------------------------------------------------------------------------
