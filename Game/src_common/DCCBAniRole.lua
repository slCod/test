--[[
/******************************************************
//Project:      ProjectMSS
//Moudle:       CDCCBAniRole
//File Name:    DCCBAniRole.h
//Author:       GostYe
//Start Data:   2014.02.2
//Language:     XCode 4.5
//Target:       IOS, Android

MSS－CCB文件的动画对象类扩展
继承CDCCBAniObjectEX增加了子节点容器，要求此对象的CCB文件中
可以有vessel绑定的节点作为子节点容器，允许使用此类的时候添加子节点

******************************************************/
]]

require( REQUIRE_PATH.."DCCBAniObjectEX")
--require "CCBReaderLoad"

-----------------------------------------
-- 类定义
CDCCBAniRole = class("CDCCBAniRole", CDCCBAniObjectEX)

CDCCBAniRole.__index = CDCCBAniRole

-- 构造函数
function CDCCBAniRole:ctor()
    cclog("CDCCBAniRole::ctor")
    CDCCBAniRole.super.ctor(self)
    CDCCBAniRole.initialMember(self)
    
    local function onNodeEvent(event)
        if "exit" == event then
            CDCCBAniRole.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function CDCCBAniRole:onExit()
    cclog("CDCCBAniRole::onExit")
    self:stopAllActions()
    --模拟析构自身
    CDCCBAniRole.releaseMember(self)
    self:unregisterScriptHandler()
end


-----------------------------------------
-- 成员变量定义
CDCCBAniRole.m_pChild = nil       --子节点
CDCCBAniRole.m_pChildVessel = nil --子节点容器
CDCCBAniRole.m_pChildNode = nil   --子节点


-----------------------------------------
-- 初始化
function CDCCBAniRole:initialMember()
    cclog("CDCCBAniRole::initialMember")
    
    self.m_pChild = nil
    self.m_pChildVessel = nil
end

function CDCCBAniRole:releaseMember()
    cclog("CDCCBAniRole::releaseMember")
    --模拟析构父类
    CDCCBAniRole.super.releaseMember(self)

    self.m_pChildVessel = nil
    
    if DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end
    CDCCBAniRole.initialMember(self)
end

-- 初始化
function CDCCBAniRole:init()
    cclog("CDCCBAniRole::init")
    CDCCBAniObjectEX.init(self);
    return true
end


-----------------------------------------
-- 功能函数

-- 添加子节点
function CDCCBAniRole:addNodeChild( pChild)

    if not self.m_pChildVessel or not pChild then
        return false;
    end
    self.m_pChildVessel:addChild( pChild);
    return true;
end

-- 获取子节点
function CDCCBAniRole:getNodeChild()
    return self.m_pChild;
end
-- 获取子节点容器
function CDCCBAniRole:getChildVessel()
    return self.m_pChildVessel;
end


-----------------------------------------
-- ccb处理

if DEF_CCB_TABLE then
CDCCBAniRoleLoader = CDCCBAniRoleLoader or {}
end--ccb["CDCCBAniRole"] = CDCCBAniRoleLoader

function CDCCBAniRole:onAssignCCBMemberVariable(loader)
    cclog("CDCCBAniRole::onAssignCCBMemberVariable")
    if nil ~= loader["vessel"] then
        self.m_pChildVessel = loader["vessel"]
    end
    -- 基类注册
    self:assignCCBMemberVariable(loader)
end


-----------------------------------------
-- create

--[[
 /**
 * 创建CCB动画对象
 *  @param: pParent         父节点对象
 *  @param: pCCBFileName    CCBI文件
 *  @param: pPos            放置的位置(假如空那么布改变位置)
 *  @param: nAniIdx         动作播放索引假如-1那么不播放
 *  @param: nZOrder         指定Z轴假如-1那么不特别指定
 */
]]
function CDCCBAniRole.createCCBAniRole(pParent, pCCBFileName, pPos, nAniIdx, nZOrder)
    cclog("CDCCBAniRole::createCCBAniRole")
    if not pParent then
        return nil
    end
    ccPushTextureParameter( gl.LINEAR, gl.LINEAR);
    
    local layer = CDCCBAniRole.new()
    layer:init()
    local loader = layer.m_ccbLoader
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad(pCCBFileName,proxy,loader,"CCNode")
    layer:ignoreAnchorPointForPosition(node:isIgnoreAnchorPointForPosition())
    layer:setAnchorPoint(node:getAnchorPoint())
    layer:setContentSize(node:getContentSize())
    if not node:isIgnoreAnchorPointForPosition() then
        node:setPosition(cc.p(node:getContentSize().width*node:getAnchorPoint().x, node:getContentSize().height*node:getAnchorPoint().y))
    end
    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild(node)
    
    if nZOrder and nZOrder >= 0 then    
        pParent:addChild( layer, nZOrder)
    else
        pParent:addChild(layer)
    end

    if pPos then
        layer:setPosition( pPos)
    end
    
    if nAniIdx and nAniIdx >= 0 then
        layer:runAnimations( nAniIdx, 0)
    end
    
    ccPopTextureParameter();
    return layer
end