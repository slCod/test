--[[
/******************************************************
 //Project:      ProjectMSS
 //Moudle:       CDDoubleTouch
 //File Name:    DDoubleTouch.h
 //Author:       GostYe
 //Start Data:   2014.02.2
 //Language:     XCode 4.5
 //Target:       IOS, Android
 
 MSS－双击处理基类
 此类用于被继承
 
 ******************************************************/
]]
-----------------------------------------
-- 类定义
CDDoubleTouch = class("CDDoubleTouch")

CDDoubleTouch.__index = CDDoubleTouch

-- 构造函数
function CDDoubleTouch:ctor()
    cclog("CDDoubleTouch::ctor")
    self.m_lDoubleTouchLastTime = 0;
    self.m_lDoubleTouchInterVal = 250;
    self.m_bDoubleTouchTest = false;
    self.m_fDoubleTouchTime = 0;
end


-----------------------------------------
-- 成员变量定义
CDDoubleTouch.m_lDoubleTouchLastTime = 0; --最后时间
CDDoubleTouch.m_lDoubleTouchInterVal = 0; --双击间隔
CDDoubleTouch.m_bDoubleTouchTest = false;     --点击测试
CDDoubleTouch.m_fDoubleTouchTime = 0;     --时间累计


-----------------------------------------
-- 功能函数

-- 判断是否触发双击
function CDDoubleTouch:isDoubleTouch()

    if self.m_bDoubleTouchTest then
    
        if self.m_fDoubleTouchTime < self.m_lDoubleTouchInterVal then
        
            self.m_fDoubleTouchTime = 0;
            self.m_bDoubleTouchTest = false;
            return true;
        else
        
            self.m_fDoubleTouchTime = 0;
            self.m_bDoubleTouchTest = false;
            return false;
        end
    else
    
        self.m_fDoubleTouchTime = 0;
        self.m_bDoubleTouchTest = true;
    end
    return false;
end

-- 更新
function CDDoubleTouch:update( fTime)

    if self.m_bDoubleTouchTest then
    
        self.m_fDoubleTouchTime = self.m_fDoubleTouchTime + fTime*1000.0;
        if self.m_fDoubleTouchTime > self.m_lDoubleTouchInterVal*2 then
        
            self.m_bDoubleTouchTest = false;
            self.m_fDoubleTouchTime = 0;
        end
    end
end

-- 设置双击的间隔时间
function CDDoubleTouch:setDoubleTouchInterVal( lVal)
    self.m_lDoubleTouchInterVal = lVal;
end


-----------------------------------------
-- create
function CDDoubleTouch.create()
    cclog("CDDoubleTouch::create")
    local instance = CDDoubleTouch.new()
    return instance
end