--[[
/******************************************************
//Project:      ProjectMSS
//Moudle:       CDTKDScene
//File Name:    DTKDScene.lua
//Author:       Tuanzi
//Start Data:   2015.12.03
//Language:     XCode 6.4
//Target:       IOS, Android

MSS-场景基础类（预设置场景将会用到的公共对象)

******************************************************/
]]

require( REQUIRE_PATH.."DSceneSwitchAnimation")
require( REQUIRE_PATH.."DLayerToolsBar")
require( REQUIRE_PATH.."DLayerPlayerBar")


-----------------------------------------
-- 类定义
CDTKDScene = class("CDTKDScene", CDSceneSwitchAnimation)

CDTKDScene.__index = CDTKDScene

function CDTKDScene:ctor()
    cclog("CDTKDScene::ctor")
    CDTKDScene.super.ctor(self)
    
    CDTKDScene.initAllUserInterface(self)
end


-----------------------------------------
-- 成员变量定义

--[[
CDTKDScene.m_pLayerToolsBar             工具条
CDTKDScene.m_pLayerPlayerBar            玩家信息条
CDTKDScene.m_pHeroList                  英雄列表
CDTKDScene.m_pHeroInfo                  英雄信息
CDTKDScene.m_pSceneBack                 背景
]]


-----------------------------------------
-- 功能函数

-- 获得场景UI
function CDTKDScene:getSceneUI( strName)

    local pUI = CDTKDScene.super.getSceneUI(self, strName)
    if pUI then
    
        return pUI
    end
    
    pUI = dtGetUIFromPool(strName)
    if pUI then

        return pUI
    end
    
    -- 临时创建UI
    if strName == "CDLayerHeroList" then
    
        --英雄列表
        self.m_pHeroList = dtGetUIFromPool("CDLayerHeroList", self)
        if not self.m_pHeroList then
    
            self.m_pHeroList = dtSetUIToPool("CDLayerHeroList", CDLayerHeroList.createCDLayerHeroList( self))
        end
    elseif strName == "CDLayerHeroInfo" then
    
        --英雄信息
        self.m_pHeroInfo = dtGetUIFromPool("CDLayerHeroInfo", self)
        if not self.m_pHeroInfo then
    
            self.m_pHeroInfo = dtSetUIToPool("CDLayerHeroInfo", CDLayerHeroInfo.createCDLayerHeroInfo( self))
        end
    end
    
    pUI = dtGetUIFromPool(strName)
    return pUI
end


-- 初始化所有用户界面
function CDTKDScene:initAllUserInterface()
    cclog("CDTKDScene::initAllUserInterface")

    self.m_pLayerToolsBar = nil
    self.m_pLayerPlayerBar = nil
    self.m_pHeroList = nil
    self.m_pHeroInfo = nil
    self.m_pSceneBack = nil
end

-- 手动释放场景
function CDTKDScene:manualReleaseScene()
    cclog("CDTKDScene::manualReleaseScene")
    
    CDTKDScene.super.manualReleaseScene(self)
    
    if DEF_MANUAL_RELEASE then

        local sReleaseUIs = { self.m_pLayerToolsBar, self.m_pLayerPlayerBar, self.m_pHeroList, self.m_pHeroInfo}
        for i, pUI in pairs(sReleaseUIs) do

            if pUI then

                if pUI.close then

                    pUI:close()
                end
                self:removeChild( pUI)
            end
        end
        
        CDTKDScene.initAllUserInterface(self)
    end
    
    if DEF_X_REMOVE_UNUSER_TEXTURE then
        dtResetTextureCache()
    end
end

-- 创建所有用户界面
function CDTKDScene:createAllUserInterface( sSrc)
    cclog("CDTKDScene::createAllUserInterface")
    
    if sSrc and sSrc ~= "" then
    
        if self.m_pSceneBack then
            self:removeChild( self.m_pSceneBack)
        end
        
        self.m_pSceneBack = cc.Sprite:createWithSpriteFrameName( sSrc)
        if self.m_pSceneBack then
        
            self.m_pSceneBack:setAnchorPoint( cc.p( 0.5, 0.5))
            self.m_pSceneBack:setPosition( CDGlobalMgr:sharedGlobalMgr():getWinCenter())
            self.m_pSceneBack:setScale( 1.42)
            self:addChild( self.m_pSceneBack)
            self.m_pSceneBack:setVisible( false)
        end
    end
    
    --[[mss todo mss
    --  两个工具条界面
    self.m_pLayerToolsBar = dtGetUIFromPool("CDLayerToolsBar", self)
    if not self.m_pLayerToolsBar then
    
        self.m_pLayerToolsBar = dtSetUIToPool("CDLayerToolsBar", CDLayerToolsBar.createCDLayerToolsBar( self), DEF_ORDER_TOOLSBAR)
    end
        
    self.m_pLayerPlayerBar = dtGetUIFromPool("CDLayerPlayerBar", self)
    if not self.m_pLayerPlayerBar then

        self.m_pLayerPlayerBar = dtSetUIToPool("CDLayerPlayerBar", CDLayerPlayerBar.createCDLayerPlayerBar( self), DEF_ORDER_TOOLSBAR)
    end
    ]]
end

-- 关闭所有用户界面
function CDTKDScene:closeAllUserInterface()
    cclog("CDTKDScene::closeAllUserInterface")
    
    CDTKDScene.super.closeAllUserInterface(self)

    local sCloseUIs = { self.m_pLayerToolsBar, self.m_pLayerPlayerBar, self.m_pHeroList, self.m_pHeroInfo}
    for i, pUI in pairs(sCloseUIs) do

        if pUI and pUI:isVisible() then

            if pUI.close then

                pUI:close()
            end
        end
    end
end
