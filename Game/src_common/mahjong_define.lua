--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       CDMahjong
//File Name:    mahjong_define.h
//Author:       GostYe
//Start Data:   2016.03.1
//Language:     XCode 4.5
//Target:       IOS, Android
****************************************************************************/
]]

require( REQUIRE_PATH.."DCCBLayer")

----------------------------------------------------------------------------
-- 类定义
CDMahjong = class( "CDMahjong", CDCCBLayer)
CDMahjong.__index = CDMahjong

----------------------------------------------------------------------------
-- 构造函数
function CDMahjong:ctor()
    CDMahjong.super.ctor(self)
    CDMahjong.initialMember(self)
    
    local function onNodeEvent(event)
        if "exit" == event then
            CDMahjong.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

----------------------------------------------------------------------------
-- 释放
function CDMahjong:onExit()
    self:stopAllActions()
    CDMahjong.releaseMember(self)
    self:unregisterScriptHandler()
end

----------------------------------------------------------------------------
-- 成员变量定义
CDMahjong.m_pRoot = nil        -- 根节点用于在上面放字等
CDMahjong.m_pFace = nil        -- 牌面

CDMahjong.m_pTouch = nil       -- 点击范围

CDMahjong.m_pDefine = nil      -- 默认样子
CDMahjong.m_pOut = nil         -- 出牌样子
CDMahjong.m_pBack = nil        -- 背面
CDMahjong.m_pMask = nil        -- 遮罩层

CDMahjong.m_pIcoLai = nil      -- 赖子标示
CDMahjong.m_pIcoTing = nil     -- 听牌标示

CDMahjong.m_nSizeW = 0         -- 点击位置宽    
CDMahjong.m_nSizeH = 0         -- 点击位置高

CDMahjong.m_pAniManager = nil  -- 动画管理器
CDMahjong.m_nDelayAniID = 0    -- 延迟播放的动画编号
CDMahjong.m_pEffect = nil      -- 特效对象

CDMahjong.m_nMahjong = 0       -- 牌
CDMahjong.m_bIsBack = false
CDMahjong.m_nBackIndex = 0
CDMahjong.m_nValue     = 0   

----------------------------------------------------------------------------
-- 初始化
function CDMahjong:initialMember()
    cclog("CDMahjong::initialMember")

    self.m_pRoot = nil
    self.m_pFace = nil
    self.m_pTouch = nil

    self.m_pDefine = nil
    self.m_pBack = nil
    self.m_pMask = nil

    self.m_pIcoLai = nil
    self.m_pIcoTing = nil

    self.m_nSizeW = nil
    self.m_nSizeH = nil
    self.m_pAniManager = nil
    self.m_nDelayAniID = 0
    self.m_pEffect = nil

    self.m_nMahjong = 0

    self.m_bIsBack = false
    self.m_nBackIndex = 0
    self.m_nValue = 0
end

----------------------------------------------------------------------------
-- 释放
function CDMahjong:releaseMember()
    cclog("CDMahjong::releaseMember")
    --模拟析构父类
    CDMahjong.super.releaseMember(self)

    CC_SAFE_RELEASE_NULL(self.m_pAniManager)
    self.m_pAniManager = nil

    if  self.m_pRoot then
        if  self.m_pFace then
            self.m_pFace:removeAllChildren( ture)
        end
        self.m_pRoot:removeAllChildren(true)
    end

    if  self.m_pEffect ~= nil then
        self:removeChild( self.m_pEffect)
        self.m_pEffect = nil
    end

    self.m_pRoot = nil
    self.m_pTouch = nil

    self.m_pDefine = nil
    self.m_pBack = nil
    self.m_pMask = nil

    if DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end
    CDMahjong.initialMember(self)
end

----------------------------------------------------------------------------
-- 初始化
function CDMahjong:init()
    cclog("CDMahjong::init")
    return true
end

----------------------------------------------------------------------------
-- 设置牌
-- 参数: 默认状态
function CDMahjong:setMahjong( file_mahjong)

    if  self.m_pDefine ~= nil then
        self.m_pDefine:removeAllChildren()
    end

    if  self.m_pFace ~= nil then
        self.m_pFace:removeAllChildren()
        self.m_pDefine = nil
    end

    if  file_mahjong ~= nil then

        self.m_pDefine = cc.Sprite:createWithSpriteFrameName( file_mahjong)
        self.m_pFace:addChild( self.m_pDefine)
        self.m_pDefine:setVisible( true)
    end
end

----------------------------------------------------------------------------
-- 设置牌数值
function CDMahjong:setMahjongNumber( mahjong)

    self.m_nMahjong = mahjong
end
function CDMahjong:getMahjongNumber()

    return self.m_nMahjong
end
----------------------------------------------------------------------------
-- 设置牌缩放
function CDMahjong:setMahjongScale( scale)

    if  self.m_pRoot then
        self.m_pRoot:setScale( scale)
    end
end

----------------------------------------------------------------------------
-- 设置赖子标示是否显示
-- 图标是否显示,颜色是否显示
function CDMahjong:setIcoLaiVisible( bVisible, bColor)

    if  bVisible == nil then
        bVisible = true
    end
    if  bColor == nil then
        bColor = true
    end

    if  self.m_pIcoLai then
        self.m_pIcoLai:setVisible( bVisible)
    end

    if  self.m_pDefine and (not self.m_pDefine:isGrey()) then

        if  bColor then
            self.m_pDefine:setColor(cc.c3b(255,255,0))
        else
            self.m_pDefine:setColor(cc.c3b(255,255,255))
        end
    end
end

----------------------------------------------------------------------------
-- 设置红中配Tip显示
-- hzp_mahjong(替代的牌)
function CDMahjong:setTipHZP( hzp_mahjong)

    if  self.m_pDefine ~= nil then
        self.m_pDefine:removeAllChildren()
    end

    if  hzp_mahjong ~= 0 then

        local temp = cc.Sprite:createWithSpriteFrameName( string.format("x_tip_%d.png", hzp_mahjong))
        temp:setAnchorPoint( cc.p( 0.0, 0.0))
        temp:setPositionY( 5.0)
        self.m_pDefine:addChild( temp)
    end
end

----------------------------------------------------------------------------
-- 设置听牌标示是否显示
-- 图标是否显示
function CDMahjong:setIcoTingVisible( bVisible)

    if  bVisible == nil then
        bVisible = true
    end
    
    if  self.m_pIcoTing then
        self.m_pIcoTing:setVisible( bVisible)
    end
end

----------------------------------------------------------------------------
-- 设置赖子颜色提示
function CDMahjong:setLaiZiColor()

    if  self.m_pDefine then
        self.m_pDefine:setColor( cc.c3b(255,255,0))
    end
end

----------------------------------------------------------------------------
-- 判断颜色是否为赖子色
function CDMahjong:isLaiZi( laizi)

    if  self.m_nMahjong == laizi then
        return true
    end
    return false
end

----------------------------------------------------------------------------
-- 初始化牌
-- 参数: 排面, 背面, 遮罩层
function CDMahjong:initMahjongWithFile( file_mahjong, file_back, file_mash)
    cclog("CDMahjong::initMahjongWithFile")

    if  self.m_pRoot == nil then
        return
    end
    
    if  self.m_pDefine ~= nil then
        self.m_pDefine:removeAllChildren()
    end

    if  self.m_pFace ~= nil then
        self.m_pFace:removeAllChildren()
        self.m_pDefine = nil
    end
    self.m_pRoot:removeAllChildren()

    self.m_pFace = cc.Node:create()
    self.m_pRoot:addChild( self.m_pFace)

    if  file_mahjong ~= nil then
        self.m_pDefine = cc.Sprite:createWithSpriteFrameName( file_mahjong)
        self.m_pFace:addChild( self.m_pDefine)
        self.m_pDefine:setVisible( true)
    else
        self.m_pDefine = nil
    end

    if  file_back ~= nil then
        self.m_pBack = cc.Sprite:createWithSpriteFrameName( file_back)
        self.m_pRoot:addChild( self.m_pBack)
        self.m_pBack:setVisible( false)
    else
        self.m_pBack = nil
    end

    if  file_mash ~= nil then
        self.m_pMask = cc.Sprite:createWithSpriteFrameName( file_mash)
        self.m_pRoot:addChild( self.m_pMask)
        self.m_pMask:setVisible( false)
    else
        self.m_pMask = nil
    end
end

----------------------------------------------------------------------------
-- 是否点中
-- 参数: 点
-- 返回: 是否选中
function CDMahjong:touchInFromPoint( point)

    if  self.m_pTouch == nil then
        return false
    end

    local sPoint = self.m_pTouch:getParent():convertToNodeSpace( point)
    local rect = self.m_pTouch:getBoundingBox()
    if cc.rectContainsPoint( rect, sPoint) then
        return true
    end
    return false
end

----------------------------------------------------------------------------
-- 设置mask显示
function CDMahjong:setMaskVisible( visible)

    if  self.m_pMask ~= nil then
        self.m_pMask:setVisible( visible)
    end
end

----------------------------------------------------------------------------
-- 设置正面显示
function CDMahjong:setFaceVisible( visible)

    if  self.m_pFace ~= nil then
        self.m_pFace:setVisible( visible)
    end
end

----------------------------------------------------------------------------
-- 设置背面显示
function CDMahjong:setBackVisible( visible)

    if  self.m_pBack ~= nil then

        self.m_pBack:setVisible( visible)
        if  visible and self.m_pIcoLai ~= nil then
            self.m_pIcoLai:setVisible( false)
        end
    end
end
-------------------------------------------------------------------------------
--设置记忆大师麻将点击颜色
function CDMahjong:setColor_JYDS()
    if  self.m_pDefine then
        self.m_pDefine:setColor( cc.c3b(255,255,0))
    end
end

function CDMahjong:clearColor_JYDS()
    if  self.m_pDefine then
        self.m_pDefine:setColor( cc.c3b(255,255,255))
    end
end


function CDMahjong:setBackColor_JYDS()
    if  self.m_pBack then
        self.m_pBack:setColor( cc.c3b(255,0,0))
    end
end

function CDMahjong:clearBackColor_JYDS()
    if  self.m_pBack then
        self.m_pBack:setColor( cc.c3b(255,255,255))
    end
end


-- 设置背面
function CDMahjong:setIsBack(boolean)
    self.m_bIsBack =boolean
end

function CDMahjong:getIsBack(boolean)
    return self.m_bIsBack
end

--设置位置
function CDMahjong:setBackIndex(index)
    self.m_nBackIndex = index
end

function CDMahjong:getBackIndex()
    return self.m_nBackIndex
end

function CDMahjong:setMahValue(value)
    self.m_nValue = value
end

function CDMahjong:getMahValue()
    return self.m_nValue
end

----------------------------------------------------------------------------
-- 设置相同的牌的颜色
function CDMahjong:setSameColor( mahjong, laizi, boolean)
    if  boolean == nil then
        boolean = false
    end 

    if  self.m_nMahjong == mahjong and mahjong ~= 0 then

        self.m_pDefine:setColor(cc.c3b(0,255,255))
        self.m_pDefine:setGrey( false)
    else

        if  self.m_nMahjong == laizi then
            if  not boolean then
                self.m_pDefine:setColor(cc.c3b(255,255,0))
            else
                self.m_pDefine:setColor(cc.c3b(255,255,255))
            end
            self.m_pDefine:setGrey( false)
        else
            self.m_pDefine:setColor(cc.c3b(255,255,255))
            self.m_pDefine:setGrey( false)
        end
    end
end
----------------------------------------------------------------------------
-- 用于吃的颜色显示
function CDMahjong:setSameColorWihtChi( mahjong)
    
    if  self.m_nMahjong == mahjong and mahjong ~= 0 then

        self.m_pDefine:setColor(cc.c3b(0,255,255))
        return true
    end
    return false
end

-- 设置相同的牌的颜色 用于广德麻将
function CDMahjong:setSameColorWithGD( mahjong, laizi, boolean,fanpai)
    if  boolean == nil then
        boolean = false
    end 

    if  self.m_nMahjong == mahjong and mahjong ~= 0 then

        self.m_pDefine:setColor(cc.c3b(0,255,255))
        self.m_pDefine:setGrey( false)
    else

        if  self.m_nMahjong == laizi or self.m_nMahjong == fanpai then
            if  not boolean then
                self.m_pDefine:setColor(cc.c3b(255,255,0))
            else
                self.m_pDefine:setColor(cc.c3b(255,255,255))
            end
            self.m_pDefine:setGrey( false)
        else
            self.m_pDefine:setColor(cc.c3b(255,255,255))
            self.m_pDefine:setGrey( false)
        end
    end
end

----------------------------------------------------------------------------
-- 设置不可操作色
function CDMahjong:setNotValueColor()
    self.m_pDefine:setGrey( true)
end

function CDMahjong:setValueColor()
    self.m_pDefine:setGrey( false)
end

----------------------------------------------------------------------------
-- 获取尺寸
function CDMahjong:getMahjongSize()

    if  self.m_pTouch ~= nil then
        local size = self.m_pTouch:getContentSize()
        self.m_nSizeW = size.width
        self.m_nSizeH = size.height
    end
end

----------------------------------------------------------------------------
-- 添加特效
function CDMahjong:addEffect( file, time)

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

    self.m_pEffect = CDCCBAniObject.createCCBAniObject( self, file, cc.p( 0, 0), 0)
    if  self.m_pEffect then

        self.m_pEffect:setScale( self.m_pRoot:getScaleX())
        self.m_pEffect:endVisible( false)
        self.m_pEffect:endRelease( false)
        self:runAction( cc.Sequence:create( cc.DelayTime:create( time), cc.CallFunc:create( removeEffect)))
    end
end

----------------------------------------------------------------------------
-- ccb处理-变量绑定
function CDMahjong:onAssignCCBMemberVariable(loader)
    cclog("CDMahjong::onAssignCCBMemberVariable")

    self.m_pRoot  = loader["scale_root"]
    self.m_pTouch = loader["touch"]

    self.m_pIcoLai = loader["ico_laizi"]
    self.m_pIcoTing = loader["ico_ting"]

    if  nil ~= loader["mAnimationManager"] then
        local animationMgr = loader["mAnimationManager"]
        self:setAniManager(animationMgr)
    end

    return true
end

----------------------------------------------------------------------------
-- ccb处理-函数绑定
function CDMahjong:onResolveCCBCCControlSelector(loader)
    cclog("CDMahjong::onResolveCCBCCControlSelector")
end

----------------------------------------------------------------------------
-- 延迟动画播放
-- 参数: 动画编号, 延迟的时间
function CDMahjong:delayAnimations( delay_ani_id, time)

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
-- 获取、设置动画控制器
function CDMahjong:setAniManager( pM)

    CC_SAFE_RELEASE_NULL(self.m_pAniManager)
    self.m_pAniManager = pM;
    if  self.m_pAniManager then
        self.m_pAniManager:retain()
    end
end
function CDMahjong:getAniManager()
    return self.m_pAniManager
end

----------------------------------------------------------------------------
-- 播放动画根据索引号，或者动画名
function CDMahjong:runAnimations( nSeqId, fTweenDuration)
    if  self.m_pAniManager then
        cclog("CDMahjong::runAnimations seqid")
        self.m_pAniManager:runAnimationsForSequenceIdTweenDuration( nSeqId, fTweenDuration)
        self:setCompletedCallback(fTweenDuration)
    end
end

----------------------------------------------------------------------------
-- 添加设置动画播放结束回调方法
function CDMahjong:setCompletedCallback(fTweenDuration)
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
-- 动画播放完的回调处理
function CDMahjong:completedAnimationSequenceNamed(name)
    --cclog("CDCCBAniNode::completedAnimationSequenceNamed")
end

----------------------------------------------------------------------------
-- 创建卡牌对象
function CDMahjong.createCDMahjong( pParent)
    cclog("CDMahjong::createCDMahjong")

    if not pParent then
        return nil
    end

    local layer = CDMahjong.new()
    layer:init()
    local loader = layer.m_ccbLoader
    layer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad( "CDMahjong.ccbi",proxy,loader)

    layer:setAnchorPoint( node:getAnchorPoint())
    layer:setContentSize( node:getContentSize())

    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild( node)
    pParent:addChild(layer)
    layer:getMahjongSize()
    return layer
end

-----------------------------------------
-- 桌子上的牌结构
X_MAHJONG = class( "X_MAHJONG")
X_MAHJONG.__index = X_MAHJONG
-- 构造函数
function X_MAHJONG:ctor()
    self:init()
end

X_MAHJONG.m_nMahjong = nil       -- 数值
X_MAHJONG.m_pMahjong = nil       -- 牌对象
X_MAHJONG.m_bSelect = false      -- 是否选中
X_MAHJONG.m_bVaild = true        -- 是否有效
X_MAHJONG.m_sPosition = cc.p( 0, 0)

function X_MAHJONG:init()
    --cclog("X_MAHJONG::init")
    self.m_nMahjong = 0
    self.m_pMahjong = nil
    self.m_bSelect = false
    self.m_bVaild = true
    self.m_sPosition = cc.p( 0, 0)
end

function X_MAHJONG:release()
    --cclog("X_MAHJONG::release")

    self:init()
end

function X_MAHJONG.create()
    --cclog("X_MAHJONG::create")
    local instance = X_MAHJONG.new()
    return instance
end
