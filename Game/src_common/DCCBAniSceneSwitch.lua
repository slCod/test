--[[
/******************************************************
//Project:      ProjectMSS
//Moudle:       CDCCBAniSceneSwitch
//File Name:    DCCBAniSceneSwitch.lua
//Author:       GostYe
//Start Data:   2014.02.2
//Language:     XCode 4.5
//Target:       IOS, Android

MSS－CCB文件的场景切换动画对象类
继承CDCCBAniObject
特殊处理在动画播放时锁定全局Touch不可，动画播放完成后再开启Touch允许

******************************************************/
]]

require( REQUIRE_PATH.."DCCBAniObject")
--require "CCBReaderLoad"


-- 场景切换动画的目的类型
SCENESWITCH_TYPE_ENTER = 0     --进入场景的动画
SCENESWITCH_TYPE_ABORT = 1     --离开场景的动画


-----------------------------------------
-- 类定义
CDCCBAniSceneSwitch = class("CDCCBAniSceneSwitch", CDCCBAniObject)

CDCCBAniSceneSwitch.__index = CDCCBAniSceneSwitch

-- 构造函数
function CDCCBAniSceneSwitch:ctor()
    cclog("CDCCBAniSceneSwitch::ctor")
    CDCCBAniSceneSwitch.super.ctor(self)
    CDCCBAniSceneSwitch.initialMember(self)
    
    local function onNodeEvent(event)
        if "exit" == event then
            CDCCBAniSceneSwitch.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function CDCCBAniSceneSwitch:onExit()
    cclog("CDCCBAniSceneSwitch::onExit")
    self:stopAllActions()
    --模拟析构自身
    CDCCBAniSceneSwitch.releaseMember(self)
    self:unregisterScriptHandler()
end


-----------------------------------------
-- 成员变量定义

--[[
CDCCBAniSceneSwitch.m_eType = SCENESWITCH_TYPE_ENTER    --场景切换动画目标类型
]]


-----------------------------------------
-- 初始化
function CDCCBAniSceneSwitch:initialMember()
    cclog("CDCCBAniSceneSwitch::initialMember")
    
    self.m_eType = SCENESWITCH_TYPE_ENTER
end

function CDCCBAniSceneSwitch:releaseMember()
    cclog("CDCCBAniSceneSwitch::releaseMember")
    --模拟析构父类
    CDCCBAniSceneSwitch.super.releaseMember(self)
end

-- 初始化
function CDCCBAniSceneSwitch:init()
    cclog("CDCCBAniSceneSwitch::init")
    CDCCBAniObject.init(self);
    return true
end


-----------------------------------------
-- 功能函数

-- 设置/获取当前动画属于场景切换的哪个类型
function CDCCBAniSceneSwitch:setType( eType)
    self.m_eType = eType
end
function CDCCBAniSceneSwitch:getType()
    return self.m_eType
end

-- 播放动画根据索引号，或者动画名
function CDCCBAniSceneSwitch:runAnimations(nSeqId, fTweenDuration)
    cclog("CDCCBAniSceneSwitch::runAnimations seqid")
    CDGlobalMgr:sharedGlobalMgr():setOpenTouch( false)
    CDCCBAniObject.runAnimations( self, nSeqId, fTweenDuration)
end

function CDCCBAniSceneSwitch:runAnimationsByName( pName)
    cclog("CDCCBAniObject::runAnimations name")
    CDGlobalMgr:sharedGlobalMgr():setOpenTouch( false)
    CDCCBAniObject.runAnimationsByName( self, pName)
end

-- 动画播放完的回调处理
function CDCCBAniSceneSwitch:completedAnimationSequenceNamed(name)
    cclog("CDCCBAniSceneSwitch::completedAnimationSequenceNamed")
    CDGlobalMgr:sharedGlobalMgr():setOpenTouch( true)
    CDCCBAniObject.completedAnimationSequenceNamed( self, name)
end


-----------------------------------------
-- ccb处理

function CDCCBAniSceneSwitch:onAssignCCBMemberVariable(loader)
    cclog("CDCCBAniSceneSwitch::onAssignCCBMemberVariable")
    -- 基类注册
    self:assignCCBMemberVariable(loader)
end


-----------------------------------------
-- create

--[[
/**
* 创建CCB文件的场景切换动画对象
*  @param: pParent         父节点对象
*  @param: pCCBFileName    CCBI文件
*  @param: pPos            放置的位置(假如空那么布改变位置)
*  @param: nAniIdx         动作播放索引假如-1那么不播放
*  @param: pCallFunc       回调处理
*/
]]
function CDCCBAniSceneSwitch.createCCBAniSceneSwitch(pParent, pCCBFileName, pPos, nAniIdx, pCallFunc)
    cclog("CDCCBAniSceneSwitch::createCCBAniSceneSwitch")
    if not pParent then
        return nil
    end
    --ccPushTextureParameter( gl.LINEAR, gl.LINEAR) --切换贴图过滤参数
    local layer = CDCCBAniSceneSwitch.new()
    layer:init()
    local loader = layer.m_ccbLoader
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad(pCCBFileName,proxy,loader)
    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild(node)
    
    pParent:addChild(layer)
    
    if pPos then
        layer:setPosition( pPos)
    end
    
    if nAniIdx and nAniIdx >= 0 then
        layer:runAnimations( nAniIdx, 0)
    end
    
    if pCallFunc then
        layer:setCallFunc( pCallFunc)
    end
    
    --ccPopTextureParameter()
    return layer
end