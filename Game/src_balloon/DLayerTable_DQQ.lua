--[[
/******************************************************
//Project:      ProjectX 
//Moudle:       CDLayerTable_DQQ 仙桃赖子斗地主桌子
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

require( REQUIRE_PATH.."balloon_item")

require( REQUIRE_PATH.."mahjong_define")

--require "CCBReaderLoad"

local casinoclient = require("script.client.casinoclient")
local platform_help = require("platform_help")

local BalloonSprite = {"Red","Blue","Golden"}

--屏幕的尺寸
local ScreenSize = CDGlobalMgr:sharedGlobalMgr():getWinSize()

-- 音效定义
DEF_SOUND_MJ_CLICK      = "sound_card_click"..DEF_TKD_SOUND     -- 点中牌
DEF_SOUND_MJ_KJ         = "mj_kj"..DEF_TKD_SOUND                -- 开局

DEF_SOUND_BALLOON_MAH       = "balloon_touchMah"..DEF_TKD_SOUND        -- 气球爆炸声

DEF_BALLOON_POSY        = 180
DEF_MAX_PRODECE_BALLON  = 35
-----------------------------------------
-- 类定义
CDLayerTable_DQQ = class("CDLayerTable_DQQ", CDCCBLayer)    
CDLayerTable_DQQ.__index = CDLayerTable_DQQ
CDLayerTable_DQQ.name = "CDLayerTable_DQQ"

-- 构造函数
function CDLayerTable_DQQ:ctor()
    cclog("CDLayerTable_DQQ::ctor")
    CDLayerTable_DQQ.super.ctor(self)
    CDLayerTable_DQQ.initialMember(self)
    --reg enter and exit
    local function onNodeEvent(event)
        if "enter" == event then
            CDLayerTable_DQQ.onEnter(self)
        elseif "exit" == event then
            CDLayerTable_DQQ.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function CDLayerTable_DQQ:onEnter()
    cclog("CDLayerTable_DQQ::onEnter")

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

function CDLayerTable_DQQ:onExit()
    cclog("CDLayerTable_DQQ::onExit")
    -- if self.playAudioID then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.playAudioID)   
    --     self.playAudioID=nil
    -- end

    -- 退出时，停止发送心跳
    self:stopHeartLoop()
    self:stopAllActions()

    casinoclient.getInstance():removeListenerAllEvents(self)
    CDLayerTable_DQQ.releaseMember(self)
    self:unregisterScriptHandler()
    self:cancelSchedule()
end

-----------------------------------------
-- 初始化
function CDLayerTable_DQQ:initialMember()
    cclog("CDLayerTable_DQQ::initialMember")

    ---------------------------------------------------
    -- 底部的状态信息 
    self.m_pGroupBar        = nil        -- 状态按钮根节点
    self.m_pButSetting      = nil        -- 设置按钮
    self.m_pSelfInfo        = nil        -- 自己的信息
    self.m_pTableInfo       = nil        -- 桌子的信息

    self.m_pJiZhongNum      = nil        -- 击中数量
    self.m_pWeiJiZhong      = nil        -- 未击中数量

    self.m_pJiZhongLabel    = nil        -- 击中Label
    self.m_pWeiJiZhongLabel = nil        -- 未击中Label
    ---------------------------------------------------
    -- 桌子中相关按钮
    self.m_pReadyBtn        = nil        -- 准备按钮

    self.m_pPauseBtn        = nil        -- 暂停按钮

    self.m_pCloseBtn        = nil        -- 关闭设置按钮
    ---------------------------------------------------
    -- 桌子中相关'节点'与'层''
    self.m_pNewEffLayer     = nil        -- 特效层
    self.m_pNewLayerRoot    = nil        -- 桌面麻将放置的根节点
    self.m_pLighting        = nil        -- 灯光
    self.m_pBalloonEffDemo  = nil        -- 特效放置层
    self.m_pBalloonDemo     = nil        -- 气球放置层
    self.m_pMahjongDemo     = nil
    ---------------------------------------------------
    -- 电池
    self.m_pIcoPower        = nil        -- 电池图标

    self.m_pNodeLastView  = nil          --胜利或失败界面Node
    self.m_pWinSprite     = nil
    self.m_pLoseSprite    = nil
    self.m_pBtnGoToHall   = nil
    self.m_pBtnRestart    = nil

    self.m_pNodeMode5     = nil
    self.m_pJiZhongMode5  = nil
    self.m_pCollectMode5  = nil
    self.m_pRuleMode5     = nil

    self.m_pLiangMode5 = {}
    self.m_pHuiMode5 = {}

    for i =1 ,3 do
        self.m_pLiangMode5[i] = nil
        self.m_pHuiMode5[i] = nil
    end
    self.m_pResumeBtn    = nil
    self.m_pSettingBtn   = nil
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

    self.m_pSpriteWarnning  = nil    -- 挑战下的提示

    ---------------------------------------------------
    -- 游戏相关变量定义
    self.m_pPlayer          = {}         -- 玩家
    self.m_pPlayer.name     = ""         -- 玩家姓名
    self.m_pPlayer.gold     = 0          -- 玩家货币
    ---------------------------------------------------
    self.m_pListener        = nil        -- 监听对象
 
    -- self.m_pEffNetLow       = nil        -- 网络连接缓慢提示特效
    self.m_bPreCreate       = false      -- 是否预创建过

    self.m_nFlag            = nil        -- 游戏类型(1、简单 2、普通 3、困难)
   
    self.isPause            = false      -- 是否暂停
    ---------------------------------------------------
    --气球数组

    self.m_nRand_Balloon   = 0          -- 只有挑战模式下才用到

    self.m_arrBalloon      = {}
  
    self.m_arraySaveX      = {}          -- 保存气球柱的x的位置

    -- 数据对象

    self.m_nAlraadyDqq     = 0           -- 打到的气球数量

    self.m_nNeedDqq        = 20          -- 需要打的气球个数
    self.m_nWeiJiZhong     = 0           -- 未击中的气球数

    self.m_nQiQiuZhu       = 0           -- 气球柱的数量
    self.m_nProBalTime     = 0           -- 气球产生的时间

    self.isWin             = false       -- 是否胜利

    self.isAgainGame       = false       -- 是否是再来一局

    self.m_pMahArrFallOut  = {}

    self.m_bTouchMah       = false

    --麻将掉落模式下

    self.m_nTouchBalloon   = 0
    self.m_nTouchMahNum    = 0 
    self.m_nTotalTouchMah  = 0

end

function CDLayerTable_DQQ:releaseMember()
    cclog("CDLayerTable_DQQ::releaseMember")

    if  self.m_pNewEffLayer then
        self.m_pNewEffLayer:removeAllChildren()
    end

    if  self.m_pNewLayerRoot ~= nil then
        self.m_pNewLayerRoot:removeAllChildren()
        self.m_pEffNetLow = nil
    end

    --模拟析构父类
    CDLayerTable_DQQ.super.releaseMember(self)
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
function CDLayerTable_DQQ:Handle_Ping( __event)
    cclog("CDLayerTable_DQQ:Handle_Ping")
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
function CDLayerTable_DQQ:createHeartbeatLoop( ... )
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
function CDLayerTable_DQQ:stopHeartLoop( ... )
    if  self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)   
        self.schedulerID=nil
    end
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------

--随机气球的颜色
function CDLayerTable_DQQ:Rand_Ballon(flag)

    local cSprite = ""
  
    if flag == 1 then --简单模式
        local n = math.random(10)
        if n>2 then
            cSprite = BalloonSprite[1]
        else
            cSprite = BalloonSprite[2]
        end
    elseif flag == 2 then
        local n = math.random(10)
        if n>8 then
            cSprite = BalloonSprite[1]   
        elseif  n<3 then
            cSprite = BalloonSprite[3]
        else
            cSprite = BalloonSprite[2]
        end

    elseif flag == 3  or flag == 4 or flag== 5 then
        local n = math.random(10)
        if n>5 then
            cSprite = BalloonSprite[3]
        elseif  n<3 then
            cSprite = BalloonSprite[1]
        else
            cSprite = BalloonSprite[2] 
        end 
    end

    return cSprite
end

--随机位置

function CDLayerTable_DQQ:randBalloonPosX( )
   
    local index = math.random(self.m_nQiQiuZhu)
    local posX = self.m_arraySaveX[index]
    
    return posX
end

function CDLayerTable_DQQ:randNotOnlyPosx(count)
    local tempArr = {1,2,3,4,5}
    local randNum = self.m_nQiQiuZhu
    local posX = {}
    for i =1 ,count do
        local tempIndex = math.random(randNum)
        table.insert(posX,self.m_arraySaveX[tempArr[tempIndex]])
        table.remove(tempArr,tempIndex)
        randNum =randNum-1
    end   
    return posX
end


--挑战模式下随机同时产生气球的气球柱 (1 ~ 3)
function CDLayerTable_DQQ:randBalloonZhuziAndPos()

    if self.m_nFlag ~= 4 and self.m_nFlag~= 5 then
        return
    end
    local posX = {}

    local zhuziCount = math.random(3)
    if zhuziCount  == 1 then
        local tempPos = self:randBalloonPosX()
        table.insert(posX,tempPos) 
    else
        posX = self:randNotOnlyPosx(zhuziCount)
    end

    return posX
end

-- 所有玩家准备结束，可以进行发牌的反馈
-- 参数: 数据包
function CDLayerTable_DQQ:Handle_Dqq_StartPlay(__event)
    cclog("CDLayerTable_DQQ:Handle_llk_StartPlay")
     math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
    -- 开始游戏后，关闭主场景中的不相关场景
    g_pSceneTable:closeAllUserInterface()

    -- 获取并生产玩家数据
    -- local nickname = casinoclient.getInstance():getPlayerData():getNickname()
    -- local channelNickname = casinoclient.getInstance():getPlayerData():getChannelNickname()
    -- self.m_pPlayer.name = dtGetNickname(nickname, channelNickname)
    -- self.m_pPlayer.gold = casinoclient:getInstance():getPlayerData():getPlayerResourceGold()
    --self:refreshSelfInfo()

    --开始生成牌数据
    self.m_bInTheGame = true

    if self.m_pSettingBtn:isVisible() then
        self.m_pSettingBtn:setVisible(false)
    end

    self.m_pPauseBtn:setVisible(true)
    self.m_pPauseBtn:setPositionY(self.m_pSettingBtn:getPositionY())

    self:stopAllActions()
    
    if self.m_pSpriteWarnning  then
        self.m_pSpriteWarnning:runAction(cc.Spawn:create(cc.MoveTo:create(0.2,cc.p(ScreenSize.width-300,ScreenSize.height-40)),cc.ScaleTo:create(0.3,0.6,0.6)))
    end

    if self.m_nFlag == 5 then
        self.m_pMahArr = {}

        self.m_pMahPrompt = cc.Label:create()
        self.m_pMahPrompt:setString("收集麻将:")
        self.m_pMahPrompt:setSystemFontSize(45)
        self.m_pMahPrompt:setTextColor(cc.c3b(255,0,0))
        self.m_pMahPrompt:setPosition(cc.p(ScreenSize.width/2-230,ScreenSize.height/2))
        self.m_pMahjongDemo:addChild(self.m_pMahPrompt)

        for i=1,self.m_nMahNum do
            print("self.m_nMahArr[i]",self.m_nMahArr[i])
             self.m_pMahArr[i]=CDMahjong.createCDMahjong(self.m_pMahjongDemo)
             self.m_pMahArr[i]:initMahjongWithFile(string.format("t_%u.png",self.m_nMahArr[i]))
            
             self.m_pMahArr[i]:setPosition(cc.p(self.m_pMahPrompt:getPositionX()+70+self.m_pMahArr[i].m_nSizeW*i,ScreenSize.height/2))
        end

        local function mahMove()
            if self.m_pMahPrompt then
                if self.m_pMahPrompt:isVisible() then
                    self.m_pMahPrompt:setVisible(false)
                end
            end
            for i = 1 ,self.m_nMahNum do
                local posX = 180+i*self.m_pMahArr[i].m_nSizeW
            
                self.m_pMahArr[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.MoveTo:create(0.3,cc.p(posX,ScreenSize.height-50))))
                self.m_pMahArr[i]:setNotValueColor()
            end
        end

        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(mahMove)))
    end

    if self.m_pttf then
        self.m_pttf:removeFromParent()
        self.m_pttf=nil
    end

    if self.m_nFlag == 5 then
        self:showTimeLabel()
    end

    --游戏是否结束判断
    local function  isWinOrLose()
        --击中的显示和判断
        if self.m_nAlraadyDqq >= self.m_nNeedDqq then
            self.m_nAlraadyDqq = self.m_nNeedDqq
        end
        self.m_pJiZhongNum:setString(self.m_nAlraadyDqq.."/"..self.m_nNeedDqq)

        local count  = 0
        for i,v in ipairs(self.m_arrBalloon) do
            if self.m_nFlag == 4 then
                if v.balItem.isBeyondPos and v.balItem.m_nColor ~=self.m_nRand_Balloon then
                    count=count+1
                    if count >=3 then
                        count= 3
                        break
                    end
                end
            else
                if v.balItem.isBeyondPos then
                    count=count+1
                    if count >=3 then
                        count= 3
                        break
                    end
                end
            end
        end

        count = self.m_nWeiJiZhong +count
        if count >=3 then 
            count =3 
        end
        self.m_pWeiJiZhong:setString(count.."/"..3)

        if self.m_nAlraadyDqq >=self.m_nNeedDqq then
           
            self.isWin = true
            self:showLastView()
            return
        end
        if count >=3 then
            self.isWin = false
            self:showLastView()
            return
        end 
    end 

     --生成一个气球
    local index = 1
    local function proBalloon()
        if self.m_nFlag == 4 or self.m_nFlag == 5 then
            local posxArr = self:randBalloonZhuziAndPos()
        
            for i=1,TABLE_SIZE(posxArr) do
                local balloonCol = self:Rand_Ballon(self.m_nFlag)

                --没有气球就临时创建
                if not self.m_arrBalloon[index] then
                    print("index--------->",index)
                    self.m_arrBalloon[index] = {}
                    self.m_arrBalloon[index].balItem=CDBalloonItem.createCDBalloon(self.m_pBalloonDemo)
                end

                self.m_arrBalloon[index].balItem:setPosition(cc.p(posxArr[i],DEF_BALLOON_POSY))
                self.m_arrBalloon[index].balItem:setBalloon(balloonCol,posxArr[i],DEF_BALLOON_POSY,self.m_nFlag)
                index = index+1       

            end

        else
            local balloonCol = self:Rand_Ballon(self.m_nFlag)
            local posX = self:randBalloonPosX()
            self.m_arrBalloon[index].balItem:setPosition(cc.p(posX,DEF_BALLOON_POSY))
            self.m_arrBalloon[index].balItem:setBalloon(balloonCol,posX,DEF_BALLOON_POSY,self.m_nFlag)
            index = index+1       
        end
    end 
    --产生气球的定时器
    if not self.schedulerID1 then
        self.schedulerID1 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(proBalloon,self.m_nProBalTime,false)
    end

    local time = 180
    local function TimerStart()
        time = time -1
        if time < 0 then
            time = 0

            if self.schedulerID3 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID3) 
                self.schedulerID3 = nil
            end
            self.isWin = false
            self:showLastView()
        end
        if self.m_pttf then
            self.m_pttf:setString(string.format("计时:%d",time))
        end
    end 

    if self.m_nFlag == 5 then
        print("-----掉落麻将模式------")

        if not self.schedulerID3 then
            self.schedulerID3 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(TimerStart,1,false)
        end

    else

        if not self.schedulerID2 then
            self.schedulerID2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(isWinOrLose,0.05,false)
        end
    end

end
----------------------------------------------------------------------------
function CDLayerTable_DQQ:showTimeLabel()
    
    self.m_pttf = cc.LabelTTF:create("0.000","Courier New",42)
    self.m_pttf:setColor(cc.c3b(255,0,0))
    self.m_pttf:setString("计时:180")
    self.m_pttf:setPosition(cc.p(110,ScreenSize.height - 50))
    self.m_pNewLayerRoot:addChild(self.m_pttf)
end

----------------------------------------------------------------------------

function CDLayerTable_DQQ:cancelSchedule( )
    if  self.schedulerID1 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID1)   
        self.schedulerID1 = nil
    end

    if self.schedulerID2 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID2) 
        self.schedulerID2 = nil
    end

    if self.schedulerID3 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID3) 
        self.schedulerID3 = nil
    end

end


function CDLayerTable_DQQ:showLastView()
    self:cancelSchedule()
    self.m_bInTheGame = false
    self:stopAllActions()
    self.m_pNodeLastView:setVisible(true)

    if self.m_nFlag == 5 then
        self.m_pNodeMode5 :setVisible(true)
        self.m_pJiZhongMode5:setString(self.m_nTouchBalloon)
        self.m_pCollectMode5:setString(self.m_nTotalTouchMah)
        self.m_pRuleMode5:setString(self.m_nTouchMahNum.."/"..self.m_nMahNum)
    else
        self.m_pNodeMode5 :setVisible(false)
    end

    if self.isWin then
        self.m_pWinSprite:setVisible(true)
        self.m_pLoseSprite:setVisible(false)

        for i = 1 ,3 do
            self.m_pLiangMode5[i]:setVisible(true)
            self.m_pHuiMode5[i]:setVisible(false)
        end

    else

        for i = 1 ,3 do
            if i == 1 or i ==2 then
                self.m_pLiangMode5[i]:setVisible(true)
                self.m_pHuiMode5[i]:setVisible(false)
            else
                self.m_pLiangMode5[i]:setVisible(false)
                self.m_pHuiMode5[i]:setVisible(true)
            end
        end
        self.m_pLoseSprite:setVisible(true)
        self.m_pWinSprite:setVisible(false)
    end

    self:showSettingAndPause(false)
end


-- 重置电量
function CDLayerTable_DQQ:resetPower()
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

function CDLayerTable_DQQ:showTestError(str,x,y)
    if  not self.m_pTestError then
        self.m_pTestError = cc.LabelTTF:create("","",30)
        self.m_pTestError:setAnchorPoint(cc.p(1,1))
        self.m_pTestError:setPosition(cc.p(x,y))
        self:addChild(self.m_pTestError)
    end
    if  str and string.len(str) > 0 then
        self.m_pTestError:setString(str)
    end
end

----------------------------------------------------------------------------
-- 设置自己的信息
-- function CDLayerTable_DQQ:refreshSelfInfo()
--     self.m_pSelfInfo:setString(self.m_pPlayer.name .. ":" .. self.m_pPlayer.gold)
-- end

-- 初始化界面
----------------------------------------------------------------------------
-- 创建用户界面
function CDLayerTable_DQQ:createUserInterface(flag)
    cclog("CDLayerTable_DQQ::createUserInterface")

    self.m_nFlag = flag

    --需要打的气球 ，气球柱子数量
    self.m_nNeedDqq,self.m_nQiQiuZhu,self.m_nProBalTime = self:getFlagConfig()

    print("========CDLayerTable_DQQ==========")
    print("self.m_nFlag",self.m_nFlag)
    print("self.m_nNeedDqq",self.m_nNeedDqq)
    print("self.m_nQiQiuZhu",self.m_nQiQiuZhu)
    print("self.m_nProBalTime",self.m_nProBalTime)
    print("========CDLayerTable_DQQ==========")


    if not self.m_bInTheGame then
        self.m_pPauseBtn:setVisible(false)
    end
    --上方击中和未击中的显示和隐藏
    if self.m_nFlag == 5 then
        if self.m_pJiZhongLabel then
            self.m_pJiZhongLabel:setVisible(false)
        end

        if self.m_pWeiJiZhongLabel then
            self.m_pWeiJiZhongLabel:setVisible(false)
        end

        if self.m_pJiZhongNum then
            self.m_pJiZhongNum:setVisible(false)
        end
        if self.m_pWeiJiZhong then
            self.m_pWeiJiZhong:setVisible(false)
        end

    else
        if self.m_pJiZhongLabel then
            self.m_pJiZhongLabel:setVisible(true)
        end

        if self.m_pWeiJiZhongLabel then
            self.m_pWeiJiZhongLabel:setVisible(true)
        end

        if self.m_pJiZhongNum then
            self.m_pJiZhongNum:setVisible(true)
        end
        if self.m_pWeiJiZhong then
            self.m_pWeiJiZhong:setVisible(true)
        end
    end


    if self.m_nFlag == 4 then
        if self.m_pSpriteWarnning ~= nil then
            self.m_pSpriteWarnning:removeFromParent()
            self.m_pSpriteWarnning =nil
        end

        self.m_nRand_Balloon = math.random(3)

        print("self.m_nRand_Balloon---------->",self.m_nRand_Balloon)
        self.m_pSpriteWarnning = cc.Sprite:create("prompt_"..self.m_nRand_Balloon..".png")
        self.m_pSpriteWarnning:setAnchorPoint(cc.p(0.5,0.5))
        self.m_pSpriteWarnning:setPosition(cc.p(ScreenSize.width/2,ScreenSize.height/2+40))

        self.m_pNewLayerRoot:addChild(self.m_pSpriteWarnning)
    end

    -- 创建桌面需要特效放置层
    if not self.isAgainGame then
        self.m_pBalloonEffDemo = cc.Layer:create()
        self.m_pBalloonEffDemo:setLocalZOrder(103)
        self.m_pNewLayerRoot:addChild(self.m_pBalloonEffDemo)
    
        self.m_pBalloonDemo = cc.Layer:create()
        self.m_pBalloonDemo:setLocalZOrder(100)
        self.m_pNewLayerRoot:addChild(self.m_pBalloonDemo)

        if self.m_nFlag == 5 then

            self.m_pMahFallOut  = cc.Layer:create()
            self.m_pMahFallOut:setLocalZOrder(102)
            self.m_pNewLayerRoot:addChild(self.m_pMahFallOut)

            self.m_pMahjongDemo = cc.Layer:create()
            self.m_pMahjongDemo:setLocalZOrder(99)
            self.m_pNewLayerRoot:addChild(self.m_pMahjongDemo)

        end
    end

    if self.m_nFlag == 5 then
        --随机的麻将的数量
        local selectFromArr = {11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,41,42,43,44,51,52,53}
        self.m_nMahNum = math.random(6,8)
        print("self.m_nMahNum----->",self.m_nMahNum)
        self.m_nMahArr = {}
        for i = 1 ,self.m_nMahNum do
            local index = math.random(25)
            self.m_nMahArr[i] = selectFromArr[index]
        end

    end
    
    if self.isAgainGame then
        if  self.m_pBalloonDemo then
            self.m_pBalloonDemo:removeAllChildren()
        end

        if self.m_pMahjongDemo then
            self.m_pMahjongDemo:removeAllChildren()
        end

        if self.m_pMahFallOut then
            self.m_pMahFallOut:removeAllChildren()
        end
    end

    -- 预创建
    self.m_bPreCreate = false
    self:preCreate()

    -- 重置电量
    self:resetPower()
end

-- 预创建
function CDLayerTable_DQQ:preCreate()
    cclog( "CDLayerTable_DQQ:preCreate")
    if  self.m_bPreCreate then
        return
    end

    self.m_pJiZhongNum:setString(self.m_nAlraadyDqq.."/"..self.m_nNeedDqq)
    self.m_pWeiJiZhong:setString("0".."/".."3")
    --创建柱子
    if not self.isAgainGame then --再来一局无需重新创建桌子
        local offsetX = self.m_pNewLayerRoot:getContentSize().width/(self.m_nQiQiuZhu+1)
        for i = 1 ,self.m_nQiQiuZhu do
            local  BalPicture = cc.Sprite:create(string.format("zhuzi.png"))
            BalPicture:setLocalZOrder(101)
            self.m_pNewLayerRoot:addChild(BalPicture)
            --保存气球柱的x值
            table.insert(self.m_arraySaveX,offsetX*i)
            BalPicture:setPosition(cc.p(offsetX*i,110))
        end
    end

    if self.m_nFlag == 4 then
        DEF_MAX_PRODECE_BALLON = 120
    elseif self.m_nFlag == 5 then
        DEF_MAX_PRODECE_BALLON = 200
    end
    --创建气球
    for i = 1 ,DEF_MAX_PRODECE_BALLON do
        local tempBalloon = {}
        --tempBalloon.speed    = 0
        --tempBalloon.color    = 0
        tempBalloon.balItem = CDBalloonItem.createCDBalloon(self.m_pBalloonDemo)
        table.insert(self.m_arrBalloon,tempBalloon)
    end
    self.m_bPreCreate = true

end
--------------------------------------------------------------------------------------
function CDLayerTable_DQQ:touchMahFromPoint(point)
    for i,v in pairs(self.m_pMahArrFallOut) do
        if v.item:touchInFromPoint(point) and v.item:isVisible() then
            print("点击到麻将了")
            dtPlaySound(DEF_SOUND_BALLOON_MAH)
            self.m_nTotalTouchMah = self.m_nTotalTouchMah+1
            self.m_bTouchMah  = true
            for i = 1 ,TABLE_SIZE(self.m_nMahArr) do
                if v.value == self.m_nMahArr[i] then
                    self.m_pMahArr[i]:setValueColor()
                    table.remove(self.m_pMahArr,i)
                    table.remove(self.m_nMahArr,i)
                    self.m_nTouchMahNum = self.m_nTouchMahNum+1
                    break
                end
            end
            v.item:setVisible(false)

            if self.m_nTouchMahNum == self.m_nMahNum then
                self.isWin = true

                self:showLastView()
            end
            return
        end
    end
end
--------------------------------------------------------------------------------------
function CDLayerTable_DQQ:touchBalloonFromPoint(point)
    --for i,v in ipairs(self.m_arrBalloon) do
    for i = TABLE_SIZE(self.m_arrBalloon),1,-1 do
        if not self.m_arrBalloon[i].balItem.isDestroy then
            if self.m_arrBalloon[i].balItem:touchInFromPoint(point) then

                local  pos = cc.p(self.m_arrBalloon[i].balItem:getPositionX(),self.m_arrBalloon[i].balItem:getPositionY())
                local effect = CDCCBAniObject.createCCBAniObject(self.m_pBalloonEffDemo, "x_tx_balloon_boom.ccbi", pos, 0)
                if  effect then
                    effect:endRelease( true)
                    effect:endVisible( true)
                end
                self.m_nTouchBalloon = self.m_nTouchBalloon +1
                if self.m_nFlag == 4 then -- 挑战模式下
                    if self.m_arrBalloon[i].balItem.m_nColor == self.m_nRand_Balloon then
                        self.m_nWeiJiZhong = self.m_nWeiJiZhong +1
                    else
                        self.m_nAlraadyDqq = self.m_nAlraadyDqq +1
                    end
                    
                elseif self.m_nFlag == 5 then
                    print("22222222222222222222222--麻将掉落---")
                     local function MahjongFallOut()
                        local selectFromArr = {11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,41,42,43,44,51,52,53}
                        local index = math.random(25)
                    
                        print("index----->",index)
                        local mahjong = {}
                        mahjong.item =CDMahjong.createCDMahjong(self.m_pMahFallOut)
                        mahjong.value = selectFromArr[index]
                        mahjong.item:initMahjongWithFile(string.format("t_%u.png",selectFromArr[index]))
                        mahjong.item:setPosition(pos)
                        mahjong.item:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.MoveTo:create(2,cc.p(self.m_arrBalloon[i].balItem:getPositionX(),-60))))
                        table.insert(self.m_pMahArrFallOut,mahjong)
                    end
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(MahjongFallOut)))

                else
                    self.m_nAlraadyDqq = self.m_nAlraadyDqq +1
                end

                self.m_arrBalloon[i].balItem:setVisible(false)

                return
            end
        end
    end

end

function CDLayerTable_DQQ:getFlagConfig()
    if not self.m_nFlag then
        return 0, 0,0
    end

    print("self.m_nFlag------->",self.m_nFlag)

    local needDqq, QiQiuZhuNum,proBalTime = 0, 0,0
    if self.m_nFlag == 1 then
        needDqq = 20 
        QiQiuZhuNum = 3
        proBalTime =2
    elseif self.m_nFlag == 2 then
        needDqq = 30
        QiQiuZhuNum = 4
        proBalTime =1.5
    elseif self.m_nFlag == 3 then
        needDqq = 30 
        QiQiuZhuNum = 5
        proBalTime =1
    elseif self.m_nFlag ==4 then
        needDqq = 50 
        QiQiuZhuNum = 5
        proBalTime =1
    elseif self.m_nFlag == 5 then 
        needDqq = 0
        QiQiuZhuNum = 5
        proBalTime =1
    end

    return needDqq,QiQiuZhuNum,proBalTime
end

--用于重新开始时一些数据的清空
function CDLayerTable_DQQ:clearData()
  
    self.m_arrBalloon= {}
    self.m_nAlraadyDqq = 0

    self.m_nWeiJiZhong = 0

    self.m_nTouchMahNum = 0
    self.m_nTotalTouchMah = 0
    self.m_nTouchBalloon = 0

    self.m_pMahArrFallOut = {}
end

----------------------------------------------------------------------------
-- 初始化
function CDLayerTable_DQQ:init()
    cclog("CDLayerTable_DQQ::init")
    
    -- touch事件
    local function onTouchBegan(touch, event)
        cclog("CDLayerTable_DQQ:onTouchBegan")

        -- 没有开始游戏或暂停时，不能进行点击
        if not self.m_bInTheGame  or self.isPause then
            return
        end
        self.m_bTouchTable = true 

        -- 点选自己的气球(游戏中才能使用，发牌阶段不能使用)
        local point = touch:getLocation()

        if self.m_nFlag == 5 then
            self:touchMahFromPoint(point)
        end

        if self.m_bInTheGame then
            if not self.m_bTouchMah then
                self:touchBalloonFromPoint(point)
            end
            self.m_bTouchMah = false
        end
        return true
    end

    local function onTouchMoved(touch, event)
        cclog("CDLayerTable_DQQ:onTouchMoved")
    end

    local function onTouchEnded(touch, event)
        cclog("CDLayerTable_DQQ:onTouchEnded")
        self.m_bTouchTable = false
    end

    self.m_pListener = cc.EventListenerTouchOneByOne:create()
    self.m_pListener:setSwallowTouches(true)
    self.m_pListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.m_pListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.m_pListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pListener, self)
end


function CDLayerTable_DQQ:showSound()

    local music = g_pGlobalManagement:isEnableMusic()
    g_pGlobalManagement:enableMusic( not music)

    self.m_pSoundOpen:setVisible(music)
    self.m_pSoundClose:setVisible(not music)
    dtPlaySound( DEF_SOUND_TOUCH)
end

function CDLayerTable_DQQ:showMusic()

    local sound = g_pGlobalManagement:isEnableSound()
    g_pGlobalManagement:enableSound( not sound)

    self.m_pMusicOpen:setVisible(sound)
    self.m_pMusicClose:setVisible(not sound)
    dtPlaySound( DEF_SOUND_TOUCH)
end

function CDLayerTable_DQQ:showSettingAndPause(bool)
    self.m_pButSetting:setVisible(bool)
    self.m_pPauseBtn:setVisible(bool)
end



--===============================界面函数绑定===============================
----------------------------------------------------------------------------
-- 设置
function CDLayerTable_DQQ:onSetting()
    cclog( "CDLayerTable_DQQ:onSetting")

    if self.m_bInTheGame then
        return
    end

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

    if self.m_pReadyBtn:isVisible() then
        self.m_pReadyBtn:setVisible(false)
    end

    if self.m_nFlag == 4 then
        if self.m_pSpriteWarnning:isVisible() then
            self.m_pSpriteWarnning:setVisible(false)
        end
    end


    if not self.m_pSettingNode:isVisible() then
        self.m_pSettingNode:setVisible(true)
    end
end

function CDLayerTable_DQQ:onCloseSetting()

    if not self.m_pReadyBtn:isVisible() then
        self.m_pReadyBtn:setVisible(true)
    end

    if self.m_nFlag == 4 then
        if not self.m_pSpriteWarnning:isVisible() then
            self.m_pSpriteWarnning:setVisible(true)
        end
    end

    if self.m_pSettingNode:isVisible() then
        self.m_pSettingNode:setVisible(false)
    end
end

function CDLayerTable_DQQ:onResume()
    if self.m_pResumeBtn:isVisible() then
        self.isPause = false
        self.m_pResumeBtn:setVisible(false)
        cc.Director:getInstance():resume()
    end
end


--暂停
function CDLayerTable_DQQ:onPause()
    if not self.m_bInTheGame then
        return
    end
    
    if self.m_pPauseBtn :isVisible() then
        self.isPause = true
        self.m_pResumeBtn:setVisible(true)
        cc.Director:getInstance():pause()
    end
end

--开始
function CDLayerTable_DQQ:onReady()
    cclog("CDLayerTable_DQQ:onReady")

    if not self.m_pReadyBtn:isVisible() then
        return
    end

     self.m_pReadyBtn:setVisible(false)

    -- 开始游戏
    self:Handle_Dqq_StartPlay()
end

--返回大厅
function CDLayerTable_DQQ:onGoToHall()

    if self.m_pNodeLastView:isVisible() or self.m_pSettingNode:isVisible() then

        --当返回时还有气球在屏幕上时必须先清除气球的定时器
        for i,v in ipairs(self.m_arrBalloon) do
            if not v.balItem.isBeyondPos then
                v.balItem:destroyTimer()
            end
        end

        self.m_pNodeLastView:setVisible(false)
        g_pSceneTable:gotoSceneHall()
        dtPlaySound(DEF_SOUND_TOUCH)
    end 
end

--重新开始
function CDLayerTable_DQQ:onRestart()

    if self.m_pNodeLastView:isVisible() then

        for i,v in ipairs(self.m_arrBalloon) do
            if not v.balItem.isBeyondPos then
                v.balItem:destroyTimer()
            end
        end

        self.isAgainGame = true
        self.m_pNodeLastView:setVisible(false)
        self:clearData()
        self:createUserInterface(self.m_nFlag)
        self:Handle_Dqq_StartPlay()
    end 
end
------------------------------------------------------

function CDLayerTable_DQQ:onOpenSound()
    if self.m_pSettingNode:isVisible() and self.m_pSoundOpen:isVisible() then
       self:showSound()
    end
end

function CDLayerTable_DQQ:onCloseSound()
    if self.m_pSettingNode:isVisible() and self.m_pSoundClose:isVisible() then
       self:showSound()
    end
end

function CDLayerTable_DQQ:onOpenSoundEffect()
    if self.m_pSettingNode:isVisible() and self.m_pMusicOpen:isVisible() then
        self:showMusic()
    end
end

function CDLayerTable_DQQ:onCloseSoundEffect()
    if self.m_pSettingNode:isVisible() and self.m_pMusicClose:isVisible() then
        self:showMusic()
    end
end

----------------------------------------------------------------------------
-- ccb处理
-- 变量绑定
function CDLayerTable_DQQ:onAssignCCBMemberVariable(loader)
    cclog("CDLayerTable_DQQ::onAssignCCBMemberVariable")

    -- 灯光
    self.m_pLighting     = loader["pic_alpha"]

    -- 底部的状态信息
    self.m_pGroupBar     = loader["group_bar"]
    self.m_pButSetting   = loader["but_setting"]
    self.m_pSelfInfo     = loader["self_info"]
    self.m_pTableInfo    = loader["table_info"]

    self.m_pJiZhongNum   = loader["jizhong_num"]
    self.m_pWeiJiZhong   = loader["weijizhong_num"]

    self.m_pJiZhongLabel    = loader["jizhong_label"]
    self.m_pWeiJiZhongLabel = loader["weijizhong_label"]

    self.m_pNewLayerRoot    = loader["new_layer"]

    -- 电池
    self.m_pIcoPower        = loader["power"]
    self.m_pNewEffLayer     = loader["newEfflayer"]

    self.m_pSettingNode     = loader["setting_Node"]

    -- 开始按钮
    self.m_pReadyBtn = loader["button_ready"]

    self.m_pPauseBtn = loader["but_pause"]

    self.m_pResumeBtn = loader["but_resume"]
    self.m_pSettingBtn = loader["but_setting"]

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
    self.m_pNodeLastView  = loader["Node_Lastview"]
    self.m_pWinSprite     = loader["show_win"]
    self.m_pLoseSprite    = loader["show_Lose"]
    self.m_pBtnGoToHall   = loader["button_gotoHall"]
    self.m_pBtnRestart    = loader["button_restart"]

    self.m_pNodeMode5     = loader["Mode5_showNode"]
    self.m_pJiZhongMode5  = loader["mode5_jizhong"]
    self.m_pCollectMode5  = loader["mode5_collect"]
    self.m_pRuleMode5     = loader["mode5_rule"]

    for i =1 ,3 do
        self.m_pLiangMode5[i] = loader["Mode5_liang"..i]
        self.m_pHuiMode5[i] = loader["Mode5_hui"..i]
    end

end

----------------------------------------------------------------------------
-- ccb处理
-- 函数绑定
function CDLayerTable_DQQ:onResolveCCBCCControlSelector(loader)
    cclog("CDLayerTable_DQQ::onResolveCCBCCControlSelector")
    
    -- 下方玩家功能区按钮
    loader["onSetting"]     = function() self:onSetting()  end         

    -- 开始准备按钮
    loader["onReady"]       = function() self:onReady()    end            

    loader["onPause"]       = function() self:onPause()    end

    loader["onGoToHall"]    = function() self:onGoToHall() end

    loader["onRestart"]     = function() self:onRestart()  end

    loader["onSetting"]     = function() self:onSetting()  end
  
    loader["onResume"]     = function () self:onResume()   end

    loader["onCloseSetting"] =function() self:onCloseSetting() end


    loader["onOpenSound"] =  function () self:onOpenSound() end
  
    loader["onCloseSound"] = function () self:onCloseSound() end
 
    loader["onOpenSoundEffect"] = function () self:onOpenSoundEffect() end

    loader["onCloseSoundEffect"] = function () self:onCloseSoundEffect() end
    
end

----------------------------------------------------------------------------
-- create
function CDLayerTable_DQQ.createCDLayerTable_dqq(pParent)
    cclog("CDLayerTable_DQQ::createCDLayerTable_xtlzddz")
    if not pParent then
        return nil
    end
    local layer = CDLayerTable_DQQ.new()
    layer:init()
    local loader = layer.m_ccbLoader
    layer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad("CDLayerTable_DQQ.ccbi",proxy,loader)
    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild(node)
    pParent:addChild(layer)
    return layer
end