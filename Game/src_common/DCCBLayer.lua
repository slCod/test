--[[
/******************************************************
//Project:      ProjectMSS
//Moudle:       CDCCBLayer
//File Name:    DCCBLayer.lua
//Author:       Tuanzi
//Start Data:   2015.12.04
//Language:     XCode 6.4
//Target:       IOS, Android

MSS－CCB层基类

******************************************************/
]]

-----------------------------------------
-- 类定义
CDCCBLayer = class("CDCCBLayer",
    function()
        return cc.CustomLayer:create()
    end
)

CDCCBLayer.__index = CDCCBLayer

-- 构造函数
function CDCCBLayer:ctor()
    --cclog("CDCCBLayer::ctor")
    CDCCBLayer.initialMember(self)
end


-----------------------------------------
-- 成员变量定义

--[[
CDCCBLayer.m_ccbLayer = nil     --ccb界面层
CDCCBLayer.m_ccbLoader = nil    --ccb加载容器
CDCCBLayer.m_bTouch = nil       --是否开启点击处理
CDCCBLayer.m_fTouchMoved = nil  --移动累积
CDCCBLayer.m_pListener = nil    --操作监听
CDCCBLayer.m_pOwner = nil       --所有者弱引用
]]


-----------------------------------------
-- 初始化
function CDCCBLayer:initialMember()
    --cclog("CDCCBLayer::initialMember")
    self.m_ccbLayer = nil
    self.m_ccbLoader = {}
    self.m_bTouch = false
    self.m_fTouchMoved = 0
    self.m_pListener = nil
    self.m_pOwner = nil
end

function CDCCBLayer:releaseMember()
    --cclog("CDCCBLayer::releaseMember")
    if self.m_ccbLayer then
        self.m_ccbLayer:setUserObject()
        self.m_ccbLayer = nil
    end
    self.m_ccbLoader = nil
    self.m_bTouch = nil
    self.m_fTouchMoved = nil
    if self.m_pListener then

        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:removeEventListener(self.m_pListener)
        self.m_pListener = nil
    end
    self.m_pOwner = nil
end

-- 初始化
function CDCCBLayer:init()
    --cclog("CDCCBLayer::init")
end

-- 设置点击标志的开启和关闭
function CDCCBLayer:enableTouch( bEnable)

    self.m_bTouch = bEnable
end

-- 移动累积相关
function CDCCBLayer:resetTouchMoved()

    self.m_fTouchMoved = 0
end

function CDCCBLayer:sumTouchMoved( delta)

    self.m_fTouchMoved = self.m_fTouchMoved + cc.pGetLength(delta)
end

function CDCCBLayer:isTouchMovedOver( distance)
    if distance == nil then distance = DEF_MAX_TOUCH_MOVED end

    if self.m_fTouchMoved >= distance then

        return true
    end
    return false
end

-- 设置获取所有者
function CDCCBLayer:setOwner( pOwner)

    self.m_pOwner = pOwner
end
function CDCCBLayer:getOwner()

    return self.m_pOwner
end
