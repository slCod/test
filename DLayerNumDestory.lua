--[[
/******************************************************
数字消消乐界面代码

******************************************************/
]]

require( REQUIRE_PATH.."DDefine")
require( REQUIRE_PATH.."DCCBLayer")
require( REQUIRE_PATH.."DTKDScene")
require( REQUIRE_PATH.."_tkd_tbmenu")
require( REQUIRE_PATH.."numDestory_math")
require( REQUIRE_PATH.."DItemNum")
require( REQUIRE_PATH.."GlobalData_Num")

require( REQUIRE_PATH.."mahjong_numDestroy")

local casinoclient = require("script.client.casinoclient")
local platform_help = require("platform_help")

DEF_SOUND_NUMGAME_CLICK     = ""..DEF_TKD_SOUND     -- 点击声音
DEF_SOUND_NUMGAME_DESTORY   = ""..DEF_TKD_SOUND     -- 消除的声音
DEF_SOUND_NUMGAME_SKILL     = ""..DEF_TKD_SOUND     -- 使用技能的声音
DEF_SOUND_NUMGAME_END       = ""..DEF_TKD_SOUND     -- 结算的声音

-----------------------------------------
-- 类定义
CDLayerNumDestory = class("CDLayerNumDestory", CDCCBLayer)
CDLayerNumDestory.__index = CDLayerNumDestory
CDLayerNumDestory.name = "CDLayerNumDestory"

-- 构造函数
function CDLayerNumDestory:ctor()
    cclog("CDLayerNumDestory::ctor")
    CDLayerNumDestory.super.ctor(self)
    CDLayerNumDestory.initialMember(self)
    --reg enter and exit
    local function onNodeEvent(event)
        if "enter" == event then
            CDLayerNumDestory.onEnter(self)
        elseif "exit" == event then
            CDLayerNumDestory.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end



function CDLayerNumDestory:onEnter()
    cclog("CDLayerNumDestory::onEnter")

    -- 网络事件
    local   listeners = {

        
    }
    casinoclient.getInstance():addEventListeners(self,listeners)

end

function CDLayerNumDestory:onExit()
    cclog("CDLayerNumDestory::onExit")

    self:stopHeartLoop()
    self:stopAllActions()
    casinoclient.getInstance():removeListenerAllEvents(self)
    CDLayerNumDestory.releaseMember(self)
    self:unregisterScriptHandler()
end

-----------------------------------------
-- 初始化
function CDLayerNumDestory:initialMember()
    cclog("CDLayerNumDestory::initialMember")
    
    self.m_pGameNum_GData = GlobalData_Num.create()  
    self.m_pListener    = nil           -- 监听对象
    self.m_pNumGameMath = nil           -- 核心算法
    self.m_bCanTouch    = false         -- 是否可以点击

    self.m_pNumNode     = nil           -- item放置层
    self.m_pNumGameEff  = nil           -- 特效层

    self.m_pBtnSetting  = nil           -- 设置按钮
    
    self.m_pTxtMaxScore = nil           -- 历史最高得分
    self.m_pTxtCurScore = nil           -- 当前得分

    self.m_pBtnSkillNode= nil           -- 技能按钮组
    self.m_pBtnSkill    = nil           -- 技能按钮
    self.m_nCostNum     = 1000          -- 花费的资源数量
    self.m_pIconCost    = nil           -- 花费的资源图片
    self.m_pTxtCose     = nil           -- 花费的数量

    self.m_pChangeNode  = nil           -- 次数多节点
    self.m_pChangeArr   = {}            -- 能量的次数
    for i = 1,DEF_NUMGAME_MAXCHANGE do
        self.m_pChangeArr[i] = nil
    end

    self.m_pMenuNode        = nil         -- 菜单栏
    self.m_pBtnReturnGame   = nil         -- 返回游戏按钮
    self.m_pBtnReStartGame  = nil         -- 重新开始游戏按钮
    self.m_pBtnQuitGame     = nil         -- 退出游戏按钮
    self.m_pBtnOpenYY       = nil         -- 打开音乐按钮
    self.m_pBtnCloseYY      = nil         -- 关闭音乐按钮
    self.m_pBtnOpenYX       = nil         -- 打开音效按钮
    self.m_pBtnColseYX      = nil         -- 关闭音效按钮

    self.m_nSkillLeftTime   = 0           -- 技能剩余的时间
    self.m_nMaxItemCount    = 0
    self.m_sItemArr         = {}          -- 管理item数组
    self.m_nCurScore        = 0           -- 当前得分

    self.m_pOverNode        = nil 
    self.m_pTxtEndScore     = nil


end

function CDLayerNumDestory:releaseMember()
    cclog("CDLayerNumDestory::releaseMember")


    --模拟析构父类
    CDLayerNumDestory.super.releaseMember(self)
    if  DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end

    if self.m_pListener then

        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:removeEventListener(self.m_pListener)
        self.m_pListener = nil
    end
end

----------------------------------------------------------------------------
-- 创建用户界面
function CDLayerNumDestory:createUserInterface()
    cclog("CDLayerNumDestory::createUserInterface")

    self.m_pBtnSetting:setVisible(false)
    self.m_pMenuNode:setVisible(false)
    self.m_pOverNode:setVisible(false)
    self.m_pTxtCose:setString("点我!")
    self.m_pBtnSkillNode:setVisible(false)
    -- 预创建牌
    self.m_pNumGameMath = CDGameNumDestory.create()
    self:onCreateClipArea()
    self.m_nMaxItemCount = self.m_pNumGameMath:getMaxCount()
    for i = 1,self.m_nMaxItemCount do

        --local curItemNum = CDItemNum.createCDItemNum(self.clip)
        local curItemNum = CDMahjong.createCDMahjong(self.clip)
        curItemNum:initMahjongWithFile("my_b_11.png")
        curItemNum:setMahjongScale(0.62)
        self.m_pNumGameMath:setGroupItem(i,curItemNum,false)
        table.insert(self.m_sItemArr,curItemNum)
        
    end

    self.m_pTxtMaxScore:setString(self.m_pGameNum_GData:getGameNumMaxScore())
    self.m_pTxtCurScore:setString(0)
    self:runAction( cc.Sequence:create( cc.DelayTime:create( 1), cc.CallFunc:create( CDLayerNumDestory.onStartPlay)))

end

----------------------------------------------------------------------------
-- 初始化桌子
-- 删除所有打出以及手上的牌，并且清除所有玩家桌面
function CDLayerNumDestory:initTable()
    cclog("CDLayerNumDestory::initTable")


end

----------------------------------------------------------------------------
-- 初始化
function CDLayerNumDestory:init()
    cclog("CDLayerNumDestory::init")
    
    -- touch事件
    local function onTouchBegan(touch, event)
        cclog("CDLayerNumDestory:onTouchBegan")
        if  not self.m_bCanTouch or self.m_pMenuNode:isVisible() or self.m_pOverNode:isVisible() then
            return
        end
        return true
    end

    local function onTouchMoved(touch, event)
        cclog("CDLayerNumDestory:onTouchMoved")
        if  not self.m_bCanTouch or self.m_pMenuNode:isVisible() or self.m_pOverNode:isVisible() then
            return
        end
    end

    local function onTouchEnded(touch, event)
        cclog("CDLayerNumDestory:onTouchEnded")
        if  not self.m_bCanTouch or self.m_pMenuNode:isVisible() or self.m_pOverNode:isVisible() then
            return
        end

        local point = touch:getLocation()
        self:touchItemNumFromPoint(point)
    end

    self.m_pListener = cc.EventListenerTouchOneByOne:create()
    self.m_pListener:setSwallowTouches(true)
    self.m_pListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.m_pListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.m_pListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pListener, self)
end
----------------------------------------------------------------------------
-- 根据指定的坐标点选择牌
-- 参数: 坐标点
function CDLayerNumDestory:touchItemNumFromPoint( point)
    cclog("CDLayerNumDestory::touchItemNumFromPoint")

    for i = 1, self.m_nMaxItemCount do
        if  self.m_sItemArr[i] and self.m_sItemArr[i]:isVisible() and 
            self.m_sItemArr[i]:touchInFromPoint( point) then

            local touch_v,touch_h = self.m_sItemArr[i]:getTargetIndex()

            print("touch_v-------->",touch_v)

            print("touch_h-------->",touch_h)

            if self.m_sItemArr[i]:getShowNum() == 53 then
                local function showLabelText()
                    if not self.m_pColorLayer:isVisible() then
                        self.m_pColorLayer:setVisible(true)
                        self.m_pColorLayer:setPosition(cc.p(self.m_sItemArr[i]:getPositionX()-130,self.m_sItemArr[i]:getPositionY()+20))
                    end
                end

                local function notShowLabelText()
                    if self.m_pColorLayer:isVisible() then
                        self.m_pColorLayer:setVisible(false)
                    end
                end 
                
                if self.m_pColorLayer and not self.m_pColorLayer:isVisible() then
                    self.m_pColorLayer:runAction(cc.Sequence:create(cc.CallFunc:create(showLabelText),cc.DelayTime:create(1.0),cc.CallFunc:create(notShowLabelText)))
                end
               
                return
            end

            self.m_pNumGameMath:onClickItem(touch_h,touch_v,2)

            self.m_pNumGameMath:lessLeftChange()
            self:refreshChangeSprite()
            local destoryArr = self.m_pNumGameMath:checkCanDestory()
            if  TABLE_SIZE(destoryArr) >= 3 then
                self.m_bCanTouch = false
                self.m_pNumGameMath:addLeftChange()
                self:refreshChangeSprite()
                self.m_pNumGameMath:checkDestoryItem(2,destoryArr,touch_h,touch_v)
                local allCount = TABLE_SIZE(self.m_pNumGameMath:getChangeArr())
                local waitTime = 0.01*allCount+0.7
                self:showDestoryScore(self.m_pNumGameMath:getChangeArr())
                self:runAction(cc.Sequence:create( cc.DelayTime:create(waitTime), cc.CallFunc:create( CDLayerNumDestory.moveToPosInGame)))
            end
            -- 结束游戏
            if  self.m_pNumGameMath:checkGameOver() then
                self.m_bCanTouch = false
                self:showEndGameView()
            end

            break
        end
    end

end

function CDLayerNumDestory:onCreateClipArea( ... )
    if  not self.m_pClipArea and not self.clip then
        self.m_pClipArea = cc.DrawNode:create()
        local points = {cc.p(0,0),cc.p(0,440),cc.p(440,440),cc.p(440,0) } 
        self.m_pClipArea:drawPolygon(points,4,cc.c4f(335,255,255,255),2,cc.c4f(255,255,255,255))
        self.clip = cc.ClippingNode:create()
        self.m_pNumNode:addChild(self.clip)
        self.clip:setStencil(self.m_pClipArea)
        self.clip:setAnchorPoint(cc.p(0.5,1))
        self.clip:setPosition(cc.p(0,0))
        self.clip:setContentSize(cc.p(440,440))
    end

    if not self.m_pLabelText and not self.m_pColorLayer then

        self.m_pColorLayer = cc.LayerColor:create(cc.c3b(190,190,190),300,40)

        self.m_pLabelText = cc.LabelTTF:create("0.000","Courier New",24)
        self.m_pLabelText:setColor(cc.c3b(255,0,0))
        self.m_pLabelText:setString("已经是最大了,不能再升级")
        self.m_pLabelText:setVisible(true)
        self.m_pLabelText:setAnchorPoint(cc.p(0,0))
        self.m_pLabelText:setPosition(cc.p(self.m_pColorLayer:getPositionX(),self.m_pColorLayer:getPositionY()))
        self.m_pColorLayer:addChild(self.m_pLabelText)
        self.m_pColorLayer:setVisible(false)
        self.m_pNumNode:addChild(self.m_pColorLayer)
    end
    
end

function CDLayerNumDestory:showDestoryScore( _destoryData )

    local function hideAllNumber()
        
        self.m_pNumGameEff:removeAllChildren()
    end
    local allCount = TABLE_SIZE(_destoryData)
    if  allCount > 0 then
        local showScore = _destoryData[1].num
        self.m_pNumGameEff:removeAllChildren()
        local curIndex = 1
        local function oneByOneDestroy( ... )
            
            local curIndexData = _destoryData[curIndex]
            if  curIndex > allCount or not curIndexData then
                return
            end
            
            curIndexData.item:setBVisible(curIndexData.bvisible)
            local curScore = cc.LabelAtlas:_create( "0", "x_number_ex2.png", 34, 44, string.byte("*"))
            curScore:setAnchorPoint( cc.p( 0.5, 0.5))
            local curPos = dtConverToWorldSpace( curIndexData.item)
            curScore:setPosition(curPos)
            local endPos = cc.p(curScore:getPositionX(),curScore:getPositionY()+10)
            curScore:setString("+"..showScore*10)
            curScore:setScale(0.2)
            curScore:runAction( cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.2, 0.60)), cc.DelayTime:create( 0.1), 
                cc.Spawn:create( cc.MoveTo:create( 0.2, endPos), cc.FadeOut:create( 0.2))))
            self.m_pNumGameEff:addChild(curScore)
            if  curIndex == allCount then
                self.m_pNumGameMath:getChangeItem()
                self.m_pNumNode:stopAllActions()
                self.m_pNumGameEff:runAction( cc.Sequence:create( cc.DelayTime:create( 0.55), cc.CallFunc:create( hideAllNumber)))
            else
                curIndex = curIndex+1
                self.m_pNumNode:runAction( cc.Sequence:create( cc.DelayTime:create(0.01), cc.CallFunc:create( oneByOneDestroy)))
            end
        end
        self.m_pNumNode:stopAllActions()
        self.m_pNumNode:runAction( cc.Sequence:create( cc.DelayTime:create(0.01), cc.CallFunc:create( oneByOneDestroy)))

    end
end

function CDLayerNumDestory:showEndGameView( ... )
    self.m_pOverNode:setVisible(true)
    self.m_pTxtEndScore:setString(self.m_nCurScore)
    self.m_pGameNum_GData:setGameNumMaxScore(self.m_nCurScore)
    self.m_bCanTouch = false
end

function CDLayerNumDestory:moveToPosInGame( _table )

    local curNeedRefreshArr = self.m_pNumGameMath:setGroupItemAndChange()

    local function canPlayGame(  )

        self.m_bCanTouch = true

        local destoryArr = self.m_pNumGameMath:checkCanDestory()
        if  TABLE_SIZE(destoryArr) >= 3 then
            self.m_bCanTouch = false
            self.m_pNumGameMath:addLeftChange()
            self:refreshChangeSprite()
            self.m_pNumGameMath:checkDestoryItem(2,destoryArr)
            local allCount = TABLE_SIZE(self.m_pNumGameMath:getChangeArr())
            local waitTime = 0.01*allCount+0.7
            self:showDestoryScore(self.m_pNumGameMath:getChangeArr())
            self:runAction(cc.Sequence:create( cc.DelayTime:create(waitTime), cc.CallFunc:create( CDLayerNumDestory.moveToPosInGame)))
            
        end
    end

    self.m_nCurScore = self.m_nCurScore+self.m_pNumGameMath:getDestoryScore(curNeedRefreshArr)
    self.m_pGameNum_GData:setGameNumMaxScore(self.m_nCurScore)
    self.m_pTxtCurScore:setString(self.m_nCurScore)

    if  curNeedRefreshArr and TABLE_SIZE(curNeedRefreshArr)>0 then

        for i,v in ipairs(curNeedRefreshArr) do
            if  v and v.item then
                self.m_pNumGameMath:resetGroupItem(v,true)
                v.item:moveToPos(true,0.5)
            end
        end
    end

    self.m_pNumNode:runAction(cc.Sequence:create( cc.DelayTime:create( 1.5), cc.CallFunc:create( canPlayGame)))
end

function CDLayerNumDestory:refreshChangeSprite( ... )
    local minCount = DEF_NUMGAME_MAXCHANGE - self.m_pNumGameMath:getLeftChange()
    for i = 1,minCount do
        if  self.m_pChangeArr[i] then
            self.m_pChangeArr[i]:setVisible(false)
        end
    end
    for i = minCount+1,DEF_NUMGAME_MAXCHANGE do
        if  self.m_pChangeArr[i] then
            self.m_pChangeArr[i]:setVisible(true)
        end
    end
end

function CDLayerNumDestory:refreshSkillLeftTime( ... )
    if  self.m_nSkillLeftTime > 0 then
        local function refrshLeftTime( ... )
            self.m_nSkillLeftTime = self.m_nSkillLeftTime - 1
            if  self.m_nSkillLeftTime > 0 then
                self.m_pTxtCose:setString(self.m_nSkillLeftTime)
                self.m_pTxtCose:runAction(cc.Sequence:create( cc.DelayTime:create( 1), cc.CallFunc:create( refrshLeftTime)))
            else
                self.m_pTxtCose:stopAllActions()
                self.m_nSkillLeftTime = 0
                self.m_pTxtCose:setString("点我!")
            end
        end
        self.m_pTxtCose:stopAllActions()
        self.m_pTxtCose:runAction(cc.Sequence:create( cc.DelayTime:create( 1), cc.CallFunc:create( refrshLeftTime)))
        
    end
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
function CDLayerNumDestory:onStartPlay( ... )
    local function canPlayGame(  )
        self.m_pBtnSetting:setVisible(true)
        self.m_pBtnSkillNode:setVisible(true)
        if  self.m_pMenuNode:isVisible() then
            self.m_pMenuNode:setVisible(false)
        end
        self.m_bCanTouch = true
    end

    self.m_pNumGameMath:onResetItemPos()

    for i = self.m_nMaxItemCount,1,-1 do
        self.m_sItemArr[i]:moveToPos(true,0.5)
    end

    self.m_pNumNode:runAction(cc.Sequence:create( cc.DelayTime:create( 1.5), cc.CallFunc:create( canPlayGame)))
end
-- 添加能量
function CDLayerNumDestory:onAddChange( ... )
    if  not self.m_bCanTouch or self.m_pMenuNode:isVisible() or self.m_pOverNode:isVisible() then
        return
    end
    if  self.m_nSkillLeftTime == 0 then
        if  self.m_pNumGameMath:getLeftChange() >= DEF_NUMGAME_MAXCHANGE then
            dtAddMessageToScene( self, "能量已满，不需要添加哦!")
        else
            self.m_nSkillLeftTime = 300
            self.m_pTxtCose:setString(self.m_nSkillLeftTime)
            self:refreshSkillLeftTime()
            self.m_pNumGameMath:addLeftChange()
            self:refreshChangeSprite()
        end
    else
        dtAddMessageToScene( self, "时间还未回复,请稍等!")
    end
end

-- 设置
function CDLayerNumDestory:onSetting()
    cclog( "CDLayerNumDestory:onSetting")

    if  self.m_pMenuNode:isVisible() or self.m_pOverNode:isVisible() then

        return
    end

    self.m_pBtnOpenYY:setVisible(not g_pGlobalManagement:isEnableMusic())
    self.m_pBtnCloseYY:setVisible(g_pGlobalManagement:isEnableMusic())
    self.m_pBtnOpenYX:setVisible(not g_pGlobalManagement:isEnableSound())
    self.m_pBtnColseYX:setVisible(g_pGlobalManagement:isEnableSound())

    self.m_pMenuNode:setVisible(true)

    self.m_bCanTouch = false
  
end

-- 返回游戏
function CDLayerNumDestory:onReturnGame( ... )

    if  self.m_pOverNode:isVisible() then
        return
    end

    if  self.m_pMenuNode:isVisible() then
        self.m_pMenuNode:setVisible(false)
    end  
    self.m_bCanTouch = true
end

-- 重新开始
function CDLayerNumDestory:onRestartGame( ... )
    if  self.m_pOverNode:isVisible() then
        return
    end
    self.m_pBtnSetting:setVisible(false)
    self.m_pMenuNode:setVisible(false)
    self.m_pOverNode:setVisible(false)
    self.m_pBtnSkillNode:setVisible(false)
    self.m_nCurScore = 0
    self.m_pTxtCurScore:setString(0)
    self.m_pTxtMaxScore:setString(self.m_pGameNum_GData:getGameNumMaxScore())
    self.m_pNumGameMath:resetLeftChange()
    self:refreshChangeSprite()
    self:onStartPlay()

end
-- 退出桌子
function CDLayerNumDestory:onQuitGame( ... )
    if  self.m_pOverNode:isVisible() then
        return
    end
    g_pSceneTable:gotoSceneHall()
    dtPlaySound( DEF_SOUND_TOUCH)
end
-- 打开音乐
function CDLayerNumDestory:onOpenYY( ... )
    if  self.m_pOverNode:isVisible() then
        return
    end
    local music = g_pGlobalManagement:isEnableMusic()
    g_pGlobalManagement:enableMusic( not music)

    self.m_pBtnCloseYY:setVisible(true)
    self.m_pBtnOpenYY:setVisible(false)

    dtPlaySound( DEF_SOUND_TOUCH)
end
-- 关闭音乐
function CDLayerNumDestory:onCloseYY( ... )
    if  self.m_pOverNode:isVisible() then
        return
    end
    local music = g_pGlobalManagement:isEnableMusic()
    g_pGlobalManagement:enableMusic( not music)

    self.m_pBtnCloseYY:setVisible(false)
    self.m_pBtnOpenYY:setVisible(true)

    dtPlaySound( DEF_SOUND_TOUCH)
end
-- 打开音效
function CDLayerNumDestory:onOpenYX( ... )
    if  self.m_pOverNode:isVisible() then
        return
    end
    local bSound = g_pGlobalManagement:isEnableSound()
    g_pGlobalManagement:enableSound( not bSound)

    self.m_pBtnCloseYX:setVisible(true)
    self.m_pBtnOpenYX:setVisible(false)

    dtPlaySound( DEF_SOUND_TOUCH)
end
--关闭音效
function CDLayerNumDestory:onCloseYX( ... )
    if  self.m_pOverNode:isVisible() then
        return
    end
    local bSound = g_pGlobalManagement:isEnableSound()
    g_pGlobalManagement:enableSound( not bSound)

    self.m_pBtnCloseYX:setVisible(false)
    self.m_pBtnOpenYX:setVisible(true)

    dtPlaySound( DEF_SOUND_TOUCH)
end

function CDLayerNumDestory:onRestartGameEndView( ... )
    self.m_pOverNode:setVisible(false)

    self.m_nCurScore = 0
    self.m_pTxtCurScore:setString(0)
    self.m_pTxtMaxScore:setString(self.m_pGameNum_GData:getGameNumMaxScore())
    self.m_pNumGameMath:resetLeftChange()
    self:refreshChangeSprite()
    self:onStartPlay()
end

function CDLayerNumDestory:onQuitGameEndView( ... )
    g_pSceneTable:gotoSceneHall()
    dtPlaySound( DEF_SOUND_TOUCH)
end
-- 循环发送心跳包
function CDLayerNumDestory:createHeartbeatLoop( ... )
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

function CDLayerNumDestory:stopHeartLoop( ... )
    if  self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)   
        self.schedulerID=nil
    end
end

----------------------------------------------------------------------------
-- ccb处理
-- 变量绑定
function CDLayerNumDestory:onAssignCCBMemberVariable(loader)
    cclog("CDLayerNumDestory::onAssignCCBMemberVariable")

    self.m_pNumNode     = loader["numNode"]        
    self.m_pNumGameEff  = loader["new_layer"]        
    self.m_pBtnSetting  = loader["btn_setting"]        
    self.m_pTxtMaxScore = loader["maxScoreTxt"]        
    self.m_pTxtCurScore = loader["curScoreTxt"]        
    self.m_pBtnSkillNode= loader["skillBtnNode"]        
    self.m_pBtnSkill    = loader["skillbtn"]        
    self.m_pIconCost    = loader["costicon"]        
    self.m_pTxtCose     = loader["costTxt"]  

    self.m_pChangeNode  = loader["changenode"]    
    for i = 1,DEF_NUMGAME_MAXCHANGE do
        self.m_pChangeArr[i] = loader["icon_change"..i] 
    end

    self.m_pMenuNode        = loader["menuNode"]      
    self.m_pBtnReturnGame   = loader["btn_returngame"]      
    self.m_pBtnReStartGame  = loader["btn_restartgame"]      
    self.m_pBtnQuitGame     = loader["btn_quitgame"]      
    self.m_pBtnOpenYY       = loader["btn_openYX"]      
    self.m_pBtnCloseYY      = loader["btn_closeYY"]      
    self.m_pBtnOpenYX       = loader["btn_openYX"]      
    self.m_pBtnColseYX      = loader["btn_closeYX"]  

    self.m_pOverNode        = loader["overNode"]
    self.m_pTxtEndScore     = loader["endMaxScore"]    

end

----------------------------------------------------------------------------
-- ccb处理
-- 函数绑定
function CDLayerNumDestory:onResolveCCBCCControlSelector(loader)
    cclog("CDLayerNumDestory::onResolveCCBCCControlSelector")

    loader["onSetting"] = function() self:onSetting() end
    loader["onAddChange"] = function() self:onAddChange() end
    loader["onReturnGame"] = function() self:onReturnGame() end
    loader["onRestartGame"] = function() self:onRestartGame() end
    loader["onQuitGame"] = function() self:onQuitGame() end
    loader["onOpenYY"] = function() self:onOpenYY() end
    loader["onCloseYY"] = function() self:onCloseYY() end
    loader["onOpenYX"] = function() self:onOpenYX() end
    loader["onCloseYX"] = function() self:onCloseYX() end

    loader["onRestartGameEndView"] = function() self:onRestartGameEndView() end
    loader["onQuitGameEndView"] = function() self:onQuitGameEndView() end

end

----------------------------------------------------------------------------
-- create
function CDLayerNumDestory.createCDLayerNumDestory(pParent)
    cclog("CDLayerNumDestory::createCDLayerNumDestory")
    if not pParent then
        return nil
    end
    local layer = CDLayerNumDestory.new()
    layer:init()
    local loader = layer.m_ccbLoader
    layer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad("CDLayerNumDestory.ccbi",proxy,loader)
    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild(node)
    pParent:addChild(layer)
    return layer
end
