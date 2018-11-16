--[[
/******************************************************
//Project:      ProjectX 
//Moudle:       CDLayerTable_CBK 仙桃赖子斗地主桌子
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

require( REQUIRE_PATH.."block_item")

require( REQUIRE_PATH.."mahjong_define")

--require "CCBReaderLoad"

local casinoclient = require("script.client.casinoclient")
local platform_help = require("platform_help")


--屏幕的尺寸
local ScreenSize = CDGlobalMgr:sharedGlobalMgr():getWinSize()

GAME_BLOCK_WIDTH = 2
DEF_MAX_ROW      = 200

-- 音效定义
DEF_SOUND_MJ_CLICK      = "sound_card_click"..DEF_TKD_SOUND     -- 点中牌
DEF_SOUND_MJ_KJ         = "mj_kj"..DEF_TKD_SOUND                -- 开局

DEF_SOUND_CMJ       = "sound_cmj"..DEF_TKD_SOUND            -- 踩麻将的声音
-----------------------------------------
-- 类定义
CDLayerTable_CBK = class("CDLayerTable_CBK", CDCCBLayer)    
CDLayerTable_CBK.__index = CDLayerTable_CBK
CDLayerTable_CBK.name = "CDLayerTable_CBK"

-- 构造函数
function CDLayerTable_CBK:ctor()
    cclog("CDLayerTable_CBK::ctor")
    CDLayerTable_CBK.super.ctor(self)
    CDLayerTable_CBK.initialMember(self)
    --reg enter and exit
    local function onNodeEvent(event)
        if "enter" == event then
            CDLayerTable_CBK.onEnter(self)
        elseif "exit" == event then
            CDLayerTable_CBK.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function CDLayerTable_CBK:onEnter()
    cclog("CDLayerTable_CBK::onEnter")

    -- 网络事件
    local   listeners = {
    }

    casinoclient.getInstance():addEventListeners(self,listeners)

    --暂时使用的心跳循环
    --self:createHeartbeatLoop()
end

function CDLayerTable_CBK:onExit()
    cclog("CDLayerTable_CBK::onExit")
    -- if self.playAudioID then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.playAudioID)   
    --     self.playAudioID=nil
    -- end

    -- 退出时，停止发送心跳
    self:stopHeartLoop()
    self:stopAllActions()

    casinoclient.getInstance():removeListenerAllEvents(self)
    CDLayerTable_CBK.releaseMember(self)
    self:unregisterScriptHandler()
    self:stopTimer()
end

-----------------------------------------
-- 初始化
function CDLayerTable_CBK:initialMember()
    cclog("CDLayerTable_CBK::initialMember")

    ---------------------------------------------------
    -- 底部的状态信息 
    self.m_pGroupBar        = nil        -- 状态按钮根节点
    self.m_pButSetting      = nil        -- 设置按钮
    self.m_pSelfInfo        = nil        -- 自己的信息
    self.m_pTableInfo       = nil        -- 桌子的信息

    ---------------------------------------------------
   
    self.m_pCloseBtn        = nil        -- 关闭设置按钮
    ---------------------------------------------------
    -- 桌子中相关'节点'与'层''
    self.m_pNewEffLayer     = nil        -- 特效层
    self.m_pNewLayerRoot    = nil        -- 桌面麻将放置的根节点
    self.m_pLighting        = nil        -- 灯光
   
    self.m_pBlockDemo       = nil        -- block放置层

    self.m_pMahjongShowLayer = nil       -- 麻将放置层
    ---------------------------------------------------
    -- 电池
    self.m_pIcoPower        = nil        -- 电池图标

    self.m_pNodeLastView  = nil          --胜利或失败界面Node
  
    self.m_pBtnGoToHall   = nil
    self.m_pBtnRestart    = nil
   
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


    self.m_pttf             = nil    -- 显示时间的label

    ---------------------------------------------------
    self.m_pListener        = nil        -- 监听对象
 
    self.m_bPreCreate       = false      -- 是否预创建过

    self.m_nFlag            = nil        -- 游戏类型(1、经典 2、挑战)
   
    ---------------------------------------------------

    self.m_pBlock1         =  {} 

    self.m_pBlock2         =  nil       
    
    self.m_pBlock3         = {}
    -- 数据对象

    self.m_nNeedTouch      = 25           -- 需要点击的数量
    self.m_nRow            = 4           -- 行数和列数
    
    self.m_pBlockArr       = {}

    for i=1 ,DEF_MAX_ROW do
        self.m_pBlockArr[i]={}
    end

    self.m_bIsAgainGame    = false      --  是否再来一局

    self.m_bIsWin          = false      -- 是否胜利
    self.m_bIsTouchSetting = false      -- 是否点击设置

    self.m_nTouchNum        = 0 

    self.m_nCurNomalIndex  = 0           -- 当前的行数

    self.m_nIndex          = 1          -- 记录上次的点击 ，默认为1

    self.m_nLastIndex  = 0

    self.m_bTouchEndLine  = false        --选择行的点击判断

    --模式2 下

    self.m_nTouchFaCai      = 0          -- 踩中发财的数量

    self.m_arrFaCaiIndex      = {}         -- 保存发财的位置

    self.m_arrNotFaCaiIndex   = {}         -- 保存另一张随机出的位置
    ----------------------
    self.m_nTouchRow     =  1            --  需要点击的行数

    self.m_nRecordTime  =  0             -- 记录时间

    self.m_nJiSuTouchNum  = 0 

    self.m_nTimer = 1.1 
end

function CDLayerTable_CBK:releaseMember()
    cclog("CDLayerTable_CBK::releaseMember")

    if  self.m_pNewEffLayer then
        self.m_pNewEffLayer:removeAllChildren()
    end

    if  self.m_pNewLayerRoot ~= nil then
        self.m_pNewLayerRoot:removeAllChildren()
        self.m_pEffNetLow = nil
    end

    --模拟析构父类
    CDLayerTable_CBK.super.releaseMember(self)
    if  DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end

    if self.m_pListener then
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:removeEventListener(self.m_pListener)
        self.m_pListener = nil
    end
end


-- 循环发送心跳包
function CDLayerTable_CBK:createHeartbeatLoop( ... )
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
function CDLayerTable_CBK:stopHeartLoop( ... )
    if  self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)   
        self.schedulerID=nil
    end
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--显示最下方的一行
function CDLayerTable_CBK:addStartLine(index)
    if not self.m_pBlockDemo then
           
        self.m_pBlockDemo = cc.LayerColor:create(cc.c3b(0,0,0),ScreenSize.width,ScreenSize.height/5)
        self.m_pBlockDemo:setAnchorPoint(cc.p(0,0))
        self.m_pBlockDemo:setPosition(cc.p(0,0))
        self.m_pNewLayerRoot:addChild(self.m_pBlockDemo)
    end

    if self.m_nFlag == 1 then -- 经典模式

        local blockWidth  = (ScreenSize.width - (GAME_BLOCK_WIDTH)*4)/5
        local blockHeight = (ScreenSize.height- (GAME_BLOCK_WIDTH)*4)/5

        local str =""
        local layerColor 
        local textColor 

        self.m_pBlock1 = {}
        
        for i=1 ,5 do
            if i==1 then
                str = "25"
            elseif i==2 then
                str = "50"
            elseif i==3 then
                str = "不连续"
            elseif i == 4 then
                str = "5*5"
            else
                str ="6*6"
            end

            if i== index then
                layerColor = cc.c3b(0,0,0)
                textColor  = cc.c3b(255,255,255)
            else
                layerColor = cc.c3b(255,255,0)
                textColor = cc.c3b(0,0,0)
            end
             
            self.m_pBlock1[i] = CDBlockItem:createdBlockItem()
            self.m_pBlock1[i]:createBlock(layerColor,cc.size(blockWidth,blockHeight),str,26,textColor)
            self.m_pBlock1[i]:setPosition(cc.p(ScreenSize.width/5*(i-1),0))
            self.m_pBlockDemo:addChild(self.m_pBlock1[i])
        end
    elseif self.m_nFlag == 2 then
        local str = "踩两张发财！！！！"
        self.m_pBlock2 = CDBlockItem:createdBlockItem()
        self.m_pBlock2:createBlock(cc.c3b(67,205,128),cc.size(ScreenSize.width,ScreenSize.height/5),str,36,cc.c3b(0,0,0))  
        self.m_pBlock2:setPosition(cc.p(0,0))
        self.m_pBlockDemo:addChild(self.m_pBlock2)
    elseif self.m_nFlag == 3 then

        local blockWidth  = (ScreenSize.width - (GAME_BLOCK_WIDTH)*3)/4
        local blockHeight = (ScreenSize.height- (GAME_BLOCK_WIDTH)*4)/5

        local str =""
        local layerColor 
        local textColor 

        self.m_pBlock3 = {}
        
        for i=1 ,4 do
            if i==1 then
                str = "4*4"
            elseif i==2 then
                str = "不连续"
            elseif i == 3 then
                str = "5*5"
            else
                str ="6*6"
            end

            if i== index then
                layerColor = cc.c3b(0,0,0)
                textColor  = cc.c3b(255,255,255)
            else
                layerColor = cc.c3b(255,255,0)
                textColor = cc.c3b(0,0,0)
            end
             
            self.m_pBlock3[i] = CDBlockItem:createdBlockItem()
            self.m_pBlock3[i]:createBlock(layerColor,cc.size(blockWidth,blockHeight),str,26,textColor)
            self.m_pBlock3[i]:setPosition(cc.p(ScreenSize.width/4*(i-1),0))
            self.m_pBlockDemo:addChild(self.m_pBlock3[i])
        end

    end
end

function CDLayerTable_CBK:showWinView()

    if self.m_pButSetting:isVisible() then
        self.m_pButSetting:setVisible(false)
    end

    local scale9Sprite1  = cc.Scale9Sprite:create("returnBtn.png")
    local scale9Sprite2  = cc.Scale9Sprite:create("againBtn.png")

    local function returnView()
        
        g_pSceneTable:gotoSceneHall()
        dtPlaySound(DEF_SOUND_TOUCH)
    end 


    local function againNext()
        if self.m_pEndLineBlock then
            self.m_pEndLineBlock:removeFromParent()
            self.m_pEndLineBlock = nil
        end
        self.m_bIsAgainGame = true
        self:clearData()
        self:createUserInterface(self.m_nFlag)
    end 


    local  returnBtn = cc.ControlButton:create(scale9Sprite1)
    returnBtn:setPosition(cc.p(ScreenSize.width/2-160,150))
    returnBtn:setPreferredSize(cc.size(210,90))
    returnBtn:registerControlEventHandler(returnView,cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
    self.m_pNewLayerRoot:addChild(returnBtn)


    local  againBtn  = cc.ControlButton:create(scale9Sprite2)
    againBtn:setPosition(cc.p(ScreenSize.width/2+160,150))
    againBtn:setPreferredSize(cc.size(210,90))
    againBtn:registerControlEventHandler(againNext,cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
    self.m_pNewLayerRoot:addChild(againBtn)
    

    local winViewLabel = cc.Label:create()
    winViewLabel:setString("游戏玩法:")
    winViewLabel:setSystemFontSize(40)
    winViewLabel:setTextColor(cc.c3b(255,255,255))
    winViewLabel:setPosition(cc.p(120,ScreenSize.height-30))
    self.m_pNewLayerRoot:addChild(winViewLabel)

    local typeLabel = cc.Label:create()
    typeLabel:setString("经典模式")
    typeLabel:setSystemFontSize(60)
    typeLabel:setTextColor(cc.c3b(255,255,255))
    typeLabel:setPosition(cc.p(ScreenSize.width/2,ScreenSize.height-160))
    self.m_pNewLayerRoot:addChild(typeLabel)

    local str  = string.format("%.3f".."'' ",self.m_nRecordTime)
    local timeLabel = cc.Label:create()
    timeLabel:setString(str)
    timeLabel:setSystemFontSize(120)
    timeLabel:setTextColor(cc.c3b(0,0,0))
    timeLabel:setPosition(cc.p(ScreenSize.width/2,ScreenSize.height-260))
    self.m_pNewLayerRoot:addChild(timeLabel)

    local str 
    local posX = 240
    if self.m_nIndex == 1 then
        str = "25"
    elseif self.m_nIndex == 2 then
        str = "50"
    elseif self.m_nIndex == 3 then
        str = "不连续"
        posX = 280
    elseif self.m_nIndex == 4 then
        str = "5*5"
    elseif self.m_nIndex == 5 then
        str = "6*6"
    end
   
    self.m_pGameTypeLabel = cc.Label:create()
    self.m_pGameTypeLabel:setString(str)
    self.m_pGameTypeLabel:setSystemFontSize(40)
    self.m_pGameTypeLabel:setTextColor(cc.c3b(0,0,0))
    self.m_pGameTypeLabel:setPosition(cc.p(posX,ScreenSize.height-30))
    self.m_pNewLayerRoot:addChild(self.m_pGameTypeLabel)

end

function CDLayerTable_CBK:recordTime()
    if self.m_bIsWin then
        if g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex)~= 0 then
            if g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex) >self.m_nRecordTime then
                g_pGlobalManagement:setHistoryTime(self.m_nRecordTime,self.m_nFlag,self.m_nIndex)
            end
        else
            g_pGlobalManagement:setHistoryTime(self.m_nRecordTime,self.m_nFlag,self.m_nIndex)
        end
    end
end

function CDLayerTable_CBK:addEndLineBlock()

    self:recordTime()
    self.m_pRecordttf = cc.LabelTTF:create("0.000","Courier New",60)
    self.m_pRecordttf:setColor(cc.c3b(255,0,0))
    self.m_pRecordttf:setLocalZOrder(100)
    self.m_pRecordttf:setPosition(cc.p(ScreenSize.width/2,260))
    self.m_pNewLayerRoot:addChild(self.m_pRecordttf)
    if g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex) < self.m_nRecordTime then
        self.m_pRecordttf:setString(string.format("历史最佳:".."%.3f",g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex)))
    else
        self.m_pRecordttf:setString("新纪录!")
    end

    self:showWinView()
end

function CDLayerTable_CBK:randInChallenge(num)

    local saveBlockIndex = {}
    if num>0 and num % 8 == 0 then
       
        -- 两个黑block
        local arr  = {1,2,3,4,5,6}
        local index = math.random(6)
        table.insert(saveBlockIndex,arr[index])
        table.remove(arr,index)

        index = math.random(5)
        table.insert(saveBlockIndex,arr[index])

    else
        
        local index = math.random(6)
        table.insert(saveBlockIndex,index)
    end
    return saveBlockIndex
end


--参数：设置的行数,一行有几个
function CDLayerTable_CBK:addNormalLineBlocks(lineCount,row)
    --if lineCount ~=0 then
        self.m_nCurNomalIndex = self.m_nCurNomalIndex +1
    --end
    local index = 0
    local arr = nil

    if self.m_nFlag == 1 then
        if self.m_nIndex ==3 then
           
            index = self:randIndex(self.m_nLastIndex ,row)
            self.m_nLastIndex = index
        else
    
            index = math.random(row)
        end
    elseif self.m_nFlag == 3 then
        if self.m_nIndex ==2 then
           
            index = self:randIndex(self.m_nLastIndex ,row)
            self.m_nLastIndex = index
        else
    
            index = math.random(row)
        end
    else
        arr =self:randInChallenge(self.m_nCurNomalIndex-2)
        if #arr == 2 then
            table.insert(self.m_arrFaCaiIndex,arr[1])
            table.insert(self.m_arrNotFaCaiIndex,arr[2])
        end
        print("===============>>>>>>")
        dumpArray(self.m_arrFaCaiIndex)
    end
  
    local color 

    local blockWidth  = (ScreenSize.width - GAME_BLOCK_WIDTH*(row-1))/row
    local blockHeight = (ScreenSize.height- GAME_BLOCK_WIDTH*(row-1))/row

    local originalRow = 0
    if self.m_nFlag == 1 then
        if self.m_nIndex~= 5 then
            originalRow = 1
        else
            originalRow = 2
        end 
    elseif self.m_nFlag == 3 then
        if self.m_nIndex ~= 4 then
            originalRow = 1
        else
            originalRow = 2 
        end
    else
        originalRow = 2
    end

    local str = nil
    for i=1 ,row do
        if  lineCount == 0 then
            color =cc.c3b(255,255,255)
       
        elseif lineCount == originalRow then
            if self.m_nFlag == 2 then
                index = arr[1]
            end

            if i==index then
                str ="开始"
                color = cc.c3b(0,150,0)
            else
                str = nil
                color =cc.c3b(255,255,255)
            end

         elseif lineCount ~= originalRow then
            if self.m_nFlag == 1 or self.m_nFlag == 3 then

                if lineCount == 1 and originalRow == 2 then
                    color = cc.c3b(255,255,255)
                else
                    if i == index then
                        color = cc.c3b(0,150,0)
                    else
                        color =cc.c3b(255,255,255)
                    end
                end

            elseif self.m_nFlag == 2 then
                if lineCount == 1 then
                    color = cc.c3b(255,255,255)
                else
                    for m,n in ipairs(arr) do
                        if n == i then
                           
                            color = cc.c3b(0,150,0)
                            break
                        else
                            color =cc.c3b(255,255,255)
                        end
                    end
                end
            end
 
        end

        local curC3b = cc.c3b(67,205,128)
        
        local block = CDBlockItem:createdBlockItem()
        block:createBlock(color,cc.size(blockWidth,blockHeight),str,30,curC3b)
       
        block:SetLineIndex(lineCount)
        block:setPosition(cc.p(ScreenSize.width/row*(i-1),ScreenSize.height/row*lineCount))
        self.m_pNewLayerRoot:addChild(block)


        if not self.m_pBlockArr[self.m_nCurNomalIndex] then
            print("self.m_nCurNomalIndex---------------------->",self.m_nCurNomalIndex)
            self.m_pBlockArr[self.m_nCurNomalIndex] = {}
        end

        table.insert(self.m_pBlockArr[self.m_nCurNomalIndex],block)
    end

end

----------------------------------------------------------------------------
--不连续规则下使用
-- 记录上一次随机的位置
function CDLayerTable_CBK:randIndex(lastIndex,row)

    local selectArr = {1,2,3,4,5}
    local randNumTotal = row
    local pos = 0
    local  indexPos
    if lastIndex ~= 0 then
        table.remove(selectArr,lastIndex)

        pos = math.random(randNumTotal-1)
        indexPos  = selectArr[pos]
    else
        pos = math.random(randNumTotal)
        indexPos = pos
    end

    return indexPos
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------

function CDLayerTable_CBK:startTimer()
    local time = os.clock()
    local function showTimeLabel()
      
        local offest = os.clock() - time
        local str  = string.format("%.3f",offest)
        self.m_pttf:setString(str)
        self.m_nRecordTime = offest
    end 

    if not self.schedulerID then
         self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(showTimeLabel,0.1,false)
    end
end


function CDLayerTable_CBK:stopTimer( )

    if self.m_pttf then
        self.m_pttf:setVisible(false)
    end

    if  self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)  
        print("self.m_nRecordTime--------->",self.m_nRecordTime) 
        self.schedulerID = nil
    end  
end


function CDLayerTable_CBK:showLastView()
    if self.m_pButSetting:isVisible() then
        self.m_pButSetting:setVisible(false)
    end

    self.m_bInTheGame = false
    self:stopAllActions()
    self.m_pNodeLastView:setVisible(true)

    if self.m_PEndSprite ~= nil then
        self.m_PEndSprite:removeFromParent()
        self.m_PEndSprite = nil
    end

    if self.m_pLabel~= nil then
        self.m_pLabel:removeFromParent()
        self.m_pLabel = nil
    end

    if self.m_pWinttf~= nil then
        self.m_pWinttf:removeFromParent()
        self.m_pWinttf = nil
    end

    if self.m_ptimeLabel ~= nil then
        self.m_ptimeLabel:removeFromParent()
        self.m_ptimeLabel = nil
    end

    --胜利
    if self.m_bIsWin then
        local index  = math.random(4)
        local SpriteStr = "win_"..index..".png"

        self.m_PEndSprite= cc.Sprite:create(SpriteStr)
        self.m_PEndSprite:setPosition(cc.p(ScreenSize.width/2,480))
        self.m_PEndSprite:setAnchorPoint(cc.p(0.5,0.5))
        self.m_PEndSprite:setVisible(true)
        self.m_pNodeLastView:addChild(self.m_PEndSprite)

        self.m_pLabel =  cc.Label:create()
        self.m_pLabel:setString("成 功 了 !")
        self.m_pLabel:setSystemFontSize(60)
        self.m_pLabel:setTextColor(cc.c3b(250,0,0))
        self.m_pLabel:setPosition(cc.p(ScreenSize.width/2,420))
        self.m_pNodeLastView:addChild(self.m_pLabel)

    else--失败

        local index  = math.random(4)
        local SpriteStr = "lost_"..index..".png"

        self.m_PEndSprite= cc.Sprite:create(SpriteStr)
        self.m_PEndSprite:setPosition(cc.p(ScreenSize.width/2,480))
        self.m_PEndSprite:setAnchorPoint(cc.p(0.5,0.5))
        self.m_PEndSprite:setVisible(true)
        self.m_pNodeLastView:addChild(self.m_PEndSprite)

        self.m_pLabel =  cc.Label:create()
        self.m_pLabel:setString("失 败 了!")
        self.m_pLabel:setSystemFontSize(60)
        self.m_pLabel:setTextColor(cc.c3b(130,130,130))
        self.m_pLabel:setPosition(cc.p(ScreenSize.width/2,420))
        self.m_pNodeLastView:addChild(self.m_pLabel)

    end


    local str  = string.format("%.3f".."'' ",self.m_nRecordTime)
    self.m_ptimeLabel = cc.Label:create()
    self.m_ptimeLabel:setString(str)
    self.m_ptimeLabel:setSystemFontSize(80)
    self.m_ptimeLabel:setTextColor(cc.c3b(0,0,0))
    self.m_ptimeLabel:setPosition(cc.p(ScreenSize.width/2,340))
    self.m_pNodeLastView:addChild(self.m_ptimeLabel)

    self:recordTime()
    self.m_pWinttf = cc.LabelTTF:create("0.000","Courier New",42)
    self.m_pWinttf:setColor(cc.c3b(255,0,0))
    self.m_pWinttf:setLocalZOrder(100)
    self.m_pWinttf:setPosition(cc.p(ScreenSize.width/2,280))
    self.m_pNodeLastView:addChild(self.m_pWinttf)
    if self.m_bIsWin then
        if g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex) < self.m_nRecordTime then
            self.m_pWinttf:setString(string.format("历史最佳:".."%.3f",g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex)))
        else
            self.m_pWinttf:setString("新纪录!")
        end
    else
        self.m_pWinttf:setString(string.format("历史最佳:".."%.3f",g_pGlobalManagement:getHistoryTime(self.m_nFlag,self.m_nIndex)))
    end
    
end

-- 重置电量
function CDLayerTable_CBK:resetPower()
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

--根据 模式 创建格子的数量
function CDLayerTable_CBK:getNumByFlag()
    if not self.m_nFlag then
        return 0
    end

    if self.m_nFlag == 1 then
        self.m_nRow = 4
    elseif self.m_nFlag == 2 then
        self.m_nRow = 6
    elseif self.m_nFlag == 3 then
        self.m_nRow = 4 
    end
end

--显示时间的label
function CDLayerTable_CBK:showTimeLabel()
    
    self.m_pttf = cc.LabelTTF:create("0.000","Courier New",45)
    self.m_pttf:setColor(cc.c3b(255,0,0))
    self.m_pttf:setZOrder(100)
    self.m_pttf:setPosition(cc.p(110,ScreenSize.height - 20))
    self.m_pNewLayerRoot:addChild(self.m_pttf)
end

-- 创建用户界面
function CDLayerTable_CBK:createUserInterface(flag)
    cclog("CDLayerTable_CBK::createUserInterface")

    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

    if not self.m_pButSetting:isVisible() then
        self.m_pButSetting:setVisible(true)
    end
 
     --经典模式 1  挑战模式 2 
    self.m_nFlag = flag
    self:getNumByFlag()
    if self.m_nFlag ~= 3 then
        self:showTimeLabel()
    else

    end

    if self.m_nFlag == 2 then
        if not self.m_pMahjongShowLayer then
            self.m_pMahjongShowLayer = cc.Layer:create()
            self.m_pMahjongShowLayer:setLocalZOrder(1000)
            self.m_pNewLayerRoot:addChild(self.m_pMahjongShowLayer)
        end
    end
    --初始化时是 4*4 的界面
    if self.m_nFlag == 1 then

        if self.m_nIndex == 1 or self.m_nIndex == 2 then
            self.m_nRow = 4
        elseif self.m_nIndex == 3 or self.m_nIndex == 4 then
            self.m_nRow = 5
        else
            self.m_nRow = 6
        end
    elseif self.m_nFlag == 3 then

        if self.m_nIndex == 1 then
            self.m_nRow = 4
        elseif self.m_nIndex == 2 or self.m_nIndex == 3 then
            self.m_nRow = 5
        else
            self.m_nRow = 6
        end
    end

    if not self.m_bIsAgainGame  then

        self:addNormalLineBlocks(0,self.m_nRow)
        self:addNormalLineBlocks(1,self.m_nRow)
        self:addNormalLineBlocks(2,self.m_nRow)
        self:addNormalLineBlocks(3,self.m_nRow)
        
        if self.m_nFlag == 2 then
            self:addNormalLineBlocks(4,self.m_nRow)
            self:addNormalLineBlocks(5,self.m_nRow) 
        end

        self:addStartLine(1)

    elseif self.m_nFlag == 2 then
         self:addNormalLineBlocks(0,self.m_nRow)
        self:addNormalLineBlocks(1,self.m_nRow)
        self:addNormalLineBlocks(2,self.m_nRow)
        self:addNormalLineBlocks(3,self.m_nRow)
        self:addNormalLineBlocks(4,self.m_nRow)
        self:addNormalLineBlocks(5,self.m_nRow) 
         self:addStartLine(1)
    else
        self:changeRuleAndView(self.m_nIndex)
    end
   
    self.m_bInTheGame = false
    local function setIsInTheGame()
       self.m_bInTheGame =true
    end 
    --为了点击再来一局而延迟
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(setIsInTheGame)))    

    -- 重置电量
    self:resetPower()
end



--用于重新开始时一些数据的清空
function CDLayerTable_CBK:clearData()
    if self.m_pNewLayerRoot ~= nil then
        self.m_pNewLayerRoot:removeAllChildren()
    end

    if self.m_pMahjongShowLayer ~= nil then
        self.m_pMahjongShowLayer = nil
    end

    if self.m_nFlag == 2 then
        self.m_nTouchFaCai = 0
        self.m_arrFaCaiIndex = {}
        self.m_arrNotFaCaiIndex = {}
    end

    self.m_nRecordTime = 0
    self.m_nNeedTouch = 25
    
    self.m_bTouchEndLine = false
    --self.m_nIndex = 1
    self.m_nTouchNum = 0
    self.m_nCurNomalIndex = 0
    self.m_pBlockArr = {}
    for i=1 ,DEF_MAX_ROW do
        self.m_pBlockArr[i] = {}
    end
end

---------------------------------------------------------------------------

function CDLayerTable_CBK:changeRuleAndView(index)
    
    self.m_nIndex = index
    if self.m_nFlag ~= 3 then
        if index == 1 then
            self.m_nNeedTouch =25
            self.m_nRow=4
            
        elseif index == 2 then  
            
            self.m_nNeedTouch =50
            self.m_nRow=4
         
        elseif index ==3  then
    
            self.m_nNeedTouch =50
            self.m_nRow=5
            
        elseif index ==4 then
         
            self.m_nNeedTouch =50
            self.m_nRow=5
        elseif index == 5 then
            self.m_nNeedTouch =50
            self.m_nRow=6
        else
            self.m_nNeedTouch = 25
            self.m_nRow=4
        end
    else
         if index == 1 then
            self.m_nRow=4 
        elseif index == 2 then  

            self.m_nRow=5
        elseif index ==3  then
    
            self.m_nRow=5
            
        elseif index ==4 then
         
            self.m_nRow=6
        end
    end

    if self.m_pNewLayerRoot ~= nil then
        self.m_pNewLayerRoot:removeAllChildren()
    end

    if self.m_pBlockDemo ~= nil then
        self.m_pBlockDemo = nil
    end

    --清空数组，便于存储
    self.m_nCurNomalIndex = 0
    for i=1 ,DEF_MAX_ROW do
        self.m_pBlockArr[i] = {}
    end
    self:showTimeLabel()

    self:addNormalLineBlocks(0,self.m_nRow)
    self:addNormalLineBlocks(1,self.m_nRow)
    self:addNormalLineBlocks(2,self.m_nRow)
    self:addNormalLineBlocks(3,self.m_nRow)
    
    if self.m_nRow == 6 then
        self:addNormalLineBlocks(4,self.m_nRow)
        self:addNormalLineBlocks(5,self.m_nRow)
    elseif self.m_nRow ==5 then
        self:addNormalLineBlocks(4,self.m_nRow)
    end

    self:addStartLine(index)
end

function CDLayerTable_CBK:cancelSchedule3()
   
    if  self.schedulerID3 then
       
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID3)   
        self.schedulerID3=nil
    end
end 

function CDLayerTable_CBK:startSchedule3(func)

    local time = 1 - math.floor(self.m_nJiSuTouchNum/20)*0.1

    print("time------------------------>",time)
    if self.m_nTimer ~= time  then
        self.m_nTimer = time 
        self:cancelSchedule3()
    
        if not self.schedulerID3 then
            
            self.schedulerID3 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(func,self.m_nTimer,false)
    
        end
    end
end



----------------------------------------------------------------------------
-- 初始化
function CDLayerTable_CBK:init()
    cclog("CDLayerTable_CBK::init")
    
    -- touch事件
    local function onTouchBegan(touch, event)
        cclog("CDLayerTable_CBK:onTouchBegan")

        -- 没有开始时，不能进行点击
        if not self.m_bInTheGame  or self.m_bIsTouchSetting then
            return
        end

        -- 点选自己的气球(游戏中才能使用，发牌阶段不能使用)
        if not self.m_bTouchEndLine then
            if self.m_nFlag == 1  then
        
                local sPoint = touch:getLocation()
                local rect 
                if self.m_pBlock1[1] then
                     rect =self.m_pBlock1[1]:getBoundingBox()
                end
                local index = 1
                if self.m_pBlock1[1]:isVisible() then
                 
                    if sPoint.y<rect.height then
                        if sPoint.x < self.m_pBlock1[1]:getPositionX()+rect.width then
                            index =1
                        elseif sPoint.x<self.m_pBlock1[2]:getPositionX() +rect.width then
                            index =2
                        elseif sPoint.x<self.m_pBlock1[3]:getPositionX() +rect.width then
                            index =3
                        elseif sPoint.x<self.m_pBlock1[4]:getPositionX() +rect.width then
                            index =4
                        elseif sPoint.x<self.m_pBlock1[5]:getPositionX() +rect.width then
                            index =5
                        end
    
    
                        if index~=self.m_nIndex then
                            self:changeRuleAndView(index)
                        end

                       
                        if self.m_nIndex~= 5 then
                            self.m_nTouchRow = 1
                        else
                            self.m_nTouchRow = 2
                        end
                    
                        return
                    else
    
    
                    end 
                end
            elseif self.m_nFlag == 3 then
                  local sPoint = touch:getLocation()
                local rect 
                if self.m_pBlock3[1] then
                     rect =self.m_pBlock3[1]:getBoundingBox()
                end
                local index = 1
                if self.m_pBlock3[1]:isVisible() then
                 
                    if sPoint.y<rect.height then
                        if sPoint.x < self.m_pBlock3[1]:getPositionX()+rect.width then
                            index =1
                        elseif sPoint.x<self.m_pBlock3[2]:getPositionX() +rect.width then
                            index =2
                        elseif sPoint.x<self.m_pBlock3[3]:getPositionX() +rect.width then
                            index =3
                        elseif sPoint.x<self.m_pBlock3[4]:getPositionX() +rect.width then
                            index =4
                      
                        end
    
    
                        if index~=self.m_nIndex then
                            self:changeRuleAndView(index)
                        end

                       
                        -- if self.m_nIndex~= 5 then
                        --     self.m_nTouchRow = 1
                        -- else
                        --     self.m_nTouchRow = 2
                        -- end
                        return
                    else

                    end
                end
            else
                self.m_nTouchRow = 2
            end
        end

        local sPoint = touch:getLocation()
        local max_row = self.m_nCurNomalIndex

        -- print("self.m_nTouchRow-------->",self.m_nTouchRow)
        -- print("max_row----------------->",max_row)

        print("self.m_nRow------->",self.m_nRow)
        if self.m_nFlag == 3 then
          
            local function ProduceBlock()
                self:addNormalLineBlocks(self.m_nRow,self.m_nRow)

                 -- local row = self.m_nCurNomalIndex
                 -- for i =row- self.m_nRow+1,row do
    
                 --     for j=1 ,self.m_nRow do
                 --         if self.m_pBlockArr[i][j]~= nil and self.m_pBlockArr[i][j]._LineIndex then
                 --             self.m_pBlockArr[i][j]:initTimer()
                  
                 --         end   
                 --     end
                 -- end
            end

            -- local function MoveBlock()
            --     self:blockMove()
            -- end 

            -- local function ProduceAndMove( ... )
            --     self:runAction(cc.Sequence:create(cc.CallFunc:create(ProduceBlock),cc.DelayTime:create(0.1),cc.CallFunc:create(MoveBlock)))
            -- end

            print("max_row------------>",max_row)
            local index = 0
            local canTouchGreen = false
            for i=max_row -self.m_nRow+1 ,max_row do
                for m =1 ,self.m_nRow do
                    local colorVec = self.m_pBlockArr[i][m]:getColor()
                    if (colorVec.r ==0 and colorVec.g == 150 and colorVec.b==0) and not self.m_pBlockArr[i][m].m_bTouch then
                        index = i 
                        canTouchGreen =true
                        break
                    end
                end

                if canTouchGreen then
                    break
                end
            end

            print("index------------>",index)
            
            if index ~= 0 then
                for j =1 ,self.m_nRow do        
                    if  self.m_pBlockArr[index][j]._LineIndex ~= nil and self.m_pBlockArr[index][j]._LineIndex >-1 then
                      
                        local rect = self.m_pBlockArr[index][j]:getBoundingBox()
                        local colorArr = self.m_pBlockArr[index][j]:getColor()
                        if cc.rectContainsPoint(rect,sPoint) then
                            print("1112312312122112")
                            if (colorArr.r ==0 and colorArr.g == 150 and colorArr.b==0) then
                                    
                                    self.m_nJiSuTouchNum = self.m_nJiSuTouchNum +1
                                    self.m_bTouchEndLine = true
                                    if self.m_pBlockDemo then
                                        self.m_pBlockDemo :removeFromParent()
                                        self.m_pBlockDemo = nil
                                    end
                                    
                                    self.m_pBlockArr[index][j]:setTextBVisible(false)    
                                    self.m_pBlockArr[index][j].m_bTouch = true
                                    self.m_pBlockArr[index][j]:setBlockColor(cc.c3b(200,200,200))
                                  
                                    --self:startSchedule3(ProduceAndMove)

                                    if not self.schedulerID3 then
            
                                        self.schedulerID3 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(ProduceBlock,0.5,false)
    
                                    end

                                return
                            else
                                --结束游戏
                                print("-------------结束游戏-------------")
                                self.m_pBlockArr[index][j]:runAction(cc.Sequence:create(cc.CallFunc:create(self.m_pBlockArr[index][j].setRedColor),cc.DelayTime:create(0.4),cc.CallFunc:create(self.m_pBlockArr[index][j].clearBlockItem)))
                            
                                self:cancelSchedule3()
                                self.m_nTimer = 1.1
                                return
                            end
                        end
                    end
                end
            end
            
        else

            for i=max_row -self.m_nRow+1 ,max_row do
        
                for j =1 ,self.m_nRow do
                   --if  self.m_pBlockArr[i][j]~= nil then
                        if  self.m_pBlockArr[i][j]._LineIndex ~= nil and self.m_pBlockArr[i][j]._LineIndex >-1 then
    
                            local rect = self.m_pBlockArr[i][j]:getBoundingBox()
                            local colorArr = self.m_pBlockArr[i][j]:getColor()
                            local curBlockIndex = self.m_pBlockArr[i][j]._LineIndex 
    
    
                            if cc.rectContainsPoint( rect, sPoint)  and  curBlockIndex == self.m_nTouchRow   then
    
                                dtPlaySound(DEF_SOUND_CMJ)
                                -- 移除最下方的一行
                                if self.m_pBlockDemo then
                                    self.m_pBlockDemo :removeFromParent()
                                    self.m_pBlockDemo = nil
                                end
    
                                if (colorArr.r ==0 and colorArr.g == 150 and colorArr.b==0) then
                           
                                    self.m_pBlockArr[i][j]:setTextBVisible(false)
                                    self.m_pBlockArr[i][j]:setBlockColor(cc.c3b(200,200,200))
                                    self.m_bTouchEndLine = true
    
                                   
                                    self.m_nTouchNum   = self.m_nTouchNum +1
    
                                    self:startTimer()
                                   
    
                                    if self.m_nFlag == 2 then
                                        if (i-2)%8 == 0 then
                                            local FaCaiIndex = (i-2)/8
                                            if self.m_arrFaCaiIndex[FaCaiIndex] == j then
                                        
                                                self.m_nTouchFaCai = self.m_nTouchFaCai +1
    
                                                self.m_pBlockArr[i][self.m_arrNotFaCaiIndex[FaCaiIndex]]:setBlockColor(cc.c3b(200,200,200))
    
                                                local mahjong =  CDMahjong.createCDMahjong(self.m_pMahjongShowLayer)
                                                mahjong:initMahjongWithFile("t_52.png")
                                                mahjong:setPosition(cc.p(ScreenSize.width/6*(j-1),ScreenSize.height/3))
                                                mahjong:runAction(cc.Spawn:create(cc.MoveTo:create(0.3,cc.p(140+self.m_nTouchFaCai*100,ScreenSize.height-mahjong.m_nSizeH/2-10)),cc.ScaleTo:create(0.3,1.5,1.5)))
                                            else
                                                self.m_pBlockArr[i][self.m_arrFaCaiIndex[FaCaiIndex]]:setBlockColor(cc.c3b(200,200,200))
                                            end
                                        end
                                    end
    
                                    self:moveDown()
    
                                    return
                                elseif (colorArr.r ==255 and colorArr.g == 255 and colorArr.b== 255) then
    
                                    self.m_bInTheGame = false
                                    local function showLast()
                                        self.m_bIsWin = false
                                        self:showLastView()
                                    end 
    
                                    self.m_pBlockArr[i][j]:runAction(cc.Sequence:create(cc.CallFunc:create(self.m_pBlockArr[i][j].setRedColor),cc.DelayTime:create(0.4),cc.CallFunc:create(self.m_pBlockArr[i][j].clearBlockItem)))
                                    self:stopTimer()
                                    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(showLast)))
                                   
                                    return
                                end
                            end
                        end
                    --end
                end
            end
        end

        return true
    end

    local function onTouchMoved(touch, event)
        cclog("CDLayerTable_CBK:onTouchMoved")
    end

    local function onTouchEnded(touch, event)
        cclog("CDLayerTable_CBK:onTouchEnded")

    end

    self.m_pListener = cc.EventListenerTouchOneByOne:create()
    self.m_pListener:setSwallowTouches(true)
    self.m_pListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.m_pListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.m_pListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pListener, self)
end

-------------------------------------------------------------------------------

function CDLayerTable_CBK:blockMove()
    local row = self.m_nCurNomalIndex
    for i =row- self.m_nRow+1,row do
    --for i=1,DEF_MAX_ROW do 
        for j=1 ,self.m_nRow do
            if self.m_pBlockArr[i][j]~= nil and self.m_pBlockArr[i][j]._LineIndex then
                self.m_pBlockArr[i][j]:moveDownAndCleanUp(self.m_nRow)
                -- if self.m_nFlag == 3 then
                --     local colorArr = self.m_pBlockArr[i][j]:getColor()
                --     if (colorArr.r ==0 and colorArr.g == 150 and colorArr.b==0) and not self.m_pBlockArr[i][j].m_bTouch then
                --         print("blockMove-----------")
                --         print("i--------------->",i)
                --         print("j--------------->",j)
                --         print(self.m_pBlockArr[i][j]:getPositionY())
                --         if self.m_pBlockArr[i][j]:getPositionY()<=160 then
                --             print("dfsdfdsfsdfsdfsdfsdfsdfsd")
                --             self:cancelSchedule3()
                --         end
                --     end
                -- end
                --self.m_pBlockArr[i][j]:moveDownAndCleanUp(self.m_nRow)
            end   
        end
    end

    if self.m_nFlag ~= 3 then
        if self.m_pEndLineBlock then
            self.m_pEndLineBlock:moveDownAndCleanUp(self.m_nRow)
        end
    end
end

function CDLayerTable_CBK:moveDown()
    if self.m_nFlag == 1 then
        local compareTouchNum = 0
        if self.m_nIndex == 5 then
            compareTouchNum = self.m_nNeedTouch +2
        else
             compareTouchNum = self.m_nNeedTouch +1
        end

        if self.m_nTouchNum < self.m_nNeedTouch  then
            if self.m_nCurNomalIndex < compareTouchNum then
                self:addNormalLineBlocks(self.m_nRow,self.m_nRow)
            else
                
                if not self.m_pEndLineBlock then
                    self.m_pEndLineBlock = CDBlockItem:createdBlockItem()
                    self.m_pEndLineBlock:createBlock(cc.c3b(67,205,128),ScreenSize)
                    self.m_pEndLineBlock:setPosition(cc.p(0,ScreenSize.height))
                    self.m_pEndLineBlock:SetLineIndex(self.m_nRow)
                    self.m_pNewLayerRoot:addChild(self.m_pEndLineBlock)
                end

            end
        else
            local function showEndBlock()
                self.m_bIsWin = true
                self:addEndLineBlock()
            end 
           
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(showEndBlock)))
            self:blockMove()

            if self.m_nIndex == 5 then
                self:blockMove()
            end

            self:stopTimer()
        end
    else
        
        if self.m_nTouchFaCai < 2 then 
            self:addNormalLineBlocks(self.m_nRow,self.m_nRow)
           
        else
            self:addNormalLineBlocks(self.m_nRow,self.m_nRow)
            self:stopTimer()
            self:recordTime()

            local function showWinLastView()
                self.m_bIsWin = true
                self:showLastView()
            end 

            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(showWinLastView)))

        end
    end

    self:blockMove()
end

------------------------------------------------------------------------------
function CDLayerTable_CBK:showSound()

    local music = g_pGlobalManagement:isEnableMusic()
    g_pGlobalManagement:enableMusic( not music)

    self.m_pSoundOpen:setVisible(music)
    self.m_pSoundClose:setVisible(not music)
    dtPlaySound( DEF_SOUND_TOUCH)
end

function CDLayerTable_CBK:showMusic()

    local sound = g_pGlobalManagement:isEnableSound()
    g_pGlobalManagement:enableSound( not sound)

    self.m_pMusicOpen:setVisible(sound)
    self.m_pMusicClose:setVisible(not sound)
    dtPlaySound( DEF_SOUND_TOUCH)
end


--===============================界面函数绑定===============================
----------------------------------------------------------------------------
-- 设置
function CDLayerTable_CBK:onSetting()
    cclog( "CDLayerTable_CBK:onSetting")

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

    if not self.m_pSettingNode:isVisible() then
        self.m_pSettingNode:setVisible(true)
    end
end

function CDLayerTable_CBK:onCloseSetting()
    if self.m_pSettingNode:isVisible() then
        self.m_pSettingNode:setVisible(false)
        self.m_bIsTouchSetting = false
    end
end

--返回大厅
function CDLayerTable_CBK:onGoToHall()
    if self.m_pNodeLastView:isVisible() or self.m_pSettingNode:isVisible() then
        self.m_pNodeLastView:setVisible(false)
        g_pSceneTable:gotoSceneHall()
        dtPlaySound(DEF_SOUND_TOUCH)
    end 
end

--重新开始
function CDLayerTable_CBK:onRestart()
    if self.m_pNodeLastView:isVisible() then
        self.m_pNodeLastView:setVisible(false)
        self.m_bIsAgainGame = true
        self:clearData()

        self:createUserInterface(self.m_nFlag)
    end 
end
------------------------------------------------------

function CDLayerTable_CBK:onOpenSound()
    if self.m_pSettingNode:isVisible() and self.m_pSoundOpen:isVisible() then
       self:showSound()
    end
end

function CDLayerTable_CBK:onCloseSound()
    if self.m_pSettingNode:isVisible() and self.m_pSoundClose:isVisible() then
       self:showSound()
    end
end

function CDLayerTable_CBK:onOpenSoundEffect()
    if self.m_pSettingNode:isVisible() and self.m_pMusicOpen:isVisible() then
        self:showMusic()
    end
end

function CDLayerTable_CBK:onCloseSoundEffect()
    if self.m_pSettingNode:isVisible() and self.m_pMusicClose:isVisible() then
        self:showMusic()
    end
end

----------------------------------------------------------------------------
-- ccb处理
-- 变量绑定
function CDLayerTable_CBK:onAssignCCBMemberVariable(loader)
    cclog("CDLayerTable_CBK::onAssignCCBMemberVariable")

    -- 灯光
    self.m_pLighting     = loader["pic_alpha"]

    -- 底部的状态信息
    self.m_pGroupBar     = loader["group_bar"]
    self.m_pButSetting   = loader["but_setting"]
    self.m_pSelfInfo     = loader["self_info"]
    self.m_pTableInfo    = loader["table_info"]

    self.m_pNewLayerRoot    = loader["new_layer"]

    -- 电池
    self.m_pIcoPower        = loader["power"]
    self.m_pNewEffLayer     = loader["newEfflayer"]

    self.m_pSettingNode     = loader["setting_Node"]

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

    self.m_pBtnGoToHall   = loader["button_gotoHall"]
    self.m_pBtnRestart    = loader["button_restart"]

end

----------------------------------------------------------------------------
-- ccb处理
-- 函数绑定
function CDLayerTable_CBK:onResolveCCBCCControlSelector(loader)
    cclog("CDLayerTable_CBK::onResolveCCBCCControlSelector")
    
    -- 下方玩家功能区按钮
    loader["onSetting"]     = function() self:onSetting()  end         
       
    loader["onGoToHall"]    = function() self:onGoToHall() end

    loader["onRestart"]     = function() self:onRestart()  end

    loader["onSetting"]     = function() self:onSetting()  end
  
    loader["onCloseSetting"] =function() self:onCloseSetting() end


    loader["onOpenSound"] =  function () self:onOpenSound() end
  
    loader["onCloseSound"] = function () self:onCloseSound() end
 
    loader["onOpenSoundEffect"] = function () self:onOpenSoundEffect() end

    loader["onCloseSoundEffect"] = function () self:onCloseSoundEffect() end
    
end

----------------------------------------------------------------------------
-- create
function CDLayerTable_CBK.createCDLayerTable_CBK(pParent)
    cclog("CDLayerTable_CBK::createCDLayerTable_xtlzddz")
    if not pParent then
        return nil
    end
    local layer = CDLayerTable_CBK.new()
    layer:init()
    local loader = layer.m_ccbLoader
    layer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad("CDLayerTable_CBK.ccbi",proxy,loader)
    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild(node)
    pParent:addChild(layer)
    return layer
end