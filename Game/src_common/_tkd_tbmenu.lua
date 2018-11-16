
-----------------------------------------
-- 类定义
TKD_TBMENU = class("TKD_TBMENU")

TKD_TBMENU.__index = TKD_TBMENU

-- 构造函数
function TKD_TBMENU:ctor()
    cclog("TKD_TBMENU::ctor")
    self:init()
end


-----------------------------------------
-- 成员变量定义
TKD_TBMENU.m_pGroup = nil
TKD_TBMENU.m_pDefine = nil
TKD_TBMENU.m_pSelect = nil
TKD_TBMENU.m_pCallFunc = nil
TKD_TBMENU.m_pHint = nil
TKD_TBMENU.m_sHintBegin = nil   --图标原始位置
TKD_TBMENU.m_bHintGet = nil     --图标是否获取过
TKD_TBMENU.m_fScale = 1.0


-----------------------------------------
-- 初始化
function TKD_TBMENU:init()
    --cclog("TKD_TBMENU::init")

    self.m_pGroup = nil
    self.m_pDefine = nil
    self.m_pSelect = nil
    self.m_pCallFunc = nil
    self.m_pHint = nil
    self.m_bHintGet = false;
    self.m_sHintBegin = cc.p( 0, 0);

end

function TKD_TBMENU:release()
    --cclog("TKD_TBMENU::release")
    
    --CC_SAFE_RELEASE_NULL( self.m_pGroup)
    --CC_SAFE_RELEASE_NULL( self.m_pDefine)
    --CC_SAFE_RELEASE_NULL( self.m_pSelect)
    CC_SAFE_RELEASE_NULL( self.m_pCallFunc)
    --CC_SAFE_RELEASE_NULL( self.m_pHint)
    self:init()
end


-----------------------------------------
-- 功能函数

--  可见
function TKD_TBMENU:setVisible( bVisible)
    if  self.m_pGroup ~= nil then
        self.m_pGroup:setVisible( bVisible)
    end
end
function TKD_TBMENU:isVisible()
    if  self.m_pGroup ~= nil then
        return self.m_pGroup:isVisible()
    end
    return false
end
--  默认项
function TKD_TBMENU:define()
    if  self.m_pDefine ~= nil then
        self.m_pDefine:setVisible( true)
    end
    if  self.m_pSelect ~= nil then
        self.m_pSelect:setVisible( false)
    end
end
--  选中项
function TKD_TBMENU:select()
    if  self.m_pDefine ~= nil then
        self.m_pDefine:setVisible( false)
    end
    if  self.m_pSelect ~= nil then
        self.m_pSelect:setVisible( true)
    end
end
--  不可用设置
function TKD_TBMENU:setGrey( bGrey)
    if  self.m_pGroup ~= nil then
        self.m_pGroup:setGrey( bGrey)
    end
end
function TKD_TBMENU:isGrey()
    if  self.m_pGroup ~= nil then
        return self.m_pGroup:isGrey()
    end
    return false
end
--  设置默认缩放
function TKD_TBMENU:setScale( fScale)

    self.m_fScale = fScale
end
--  函数处理
function TKD_TBMENU:runCallfunc()
    cclog("TKD_TBMENU:runCallfunc")
    local fScaleTo = self.m_fScale*1.15

    if self.m_pDefine then
        self.m_pDefine:runAction( cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.15, fScaleTo)), cc.ScaleTo:create( 0.1, self.m_fScale)))
    end
    if self.m_pSelect then
        self.m_pSelect:runAction( cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.15, fScaleTo)), cc.ScaleTo:create( 0.1, self.m_fScale)))
    end
    
    if self.m_pCallFunc then
        self.m_pCallFunc:execute()
    end
end
--  设置新图标提示
function TKD_TBMENU:setHint( bHint)

    if not self.m_pHint then
        return
    end
    if ( not self.m_bHintGet) then

        self.m_bHintGet = true;
        self.m_sHintBegin = cc.p(self.m_pHint:getPosition());
    end

    self.m_pHint:setVisible( bHint)
    if bHint then
        self.m_pHint:stopAllActions()
        -- local sPos1 = cc.pAdd(self.m_sHintBegin, cc.p( 0.0, 30.0));
        -- local sPos2 = cc.pAdd(self.m_sHintBegin, cc.p( 0.0, 10.0));
        -- self.m_pHint:runAction( cc.RepeatForever:create( cc.Sequence:create( cc.MoveTo:create( 0.2, sPos1), cc.MoveTo:create( 0.15, self.m_sHintBegin), cc.MoveTo:create( 0.15, sPos2), cc.MoveTo:create( 0.1, self.m_sHintBegin), cc.DelayTime:create( 1.0))));
        self.m_pHint:runAction( cc.RepeatForever:create( 
            cc.Sequence:create( cc.ScaleTo:create( 0.2, 1.3), cc.ScaleTo:create( 0.15, 1.0), 
                cc.ScaleTo:create( 0.15, 1.1), cc.ScaleTo:create( 0.1, 1.0), cc.DelayTime:create( 1.0))))
    else
        self.m_pHint:stopAllActions()
    end
end
-- 判断是否有红点
function TKD_TBMENU:isHint()

    if  not self.m_pHint then
        return false
    end
    return self.m_pHint:isVisible()
end

-----------------------------------------
-- create
function TKD_TBMENU.create()
    cclog("TKD_TBMENU::create")
    local instance = TKD_TBMENU.new()
    return instance
end