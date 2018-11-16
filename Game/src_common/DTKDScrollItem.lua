--[[
/******************************************************
//Project:      ProjectMSS
//Moudle:       CDTKDScrollItem
//File Name:    DTKDScrollItem.h
//Author:       GostYe
//Start Data:   2014.11.11
//Language:     XCode 4.5
//Target:       IOS, Android

MSS－滚动列表节点基类

******************************************************/
]]

-----------------------------------------
-- 类定义
CDTKDScrollItem = class("CDTKDScrollItem",
    function()
        return cc.CustomLayer:create()
    end
)

CDTKDScrollItem.__index = CDTKDScrollItem

-- 构造函数
function CDTKDScrollItem:ctor()
    cclog("CDTKDScrollItem::ctor")
    CDTKDScrollItem.initialMember(self)
end

-- 析构函数 暂时不会用到
function CDTKDScrollItem:dctor()
    cclog("CDTKDScrollItem::dctor")
    self:releaseMember()
    self:unregisterScriptHandler()
end

-----------------------------------------
-- 成员变量定义
CDTKDScrollItem.m_ccbLayer = nil  --ccb界面层
CDTKDScrollItem.m_ccbLoader = nil    --ccb加载容器

-----------------------------------------
-- 初始化
function CDTKDScrollItem:initialMember()
    cclog("CDTKDScrollItem::initialMember")
    self.m_ccbLayer = nil
    self.m_ccbLoader = {}
end

function CDTKDScrollItem:releaseMember()
    cclog("CDTKDScrollItem::releaseMember")
    if self.m_ccbLayer then
        self.m_ccbLayer:setUserObject()
        self.m_ccbLayer = nil
    end
    self.m_ccbLoader = nil
end

-- 初始化
function CDTKDScrollItem:init()
    cclog("CDTKDScrollItem::init")
    return true
end


-----------------------------------------
-- 功能函数
