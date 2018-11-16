--[[
/******************************************************
//Project:      ProjectX
//Moudle:       CDLayerJYDS
//File Name:    DLayerDqq.lua
//Author:       Gostye
//Start Data:   2018.06.22
//Language:     XCode 9.4
//Target:       IOS, Android

ProjectX - 连连看选择界面

******************************************************/
]]

require( REQUIRE_PATH.."DTKDTableView")
-- 单项，等确项目确认后倒入
-- require( REQUIRE_PATH.."DItemHBTask")

local casinoclient = require("script.client.casinoclient")

-----------------------------------------
-- 类定义
CDLayerJYDS = class("CDLayerJYDS", CDTKDTableView)
CDLayerJYDS.__index = CDLayerJYDS

-- 构造函数
function CDLayerJYDS:ctor()
    cclog("CDLayerJYDS::ctor")
    CDLayerJYDS.super.ctor(self)
    CDLayerJYDS.initialMember(self)

    local function onNodeEvent(event)
    	if "enter" == event then
            -- 网络事件
            local   listeners = {
                -- { casino.MSG_ACT_ACK,                handler( self, self.Handle_Act_Ack)},
            }
            casinoclient.getInstance():addEventListeners(self,listeners)
        elseif "exit" == event then
            CDLayerJYDS.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
end

function CDLayerJYDS:onEnter( ... )

	cclog("CDLayerJYDS::onEnter")
	-- dtOpenWaiting(self)

end

function CDLayerJYDS:onExit()
    cclog("CDLayerJYDS::onExit")

    self:stopAllActions()
    self:enableTouch(false)
    --模拟析构自身
    CDLayerJYDS.releaseMember(self)
    self:unregisterScriptHandler()
    casinoclient.getInstance():removeListenerAllEvents(self)
end


-- 设置点击标志的开启和关闭
function CDLayerJYDS:enableTouch( bEnable)
	cclog("CDLayerJYDS::enableTouch")
    print("===================")
    print("bEnable",bEnable)
    print("self.m_bTouch",self.m_bTouch)
    print("===================")

	if bEnable then
    
        if self.m_bTouch then
            return
        end
        
        -- touch事件
        local function onTouchBegan(touch, event)
            cclog("CDLayerJYDS::onTouchBegan")
            print("self",self)
            if  not self:isVisible() then
                return
            end
            return true
        end
    
        local function onTouchMoved(touch, event)
            --cclog("CDLayerJYDS::onTouchMoved")
        end
    
        local function onTouchEnded(touch, event)
            cclog("CDLayerJYDS::onTouchEnded")
            if self.m_pGroupGame == nil then
                return
            end

            local touchPoint = touch:getLocation()
            local sJudge = self.m_pGroupGame:convertToNodeSpace(touchPoint)

            local sRect = self.m_pSimpleTouch:getBoundingBox()
            if cc.rectContainsPoint(sRect, sJudge) then
                --记忆大师的二期
                --self.m_nFlag = 5 
                self.m_nFlag = 1 
                self.m_nNeedGold = 5000
                self:joinJYDSTable()
                return
            end

            sRect = self.m_pNormalTouch:getBoundingBox()
            if cc.rectContainsPoint(sRect, sJudge) then
                self.m_nFlag = 2
                self.m_nNeedGold = 10000
                self:joinJYDSTable()
                return
            end

            sRect = self.m_pHardTouch:getBoundingBox()
            if cc.rectContainsPoint(sRect, sJudge) then
                self.m_nFlag = 3
                self.m_nNeedGold = 50000
                self:joinJYDSTable()
                return
            end

            sRect = self.m_pChallengeTouch:getBoundingBox()
            if cc.rectContainsPoint(sRect,sJudge) then
                self.m_nFlag = 4
                self.m_nNeedGold = 5000
                self:joinJYDSTable()
                return
            end
        end
        
        self.m_pListener = cc.EventListenerTouchOneByOne:create()
        self.m_pListener:setSwallowTouches(false)
        self.m_pListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        self.m_pListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
        self.m_pListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pListener, self)

    end
    self.m_bTouch = bEnable

end

CDLayerJYDS.m_pSimpleTouch = nil         -- 简单场按钮
CDLayerJYDS.m_pNormalTouch = nil         -- 普通场按钮
CDLayerJYDS.m_pHardTouch   = nil         -- 困难场按钮
CDLayerJYDS.m_pChallengeTouch = nil      -- 挑战场按钮


CDLayerJYDS.m_pSimpleGoldNode = nil      -- 简单场金币特效图标挂载点
CDLayerJYDS.m_pNormalGoldNode = nil      -- 普通场金币特效图标挂载点
CDLayerJYDS.m_pHardGoldNode   = nil      -- 困难场金币特效图标挂载点
CDLayerJYDS.m_pChallengeGoldNode =nil    -- 挑战场金币特效图标挂载点

CDLayerJYDS.m_pSimpleGoldLabel = nil     -- 简单场金币消耗文本显示框
CDLayerJYDS.m_pNormalGoldLabel = nil     -- 普通场金币消耗文本显示框
CDLayerJYDS.m_pHardGoldLabel   = nil     -- 困难场金币消耗文本显示框
CDLayerJYDS.m_pChallengeGoldLabel = nil  -- 挑战场金币消耗文本显示框


CDLayerJYDS.m_pGroupGame = nil

-- 初始化
function CDLayerJYDS:initialMember()
    cclog("CDLayerJYDS::initialMember")

    self.m_pSimpleTouch = nil 
    self.m_pNormalTouch = nil
    self.m_pHardTouch   = nil
    self.m_pChallengeTouch   = nil

    self.m_pSimpleGoldNode = nil
    self.m_pNormalGoldNode = nil
    self.m_pHardGoldNode   = nil
    self.m_pChallengeGoldNode =nil

    self.m_pSimpleGoldLabel = nil
    self.m_pNormalGoldLabel = nil
    self.m_pHardGoldLabel   = nil
    self.m_pChallengeGoldLabel = nil

    self.m_pGroupGame = nil

    self.m_nNeedGold = nil -- 开启连连看需要的金币数量
    self.m_nFlag     = nil -- 选择的难度
end

function CDLayerJYDS:releaseMember()
    cclog("CDLayerJYDS::releaseMember")

    --模拟析构父类
    CDTKDTableView.releaseMember(self)
    if 	DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end
    CDLayerJYDS.initialMember(self)
end

-- 初始化
function CDLayerJYDS:init()
    cclog("CDLayerJYDS::init")
    self:setVisible(false)
    return true
end

-- 开启界面
function CDLayerJYDS:open()
    cclog("CDLayerJYDS::open")
    if 	self:isVisible() then
        return
    end

    self:onLoadUI()
    self:refreshInterface()
    self:runAnimations(0, 0.0)
    -- self:runAction( cc.Sequence:create( cc.DelayTime:create( 0.3), cc.CallFunc:create( CDLayerJYDS.createRedTask)))

    -- 锁屏
    CDGlobalMgr:sharedGlobalMgr():setOpenTouch(false)
    
    self:enableTouch(true)

    self:setVisible(true)
end


-- 添加所有节点
function CDLayerJYDS:refreshInterface()
    cclog("CDLayerJYDS::refreshInterface")

    if not self.m_pSimpleGoldNode:getChildByTag(0) then
        local eff_gold1 = CDCCBAniObject.createCCBAniObject( self.m_pSimpleGoldNode, "x_tx_gold.ccbi", pos, 0)
        eff_gold1:setTag(0)
        if  eff_gold1 ~= nil then
            eff_gold1:endRelease( false)
            eff_gold1:endVisible( false)
        end
    end

    if not self.m_pNormalGoldNode:getChildByTag(0) then
        local eff_gold2 = CDCCBAniObject.createCCBAniObject( self.m_pNormalGoldNode, "x_tx_gold.ccbi", pos, 0)
        eff_gold2:setTag(0)
        if  eff_gold2 ~= nil then
            eff_gold2:endRelease( false)
            eff_gold2:endVisible( false)
        end
    end

    if not self.m_pHardGoldNode:getChildByTag(0) then
        local eff_gold3 = CDCCBAniObject.createCCBAniObject( self.m_pHardGoldNode, "x_tx_gold.ccbi", pos, 0)
        eff_gold3:setTag(0)
        if  eff_gold3 ~= nil then
            eff_gold3:endRelease( false)
            eff_gold3:endVisible( false)
        end
    end

    if not self.m_pChallengeGoldNode:getChildByTag(0) then
        local eff_gold4 = CDCCBAniObject.createCCBAniObject( self.m_pChallengeGoldNode, "x_tx_gold.ccbi", pos, 0)
        eff_gold4:setTag(0)
        if  eff_gold4 ~= nil then
            eff_gold4:endRelease( false)
            eff_gold4:endVisible( false)
        end
    end

    self.m_pSimpleGoldLabel:setString("5000")
    self.m_pNormalGoldLabel:setString("10000")
    self.m_pHardGoldLabel:setString("50000")
    self.m_pChallengeGoldLabel:setString("5000")
end

function CDLayerJYDS:joinJYDSTable()
    local function onCallJoinFuc()

        -- 向服务器发送消息，要求开启连连看游戏
        local function sendJoinJYDS()
            -- dtOpenWaiting(self)
            -- todo：暂时不向服务器发送消息，直接调用接口，开始
            -- casinoclient:getInstance():sendTableJoinReqByMatchId(self.m_pMatchData.id)

            print("===========joinJYDSTable===========")
            print("need Gold:", self.m_nNeedGold)
            print("need flag:", self.m_nFlag)
            print("===========joinJYDSTable===========")
            g_pSceneHall:goToScenneTable_JYDS(self.m_nFlag)
        end

        -- 开启商城
        local function openStore()
            g_pSceneHall:openShopping()
        end

        -- 获取当前自身的金币数量
        --local myGold = casinoclient:getInstance():getPlayerData():getPlayerResourceGold()

        -- 提示语句
        -- TODO:需要在相关的string.xml中添加条目
        -- local tipStr = "" 
        -- if  myGold >= self.m_nNeedGold then
        --     -- tipStr = string.format(casinoclient:getInstance():findString("确定花费%d%s报名【%s】吗？"),needRes,casinoclient:getInstance():findString("金币"),self.m_pGameName)
        --     tipStr = string.format("确定花费%d%s开始麻将连连看游戏吗？", self.m_nNeedGold, "金币")

             --g_pSceneHall:goToScenneTable_JYDS(self.m_nFlag)

             g_pSceneHall:goToScenneTable_TPGS(self.m_nFlag)

             --g_pSceneHall:goToScenneTable_SZXXL(self.m_nFlag)
        --     --g_pSceneHall.m_pLayerHall:onOpenTipWithFuc(tipStr,cc.CallFunc:create(sendJoinJYDS),10)
        -- else
        --     -- tipStr = string.format(casinoclient:getInstance():findString("您的%s不够了，快点充点吧！"),casinoclient:getInstance():findString("match_gamename_gold"))
        --     tipStr = "您的金币不够了，快点充点吧！"
        --    dtAddMessageToScene( self, tipStr)
        --     --g_pSceneHall.m_pLayerHall:onOpenTipWithFuc(tipStr,cc.CallFunc:create(openStore),10)
        -- end
    end

    onCallJoinFuc()
end

-- 关闭界面
function CDLayerJYDS:close()
    cclog("CDLayerJYDS::close")

    self:enableTouch( false)
    self:setVisible( false)
end

-- 关闭界面
function CDLayerJYDS:onClose()
    cclog("CDLayerJYDS::onClose")

    self:close()
    g_pSceneHall:gotoPriorToHall()
    dtPlaySound( DEF_SOUND_TOUCH)
end

-----------------------------------------
-- 网络相关处理
function CDLayerJYDS:Handle_Act_Ack( __event)
    cclog( "CDLayerTask:Handle_Act_Ack")

    local pAck = __event.packet
    if  not pAck then
        return false
    end

    dtCloseWaiting( self)
    if  self:isVisible() then
        if  pAck.type == casino.ACT_RED_RAIN then
            self:refreshInterface()
        end
    end
    
    return true
end

-----------------------------------------
-- ccb处理
function CDLayerJYDS:onAssignCCBMemberVariable(loader)
    cclog("CDLayerJYDS::onAssignCCBMemberVariable")

    -- 简单、普通、困难 挑战 点选图片
    self.m_pSimpleTouch= loader["touch_simple"]
    self.m_pNormalTouch= loader["touch_normal"]
    self.m_pHardTouch= loader["touch_hard"]
    self.m_pChallengeTouch = loader["touch_challenge"]

    -- 简单、普通、困难 挑战 金币特效图片挂载点
    self.m_pSimpleGoldNode = loader["simple_gold_node"]
    self.m_pNormalGoldNode = loader["normal_gold_node"]
    self.m_pHardGoldNode = loader["hard_gold_node"]
    self.m_pChallengeGoldNode = loader["challenge_gold_node"]

    -- 简单、普通、困难 挑战 金币消耗文本显示控件
    self.m_pSimpleGoldLabel = loader["label_simple"]
    self.m_pNormalGoldLabel = loader["label_normal"]
    self.m_pHardGoldLabel = loader["label_hard"]
    self.m_pChallengeGoldLabel = loader["label_challenge"]

    -- 场次选择父节点
    self.m_pGroupGame = loader["group_game"]
    
    -- 基类注册
    self:assignCCBMemberVariable(loader)
end


function CDLayerJYDS:onResolveCCBCCControlSelector(loader)
    cclog("CDLayerJYDS::onResolveCCBCCControlSelector")
    loader["onClose"] = function() self:onClose() end
end

-----------------------------------------
-- create
function CDLayerJYDS.createCDLayer_JYDS(pParent)
    cclog("CDLayerJYDS::createCDLayerJYDS")
    if  not pParent then
        return nil
    end
    local layer = CDLayerJYDS.new()
    layer:init()
    pParent:addChild( layer)
    return layer
end

function CDLayerJYDS:onLoadUI()

    if  self.m_ccbLayer then
        return self
    end
    local layer = self
    local loader = layer.m_ccbLoader
    layer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    --local node  = CCBReaderLoad("CDLayer_JYDS.ccbi",proxy,loader)
    local node  = CCBReaderLoad("CDLayer_TPGS.ccbi",proxy,loader)

    --local node  = CCBReaderLoad("CDLayer_SZXXL.ccbi",proxy,loader)
    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild(node)
    return self
end