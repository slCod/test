--[[
/******************************************************
//Project:      ProjectX 
//Moudle:       CDLayerTable_JYDS 仙桃赖子斗地主桌子
//File Name:    DLayerCardTable_xtlzddz.h
//Author:       GostYe
//Start Data:   2016.12.27
//Language:     XCode 4.5
//Target:       IOS, Android

-- 在调用前，需要先设置 m_nPlayers 玩家
-- 进入类后，先调用createUserInterface

******************************************************/
]]

require( REQUIRE_PATH.."DDefine")
require( REQUIRE_PATH.."DCCBLayer")
require( REQUIRE_PATH.."DTKDScene")
require( REQUIRE_PATH.."_tkd_tbmenu")

require( REQUIRE_PATH.."mahjong_define")

--require "CCBReaderLoad"

local casinoclient = require("script.client.casinoclient")
local platform_help = require("platform_help")


--屏幕的尺寸
local ScreenSize = CDGlobalMgr:sharedGlobalMgr():getWinSize()

-- 音效定义
DEF_SOUND_MJ_CLICK      = "sound_card_click"..DEF_TKD_SOUND     -- 点中牌
DEF_SOUND_MJ_KJ         = "mj_kj"..DEF_TKD_SOUND                -- 开局

-----------------------------------------
-- 类定义
CDLayerTable_JYDS = class("CDLayerTable_JYDS", CDCCBLayer)    
CDLayerTable_JYDS.__index = CDLayerTable_JYDS
CDLayerTable_JYDS.name = "CDLayerTable_JYDS"

-- 构造函数
function CDLayerTable_JYDS:ctor()
    cclog("CDLayerTable_JYDS::ctor")
    CDLayerTable_JYDS.super.ctor(self)
    CDLayerTable_JYDS.initialMember(self)
    --reg enter and exit
    local function onNodeEvent(event)
        if "enter" == event then
            CDLayerTable_JYDS.onEnter(self)
        elseif "exit" == event then
            CDLayerTable_JYDS.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function CDLayerTable_JYDS:onEnter()
    cclog("CDLayerTable_JYDS::onEnter")

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
end

function CDLayerTable_JYDS:onExit()
    cclog("CDLayerTable_JYDS::onExit")
    -- if self.playAudioID then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.playAudioID)   
    --     self.playAudioID=nil
    -- end

    -- 退出时，停止发送心跳
    self:stopHeartLoop()
    self:stopAllActions()

    casinoclient.getInstance():removeListenerAllEvents(self)
    CDLayerTable_JYDS.releaseMember(self)
    self:unregisterScriptHandler()

    --退出时销毁定时器
    self:cancelSchedule1()
    self:cancelSchedule2()
end

-----------------------------------------
-- 初始化
function CDLayerTable_JYDS:initialMember()
    cclog("CDLayerTable_JYDS::initialMember")

    ---------------------------------------------------
    -- 底部的状态信息 
    self.m_pGroupBar        = nil        -- 状态按钮根节点
    self.m_pButSetting      = nil        -- 设置按钮
    self.m_pSelfInfo        = nil        -- 自己的信息
    self.m_pTableInfo       = nil        -- 桌子的信息

    self.m_pTimeLabel      = nil        -- 倒计时的时间
    self.m_pShowMode       = nil         -- 显示的模式
    self.m_pShowNanDu      = nil
    self.m_pShowJiShi      = nil
    ---------------------------------------------------
    -- 桌子中相关按钮
    self.m_pReadyBtn        = nil        -- 准备按钮

    self.m_pReadyBtnLayer   = nil  
    self.m_pCloseBtn        = nil        -- 关闭设置按钮
    ---------------------------------------------------
    -- 桌子中相关'节点'与'层''
    self.m_pNewEffLayer     = nil        -- 特效层
    self.m_pNewLayerRoot    = nil        -- 桌面麻将放置的根节点
    self.m_pLighting        = nil        -- 灯光

    self.m_pMahjongBtnDemo     = nil        -- 麻将按钮放置层

    self.m_pMahjongShowLayer = nil      -- 中间麻将显示的放置层
    ---------------------------------------------------
    -- 电池
    self.m_pIcoPower        = nil        -- 电池图标

    self.m_pLastViewLayer = nil          --胜利或失败界面Layer

    self.m_pWinNode     = nil
    self.m_pLoseNode    = nil

    
    self.m_PEndSprite  = nil

    -- self.m_pBtnGoToHall   = nil
     self.m_pBtnRestart    = nil

     self.m_pBtnNextRound  = nil
------------------------------------
    self.m_pSettingNode  = nil

    self.m_pSoundOpen   = nil
    self.m_pSoundClose  = nil
    self.m_pMusicOpen   = nil
    self.m_pMusicClose  = nil

    self.m_pSoundOpenBtn   = nil
    self.m_pSoundCloseBtn  = nil
    self.m_pMusicOpenBtn   = nil
    self.m_pMusicCloseBtn  = nil

    self.m_pShowPrompt    = nil

    ---------------------------------------------------
    -- 游戏相关变量定义
    self.m_pPlayer          = {}         -- 玩家
    self.m_pPlayer.name     = ""         -- 玩家姓名
    self.m_pPlayer.gold     = 0          -- 玩家货币
    ---------------------------------------------------

    self.m_pMahjongBtn      = {}         -- 麻将按钮数组

    self.m_pShowMah         = {}         -- 显示在中间的麻将牌

    self.m_pShowFloorMah    = {}         -- 显示在上方框里面的麻将

    self.m_pListener        = nil        -- 监听对象
 
    -- self.m_pEffNetLow       = nil        -- 网络连接缓慢提示特效
    self.m_bPreCreate       = false      -- 是否预创建过

    self.m_nFlag            = nil        -- 游戏类型(1、简单 2、普通 3、困难 、4.挑战)
    
    ---------------------------------------------------
    self.m_bIsTouchSetting = false      -- 是否点击设置
    self.m_nGuessNumLength        = 0          -- 需要猜的麻将个数
    
    self.m_nNeedTime       =   0               -- 所需的时间
    self.isWin             = false       -- 是否胜利

    self.m_nTotalRound    = 1            -- 局数(再来一局时这个值会增加)

    self.m_nShowMahjongArr      =  {}    -- 保存显示的麻将牌数组

    self.m_nRandMahjongArr      = {}     -- 随机出来的的麻将

    self.m_nGuessIndex          = 1      -- 猜的第几个

    self.m_saveTouchArr         = {}     -- 保存点击的麻将牌数值

    self.m_nNeedGuessPos        = 0      -- 挑战模式下需要猜的第几个

    self.m_nStage     =   -1

    self.m_nBackIndex   = 0              -- 保存上面麻将牌第几个的位置
    self.m_nCount       = 0
end

function CDLayerTable_JYDS:releaseMember()
    cclog("CDLayerTable_JYDS::releaseMember")

    if  self.m_pNewEffLayer then
        self.m_pNewEffLayer:removeAllChildren()
    end

    if  self.m_pNewLayerRoot ~= nil then
        self.m_pNewLayerRoot:removeAllChildren()
        self.m_pEffNetLow = nil
    end

    --模拟析构父类
    CDLayerTable_JYDS.super.releaseMember(self)
    if  DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end

    if self.m_pListener then
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:removeEventListener(self.m_pListener)
        self.m_pListener = nil
    end
end

--===============================网络消息处理===============================--

-- 心跳包
-- 参数: 数据包
function CDLayerTable_JYDS:Handle_Ping( __event)
    cclog("CDLayerTable_JYDS:Handle_Ping")
    local function badNetWork() -- 网络恢复缓慢
        if  self.m_bInTheGame then

            self.m_pNewLayerRoot:stopAllActions()
            self.m_pEffNetLow:setVisible( false)

            casinoclient.getInstance().m_socket:onDisconnect() --超时太多断线重连
            dtPlaySound( DEF_SOUND_ERROR)
        end
    end

    local function netRefreshTimeOut()
        if  self.m_bInTheGame then
            self.m_nTimeOut = self.m_nTimeOut - 1
            if  self.m_nTimeOut < 0 then
                self.m_nTimeOut = 0
            end
            self.m_pEffNetLow:setDefineText( 
                string.format( casinoclient.getInstance():findString("net_low"), self.m_nTimeOut))

            if  self.m_nTimeOut > 0 then

                self.m_pNewLayerRoot:stopAllActions()
                self.m_pNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( netRefreshTimeOut)))
            else
                self.m_pNewLayerRoot:stopAllActions()
                self.m_pNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( badNetWork)))
            end
        end
    end

    local function netTimeOut() -- 超时提示
        if self.m_bInTheGame then
            self.m_nTimeOut = DEF_TIMEOUT1
            self.m_pEffNetLow:setVisible( true)
            self.m_pEffNetLow:setDefineText( 
                string.format( casinoclient.getInstance():findString("net_low"), self.m_nTimeOut))

            self.m_pNewLayerRoot:stopAllActions()
            self.m_pNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( netRefreshTimeOut)))
            dtPlaySound( DEF_SOUND_ERROR)
        end
    end

    -- 假如提示资源存在那么显示
    if  self.m_pNewLayerRoot ~= nil and self.m_pEffNetLow ~= nil then
        self.m_pEffNetLow:setVisible( false)
        self.m_pNewLayerRoot:stopAllActions()
        self.m_pNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( DEF_HEARTBEAT_TIME), cc.CallFunc:create( netTimeOut)))
    end
    return true
end

-- 循环发送心跳包
function CDLayerTable_JYDS:createHeartbeatLoop( ... )
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
function CDLayerTable_JYDS:stopHeartLoop( ... )
    if  self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)   
        self.schedulerID=nil
    end
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------

-- 所有玩家准备结束，可以进行发牌的反馈
-- 参数: 数据包
function CDLayerTable_JYDS:Handle_Dqq_StartPlay(__event)
    cclog("CDLayerTable_JYDS:Handle_llk_StartPlay")
     math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
    -- 开始游戏后，关闭主场景中的不相关场景
    g_pSceneTable:closeAllUserInterface()

    -- 获取并生产玩家数据
    -- local nickname = casinoclient.getInstance():getPlayerData():getNickname()
    -- local channelNickname = casinoclient.getInstance():getPlayerData():getChannelNickname()
    -- self.m_pPlayer.name = dtGetNickname(nickname, channelNickname)
    -- self.m_pPlayer.gold = casinoclient:getInstance():getPlayerData():getPlayerResourceGold()
    --self:refreshSelfInfo()


    self.m_bInTheGame = false
    --进入游戏

    if self.m_pttf then
        self.m_pttf:removeFromParent()
        self.m_pttf=nil
    end

    if self.m_pLabelPrompt then
        self.m_pLabelPrompt:removeFromParent()
        self.m_pLabelPrompt = nil
    end    

    if self.m_nFlag == 5 then
        self:showTimeLabel()
    end

    self.m_nStage = 0 

    self:IntoGameStage()

end


----------------------------------------------------------------------------
function CDLayerTable_JYDS:showTimeLabel()
    
    self.m_pttf = cc.LabelTTF:create("0.000","Courier New",60)
    self.m_pttf:setColor(cc.c3b(255,0,0))
    self.m_pttf:setString("10")
    self.m_pttf:setVisible(false)
    self.m_pttf:setPosition(cc.p(ScreenSize.width/2,ScreenSize.height/2+50))
    self.m_pNewLayerRoot:addChild(self.m_pttf)
end

----------------------------------------------------------------------------

function CDLayerTable_JYDS:IntoGameStage()
    if self.m_nStage ==  0 then
  
        print("展示随机的麻将牌")

        local index = 1
        local function showMahjong()
            for i = 1 ,self.m_nGuessNumLength do
                self.m_pShowMah[i]:setVisible(false)
            end
            print(self.m_nRandMahjongArr[index])
           
            self.m_pShowMah[index]:initMahjongWithFile( string.format( "t_%u.png", self.m_nRandMahjongArr[index]))
            self.m_pShowMah[index]:setPosition(cc.p(ScreenSize.width/2,ScreenSize.height/2+50))
            self.m_pShowMah[index]:setVisible(true)

            --挑战模式下无需显示
            if self.m_nFlag ~= 4 then
                table.insert(self.m_nShowMahjongArr,self.m_nRandMahjongArr[index])
                
                local startPosX = 950 - TABLE_SIZE(self.m_nShowMahjongArr)*80
                for j =1 ,TABLE_SIZE(self.m_nShowMahjongArr) do
                    self.m_pShowFloorMah[j]:initMahjongWithFile( string.format( "t_%u.png", self.m_nShowMahjongArr[j]))
                    self.m_pShowFloorMah[j]:setPosition(cc.p(startPosX+j*80,490))
                end
            end

            
            if index == self.m_nGuessNumLength then
                self.m_nStage =  1
                self:cancelSchedule1()
                self:runAction(cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( CDLayerTable_JYDS.IntoGameStage)))
            end
            index = index + 1
        end

        if self.m_nFlag ~= 5 then
            if not self.schedulerID1 then
                self.schedulerID1 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(showMahjong,1.0,false)
            end
        else

            local mahSize = 0
            if self.m_pShowMah[1] then
                mahSize = self.m_pShowMah[1].m_nSizeW *1.5
            end
            for i =1 ,TABLE_SIZE(self.m_nRandMahjongArr) do
                self.m_pShowMah[i]:initMahjongWithFile( string.format( "t_%u.png", self.m_nRandMahjongArr[i]),"mj_b_back.png")
                self.m_pShowMah[i]:setPosition(cc.p(ScreenSize.width/2-20-5*mahSize+(8+mahSize)*i,ScreenSize.height/2-50))
                self.m_pShowMah[i]:setVisible(true)
        
            end     

            local time = 10
            self.m_pttf:setVisible(true)
            local function startTimer()
                time = time - 1
                if time < 0 then
                    time = 0
                    self.m_nStage =  1
                    self:cancelSchedule1()
                    self:runAction(cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( CDLayerTable_JYDS.IntoGameStage)))
                end
                 if self.m_pttf then
                    self.m_pttf:setString(string.format("%d",time))
                end
            end 

            if not self.schedulerID1 then
                self.schedulerID1 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(startTimer,1.0,false)
            end   

            --随机要猜的几个麻将
            self.m_nRandNum = math.random(3,5)
            self.m_ArrRand = {}
            self.m_indexArr = {}
            local arr = {1,2,3,4,5,6,7,8,9}
           
            for i = 1,self.m_nRandNum do
                local index = math.random(1,#arr)
                table.insert(self.m_indexArr,arr[index])
                table.insert(self.m_ArrRand,self.m_nRandMahjongArr[arr[index]])
                table.remove(arr,index)
            end
            dumpArray(self.m_indexArr)
           
            print(self.m_nRandNum)
            dumpArray(self.m_ArrRand)

        end
      
      
    elseif  self.m_nStage ==  1 then
        --隐藏所有的显示麻将牌
        print("第一阶段------")

      
        if self.m_nFlag == 5 then
            if self.m_pttf then
                self.m_pttf:removeFromParent()
                self.m_pttf = nil
            end

            self.m_pLabelPrompt = cc.Label:create()
            self.m_pLabelPrompt:setString("请选择填写未知麻将")
            self.m_pLabelPrompt:setSystemFontSize(45)
            self.m_pLabelPrompt:setTextColor(cc.c3b(255,255,0))
            self.m_pLabelPrompt:setPosition(cc.p(ScreenSize.width/2,ScreenSize.height/2+50))
            self.m_pNewLayerRoot:addChild(self.m_pLabelPrompt)


            local mahSize = 0
            if self.m_pShowMah[1] then
                mahSize = self.m_pShowMah[1].m_nSizeW *1.5
            end
           
            for i=1,self.m_nGuessNumLength do
                self.m_pShowMah[i]:setVisible(true)
                self.m_pShowMah[i]:setPosition(cc.p(ScreenSize.width/2-20-5*mahSize+(8+mahSize)*i,ScreenSize.height-150))
            end

            for j = 1 ,#self.m_indexArr do
                self.m_pShowMah[self.m_indexArr[j]]:setBackVisible(true)
                self.m_pShowMah[self.m_indexArr[j]]:setMahjongScale(0.9)
                self.m_pShowMah[self.m_indexArr[j]]:setIsBack(true)
                self.m_pShowMah[self.m_indexArr[j]]:setBackIndex(self.m_indexArr[j])
                self.m_pShowMah[self.m_indexArr[j]]:setMahValue(self.m_ArrRand[j])
            end

        else

            for j = 1 ,self.m_nGuessNumLength do
                self.m_pShowMah[j]:setVisible(false)
                if self.m_nFlag~=4 then
                    self.m_pShowFloorMah[j]:setVisible(false)
                end
            end
        end

        --显示麻将按钮
        if self.m_nFlag == 5 then
            for i,v in pairs(self.m_pMahjongBtn) do
                if not v.item:isVisible() then
                    v.item:setVisible(true)
                end
            end
        end

        
        self.m_nStage = 2
        self:runAction(cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( CDLayerTable_JYDS.IntoGameStage)))

    elseif   self.m_nStage ==  2 then
        --启动定时器

        if self.m_pTimeLabel then
            self.m_pTimeLabel:setVisible(true)
            self.m_pShowJiShi:setVisible(true)
        end
       
        self.m_bInTheGame = true

        local timeCount = self.m_nNeedTime

        local function startGame ()
            timeCount = timeCount-1
            if timeCount<0 then
                timeCount =0
                self:cancelSchedule2()
                self.isWin = false
                self:showLastView()
            end

            self.m_pTimeLabel:setString(timeCount)
        end 

        if self.m_nFlag == 4 then
            --显示要猜的第几个数字图标,此时一张牌飞上去
            if self.m_pShowPrompt then

                self.m_pShowPrompt:setVisible(true)
                self.m_pShowFloorMah[1]:initMahjongWithFile("t_11.png","mj_b_back.png")
                self.m_pShowFloorMah[1]:setBackVisible(true)
                self.m_pShowFloorMah[1]:setPosition(cc.p(ScreenSize.width/2,ScreenSize.height/2+50))
                self.m_pShowFloorMah[1]:runAction(cc.Spawn:create(cc.MoveTo:create(0.3,cc.p(ScreenSize.width-150,ScreenSize.height-155)),cc.ScaleTo:create(0.3,0.6,0.6)))
            end
        end
        if not self.schedulerID2 then
            self.schedulerID2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(startGame,1.0,false)
        end

    end
end



function CDLayerTable_JYDS:cancelSchedule1()
    if  self.schedulerID1 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID1)   
        self.schedulerID1 = nil
    end
end

function CDLayerTable_JYDS:cancelSchedule2()
    if  self.schedulerID2 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID2)   
        self.schedulerID2 = nil
    end
end

function CDLayerTable_JYDS:randEndSprite()
    local SpriteStr = ""
    local index = 0

    if self.isWin then
        --成功有7个sprite 1 ~ 7
        local  tempArr = {1,2,3,4}
        if self.m_nFlag == 1 then
            table.insert(tempArr,5)
        elseif self.m_nFlag == 2 then
            table.insert(tempArr,6)
        elseif self.m_nFlag == 3 then
            table.insert(tempArr,7)
        end

        index = math.random(TABLE_SIZE(tempArr))
        SpriteStr ="win_"..index..".png"
    else
        --一共有5个失败的sprite
        index = math.random(4)
        SpriteStr ="lost_"..index..".png"
    end

    return SpriteStr
end




function CDLayerTable_JYDS:showLastView()
    --DEF_GAME_ISEND =true
    local tempSprite =self:randEndSprite()
    self.m_bInTheGame = false
    -- for i =1 ,TABLE_SIZE(self.m_saveTouchArr) do
    --     self.m_pShowFloorMah[i]:setVisible(false)
    -- end
    self:stopAllActions()
    self.m_pLastViewLayer:setVisible(true)

    if self.m_PEndSprite ~= nil then
        self.m_PEndSprite:removeFromParent()
        self.m_PEndSprite = nil
    end

    if self.isWin then

        self.m_pWinNode:setVisible(true)
        self.m_pLoseNode:setVisible(false)

        self.m_PEndSprite = cc.Sprite:create(tempSprite)
        self.m_pWinNode:addChild(self.m_PEndSprite)
        self.m_PEndSprite:setPosition(cc.p(145,175))
        self.m_PEndSprite:setAnchorPoint(cc.p(0.5,0.5))
        self.m_PEndSprite:setVisible(true)

        
        if self.m_nFlag == 5 then
            self.m_pBtnRestart:setVisible(true)
            self.m_pBtnNextRound:setVisible(false)
        else
            self.m_pBtnRestart:setVisible(false)
            self.m_pBtnNextRound:setVisible(true)
        end
       
    else
        
        self.m_pLoseNode:setVisible(true)
        self.m_pWinNode:setVisible(false)

        self.m_PEndSprite = cc.Sprite:create(tempSprite)
        self.m_pLoseNode:addChild(self.m_PEndSprite)
        self.m_PEndSprite:setPosition(cc.p(145,175))
        self.m_PEndSprite:setAnchorPoint(cc.p(0.5,0.5))
        self.m_PEndSprite:setVisible(true)

        self.m_pBtnRestart:setVisible(true)
        self.m_pBtnNextRound:setVisible(false)
    end

    if self.m_nFlag == 5 then
        self.m_pBtnRestart:setVisible(true)
        self.m_pBtnNextRound:setVisible(false)
    end

    self.m_pButSetting:setVisible(false)
end


-- 重置电量
function CDLayerTable_JYDS:resetPower()
    local function updatePower()
        local power = platform_help.getBatterLevel()
        if  power > 100 then
            power = 100
        elseif power < 0 then
            power = 0
        end
    
        local width = power * 0.01 * 33
        local size = self.m_pIcoPower:getContentSize()
        size.width = width
        self.m_pIcoPower:setContentSize(size)
        self.m_pIcoPower:runAction(cc.Sequence:create(cc.DelayTime:create(60.0), cc.CallFunc:create(updatePower)))
    end
    updatePower()
end


--=================================基本方法=================================--
-- 设置自己的信息
-- function CDLayerTable_JYDS:refreshSelfInfo()
--     self.m_pSelfInfo:setString(self.m_pPlayer.name .. ":" .. self.m_pPlayer.gold)
-- end

-- 初始化界面
----------------------------------------------------------------------------
-- 创建用户界面
function CDLayerTable_JYDS:createUserInterface(flag)
    cclog("CDLayerTable_JYDS::createUserInterface")
    --DEF_GAME_ISEND = false
    self.m_nFlag = flag

    --需要猜的数字长度 ，时间
    self.m_nGuessNumLength,self.m_nNeedTime = self:getFlagConfig()

    print("========CDLayerTable_JYDS==========")
    print("self.m_nFlag",self.m_nFlag)
    print("self.m_nGuessNumLength",self.m_nGuessNumLength)
    print("========CDLayerTable_JYDS==========")


    -- 创建桌面需要特效放置层

    if self.m_pMahjongBtnDemo then
        self.m_pMahjongBtnDemo:removeFromParent()
        self.m_pMahjongBtnDemo = nil
    end

    if self.m_pMahjongShowLayer then
        self.m_pMahjongShowLayer:removeFromParent()
        self.m_pMahjongShowLayer = nil
    end
      
    self.m_pMahjongBtnDemo = cc.Layer:create()
    self.m_pNewLayerRoot:addChild(self.m_pMahjongBtnDemo)
    self.m_pMahjongShowLayer = cc.Layer:create()
    self.m_pNewLayerRoot:addChild(self.m_pMahjongShowLayer)
   
    -- 预创建
    self.m_bPreCreate = false
    self:preCreate()

    -- 重置电量
    self:resetPower()
end

function CDLayerTable_JYDS:createAllMahjongBtnAndMode(flag)

    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

    local modeLabel = ""
    if flag == 1 then
         modeLabel = "简单 1-"..self.m_nTotalRound
     
    elseif flag == 2 then
         modeLabel = "普通 2-"..self.m_nTotalRound
    elseif flag == 3 then 
         modeLabel = "困难 3-"..self.m_nTotalRound
    elseif flag == 4 then
         modeLabel = "挑战 4-"..self.m_nTotalRound
    end

    --创建 麻将牌按钮
    if flag == 4 then
        flag = 2 
    end

    if flag == 5 then
        flag = 3
    end

    for i =1,flag do
        for j =1 ,9 do
            local index = j+i*10
            local mahjongBtn = {}
            mahjongBtn.item = CDMahjong.createCDMahjong(self.m_pMahjongBtnDemo)
            mahjongBtn.value = index
            mahjongBtn.item:setMahjongScale(1.2)
            mahjongBtn.item:initMahjongWithFile( string.format( "t_%u.png", index))
            local x = (ScreenSize.width-(mahjongBtn.item.m_nSizeW+20)*9)/2 +mahjongBtn.item.m_nSizeW/2
            mahjongBtn.item:setPosition(cc.p(x+(j-1)*(mahjongBtn.item.m_nSizeW+20),260-(i-1)*(mahjongBtn.item.m_nSizeH+10)))
            table.insert(self.m_pMahjongBtn,mahjongBtn)
        end
    end

    if self.m_nFlag == 5 then
        for i,v in pairs(self.m_pMahjongBtn) do
            if v.item:isVisible() then
                v.item:setVisible(false)
            end
        end
    end

    --随机出麻将牌 --self.m_nRandMahjongArr保存随机出的麻将牌数值
    local count = 0
    while  count < self.m_nGuessNumLength do
        local randNum = math.random(11,9+flag*10)
        if randNum ~=20 and randNum~=30 then
            count = count +1 
            table.insert(self.m_nRandMahjongArr,randNum)
        end
    end


    --创建显示在中间,上方的麻将牌
    for i =1 ,self.m_nGuessNumLength do
        self.m_pShowMah[i] =CDMahjong.createCDMahjong(self.m_pMahjongShowLayer)
        if self.m_nFlag == 5 then
            self.m_pShowMah[i]:setMahjongScale(1.5)
        else
            self.m_pShowMah[i]:setMahjongScale(2.0)
        end
   
        self.m_pShowFloorMah[i] = CDMahjong.createCDMahjong(self.m_pMahjongShowLayer)
        self.m_pShowFloorMah[i]:setMahjongScale(1.5)

    end

    if self.m_nFlag == 4 then
        if self.numberLabel ~= nil then
            self.numberLabel:removeFromParent()
            self.numberLabel =nil
        end
        self.m_nNeedGuessPos = math.random(self.m_nGuessNumLength)
        print("self.m_nNeedGuessPos----------->",self.m_nNeedGuessPos)
        local str = string.format("%d",self.m_nNeedGuessPos)
        self.numberLabel = cc.LabelAtlas:_create(str, "Number_jyds.png", 34, 49, string.byte("0"))
        self.numberLabel:setPosition(cc.p(18,20))
        self.numberLabel:setAnchorPoint(cc.p(1,1))
        self.m_pShowPrompt:addChild(self.numberLabel)
        self.numberLabel:setVisible(true)
        self.m_pShowPrompt:setVisible(false)
    end

    self.m_pTimeLabel:setString(self.m_nNeedTime)
    self.m_pShowMode:setString(modeLabel)

    if self.m_nFlag == 5 then
        self.m_pShowNanDu:setVisible(false)
        self.m_pShowMode:setVisible(false)
        self.m_pTimeLabel:setVisible(false)
        self.m_pShowJiShi:setVisible(false)
    else
        self.m_pShowNanDu:setVisible(true)
        self.m_pShowMode:setVisible(true)
        self.m_pTimeLabel:setVisible(true)
        self.m_pShowJiShi:setVisible(true)
    end

end

-- 预创建
function CDLayerTable_JYDS:preCreate()
    cclog( "CDLayerTable_JYDS:preCreate")
    if  self.m_bPreCreate then
        return
    end

    -- 创建下方麻将牌的按钮和模式，根据 self.m_nFlag 的值
    self:createAllMahjongBtnAndMode(self.m_nFlag)
  
    --随机需要展示的麻将牌

    self.m_bPreCreate = true

end

function CDLayerTable_JYDS:touchMahFromPoint(point)

    if self.m_nFlag == 5 then
        --清除所有点击背面的麻将的颜色
        for i ,v in pairs(self.m_pShowMah) do
            if v:getIsBack() then
                v:clearBackColor_JYDS()
            end
        end

        for i,v in pairs(self.m_pShowMah) do
            if v:touchInFromPoint(point) then
                if v:getIsBack() then --当是背面时
                    --v:runAction(cc.Sequence:create(cc.CallFunc:create(v.setBackColor_JYDS),cc.DelayTime:create(0.4),cc.CallFunc:create(v.clearBackColor_JYDS)))
                    v:setBackColor_JYDS()
                    self.m_nBackIndex = v:getBackIndex()
                    self.m_nValue = v:getMahValue()
                    print("self.m_nBackIndex---->",self.m_nBackIndex)
                    print("self.m_nValue---->",self.m_nValue)
                    break
                end
            end
        end
    end
    print("self.m_nBackIndex-------------------->",self.m_nBackIndex)

    for i,v in pairs(self.m_pMahjongBtn) do
        if v.item:touchInFromPoint(point) then
            dtPlaySound( DEF_SOUND_TOUCH)
            --点击麻将颜色变化然后消失
            v.item:runAction(cc.Sequence:create(cc.CallFunc:create(v.item.setColor_JYDS),cc.DelayTime:create(0.4),cc.CallFunc:create(v.item.clearColor_JYDS)))
        
            --上方显示自己点击的麻将
            if self.m_nFlag == 4 then
                self.m_pShowFloorMah[1]:setBackVisible(false)
                self.m_pShowFloorMah[1]:initMahjongWithFile(string.format( "t_%u.png",self.m_nRandMahjongArr[self.m_nNeedGuessPos]))
                self.m_pShowFloorMah[1]:setMahjongScale(2.0)
             
                if self.m_nRandMahjongArr[self.m_nNeedGuessPos] == v.value then
                    self.isWin = true
                    self:showLastView()
                else
                    self.isWin = false
                    self:showLastView()
                end
                self:cancelSchedule2()
                return
            elseif self.m_nFlag == 5 then
                if self.m_nBackIndex ~= 0 then
                    if v.value == self.m_nValue then
                        print("-----点对了--------")
                        self.m_nCount = self.m_nCount +1 
                        self.m_pShowMah[self.m_nBackIndex]:clearBackColor_JYDS()
                        self.m_pShowMah[self.m_nBackIndex]:setBackVisible(false)
                        self.m_pShowMah[self.m_nBackIndex]:setMahjongScale(1.5)
                        self.m_pShowMah[self.m_nBackIndex]:setIsBack(false)
                        self.m_nBackIndex = 0

                    else
                        
                        self.m_pShowMah[self.m_nBackIndex]:setBackVisible(false)
                        self.m_pShowMah[self.m_nBackIndex]:setMahjongScale(1.5)
                        self.m_pShowMah[self.m_nBackIndex]:setIsBack(false)    

                        self.isWin = false
                        self:showLastView()
                        self:cancelSchedule2()
                    end
                else --此时默认从左向右
                    for i = 1 ,self.m_nGuessNumLength do
                        if self.m_pShowMah[i]:getIsBack() then
                            local  index = i
                            print("index---------------->",index)
                            if self.m_pShowMah[index]:getMahValue() == v.value then
                                self.m_nCount = self.m_nCount +1 
                                print("--此时默认从左向右")
                              
                                self.m_pShowMah[i]:setBackVisible(false)
                                self.m_pShowMah[i]:setMahjongScale(1.5)
                                self.m_pShowMah[i]:setIsBack(false)
                                break
                            else
                                print("1111232323232323232323232")

                                self.m_pShowMah[index]:setBackVisible(false)
                                self.m_pShowMah[index]:setMahjongScale(1.5)
                                self.m_pShowMah[index]:setIsBack(false)

                                self.isWin = false
                                self:showLastView()
                                self:cancelSchedule2()
                                return
                            end
                        end
                    end
                end
            else
                table.insert(self.m_saveTouchArr,v.value)
                local startPosX = 950 - self.m_nGuessIndex*80
                for j =1 ,self.m_nGuessIndex do
                    self.m_pShowFloorMah[j]:initMahjongWithFile( string.format( "t_%u.png",self.m_saveTouchArr[j]))
                    self.m_pShowFloorMah[j]:setPosition(cc.p(startPosX+j*80,490))
                    self.m_pShowFloorMah[j]:setVisible(true)
                end
    
            
                if v.value == self.m_nRandMahjongArr[self.m_nGuessIndex] then
                    self.m_nGuessIndex = self.m_nGuessIndex + 1
                else
                    -- 失败了
                    self.isWin = false
                    self:showLastView()
                    self:cancelSchedule2()
                    return
                end
            end
            break
        end
    end

    if self.m_nFlag == 5 then
        
        if self.m_nRandNum == self.m_nCount then
    
            self.isWin = true
            self:showLastView()
            self:cancelSchedule2()
        end
    end

    if self.m_nFlag ~=4 and self.m_nFlag ~=5 then
        if self.m_nGuessIndex == self.m_nGuessNumLength +1 then

            self:cancelSchedule2()
            self.isWin = true
            self:showLastView()
        end
    end
end

function CDLayerTable_JYDS:getFlagConfig()
    if not self.m_nFlag then
        return 0, 0
    end

    local numLength, needTime = 0, 0
    if self.m_nFlag == 1 then
        numLength = 5 
        needTime = 15
    
    elseif self.m_nFlag == 2 then
        numLength = 7
        needTime = 25
       
    elseif self.m_nFlag == 3 then
        numLength = 9
        needTime = 30
        
    elseif self.m_nFlag ==4 then
        numLength = 7 
        needTime = 18
    elseif  self.m_nFlag == 5 then
        numLength = 9
        needTime = 60 
    end

    return numLength,needTime
end

--用于重新开始时一些数据的清空
function CDLayerTable_JYDS:clearData()
  
    self.m_pMahjongBtn = {}
    self.m_pShowMah = {}
    self.m_nShowMahjongArr = {}
    self.m_nRandMahjongArr = {}
    self.m_nGuessIndex = 1
    self.m_saveTouchArr = {}
    self.m_pShowFloorMah = {}
    self.m_nStage = 0
    self.m_nCount = 0
    self.m_nBackIndex = 0
end

----------------------------------------------------------------------------
-- 初始化
function CDLayerTable_JYDS:init()
    cclog("CDLayerTable_JYDS::init")
    
    -- touch事件
    local function onTouchBegan(touch, event)
        cclog("CDLayerTable_JYDS:onTouchBegan")

        -- 没有开始游戏或暂停时，不能进行点击
        if not self.m_bInTheGame  or self.m_bIsTouchSetting then
            return
        end
        
        -- 点选自己的气球(游戏中才能使用，发牌阶段不能使用)
        local point = touch:getLocation()
        if self.m_bInTheGame then
            self:touchMahFromPoint(point)
        end
        return true
    end

    local function onTouchMoved(touch, event)
        cclog("CDLayerTable_JYDS:onTouchMoved")
    end

    local function onTouchEnded(touch, event)
        cclog("CDLayerTable_JYDS:onTouchEnded")
    end

    self.m_pListener = cc.EventListenerTouchOneByOne:create()
    self.m_pListener:setSwallowTouches(true)
    self.m_pListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.m_pListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.m_pListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pListener, self)
end


function CDLayerTable_JYDS:showSound()

    local music = g_pGlobalManagement:isEnableMusic()
    g_pGlobalManagement:enableMusic( not music)

    self.m_pSoundOpen:setVisible(music)
    self.m_pSoundClose:setVisible(not music)
    dtPlaySound( DEF_SOUND_TOUCH)
end

function CDLayerTable_JYDS:showMusic()

    local sound = g_pGlobalManagement:isEnableSound()
    g_pGlobalManagement:enableSound( not sound)

    self.m_pMusicOpen:setVisible(sound)
    self.m_pMusicClose:setVisible(not sound)
    dtPlaySound( DEF_SOUND_TOUCH)
end


--===============================界面函数绑定===============================
----------------------------------------------------------------------------
-- 设置
function CDLayerTable_JYDS:onSetting()
    cclog( "CDLayerTable_JYDS:onSetting")
    if self.m_nStage > -1 and self.m_nStage<2  then
        return
    end

    self.m_bIsTouchSetting = true

    local music = g_pGlobalManagement:isEnableMusic()
    local sound = g_pGlobalManagement:isEnableSound()

    if music then
        self.m_pSoundOpen:setVisible(false)
        self.m_pSoundClose:setVisible(true)

    else
        self.m_pSoundOpen:setVisible(true)
        self.m_pSoundClose:setVisible(false)
    end

    if sound then
        self.m_pMusicOpen:setVisible(false)
        self.m_pMusicClose:setVisible(true)
    else
        self.m_pMusicOpen:setVisible(true)
        self.m_pMusicClose:setVisible(false)
    end

    if self.m_pReadyBtnLayer:isVisible() then
        self.m_pReadyBtnLayer:setVisible(false)
    end

    if not self.m_pSettingNode:isVisible() then
        self.m_pSettingNode:setVisible(true)
    end

    dtPlaySound( DEF_SOUND_TOUCH)
end

function CDLayerTable_JYDS:onCloseSetting()

    if self.m_pSettingNode:isVisible() then
        self.m_pSettingNode:setVisible(false)
        self.m_bIsTouchSetting = false
    end

    if  self.m_nStage == -1 then
        if not self.m_pReadyBtnLayer:isVisible() then
            self.m_pReadyBtnLayer:setVisible(true)
        end
    end

    dtPlaySound( DEF_SOUND_TOUCH)
end


--开始
function CDLayerTable_JYDS:onReady()
    cclog("CDLayerTable_JYDS:onReady")

    if not self.m_pReadyBtnLayer:isVisible() then
        return
    end

     self.m_pReadyBtnLayer:setVisible(false)

    -- 开始游戏
    self:Handle_Dqq_StartPlay()

    dtPlaySound( DEF_SOUND_TOUCH)
end

--返回大厅
function CDLayerTable_JYDS:onGoToHall()
    if self.m_pLastViewLayer:isVisible() or self.m_pSettingNode:isVisible() then
        self.m_pLastViewLayer:setVisible(false)
        g_pSceneTable:gotoSceneHall()
        dtPlaySound(DEF_SOUND_TOUCH)
    end 
end

--重新开始
function CDLayerTable_JYDS:onRestart()

    if self.m_pLastViewLayer:isVisible() then

        if self.m_nFlag ==4 then
            self.m_pShowFloorMah[1]:setVisible(false)
        else
            for i =1 ,TABLE_SIZE(self.m_saveTouchArr) do
                self.m_pShowFloorMah[i]:setVisible(false)
            end
        end

        if not self.m_pButSetting:isVisible() then
            self.m_pButSetting:setVisible(true)
        end

        self.m_pLastViewLayer:setVisible(false)
        self:clearData()
        self:createUserInterface(self.m_nFlag)
        self:Handle_Dqq_StartPlay()
        dtPlaySound( DEF_SOUND_TOUCH)
    end 
end

--下一局
function CDLayerTable_JYDS:onNextRound()
    if self.m_pLastViewLayer:isVisible() then

        if not self.m_pButSetting:isVisible() then
            self.m_pButSetting:setVisible(true)
        end

        if self.m_nFlag ==4 then
            self.m_pShowFloorMah[1]:setVisible(false)
        else
            for i =1 ,TABLE_SIZE(self.m_saveTouchArr) do
                self.m_pShowFloorMah[i]:setVisible(false)
            end
        end

        self.m_nTotalRound = self.m_nTotalRound+1
        self.m_pLastViewLayer:setVisible(false)
        self:clearData()
        self:createUserInterface(self.m_nFlag)
        self:Handle_Dqq_StartPlay()
        dtPlaySound( DEF_SOUND_TOUCH)
    end 
end
------------------------------------------------------

function CDLayerTable_JYDS:onOpenSound()
    if self.m_pSettingNode:isVisible() and self.m_pSoundOpen:isVisible() then
       self:showSound()
    end
end

function CDLayerTable_JYDS:onCloseSound()
    if self.m_pSettingNode:isVisible() and self.m_pSoundClose:isVisible() then
       self:showSound()
    end
end

function CDLayerTable_JYDS:onOpenSoundEffect()
    if self.m_pSettingNode:isVisible() and self.m_pMusicOpen:isVisible() then
        self:showMusic()
    end
end

function CDLayerTable_JYDS:onCloseSoundEffect()
    if self.m_pSettingNode:isVisible() and self.m_pMusicClose:isVisible() then
        self:showMusic()
    end
end

----------------------------------------------------------------------------
-- ccb处理
-- 变量绑定
function CDLayerTable_JYDS:onAssignCCBMemberVariable(loader)
    cclog("CDLayerTable_JYDS::onAssignCCBMemberVariable")

    -- 灯光
    self.m_pLighting     = loader["pic_alpha"]

    -- 底部的状态信息
    self.m_pGroupBar     = loader["group_bar"]
    self.m_pButSetting   = loader["but_setting"]
    self.m_pSelfInfo     = loader["self_info"]
    self.m_pTableInfo    = loader["table_info"]

    self.m_pTimeLabel   = loader["time_label"]
    self.m_pShowMode   =  loader["Show_Mode"]
    self.m_pShowNanDu  =  loader["show_NanDu"]
    self.m_pShowJiShi  = loader["jishi"]

    self.m_pNewLayerRoot    = loader["new_layer"]
    self.m_pShowPrompt      = loader["showPrompt_Node"]
    -- 电池
    self.m_pIcoPower        = loader["power"]
    self.m_pNewEffLayer     = loader["newEfflayer"]

    self.m_pSettingNode     = loader["setting_Node"]

    -- 开始按钮
    self.m_pReadyBtn = loader["button_ready"]
    --开始按钮的Layer
    self.m_pReadyBtnLayer = loader["button_readyLayer"]

    self.m_pCloseBtn   = loader["btn_closeSetting"]

    ---------------------------------------------------

    self.m_pSoundOpen   = loader["sound_open"]
    self.m_pSoundClose  = loader["sound_close"]
    self.m_pMusicOpen   = loader["soundEffect_open"]
    self.m_pMusicClose  = loader["soundEffect_close"]

    self.m_pSoundOpenBtn  = loader["btn_sound"]
    self.m_pSoundCloseBtn = loader["btn_soundClose"]
    self.m_pMusicOpenBtn  = loader["btn_soundEffect"]
    self.m_pMusicCloseBtn = loader["btn_soundEffectClose"]
    ---------------------------------------------------
    --结束界面控件

    self.m_pLastViewLayer = loader["lastview_Layer"]

    self.m_pWinNode       = loader["node_success"]
    self.m_pLoseNode      = loader["node_failure"]
    -- self.m_pBtnGoToHall   = loader["button_gotoHall"]
    self.m_pBtnRestart    =  loader["button_restart"]
    self.m_pBtnNextRound  =  loader["button_NextRound"]
end

----------------------------------------------------------------------------
-- ccb处理
-- 函数绑定
function CDLayerTable_JYDS:onResolveCCBCCControlSelector(loader)
    cclog("CDLayerTable_JYDS::onResolveCCBCCControlSelector")
    
    -- 开始准备按钮
    loader["onReady"]       = function() self:onReady()    end            

    loader["onGoToHall"]    = function() self:onGoToHall() end

    loader["onRestart"]     = function() self:onRestart()  end

    loader["onNextRound"]     = function() self:onNextRound()  end

    loader["onSetting"]     = function() self:onSetting()  end
  
   
    loader["onCloseSetting"] =function() self:onCloseSetting() end


    loader["onOpenSound"] =  function () self:onOpenSound() end
  
    loader["onCloseSound"] = function () self:onCloseSound() end
 
    loader["onOpenSoundEffect"] = function () self:onOpenSoundEffect() end

    loader["onCloseSoundEffect"] = function () self:onCloseSoundEffect() end
    
end

----------------------------------------------------------------------------
-- create
function CDLayerTable_JYDS.createCDLayerTable_JYDS(pParent)
    cclog("CDLayerTable_JYDS::createCDLayerTable_xtlzddz")
    if not pParent then
        return nil
    end
    local layer = CDLayerTable_JYDS.new()
    layer:init()
    local loader = layer.m_ccbLoader
    layer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad("CDLayerTable_JYDS.ccbi",proxy,loader)
    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild(node)
    pParent:addChild(layer)
    return layer
end