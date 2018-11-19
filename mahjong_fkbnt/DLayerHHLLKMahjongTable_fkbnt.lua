--[[
/******************************************************
//Project:      ProjectX 
//Moudle:       CDLayerHHLLKMahjongTable_fkbnt 仙桃赖子斗地主桌子
//File Name:    DLayerHHLLKMahjongTable_fkbnt.h
//Author:       GostYe
//Start Data:   2016.12.27
//Language:     XCode 4.5
//Target:       IOS, Android

-- 在调用前，需要先设置 m_nHHLLKPlayers 玩家
-- 进入类后，先调用createUserInterface

******************************************************/
]]

require( REQUIRE_PATH.."DDefine")
require( REQUIRE_PATH.."DCCBHHLLKBaseLayer")
require( REQUIRE_PATH.."DTKDScene")
require( "mahjong_fkbnt.HHLLK_mahjong_fkbnt_ai")
require( "mahjong_fkbnt.HHLLK_llk_item")
require( "mahjong_fkbnt.HHLLK_llk_grid")

local casinoclient = require("script.client.casinoclient")
local platform_help = require("platform_help")

-- 音效定义
DEF_PROJCETHHLLK_SOUND_MJ_CLICK      = "tpgs_click_mahjong"..DEF_PROJCETHHLLK_TKD_SOUND     -- 点中牌
DEF_PROJCETHHLLK_SOUND_MJ_KJ         = "mj_kj"..DEF_PROJCETHHLLK_TKD_SOUND                  -- 开局

DEF_PROJCETHHLLK_SOUND_MJ_ERROR      = "tpgs_click_error"..DEF_PROJCETHHLLK_TKD_SOUND       -- 选择错误
DEF_PROJCETHHLLK_SOUND_MJ_OK         = "tpgs_click_ok"..DEF_PROJCETHHLLK_TKD_SOUND          -- 选择正确
DEF_PROJCETHHLLK_SOUND_MJ_COUNT_DOWN = "tpgs_count_down"..DEF_PROJCETHHLLK_TKD_SOUND        -- 倒计时
DEF_PROJCETHHLLK_SOUND_MJ_SCORE      = "tpgs_score"..DEF_PROJCETHHLLK_TKD_SOUND             -- 结算
DEF_PROJCETHHLLK_SOUND_MJ_TIME_OVER  = "tpgs_time_over"..DEF_PROJCETHHLLK_TKD_SOUND         -- 时间结束

-----------------------------------------
-- 类定义
CDLayerHHLLKMahjongTable_fkbnt = class("CDLayerHHLLKMahjongTable_fkbnt", CDCCBHHLLKBaseLayer)    
CDLayerHHLLKMahjongTable_fkbnt.__index = CDLayerHHLLKMahjongTable_fkbnt
CDLayerHHLLKMahjongTable_fkbnt.name = "CDLayerHHLLKMahjongTable_fkbnt"

-- 构造函数
function CDLayerHHLLKMahjongTable_fkbnt:ctor()
    cclog("CDLayerHHLLKMahjongTable_fkbnt::ctor")
    CDLayerHHLLKMahjongTable_fkbnt.super.ctor(self)
    CDLayerHHLLKMahjongTable_fkbnt.initialMember(self)
    --reg enter and exit
    local function onNodeEvent(event)
        if "enter" == event then
            CDLayerHHLLKMahjongTable_fkbnt.onEnter(self)
        elseif "exit" == event then
            CDLayerHHLLKMahjongTable_fkbnt.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function CDLayerHHLLKMahjongTable_fkbnt:onEnter()
    cclog("CDLayerHHLLKMahjongTable_fkbnt::onEnter")

    -- 网络事件
    local   listeners = {
        -- { casino.MSG_PING,                      handler( self, self.Handle_Ping)},
        -- { casino.MSG_TABLE_SCORE,               handler( self, self.Handle_Table_Score)},
        -- { casino.MSG_TABLE_PAUSE,               handler( self, self.Handle_Table_Pause)},
    
        -- { casino_ddz.DDZ_MSG_SC_STARTPLAY,      handler(self, self.Handle_llk_StartPlay)},               -- 游戏开始消息

        -- 
    }

    casinoclient.getInstance():addEventListeners(self,listeners)

    --暂时使用的心跳循环
    self:createHeartbeatLoop()
    self:restoreTimeCount()
end

function CDLayerHHLLKMahjongTable_fkbnt:onExit()
    cclog("CDLayerHHLLKMahjongTable_fkbnt::onExit")

    -- 关闭计时器
    if self.m_pRestoreTime then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_pRestoreTime)   
        self.m_pRestoreTime = nil
    end

    -- 退出时，停止发送心跳
    self:stopHeartLoop()
    self:stopAllActions()

    casinoclient.getInstance():removeListenerAllEvents(self)
    CDLayerHHLLKMahjongTable_fkbnt.releaseMember(self)
    self:unregisterScriptHandler()
end

-----------------------------------------
-- 计时器
function CDLayerHHLLKMahjongTable_fkbnt:restoreTimeCount()
    local nTmpTimeTotle = g_pHHLLKGlobalManagment.m_nTiming

    local function countTiming()
        nTmpTimeTotle = nTmpTimeTotle + 1
        if nTmpTimeTotle >= DEF_PROJCETHHLLK_LLK_PHY_RESTORE_TIME then
            nTmpTimeTotle = 0

            local nTmpPhysicalValue = g_pHHLLKGlobalManagment.nTmpPhysicalValue + DEF_PROJCETHHLLK_LLK_PHY_RESTORE
            if  nTmpPhysicalValue > DEF_PROJCETHHLLK_LLK_PHY_TOTLE then
                nTmpPhysicalValue = DEF_PROJCETHHLLK_LLK_PHY_TOTLE
            end
            g_pHHLLKGlobalManagment:setLLKTmpPhysical(nTmpPhysicalValue)

            -- 恢复体力刷新界面
            -- self:refreshTableCheckPoint()
        end
        g_pHHLLKGlobalManagment:setLLKTiming(nTmpTimeTotle)
    end

    if  self.m_pRestoreTime == nil then
        self.m_pRestoreTime = cc.Director:getInstance():getScheduler():scheduleScriptFunc(countTiming, 1, false)
    end
end

-----------------------------------------
-- 初始化
function CDLayerHHLLKMahjongTable_fkbnt:initialMember()
    cclog("CDLayerHHLLKMahjongTable_fkbnt::initialMember")

    ---------------------------------------------------
    -- 底部的状态信息 
    self.m_pHHLLKGroupBar        = nil        -- 状态按钮根节点
    self.m_pHHLLKButSetting      = nil        -- 设置按钮
    self.m_pHHLLKSelfInfo        = nil        -- 自己的信息
    self.m_pHHLLKTableInfo       = nil        -- 桌子的信息

    ---------------------------------------------------
    -- 桌子中相关'节点'与'层''
    self.m_pHHLLKNewEffLayer     = nil        -- 特效层
    self.m_pHHLLKNewLayerRoot    = nil        -- 桌面麻将放置的根节点
    self.m_pHHLLKGridNodeRoot    = nil        -- 棋盘放置层
    self.m_pHHLLKNodeGaugePoint  = nil        -- 定位标识
    self.m_pHHLLKLighting        = nil        -- 灯光
    self.m_pHHLLKMahjongEffDemo  = nil        -- 特效放置层
    self.m_pHHLLKMahjongDemo     = nil        -- 麻将放置层

    self.m_pHHLLKSelectTouchGroup = {}       -- 方块放置touch框
    for i = 1, 3 do
        self.m_pHHLLKSelectTouchGroup[i] = {}
        self.m_pHHLLKSelectTouchGroup[i].pGridTouchNode = nil
        self.m_pHHLLKSelectTouchGroup[i].nGridIndex = 0
        self.m_pHHLLKSelectTouchGroup[i].pGridSprite = nil
        self.m_pHHLLKSelectTouchGroup[i].pRgb = nil
    end

    ---------------------------------------------------
    -- 电池
    self.m_pHHLLKIcoPower        = nil        -- 电池图标

    ---------------------------------------------------
    -- 技能
    self.m_pHHLLKSkillBar        = nil        -- 技能根Node
    self.m_pHHLLKSkillLayer      = nil        -- 技能遮罩
    self.m_pHHLLKLabelResetExp   = nil        -- 重置技能消耗文本
    self.m_pHHLLKLabelEliminateExp = nil      -- 消除技能消耗文本
    self.m_pHHLLKLabelPlaceExp   = nil        -- 放置单方块技能消耗文本

    ---------------------------------------------------
    -- 游戏相关变量定义
    self.m_pHHLLKPlayAI          = nil        -- 玩家AI
    ---------------------------------------------------
    self.m_pHHLLKPlayer          = {}         -- 玩家
    self.m_pHHLLKPlayer.name     = ""         -- 玩家姓名
    self.m_pHHLLKPlayer.gold     = 0          -- 玩家货币
    ---------------------------------------------------
    self.m_pHHLLKListener        = nil        -- 监听对象
    self.mahjongMath_llk         = nil        -- 麻将连连看数学库  

    self.m_pHHLLKEffNetLow       = nil        -- 网络连接缓慢提示特效
    self.m_bHHLLKPreCreate       = false      -- 是否预创建过
    self.m_bHHLLKCanTouch        = false      -- 是否可以进行点击

    ---------------------------------------------------
    -- UI对象
    self.m_pHHLLKLableMaxScore   = nil        -- 最大积分控件
    self.m_pHHLLKLayerTip        = nil        -- 提示层控件
    self.m_pHHLLKNodeNotPlaceTip = nil        -- 不能再放置提示Node
    self.m_pHHLLKNodeGameOverTip = nil        -- 游戏结束提示Node
    self.m_pHHLLKLableTotleScore = nil        -- 总积分控件
    self.m_pHHLLKNodeResurgenceTip = nil      -- 复活提示Node
    self.m_pHHLLKLableResurgenceExp = nil     -- 复活消耗文本控件

    ---------------------------------------------------
    -- 数据对象
    self.m_nHHLLKNowCheckPoint   = 1          -- 当前关卡
    self.m_pHHLLKArrayShowGrid   = nil        -- 放置棋盘
    self.m_pHHLLKConfigData      = {}         -- 棋牌的配置数据

    self.m_pHHLLKTouchMoveItem   = nil        -- 点击选中物体
    self.m_pHHLLKGridPos         = nil        -- 选中的位置
    self.m_nHHLLKLeftPlaceNum    = 3          -- 剩余放置数量

    self.m_bHHLLKSkillEliminate  = false      -- 消除技能开启
    self.m_bHHLLKSkillPlace      = false      -- 放置技能开启
end

function CDLayerHHLLKMahjongTable_fkbnt:releaseMember()
    cclog("CDLayerHHLLKMahjongTable_fkbnt::releaseMember")

    if  self.m_pHHLLKNewEffLayer then
        self.m_pHHLLKNewEffLayer:removeAllChildren()
    end

    if  self.m_pHHLLKNewLayerRoot ~= nil then
        self.m_pHHLLKNewLayerRoot:removeAllChildren()
        self.m_pHHLLKMahjongDemo = nil
        self.m_pHHLLKEffNetLow = nil
    end

    if  self.m_pHHLLKGridNodeRoot ~= nil then
        self.m_pHHLLKGridNodeRoot:removeAllChildren()
        self.m_pHHLLKGridDemo = nil
    end

    --模拟析构父类
    CDLayerHHLLKMahjongTable_fkbnt.super.releaseMember(self)
    if  DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end

    if self.m_pHHLLKListener then
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:removeEventListener(self.m_pHHLLKListener)
        self.m_pHHLLKListener = nil
    end
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------

--===============================网络消息处理===============================--

-- 心跳包
-- 参数: 数据包
function CDLayerHHLLKMahjongTable_fkbnt:Handle_Ping( __event)
    cclog("CDLayerHHLLKMahjongTable_fkbnt:Handle_Ping")
    local function badNetWork() -- 网络恢复缓慢
        if  self.m_bHHLLKInTheGame then

            self.m_pHHLLKNewLayerRoot:stopAllActions()
            self.m_pHHLLKEffNetLow:setVisible( false)

            casinoclient.getInstance().m_socket:onDisconnect() --超时太多断线重连
            dtProjectHHLLKPlaySound( DEF_SOUND_ERROR)
        end
    end

    local function netRefreshTimeOut()
        if  self.m_bHHLLKInTheGame then
            self.m_nHHLLKTimeOut = self.m_nHHLLKTimeOut - 1
            if  self.m_nHHLLKTimeOut < 0 then
                self.m_nHHLLKTimeOut = 0
            end
            self.m_pHHLLKEffNetLow:setDefineText( 
                string.format( casinoclient.getInstance():findString("net_low"), self.m_nHHLLKTimeOut))

            if  self.m_nHHLLKTimeOut > 0 then

                self.m_pHHLLKNewLayerRoot:stopAllActions()
                self.m_pHHLLKNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( netRefreshTimeOut)))
            else
                self.m_pHHLLKNewLayerRoot:stopAllActions()
                self.m_pHHLLKNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( badNetWork)))
            end
        end
    end

    local function netTimeOut() -- 超时提示
        if self.m_bHHLLKInTheGame then
            self.m_nHHLLKTimeOut = DEF_TIMEOUT1
            self.m_pHHLLKEffNetLow:setVisible( true)
            self.m_pHHLLKEffNetLow:setDefineText( 
                string.format( casinoclient.getInstance():findString("net_low"), self.m_nHHLLKTimeOut))

            self.m_pHHLLKNewLayerRoot:stopAllActions()
            self.m_pHHLLKNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( netRefreshTimeOut)))
            dtProjectHHLLKPlaySound( DEF_SOUND_ERROR)
        end
    end

    -- 假如提示资源存在那么显示
    if  self.m_pHHLLKNewLayerRoot ~= nil and self.m_pHHLLKEffNetLow ~= nil then
        self.m_pHHLLKEffNetLow:setVisible( false)
        self.m_pHHLLKNewLayerRoot:stopAllActions()
        self.m_pHHLLKNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( DEF_PROJCETHHLLK_HEARTBEAT_SPACETIME), cc.CallFunc:create( netTimeOut)))
    end
    return true
end

-- 循环发送心跳包
function CDLayerHHLLKMahjongTable_fkbnt:createHeartbeatLoop( ... )
    local waitTime=0
    local function sendHeartLoop( event )
        waitTime=waitTime+1
        if  waitTime > 30 then
            waitTime = 0
            casinoclient.getInstance():sendPong()
        end
    end
    if  not self.schedulerID then
        self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(sendHeartLoop,1,false)
    end
end

-- 停止发送心跳包
function CDLayerHHLLKMahjongTable_fkbnt:stopHeartLoop( ... )
    if  self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)   
        self.schedulerID=nil
    end
end

----------------------------------------------------------------------------
-- 暂停
-- 参数: 数据包
function CDLayerHHLLKMahjongTable_fkbnt:Handle_Table_Pause( __event)
    cclog("CDLayerHHLLKMahjongTable_fkbnt:Handle_Table_Pause")
    local pAck = __event.packet
    if  not pAck then
        return false
    end    

    if  casinoclient.getInstance():isSelfBuildTable() then
        self:initTablePauseTime( pAck.quit_time)
    end
    return true
end

----------------------------------------------------------------------------
-- 所有玩家准备结束，可以进行发牌的反馈
-- 参数: 数据包
function CDLayerHHLLKMahjongTable_fkbnt:Handle_llk_StartPlay(__event)
    cclog("CDLayerHHLLKMahjongTable_fkbnt:Handle_llk_StartPlay")

    -- 开始游戏后，关闭主场景中的不相关场景
    g_pHHLLKSceneTable:closeAllUserInterface()

    -- 更新 
    self:refreshTableLeftScore()

    -- 重置桌面上的牌
    self:initAllMahjong()

    -- 开始生成牌数据
    self.m_bHHLLKInTheGame = true
    self:stopAllActions()
    self.m_nHHLLKLicensingType = 0

    self:round_licensingPlayer()

    return true
end

----------------------------------------------------------------------------
-- 重连
-- 参数: 数据包
function CDLayerHHLLKMahjongTable_fkbnt:Handle_xtlzddz_Reconnect( __event)
    cclog("CDLayerHHLLKMahjongTable_fkbnt:Handle_xtlzddz_Reconnect")

    local pAck = __event.packet
    if  not pAck then
        return false
    end

    -- 重连上来获取报警牌数据
    self.m_nHHLLKLeftCardWarning = casinoclient:getInstance():getTable().fanpai

    local index = self:getTableIndexWithID(pAck.player_id)
    if self.m_pHHLLKPlayAI[index] then
        self.m_pHHLLKPlayAI[index]:addMultiple(pAck.card)

        if index == 0 then
            self:refreshMultiple()
        end
    end

    return true
end

----------------------------------------------------------------------------
-- 重置电量
function CDLayerHHLLKMahjongTable_fkbnt:resetPower()
    local function updatePower()
        local power = platform_help.getBatterLevel()
        if  power > 100 then
            power = 100
        elseif power < 0 then
            power = 0
        end
    
        local width = power * 0.01 * 33
        local size = self.m_pHHLLKIcoPower:getContentSize()
        size.width = width
        self.m_pHHLLKIcoPower:setContentSize(size)
        self.m_pHHLLKIcoPower:runAction(cc.Sequence:create(cc.DelayTime:create(60.0), cc.CallFunc:create(updatePower)))
    end
    updatePower()
end

----------------------------------------------------------------------------
-- 重置桌子数据
-- 参数: data桌子数据
function CDLayerHHLLKMahjongTable_fkbnt:resetTableData(data)
    cclog( "CDLayerHHLLKMahjongTable_fkbnt:resetTableData")
end

--=================================基本方法=================================--
----------------------------------------------------------------------------
-- 倒计时转到结算
function CDLayerHHLLKMahjongTable_fkbnt:showLeftTimeGotoScore()
    cclog( "CDLayerHHLLKMahjongTable_fkbnt:showLeftTimeGotoScore")

    if  not self.m_pHHLLKTimeLeftTTF:isVisible() then
        self.m_pHHLLKTimeLeftTTF:setVisible( true)
    end

    local function leftTime_low()
        self.m_pHHLLKTimeLeftTTF:stopAllActions()
        if  self.m_nHHLLKTimeLeft <= 0 then

            -- 临时增加的判断为了避免在下一局开始的时候进入到结算画面
            if  not self.m_bHHLLKInTheGame then
                self:initTable()

                self.m_pHHLLKPlayer[0].m_pHHLLKFrame:setPosition(self.m_pHHLLKPlayer[0].m_sPosEnd)
                self.m_pHHLLKPlayer[0].m_pHHLLKFrame:setVisible(false)

                g_pHHLLKSceneTable:closeAllUserInterface()
                g_pHHLLKSceneTable.m_pHHLLKLayerMJScore:open(g_pHHLLKGlobalManagment:getScoreData(), self.mahjongMath_llk, self.m_nHHLLKScoreTime)
                self:showLocation(false)
            end
        else
            self.m_pHHLLKTimeLeftTTF:setString( string.format( "%d", self.m_nHHLLKTimeLeft))
            self.m_pHHLLKTimeLeftTTF:setScale( 3.0)
            self.m_pHHLLKTimeLeftTTF:runAction( cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.25, 1.0)), cc.DelayTime:create( 0.75), cc.CallFunc:create( leftTime_low)))

            self.m_nHHLLKTimeLeft = self.m_nHHLLKTimeLeft - 1
            if  self.m_nHHLLKTimeLeft < 0 then
                self.m_nHHLLKTimeLeft = 0
            end
        end
    end
    leftTime_low()
end

----------------------------------------------------------------------------
-- 设置玩家自己的昵称
function CDLayerHHLLKMahjongTable_fkbnt:refreshSelfInfo()
    local tmpStr = string.format(casinoclient.getInstance():findString("llk_name"), self.m_pHHLLKPlayer.name)
    self.m_pHHLLKSelfInfo:setString(tmpStr)
end

-- 设置玩家积分信息
function CDLayerHHLLKMahjongTable_fkbnt:refreshTableLeftScore()
    local tmpStr = 0
    if  self.m_pHHLLKPlayAI then
        tmpStr = string.format(casinoclient.getInstance():findString("llk_left_sorce"), self.m_pHHLLKPlayAI.m_nHHLLKTableLeftScore)
    end
    self.m_pHHLLKTableInfo:setString(tmpStr)
end

function CDLayerHHLLKMahjongTable_fkbnt:refreshTableMaxScore()
    self.m_pHHLLKLableMaxScore:setString(g_pHHLLKGlobalManagment.m_tMaxTotleScore)
end

-- 初始化界面
----------------------------------------------------------------------------
-- 创建用户界面
function CDLayerHHLLKMahjongTable_fkbnt:createUserInterface(flag)
    cclog("CDLayerHHLLKMahjongTable_fkbnt::createUserInterface")

    -- 创建数学库
    self.mahjongMath_llk = CDMahjongHHLLKFKBNTMath.create()

    -- 创建AI库
    self.m_pHHLLKPlayAI = CDMahjongHHLLKFKBNT_AI.create()

    -- 获取并生成玩家数据
    local nickname = casinoclient.getInstance():getPlayerData():getNickname()
    local channelNickname = casinoclient.getInstance():getPlayerData():getChannelNickname()
    self.m_pHHLLKPlayer.name = dtProjectHHLLKGetNickname(nickname, channelNickname)
    self.m_pHHLLKPlayer.gold = casinoclient:getInstance():getPlayerData():getPlayerResourceGold()

    -- 刷新界面相关显示
    self:refreshSelfInfo()
    self:refreshTableMaxScore()

    -- 创建桌面需要特效放置层
    self.m_pHHLLKMahjongEffDemo = cc.Layer:create()
    self.m_pHHLLKNewLayerRoot:addChild(self.m_pHHLLKMahjongEffDemo)

    self.m_pHHLLKMahjongDemo = cc.Layer:create()
    self.m_pHHLLKNewLayerRoot:addChild(self.m_pHHLLKMahjongDemo)

    self.m_pHHLLKGridDemo = cc.Layer:create()
    self.m_pHHLLKGridNodeRoot:addChild(self.m_pHHLLKGridDemo)

    -- 预创建牌
    self.m_bHHLLKPreCreate = false
    self:preCreateLLKMahjong()

    -- 重置电量
    self:resetPower()

    -- 进入准备流程
    self:onReady()
end

-- 预创建牌
function CDLayerHHLLKMahjongTable_fkbnt:preCreateLLKMahjong()
    cclog( "CDLayerHHLLKMahjongTable_fkbnt:preCreateLLKMahjong")

    if  self.m_bHHLLKPreCreate then
        return
    end

    ----------------------------------------------------------------------------
    -- 预创建棋盘
    self.m_pHHLLKArrayShowGrid = self.mahjongMath_llk.m_arrayHHLLKCheckerBoard

    -- 每个底框间隔像素值
    local nInterval = 1

    -- 获取第一个格子标记点的位置
    local nTmpFirst_x = self.m_pHHLLKNodeGaugePoint:getPositionX()
    local nTmpFirst_y = self.m_pHHLLKNodeGaugePoint:getPositionY()

    -- 在界面上创建棋盘
    for i, v1 in ipairs( self.m_pHHLLKArrayShowGrid ) do
        for j, v2 in ipairs( v1 ) do
            v2.item = CDMahjongHHLLKLlkItem.createCDMahjong(self.m_pHHLLKGridDemo)
            v2.item:setPosition(cc.p(nTmpFirst_x + (v2.item.m_nHHLLKSizeW + nInterval) * (j - 1), nTmpFirst_y + (v2.item.m_nHHLLKSizeH + nInterval) * (i - 1)))
            v2.item:setVisible(true)
        end
    end

    ----------------------------------------------------------------------------
    -- 预创建选中图案
    self.m_pHHLLKTouchMoveItem = CDMahjongHHLLKGrid.createCDMahjong(self.m_pHHLLKMahjongDemo)
    self.m_pHHLLKTouchMoveItem:setVisible(false)

    self.m_bHHLLKPreCreate = true
end

----------------------------------------------------------------------------
-- 根据指定的坐标点选择牌
-- 参数: 坐标点
function CDLayerHHLLKMahjongTable_fkbnt:touchMahjongFromPoint(point)
    local tmpPos = nil
    for i, v1 in ipairs(self.m_pHHLLKArrayShowGrid) do
        for j, v2 in ipairs( v1 ) do
            if v2.item:checkWithTouchPoint(point) then
                tmpPos = v2
            end
            v2.item:setSelectVisible(false)
        end
    end

    self.m_pHHLLKGridPos = nil
    if  tmpPos then
        self.m_pHHLLKGridPos = self.mahjongMath_llk:getGridPos(tmpPos.x, tmpPos.y, self.m_pHHLLKTouchMoveItem.m_nGridIndex)
        if  self.mahjongMath_llk:checkIsPlaceGrid(self.m_pHHLLKGridPos) then
            for i, v in ipairs( self.m_pHHLLKGridPos ) do
                self.m_pHHLLKArrayShowGrid[v.y][v.x].item:setSelectVisible(true)
            end
        else
            self.m_pHHLLKGridPos = nil
        end
    end
end

function CDLayerHHLLKMahjongTable_fkbnt:touchMahjongSkillFromPoint(point, type)
    local tmpPos = nil
    for i, v1 in ipairs(self.m_pHHLLKArrayShowGrid) do
        for j, v2 in ipairs( v1 ) do
            if v2.item:checkWithTouchPoint(point) then
                -- type
                -- 1: 消除方块
                -- 2: 放置方块
                if type == 1 then
                    if  v2.isVisible then
                        v2.isVisible = false
                        v2.item:closeColorShow()
                    end
                    self.m_bHHLLKSkillEliminate = false
                    self.m_pHHLLKSkillLayer:setVisible(false)
                elseif type == 2 then
                    if  not v2.isVisible then
                        v2.isVisible = true
                        -- 设置成红色
                        v2.item:setColor(cc.c3b(242,100,88))
                        self:dataToDetermine() 
                    end
                    self.m_bHHLLKSkillPlace = false
                    self.m_pHHLLKSkillLayer:setVisible(false)
                end

                return
            end
        end
    end
end

function CDLayerHHLLKMahjongTable_fkbnt:touchMahjongEnd()
    -- 松手后关闭手中的方块显示
    self.m_pHHLLKTouchMoveItem:setVisible(false)

    if  self.m_pHHLLKGridPos and TABLE_SIZE(self.m_pHHLLKGridPos) > 0 then
        self.m_nHHLLKLeftPlaceNum = self.m_nHHLLKLeftPlaceNum - 1
        -- 如果供选择的牌不足，则需要重新生成
        if  self.m_nHHLLKLeftPlaceNum <= 0 then
            self:createSelectGrid()
        end
        for i, v in ipairs( self.m_pHHLLKGridPos ) do
            self.m_pHHLLKArrayShowGrid[v.y][v.x].item:setSelectVisible(false)
            self.m_pHHLLKArrayShowGrid[v.y][v.x].item:setColor(self.m_pHHLLKTouchMoveItem.m_pRgb)
            self.m_pHHLLKArrayShowGrid[v.y][v.x].isVisible = true
        end 
        self:dataToDetermine()

        -- 放置完毕后，清空坐标记录
        self.m_pHHLLKGridPos = nil
    else
        -- 没有成功放置方块，则需要在选择区域重新显示
        local nTmpTouchIndex = self.m_pHHLLKTouchMoveItem.m_nTouchIndex
        self.m_pHHLLKSelectTouchGroup[nTmpTouchIndex].pGridSprite:setVisible(true)
    end
end

function CDLayerHHLLKMahjongTable_fkbnt:dataToDetermine()
    local tmpPlaceGrid, tmpScore, tmpTotleScore = {},0,0
    -- 获取可消除的格子
    tmpPlaceGrid, tmpScore, tmpTotleScore = self.mahjongMath_llk:checkEliminateRowAndColumn()
    if  TABLE_SIZE(tmpPlaceGrid) > 0 then
        local tmpDelayTime = 0.3
        for i, v in ipairs( tmpPlaceGrid ) do
            self.m_pHHLLKArrayShowGrid[v.y][v.x].item:closeColorShow()
            self.m_pHHLLKArrayShowGrid[v.y][v.x].item:setScoreNum(tmpScore)
            self.m_pHHLLKArrayShowGrid[v.y][v.x].item:setScoreAction(tmpDelayTime)
            self.m_pHHLLKArrayShowGrid[v.y][v.x].isVisible = false
        end

        self.m_pHHLLKPlayAI:addScore(tmpTotleScore)
        self:refreshTableLeftScore()
    end

    -- 最大积分记录
    g_pHHLLKGlobalManagment:refreshFKBNTTotleScore(self.m_pHHLLKPlayAI.m_nHHLLKTableLeftScore)

    -- 是否失败判定
    local arrayTmpLeftGridIndexs = {}
    for i, v in ipairs( self.m_pHHLLKSelectTouchGroup ) do
        if  v.pGridSprite:isVisible() then
            table.insert( arrayTmpLeftGridIndexs, v.nGridIndex )
        end
    end
    if  TABLE_SIZE(arrayTmpLeftGridIndexs) ~= 0 then
        if not self.mahjongMath_llk:checkLeftGridIsPlace(arrayTmpLeftGridIndexs) then
            self:onGameOver()
        end
    end

    self.m_nHHLLKNowCheckPoint = self.m_nHHLLKNowCheckPoint + 1
end

----------------------------------------------------------------------------
-- 关闭所有界面
function CDLayerHHLLKMahjongTable_fkbnt:closeAllUserInterface()
    cclog("CDLayerHHLLKMahjongTable_fkbnt::closeAllUserInterface")

    local pTable = dtGetSceneTableFromParent( self)
    if  pTable then
        pTable:closeAllUserInterface()
        return
    end
end

----------------------------------------------------------------------------
-- 初始化桌子
-- 删除所有打出以及手上的牌，并且清除所有玩家桌面
function CDLayerHHLLKMahjongTable_fkbnt:initTable()
    cclog("CDLayerHHLLKMahjongTable_fkbnt::initTable")

    if  self.m_pHHLLKNewEffLayer then
        self.m_pHHLLKNewEffLayer:removeAllChildren()
    end

    self.m_sSavePutArr   = {}
    self.m_sLastPutCards = {}
    self.m_sOutInfo = {}

    self.m_bHHLLKCanOutCard = false
    self.m_bHHLLKTouchTable = false 
    self.m_pHHLLKLastSelectCard = nil

    self:refreshTableInfo()
    if  self.m_pHHLLKPlayAI == nil then
        self.m_pHHLLKPlayAI = CDMahjongHHLLKLLK_AI.create()
    end
end

function CDLayerHHLLKMahjongTable_fkbnt:initAllMahjong()
    if  self.m_pHHLLKArrayShowGrid then
        for i, v1 in ipairs( self.m_pHHLLKArrayShowGrid ) do
            for j, v2 in ipairs( v1 ) do
                v2.isVisible = false
                v2.item:closeColorShow()
                v2.item:setSelectVisible(false)
            end
        end
    end
end

----------------------------------------------------------------------------
-- 初始化
function CDLayerHHLLKMahjongTable_fkbnt:init()
    cclog("CDLayerHHLLKMahjongTable_fkbnt::init")
    
    -- touch事件
    local function onTouchBegan(touch, event)
        cclog("CDLayerHHLLKMahjongTable_fkbnt:onTouchBegan")

        -- 没有开始游戏，不能进行点击
        if not self.m_bHHLLKInTheGame or not self.m_bHHLLKCanTouch then
            return
        end
        self.m_bHHLLKTouchTable = true 

        -- 点选需要的方块
        local point = touch:getLocation()
        if  self.m_bHHLLKSkillEliminate then
            self:touchMahjongSkillFromPoint(point, 1)
            return true
        end

        if  self.m_bHHLLKSkillPlace then
            self:touchMahjongSkillFromPoint(point, 2)
            return true
        end

        if self.m_bHHLLKInTheGame then
            for i, v in ipairs( self.m_pHHLLKSelectTouchGroup ) do
                local sRect = v.pGridTouchNode:getBoundingBox()
                if v.pGridSprite:isVisible() and cc.rectContainsPoint(sRect, point) then
                    v.pGridSprite:setVisible(false)
                    if  self.m_pHHLLKTouchMoveItem and not self.m_pHHLLKTouchMoveItem:isVisible() then
                        local sTmpFileName = "fkbnt_grid_"..v.nGridIndex..".png"
                        local nTmpType = self.mahjongMath_llk:getGridType(v.nGridIndex)
                        self.m_pHHLLKTouchMoveItem:initMahjongWithFile(sTmpFileName, nTmpType)
                        self.m_pHHLLKTouchMoveItem:setGridIndex(v.nGridIndex)
                        self.m_pHHLLKTouchMoveItem:setTouchIndex(i)
                        self.m_pHHLLKTouchMoveItem:setRgb(v.pRgb)

                        local move_pos = self.m_pHHLLKTouchMoveItem:getParent():convertToNodeSpace( point)
                        self.m_pHHLLKTouchMoveItem:setScale(1)
                        self.m_pHHLLKTouchMoveItem:setPos(move_pos)
                        self.m_pHHLLKTouchMoveItem:setVisible(true)
                        break
                    end

                    -- 播放点击音效
                    dtProjectHHLLKPlaySound(DEF_PROJCETHHLLK_SOUND_MJ_CLICK)
                end
            end
        end
        return true
    end

    local function onTouchMoved(touch, event)
        -- 移动
        local point = touch:getLocation()
        if  self.m_pHHLLKTouchMoveItem:isVisible() and not self.m_bHHLLKSkillEliminate and not m_bHHLLKSkillPlace then
            local move_pos = self.m_pHHLLKTouchMoveItem:getParent():convertToNodeSpace(point)
            local ccTmpPos = self.m_pHHLLKTouchMoveItem:setPos(move_pos)
            self:touchMahjongFromPoint(ccTmpPos)
        end
    end

    local function onTouchEnded(touch, event)
        if  self.m_pHHLLKTouchMoveItem:isVisible() and not self.m_bHHLLKSkillEliminate and not m_bHHLLKSkillPlace then
            self:touchMahjongEnd()
        end

        self.m_bHHLLKTouchTable = false
    end

    self.m_pHHLLKListener = cc.EventListenerTouchOneByOne:create()
    self.m_pHHLLKListener:setSwallowTouches(true)
    self.m_pHHLLKListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.m_pHHLLKListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.m_pHHLLKListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pHHLLKListener, self)
end

--===============================回合相关处理================================-
----------------------------------------------------------------------------
-- 向玩家发牌
function CDLayerHHLLKMahjongTable_fkbnt:round_licensingPlayer()
    if  self.m_nHHLLKLicensingType == 0 then
        local effect = CDCCBHHLLKBaseAniObject.createCCBBaseAniObject(self.m_pHHLLKMahjongEffDemo, "x_tx_kaiju.ccbi", g_pHHLLKGlobalManagment:getWinCenter(), 0)
        if  effect then
            effect:endBaseVisible( true)
            effect:endBaseRelease( true)
        end

        self.m_nHHLLKLicensingType = 1
        self:runAction( cc.Sequence:create(cc.DelayTime:create(0.7), cc.CallFunc:create(CDLayerHHLLKMahjongTable_fkbnt.round_licensingPlayer)))
        dtProjectHHLLKPlaySound( DEF_PROJCETHHLLK_SOUND_MJ_KJ)

    elseif self.m_nHHLLKLicensingType == 1 then -- 发牌
        -- 生成选择组
        self:createSelectGrid()

        -- 开启允许点击
        self.m_bHHLLKCanTouch = true
    end
end

function CDLayerHHLLKMahjongTable_fkbnt:onGameOver()
    if  self.m_pHHLLKLayerTip == nil then
        return
    end

    -- 弹出选着框，关闭点击
    self.m_bHHLLKCanTouch = false

    function closeTip()
        -- 关闭没有可放置的格子提示
        self.m_pHHLLKNodeNotPlaceTip:setVisible(false)

        -- 开启结算选项
        self.m_pHHLLKNodeGameOverTip:setVisible(true)
        local tmpTotleScore = string.format(casinoclient.getInstance():findString("llk_left_sorce"), self.m_pHHLLKPlayAI.m_nHHLLKTableLeftScore)
        self.m_pHHLLKLableTotleScore:setString(tmpTotleScore)

        dtProjectHHLLKPlaySound( DEF_PROJCETHHLLK_SOUND_MJ_SCORE)
    end

    -- 开启提示层
    self.m_pHHLLKLayerTip:setVisible(true)

    -- 开启没有可放置的格子提示
    self.m_pHHLLKNodeNotPlaceTip:setVisible(true)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(closeTip)))
    dtProjectHHLLKPlaySound( DEF_PROJCETHHLLK_SOUND_MJ_ERROR)
end

function CDLayerHHLLKMahjongTable_fkbnt:createSelectGrid()
    local bTmpIsOk = true
    local arrayTmpGrid = {}
    bTmpIsOk, arrayTmpGrid = self.mahjongMath_llk:getThreeGrid()
    local arrayTmpRgb = self.mahjongMath_llk:getThreeColor()
    if  bTmpIsOk then
        for i, v in ipairs( arrayTmpGrid ) do
            self:setGridSprite(i, v, arrayTmpRgb[i])
        end
        self.m_nHHLLKLeftPlaceNum = 3
    end

    return bTmpIsOk
end

function CDLayerHHLLKMahjongTable_fkbnt:setGridSprite(_nIndex, _nGridIndex, _tGridRgb)
    if  self.m_pHHLLKSelectTouchGroup[_nIndex].pGridTouchNode == nil then
        return
    else
        if  self.m_pHHLLKSelectTouchGroup[_nIndex].pGridSprite then
            self.m_pHHLLKSelectTouchGroup[_nIndex].pGridSprite:removeFromParent()
        end
        self.m_pHHLLKSelectTouchGroup[_nIndex].pGridSprite = nil
    end

    if  _nGridIndex ~= nil and _tGridRgb ~= nil then
        self.m_pHHLLKSelectTouchGroup[_nIndex].nGridIndex = _nGridIndex
        self.m_pHHLLKSelectTouchGroup[_nIndex].pRgb = _tGridRgb
        self.m_pHHLLKSelectTouchGroup[_nIndex].pGridSprite = cc.Sprite:createWithSpriteFrameName("fkbnt_grid_".._nGridIndex..".png")
        self.m_pHHLLKSelectTouchGroup[_nIndex].pGridSprite:setColor(_tGridRgb)
        self.m_pHHLLKSelectTouchGroup[_nIndex].pGridSprite:setScale(0.6)
        self.m_pHHLLKSelectTouchGroup[_nIndex].pGridSprite:setPosition(cc.p(90, 90))
        self.m_pHHLLKSelectTouchGroup[_nIndex].pGridSprite:setAnchorPoint(0.5, 0.5)

        self.m_pHHLLKSelectTouchGroup[_nIndex].pGridTouchNode:addChild(self.m_pHHLLKSelectTouchGroup[_nIndex].pGridSprite)
        self.m_pHHLLKSelectTouchGroup[_nIndex].pGridSprite:setVisible(true)
    else
        self.m_pHHLLKSelectTouchGroup[_nIndex].pGridSprite = nil
    end
end

--===============================界面函数绑定===============================--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 退出桌子到大厅
function CDLayerHHLLKMahjongTable_fkbnt:onGotoHall()
    cclog("CDLayerHHLLKMahjongTable_fkbnt::onExit")

    -- 关闭提示界面
    self.m_pHHLLKLayerTip:setVisible(false)
    self.m_pHHLLKNodeGameOverTip:setVisible(false)

    g_pHHLLKSceneTable:gotoSceneHall()
    dtProjectHHLLKPlaySound(DEF_SOUND_TOUCH)
end

function CDLayerHHLLKMahjongTable_fkbnt:onReStart()
    -- 关闭提示界面
    self.m_pHHLLKLayerTip:setVisible(false)
    self.m_pHHLLKNodeGameOverTip:setVisible(false)

    -- 完毕格子选择组
    for i, v in ipairs( self.m_pHHLLKSelectTouchGroup ) do
        if  v.pGridSprite and v.pGridSprite:isVisible() then
            v.pGridSprite:setVisible(false)
        end
    end

    -- 增加关卡数，并刷新本地数据
    local nTmpLeftPhy = g_pHHLLKGlobalManagment.m_nTmpPhysical - DEF_PROJCETHHLLK_LLK_PHY_EXP
    if  nTmpLeftPhy >= 0 then

        local nTmpGameCount = g_pHHLLKGlobalManagment.m_nGameCount + 1
        g_pHHLLKGlobalManagment:setLLKTmpPhysical(nTmpLeftPhy)
        g_pHHLLKGlobalManagment:setLLKGameCount(nTmpGameCount)

        -- 重新更新数据
        self.m_pHHLLKPlayAI.m_nHHLLKTableLeftScore = 0

        -- 重新开始，需要刷新关卡、历史最高积分
        self.m_nHHLLKNowCheckPoint = 1
        self:refreshTableMaxScore()
        self:Handle_llk_StartPlay()
    else
        g_pHHLLKSceneTable:gotoSceneHall()
    end

    dtProjectHHLLKPlaySound(DEF_SOUND_TOUCH)
end

function CDLayerHHLLKMahjongTable_fkbnt:onResurgence()
end

----------------------------------------------------------------------------
-- 技能相关
function CDLayerHHLLKMahjongTable_fkbnt:onReset()
    if  self.m_bHHLLKSkillPlace or self.m_bHHLLKSkillEliminate or not self.m_bHHLLKCanTouch then
        return
    end
    self:createSelectGrid()
end

function CDLayerHHLLKMahjongTable_fkbnt:onEliminate()
    if  self.m_bHHLLKSkillPlace or self.m_bHHLLKSkillEliminate or not self.m_bHHLLKCanTouch then
        return
    end
    self.m_pHHLLKSkillLayer:setVisible(true)
    self.m_bHHLLKSkillEliminate = true
end

function CDLayerHHLLKMahjongTable_fkbnt:onPlace()
    if  self.m_bHHLLKSkillPlace or self.m_bHHLLKSkillEliminate or not self.m_bHHLLKCanTouch then
        return
    end
    self.m_pHHLLKSkillLayer:setVisible(true)
    self.m_bHHLLKSkillPlace = true
end

----------------------------------------------------------------------------
-- 音乐设置
function CDLayerHHLLKMahjongTable_fkbnt:onMusic()

    local bMusic = g_pHHLLKGlobalManagment:isEnableMusic()
    g_pHHLLKGlobalManagment:enableMusic(not bMusic)
end

----------------------------------------------------------------------------
-- 音效设置
function CDLayerHHLLKMahjongTable_fkbnt:onSound()

    local bSound = g_pHHLLKGlobalManagment:isEnableSound()
    g_pHHLLKGlobalManagment:enableSound( not bSound)
end

----------------------------------------------------------------------------
-- 设置
function CDLayerHHLLKMahjongTable_fkbnt:onSetting()
    cclog( "CDLayerHHLLKMahjongTable_fkbnt:onSetting")

    if  not self.m_pHHLLKGroupBar:isVisible() then
        return
    end
    if  self.m_bHHLLKSkillPlace or self.m_bHHLLKSkillEliminate or not self.m_bHHLLKCanTouch then
        return
    end

    g_pHHLLKSceneTable:closeAllUserInterface()

    local pos = cc.p( 0.0, self.m_pHHLLKButSetting:getPositionY())
    g_pHHLLKSceneTable.m_pHHLLKLayerTipBar:setPosition(pos)
    g_pHHLLKSceneTable.m_pHHLLKLayerTipBar:open(casinoclient.getInstance():isSelfBuildTable())
end

function CDLayerHHLLKMahjongTable_fkbnt:onReady()
    cclog("CDLayerHHLLKMahjongTable_fkbnt:onReady")

    -- 开始游戏
    self:Handle_llk_StartPlay()
end

----------------------------------------------------------------------------
-- ccb处理
-- 变量绑定
function CDLayerHHLLKMahjongTable_fkbnt:onAssignCCBMemberVariable(loader)
    cclog("CDLayerHHLLKMahjongTable_fkbnt::onAssignCCBMemberVariable")

    -- 灯光
    self.m_pHHLLKLighting     = loader["pic_alpha"]

    -- 底部的状态信息
    self.m_pHHLLKGroupBar     = loader["group_bar"]
    self.m_pHHLLKButSetting   = loader["but_setting"]
    self.m_pHHLLKSelfInfo     = loader["self_info"]
    self.m_pHHLLKTableInfo    = loader["table_info"]

    self.m_pHHLLKNewLayerRoot    = loader["new_layer"]
    self.m_pHHLLKGridNodeRoot    = loader["grid_layer"]
    self.m_pHHLLKNodeGaugePoint  = loader["gauge_point_node"]           -- 定位

    -- 电池
    self.m_pHHLLKIcoPower        = loader["power"]
    self.m_pHHLLKNewEffLayer     = loader["newEfflayer"]

    -- 选择框
    for i = 1, 3 do
        self.m_pHHLLKSelectTouchGroup[i].pGridTouchNode = loader["Touch_grid_"..i]
        self.m_pHHLLKSelectTouchGroup[i].nGridIndex = i
        self.m_pHHLLKSelectTouchGroup[i].pGridSprite = nil
        self.m_pHHLLKSelectTouchGroup[i].pRgb = nil
    end

    --------------------------------------------------------
    -- 技能相关绑定
    self.m_pHHLLKSkillBar            = loader["skill_group"]             -- 技能根Node
    self.m_pHHLLKSkillLayer          = loader["skill_Layer"]             -- 技能遮罩
    self.m_pHHLLKLabelResetExp       = loader["reset_gold_exp"]          -- 重置技能消耗文本
    self.m_pHHLLKLabelEliminateExp   = loader["eliminate_gold_exp"]      -- 消除技能消耗文本
    self.m_pHHLLKLabelPlaceExp       = loader["place_gold_exp"]          -- 放置单方块技能消耗文本

    --------------------------------------------------------
    -- 相关绑定
    self.m_pHHLLKLableMaxScore     = loader["max_score_label"]

    -- 弹出层相关控件
    self.m_pHHLLKLayerTip          = loader["layer_group"]
    self.m_pHHLLKNodeNotPlaceTip   = loader["tip_not_place"]
    self.m_pHHLLKNodeGameOverTip   = loader["tip_game_over"]
    self.m_pHHLLKLableTotleScore   = loader["label_tip_totle_score"]
    self.m_pHHLLKNodeResurgenceTip = loader["tip_resurgence"]
    self.m_pHHLLKLableResurgenceExp = loader["resurgence_gold_exp"]
end

----------------------------------------------------------------------------
-- ccb处理
-- 函数绑定
function CDLayerHHLLKMahjongTable_fkbnt:onResolveCCBCCControlSelector(loader)
    cclog("CDLayerHHLLKMahjongTable_fkbnt::onResolveCCBCCControlSelector")
    
    ----------------------------------------------------------------
    -- 功能函数绑定
    loader["onSetting"]     = function() self:onSetting() end         
    loader["onGotoHall"]    = function() self:onGotoHall() end
    loader["onReStart"]     = function() self:onReStart() end
    loader["onResurgence"]  = function() self:onResurgence() end

    ----------------------------------------------------------------
    -- 技能函数绑定
    loader["onReset"]       = function() self:onReset() end
    loader["onEliminate"]   = function() self:onEliminate() end
    loader["onPlace"]       = function() self:onPlace() end
end

--------------------------------------------------------------------------
function CDLayerHHLLKMahjongTable_fkbnt.createCDLayerTable_xtlzddz(pParent)
    cclog("CDLayerHHLLKMahjongTable_fkbnt::createCDLayerTable_xtlzddz")
    if not pParent then
        return nil
    end
    local insLayer = CDLayerHHLLKMahjongTable_fkbnt.new()
    insLayer:init()
    local loader = insLayer.m_ccBaseLoader
    insLayer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad("CDLayerHHLLKMahjongTable_fkbnt.ccbi",proxy,loader)
    insLayer.m_ccBaseLayer = node
    insLayer:onAssignCCBMemberVariable(loader)
    insLayer:addChild(node)
    pParent:addChild(insLayer)
    return insLayer
end
