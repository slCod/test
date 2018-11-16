--[[
图片拼装数字
Tuanzi
2015.07.02
]]

-----------------------------------------
-- 类定义
CDSpriteNumber = class("CDSpriteNumber",
    function()
        return cc.Node:create()
    end
)

CDSpriteNumber.__index = CDSpriteNumber

-- 构造函数
function CDSpriteNumber:ctor()
    --cclog("CDSpriteNumber::ctor")
    CDSpriteNumber.initialMember(self)
end


-----------------------------------------
-- 成员变量定义
--[[
CDSpriteNumber.m_sDir = nil     --方向
]]

-----------------------------------------
-- 初始化
function CDSpriteNumber:initialMember()
    --cclog("CDSpriteNumber::initialMember")
    
    self.m_sDir = "l"
end

function CDSpriteNumber:releaseMember()
    --cclog("CDSpriteNumber::releaseMember")
    
    self.m_sDir = nil
    
    self:removeAllChildren()
end

-- 初始化
function CDSpriteNumber:init( sDir)
    --cclog("CDSpriteNumber::init")
    if sDir ~= nil then
    
        self.m_sDir = sDir
    end
end

-- 设置文字
function CDSpriteNumber:setString( strText)

    self:removeAllChildren()
    self:setPosition( cc.p(0, 0))
    local fX = 0
    if self.m_sDir == "l" or self.m_sDir == "c" then
    
        for i = 1, #strText do
        
            local char = string.sub( strText, i, i)
            local pSprite = nil
            if char == "-" then
            
                pSprite = cc.Sprite:createWithSpriteFrameName( "ntf_j.png")
            else
            
                pSprite = cc.Sprite:createWithSpriteFrameName( string.format("ntf_%s.png", char))
            end
            if pSprite then
            
                self:addChild( pSprite)
                pSprite:setPosition( cc.p(fX, 0.0))
                pSprite:setAnchorPoint( cc.p(0.0, 0.5))
                fX = fX + pSprite:getContentSize().width - 2
            end
        end
        --居中调整
        if self.m_sDir == "c" then
        
            self:setPosition( cc.p(- fX / 2, 0))
        end
        
    elseif self.m_sDir == "r" then

        for i = #strText, 1, -1 do

            local char = string.sub( strText, i, i)
            local pSprite = nil
            if char == "-" then

                pSprite = cc.Sprite:createWithSpriteFrameName( "ntf_j.png")
            else

                pSprite = cc.Sprite:createWithSpriteFrameName( string.format("ntf_%s.png", char))
            end
            if pSprite then

                self:addChild( pSprite)
                pSprite:setPosition( cc.p(fX, 0.0))
                pSprite:setScaleX( -1.0)
                pSprite:setAnchorPoint( cc.p(1.0, 0.5))
                fX = fX + pSprite:getContentSize().width - 2
            end
        end
    end
end

-----------------------------------------
-- create
function CDSpriteNumber.createCDSpriteNumber(pParent, sDir)
    if not pParent then
        return nil
    end
    local layer = CDSpriteNumber.new()
    layer:init( sDir)
    pParent:addChild(layer)
    return layer
end
