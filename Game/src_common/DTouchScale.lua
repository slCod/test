--[[
/******************************************************
 //Project:      ProjectMSS
 //Moudle:       CDTouchScale
 //File Name:    DTouchScale.h
 //Author:       GostYe
 //Start Data:   2014.02.2
 //Language:     XCode 4.5
 //Target:       IOS, Android
 
 MSS－多点触摸缩放处理
 
 ******************************************************/
]]
-----------------------------------------
-- 类定义
-- 加入了Layer作为基类
CDTouchScale = class("CDTouchScale",
    function()
        return cc.CustomLayer:create()
    end
)

CDTouchScale.__index = CDTouchScale

-- 构造函数
function CDTouchScale:ctor()
    cclog("CDTouchScale::ctor")
    self.m_nTouchPoints = 0;
    self.m_sTouchPoint1 = cc.p( 0, 0);
    self.m_sTouchPoint2 = cc.p( 0, 0);
    self.m_sTouchIDList = {}
end


-----------------------------------------
-- 成员变量定义
CDTouchScale.m_nTouchPoints = 0; --点击数量
CDTouchScale.m_sTouchPoint1 = cc.p(0,0); --点击点1
CDTouchScale.m_sTouchPoint2 = cc.p(0,0); --点击点2
CDTouchScale.m_sTouchIDList = nil; --点击编号类表

-----------------------------------------
-- 初始化
function CDTouchScale:initialMember()
    --cclog("CDTouchScale::initialMember")
end

function CDTouchScale:releaseMember()
    --cclog("CDTouchScale::releaseMember")
end

-- 初始化
function CDTouchScale:init()
    --cclog("CDTouchScale::init")
    return true
end

-----------------------------------------
-- 功能函数

-- 点击相关处理(用于被调用，更新数据)
function CDTouchScale:touchScaleBegan( touch)

    for i = 1, TABLE_SIZE(touch) do
    
        if touch[i]:getId() == 0 then
        
            self.m_sTouchPoint1 = touch[i]:getLocation();
        end
        if touch[i]:getId() == 1 then
        
            self.m_sTouchPoint2 = touch[i]:getLocation();
        end
        if not self:findTouchWithID( touch[i]:getId()) then
        
            self.m_nTouchPoints = self.m_nTouchPoints + 1;
            table.insert(self.m_sTouchIDList, touch[i]:getId());
        end
    end
end

function CDTouchScale:touchScaleMoved( touch)

    for i = 1, TABLE_SIZE(touch) do
    
        if touch[i]:getId() == 0 then
        
            self.m_sTouchPoint1 = touch[i]:getLocation();
        end
        if touch[i]:getId() == 1 then
        
            self.m_sTouchPoint2 = touch[i]:getLocation();
        end
    end
end

function CDTouchScale:touchScaleEnded( touch)

    if TABLE_SIZE(touch) >= 2 then
    
        self.m_sTouchIDList = {};
    else
    
        self:deleteTouchWithID( touch[1]:getId());
    end
    
    self.m_nTouchPoints = self.m_nTouchPoints - TABLE_SIZE(touch);
    if self.m_nTouchPoints < 0 then
        self.m_nTouchPoints = 0;
    end
end

-- 是否可进行缩放
function CDTouchScale:isTouchScaling()

    return self.m_nTouchPoints>=2 and true or false;
end

-- Touch列表操作
function CDTouchScale:findTouchWithID( nID)

    for i = 1, TABLE_SIZE(self.m_sTouchIDList) do
        if self.m_sTouchIDList[i] == nID then
            return true
        end
    end
    return false;
end

function CDTouchScale:deleteTouchWithID( nID)
    
    for i = 1, TABLE_SIZE(self.m_sTouchIDList) do
        if self.m_sTouchIDList[i] == nID then
            table.remove(self.m_sTouchIDList, i)
            return true
        end
    end
    return false;
end

-- 获取缩放点击两点距离
function CDTouchScale:getTouchScaleDistance()

    return cc.pGetDistance(self.m_sTouchPoint1, self.m_sTouchPoint2);
end

-- 获取缩放点击两点中心
function CDTouchScale:getTouchScaleCenter()

    return cc.p((self.m_sTouchPoint1.x + self.m_sTouchPoint2.x) * 0.5, (self.m_sTouchPoint1.y + self.m_sTouchPoint2.y) * 0.5);
end
