--[[
/******************************************************
//Project:      ProjectMSS
//Moudle:       CDTKDTableCell
//File Name:    DTKDTableCell.lua
//Author:       Tuanzi
//Start Data:   2015.12.04
//Language:     XCode 6.4
//Target:       IOS, Android

MSS－列表节点基类

******************************************************/
]]

-----------------------------------------
-- 类定义
CDTKDTableCell = class("CDTKDTableCell",
    function()
        return cc.TableViewCell:create()
    end
)

CDTKDTableCell.__index = CDTKDTableCell

-- 构造函数
function CDTKDTableCell:ctor()
    --cclog("CDTKDTableCell::ctor")
    CDTKDTableCell.initialMember(self)
end

-- 析构函数 暂时不会用到
function CDTKDTableCell:dctor()
    --cclog("CDTKDTableCell::dctor")
    self:releaseMember()
    self:unregisterScriptHandler()
end

-----------------------------------------
-- 成员变量定义

--[[
CDTKDTableCell.m_ccbLayer = nil     --ccb界面层
CDTKDTableCell.m_ccbLoader = nil    --ccb加载容器
CDTKDTableCell.m_pOwner = nil       --所有者界面
]]

-----------------------------------------
-- 初始化
function CDTKDTableCell:initialMember()
    --cclog("CDTKDTableCell::initialMember")
    self.m_ccbLayer = nil
    self.m_ccbLoader = {}
    self.m_pOwner = nil
end

function CDTKDTableCell:releaseMember()
    --cclog("CDTKDTableCell::releaseMember")

    if self.m_ccbLayer then
        self.m_ccbLayer:setUserObject()
        self.m_ccbLayer = nil
    end
    self.m_ccbLoader = nil
    self.m_pOwner = nil
end

-- 初始化
function CDTKDTableCell:init()
    --cclog("CDTKDTableCell::init")
    return true
end


-----------------------------------------
-- 功能函数

function CDTKDTableCell:setCurrent(bCurrent)

end

function CDTKDTableCell:isCurrent()
    return false
end

function CDTKDTableCell:showTouchTip( sPos, pLayerTip)
    return false
end

function CDTKDTableCell:setOwner( pOwner)

    self.m_pOwner = pOwner
end
function CDTKDTableCell:getOwner()

    return self.m_pOwner
end