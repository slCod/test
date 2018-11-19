--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       QPHH_card_xtqf_ai(仙桃千分AI库)
//File Name:    QPHH_card_xtqf_ai.h
//Author:       GostYe
//Start Data:   2016.01.19
//Language:     XCode 4.5
//Target:       IOS, Android
/****************************************************************************
]]
require( "mahjong_fkbnt.HHLLK_mahjong_fkbnt_math")

CDMahjongHHLLKFKBNT_AI = class("CDMahjongHHLLKFKBNT_AI")
CDMahjongHHLLKFKBNT_AI.__index = CDMahjongHHLLKFKBNT_AI

----------------------------------------------------------------------------
-- 变量
CDMahjongHHLLKFKBNT_AI.m_nHHLLKExpGold         = 0          -- 消耗的金币数量
CDMahjongHHLLKFKBNT_AI.m_nHHLLKTableLeftScore  = 0          -- 桌子中剩余的积分

----------------------------------------------------------------------------
-- 构造函数
function CDMahjongHHLLKFKBNT_AI:ctor()
    cclog("CDMahjongHHLLKFKBNT_AI::ctor")
    self:init()
end

----------------------------------------------------------------------------
-- 成员变量定义

----------------------------------------------------------------------------
-- 初始化
function CDMahjongHHLLKFKBNT_AI:init()
    cclog("CDMahjongHHLLKFKBNT_AI:init")
end

----------------------------------------------------------------------------
-- 释放
function CDMahjongHHLLKFKBNT_AI:release()
    cclog("CDMahjongHHLLKFKBNT_AI:release")
    self:clearAllCards()
end

----------------------------------------------------------------------------
-- 增加已经消耗的金币
function CDMahjongHHLLKFKBNT_AI:addExpGold(count)
    if count and count > 0 then
        self.m_nHHLLKExpGold = self.m_nHHLLKExpGold + count
    end
end

----------------------------------------------------------------------------
-- 积分累加
function CDMahjongHHLLKFKBNT_AI:addScore(count)
    if count and count > 0 then
        self.m_nHHLLKTableLeftScore = self.m_nHHLLKTableLeftScore + count
    end

    return self.m_nHHLLKTableLeftScore
end

----------------------------------------------------------------------------
-- 设置玩家的ID
function CDMahjongHHLLKFKBNT_AI:setPlayerID(playerId)
    self.m_nHHLLKPlayerId = playerId
end

function CDMahjongHHLLKFKBNT_AI:getPlayerID()
    return self.m_nHHLLKPlayerId
end

----------------------------------------------------------------------------
-- 创建AI对象
function CDMahjongHHLLKFKBNT_AI.create()
    cclog("CDMahjongHHLLKFKBNT_AI.create")
    local   instance = CDMahjongHHLLKFKBNT_AI.new()
    return  instance
end