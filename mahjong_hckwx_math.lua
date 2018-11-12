--[[
/***************************************************************************
/****************************************************************************
-- 使用：（创建对象后）
    1). randomSort 等于洗牌
    2). getMahjong 等于获取一张牌(参数 从前还是从后)
    3). canHuPai   检查是否可以胡牌（摸牌后自己判断，如果别人打牌判断可以调用canHuPai_WithOther）
    4). canTingPai 检查是否听牌
]]

require( REQUIRE_PATH.."DCCBLayer")
require( REQUIRE_PATH.."DDefine")

CDMahjongHCKWX = class("CDMahjongHCKWX")
CDMahjongHCKWX.__index = CDMahjongHCKWX

DEF_HCKWX_MJ_MAX        = 84        -- 牌总数
DEF_HCKWX_MJ_NUM_MAX    = 9           -- 基本牌最大数

-- DEF_HCKWX_MJ_WAN        = 1           -- 万   
DEF_HCKWX_MJ_TIAO       = 2           -- 条
DEF_HCKWX_MJ_TONG       = 3           -- 筒

DEF_HCKWX_MJ_JIAN       = 5           -- 箭（中發白）

DEF_HCKWX_TYPE_TOTAL    = 3           -- 牌类型总数

DEF_HCKWX_MJ_MIN        = 2           -- 手上牌剩余最少数量

DEF_HCKWX_NAIZI_MAX     = 4           -- 最大赖子数量
DEF_HCKWX_NAIZI_ERR     = 99          -- 需要赖子数量的错误

DEF_HCKWX_PENG          = 1
DEF_HCKWX_GANG          = 2
DEF_HCKWX_HU            = 3
DEF_HCKWX_ZIMO          = 4
DEF_HCKWX_CHAOTIAN      = 5
DEF_HCKWX_BUZHUOCHONG   = 6           -- 不捉铳
DEF_HCKWX_QIANGXIAO     = 7

-- 以下数组属于手动配置牌，用于按设置发手牌以及后面的摸牌
DEF_WITH_CARDS        = {           -- 配牌，按照以下顺序发
--[[
                            11, 11, 12, 12, 14, 14, 15, 15, 17, 17, 18, 18, 19, --我的手牌
                            11, 12, 21, 22, 22, 24, 24, 25, 25, 27, 27, 28, 28, --右边手牌
                            31, 31, 32, 32, 34, 34, 35, 35, 37, 37, 38, 38, 39, --顶家手牌
                            13, 13, 14, 14, 16, 16, 17, 17, 19, 19, 21, 21, 11, --左边手牌
                            23,                                                 --我的补牌
                            11, 11, 11, 11, 12, 12, 12, 12, 12, 22, 22,
                            27, 28, 28, 28, 28, 29, 29, 29, 29, 31, 31, 
                            31, 31, 32, 32, 32, 32, 33, 33, 33, 33, 34, 
                            34, 34, 34, 35, 35, 35, 35, 36, 36, 36, 36,
                            37, 37, 37, 37, 38, 38, 38, 38, 39, 39, 39                           
]]
                        }
----------------------------------------------------------------------------
-- 构造函数
function CDMahjongHCKWX:ctor()
    cclog("CDMahjongHCKWX::ctor")
    self:init()
end

----------------------------------------------------------------------------
-- 成员变量定义
CDMahjongHCKWX.m_sMahjongs = nil      -- 麻将牌组(这里只有万、条、筒)
CDMahjongHCKWX.m_nForwardIndex = 0    -- 顺向取牌索引
CDMahjongHCKWX.m_nReverseIndex = 0    -- 逆向取牌索引

CDMahjongHCKWX.m_nMahjongLaiZi = 0    -- 赖子牌
CDMahjongHCKWX.m_nMahjongFan = 0      -- 翻牌(只有三张)

CDMahjongHCKWX.m_nMahjongTotal = DEF_HCKWX_MJ_MAX    -- 自己记录牌总数
CDMahjongHCKWX.m_bFlagPiao = false    -- 是否有人飘过赖子

----------------------------------------------------------------------------
-- 初始化
function CDMahjongHCKWX:init()

    -- 牌数值定义
    local index = 0
    self.m_sMahjongs = {}
    for i = 1, DEF_HCKWX_MJ_NUM_MAX do

        for j = 1, 4 do
            self.m_sMahjongs[   index] = DEF_HCKWX_MJ_TONG*10+i
            self.m_sMahjongs[ index+1] = DEF_HCKWX_MJ_TIAO*10+i
            -- self.m_sMahjongs[ index+2] = DEF_HCKWX_MJ_WAN*10+i
            index = index + 3


            -- 箭
            if  i <= 3 then

                self.m_sMahjongs[index] = DEF_HCKWX_MJ_JIAN*10+i
                index = index + 1
            end

        end
    end
end

----------------------------------------------------------------------------
-- 释放
function CDMahjongHCKWX:release()
    cclog("CDMahjongHCKWX::release")

end

----------------------------------------------------------------------------
-- 随机赖子牌
function CDMahjongHCKWX:randomLaiZi()

    local random_num = math.random(0, DEF_HCKWX_MJ_MAX-1)
    -- 先随机翻牌
    local fan = self.m_sMahjongs[random_num]
    self:setMahjongFan( fan)
    -- 赖子是翻牌的下一张，但是翻牌如果是9那么赖子就是1
    local laizi = fan+1
    if  laizi % 10 == 0 then
        laizi = laizi - 10 + 1
    end
    self:setMahjongLaiZi( laizi)
    -- 从牌库中删除一张翻牌
    local count = TABLE_SIZE( self.m_sMahjongs)-1
    local frist = self.m_sMahjongs[0]
    self.m_sMahjongs[0] = fan
    for i = 1, count do

        if  self.m_sMahjongs[i] == fan then
            self.m_sMahjongs[i] = frist
            self.m_nForwardIndex = self.m_nForwardIndex + 1
            break
        end
    end
end
----------------------------------------------------------------------------
-- 随机排序
function CDMahjongHCKWX:randomSort()
    cclog("CDMahjongHCKWX::randomSort")

    self.m_nForwardIndex = 0
    self.m_nReverseIndex = DEF_HCKWX_MJ_MAX-1

    -- 判断是否用配置牌
    local bWithCards = false
    if  TABLE_SIZE( DEF_WITH_CARDS) > 0 then
        bWithCards = true
    end

    local index = 0
    local random_num = 0
    for i = 0, DEF_HCKWX_MJ_MAX-1 do

        -- 假如不适用配置牌那么随机调换牌顺序
        if  bWithCards then

            self.m_sMahjongs[i] = DEF_WITH_CARDS[i+1]
        else

            index = self.m_sMahjongs[i]
            random_num = math.random( 0, DEF_HCKWX_MJ_MAX-1)
            self.m_sMahjongs[i] = self.m_sMahjongs[random_num]
            self.m_sMahjongs[random_num] = index
        end
    end

    self:randomLaiZi()
    self:setFlagPiao( false)
end

----------------------------------------------------------------------------
-- 随机打乱牌组顺序
function CDMahjongHCKWX:randomMahjongs( mahjongs)

    local mahjong = 0
    local size = TABLE_SIZE( mahjongs)
    local random_idx = 0

    for i = 1, size do

        mahjong = mahjongs[i]
        random_idx = math.random( 1, size)
        mahjongs[i] = mahjongs[random_idx]
        mahjongs[random_idx] = mahjong
    end
end

----------------------------------------------------------------------------
-- 设置/获取赖子牌
function CDMahjongHCKWX:setMahjongLaiZi( laizi)

    self.m_nMahjongLaiZi = laizi
end
function CDMahjongHCKWX:getMahjongLaiZi()

    return self.m_nMahjongLaiZi
end

----------------------------------------------------------------------------
-- 设置/获取赖子牌
function CDMahjongHCKWX:setMahjongFan( fan)

    self.m_nMahjongFan = fan
end
function CDMahjongHCKWX:getMahjongFan()

    return self.m_nMahjongFan
end

----------------------------------------------------------------------------
-- 设置/获取赖子牌
function CDMahjongHCKWX:setFlagPiao( piao)

    self.m_bFlagPiao = piao
end
function CDMahjongHCKWX:getFlagPiao()

    return self.m_bFlagPiao
end
----------------------------------------------------------------------------
-- 获取牌根据索引
-- 参数: 是否顺序(否就是逆向获取)
-- 返回: 0失败（没有牌)
function CDMahjongHCKWX:getMahjong( forward)

    if  forward == nil then
        forward = true
    end

    local index = 0
    if  forward then
        if  self.m_nForwardIndex > self.m_nReverseIndex then
            return 0
        end
        index = self.m_nForwardIndex
        self.m_nForwardIndex = self.m_nForwardIndex + 1
        return self.m_sMahjongs[ index]
    else
        if  self.m_nReverseIndex < self.m_nForwardIndex then
            return 0
        end
        index = self.m_nReverseIndex
        self.m_nReverseIndex = self.m_nReverseIndex - 1
        return self.m_sMahjongs[ index]
    end
end

----------------------------------------------------------------------------
-- 获取麻将剩余总数
-- 返回: 数量
function CDMahjongHCKWX:getMahjongSize()

    local size = self.m_nReverseIndex - self.m_nForwardIndex + 1
    if  size <= 0 then
        return 0
    end
    return size
end
----------------------------------------------------------------------------
-- 获取麻将牌面数值
-- 参数: 卡牌原始数值
-- 返回: 类型(参考第26～28行定义), 数值(1~9)
function CDMahjongHCKWX:getMahjongNumber( mahjong)

    return math.floor( mahjong*0.1), mahjong%10
end

----------------------------------------------------------------------------
-- 设置／获取／减少当前麻将牌总数
function CDMahjongHCKWX:mahjongTotal_set( total)

    if  total == nil then
        total = DEF_HCKWX_MJ_MAX
    end

    self.m_nMahjongTotal = total
end
function CDMahjongHCKWX:mahjongTotal_get()

    return self.m_nMahjongTotal
end
function CDMahjongHCKWX:mahjongTotal_lower( num)

    if  num == nil then
        num = 1
    end

    self.m_nMahjongTotal = self.m_nMahjongTotal - num
    if  self.m_nMahjongTotal < 0 then
        self.m_nMahjongTotal = 0
    end

    return self.m_nMahjongTotal
end

----------------------------------------------------------------------------
-- 各种排序函数
    -- 从小到大卡牌排序
function mahjong_xtsj_comps_stb( a, b)
    return a.mahjong < b.mahjong
end
    -- 从大到小卡牌排序
function mahjong_xtsj_comps_bts( a, b)
    return a.mahjong > b.mahjong
end
    -- 从小到大数值排序
function mahjong_sort_stb( a, b)
    return a < b
end
    -- 从大到小数值排序
function mahjong_sort_bts( a, b)
    return a > b
end

----------------------------------------------------------------------------
-- 麻将组由小到大排列
-- 参数: 牌列表(牌结构(mahjong))
function CDMahjongHCKWX:defMahjongSort_stb( mahjongs)
    table.sort( mahjongs, mahjong_sort_stb)
end

----------------------------------------------------------------------------
-- 麻将组由大到小排列
-- 参数: 牌列表(牌结构(mahjong))
function CDMahjongHCKWX:defMahjongSort_bts( mahjongs)
    table.sort( mahjongs, mahjong_sort_bts)
end

----------------------------------------------------------------------------
-- 牌排列从小到大
-- 参数: 牌列表(牌结构(mahjong,index))
function CDMahjongHCKWX:mahjongSort_stb( mahjongs)
    table.sort( mahjongs, mahjong_xtsj_comps_stb)
end

----------------------------------------------------------------------------
-- 牌排列从大到小
-- 参数: 牌列表(牌结构(mahjong,index))
function CDMahjongHCKWX:mahjongSort_bts( mahjongs)
    table.sort( mahjongs, mahjong_xtsj_comps_bts)
end

--＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊赖子胡牌规则＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊

----------------------------------------------------------------------------
-- 拆分普通牌和赖子牌
-- 参数: mahjongs需要拆分的牌组( mahjong, index)
-- 返回: 普通牌组，赖子牌组
function CDMahjongHCKWX:getArray_Pai_Lai( mahjongs)

    local sVecPai = {}
    local sVecLai = {}

    local size = TABLE_SIZE( mahjongs)
    if  size == 0 then
        return sVecPai, sVecLai
    end

    local laizi = self:getMahjongLaiZi()

    for i = 1, size do

        if  mahjongs[i].mahjong ~= laizi then
            sVecPai[ TABLE_SIZE( sVecPai)+1] = mahjongs[i].mahjong
        else
            sVecLai[ TABLE_SIZE( sVecLai)+1] = laizi
        end
    end

    return sVecPai, sVecLai
end
-- 参数: mahjongs需要拆分的牌组数字
function CDMahjongHCKWX:getArray_Pai_Lai_ex( mahjongs)

    local sVecPai = {}
    local sVecLai = {}

    local size = TABLE_SIZE( mahjongs)
    if  size == 0 then
        return sVecPai, sVecLai
    end

    local laizi = self:getMahjongLaiZi()

    for i = 1, size do

        if  mahjongs[i] ~= laizi then
            sVecPai[ TABLE_SIZE( sVecPai)+1] = mahjongs[i]
        else
            sVecLai[ TABLE_SIZE( sVecLai)+1] = laizi
        end
    end
    return sVecPai, sVecLai
end

function CDMahjongHCKWX:push_mahjong( array,value )
    if  array and type(array) == "table" and value then
        array[TABLE_SIZE(array)+1]= value
        return true
    end
    return false
end
----------------------------------------------------------------------------
-- 拆分普通牌和赖子牌
-- 参数: mahjongs需要拆分的牌组(数字)
-- 返回: 普通牌组，赖子牌组
function CDMahjongHCKWX:getArrayDef_Pai_Lai( mahjongs)

    local sVecPai = {}
    local sVecLai = {}

    local size = TABLE_SIZE( mahjongs)
    if  size == 0 then
        return sVecPai, sVecLai
    end

    local laizi = self:getMahjongLaiZi()

    for i = 1, size do

        if  mahjongs[i] ~= laizi then
            sVecPai[ TABLE_SIZE( sVecPai)+1] = mahjongs[i]
        else
            sVecLai[ TABLE_SIZE( sVecLai)+1] = laizi
        end
    end

    return sVecPai, sVecLai
end
----------------------------------------------------------------------------
-- 压入数组到数组最后
-- 参数: sArray最后返回的数组, sVector用于挑选的数组, nBegin开始位置, nEnd结束位置
function CDMahjongHCKWX:push_back( sArray, sVector, nBegin, nEnd)

    if  TABLE_SIZE( sVector) < nEnd then
        return
    end

    for i = nBegin, nEnd do
        sArray[ TABLE_SIZE( sArray)+1] = sVector[i]
    end
end

----------------------------------------------------------------------------
-- 删除数组从数组最后开始
-- 参数: sArray最后返回的数组, count删除数量
function CDMahjongHCKWX:pop_back( sArray, count)

    local size = TABLE_SIZE( sArray)
    if  size == 0 or count > size then
        return
    end

    for i = 1, count do

        size = TABLE_SIZE( sArray)
        table.remove( sArray, size)
    end
end

----------------------------------------------------------------------------
-- 删除数组从数组中找
-- 参数: sArray最后返回的数组, sVector用于删除的数组
function CDMahjongHCKWX:pop_array( sArray, sVector)

    local size  = TABLE_SIZE( sArray)
    local count = TABLE_SIZE( sVector)

    if  size == 0 or count == 0 then
        return
    end

    for i = 1, count do

        size = TABLE_SIZE( sArray)
        for j = 1, size do

            if  sArray[j] == sVector[i] then

                table.remove( sArray, j)
                break
            end
        end
    end
end

----------------------------------------------------------------------------
-- 删除数组从数组中找指定的牌（只删除一张相同的牌)
-- 参数: sArray最后返回的数组, mahjong要删除的牌
function CDMahjongHCKWX:pop_mahjong( sArray, mahjong)

    local size = TABLE_SIZE( sArray)
    if  size == 0 then
        return
    end

    for i = 1, size do

        if  sArray[i] == mahjong then

            table.remove( sArray, i)
            return
        end
    end
end

function CDMahjongHCKWX:pop_allMahjong( sArray, mahjongs)

    local size = TABLE_SIZE( mahjongs)

    for i = 1, size do

        for j = 1, TABLE_SIZE( sArray) do

            if  sArray[j] == mahjongs[i] then
                table.remove( sArray, j)
            end
        end
    end
end


-- 参数: sArray胡牌组, mahjong最后胡的牌
-- 返回: sParray前半组, sBArray后半组
function CDMahjongHCKWX:getArray_hupai( sArray, mahjong)

    local size = TABLE_SIZE( sArray)
    local sParray = {} 
    local sBarray = {}

    local find_idx = 0
    for i = 1, size do

        if  sArray[i] == mahjong then
            find_idx = i
            break
        end
    end

    if  find_idx ~= 0 then

        local mod = find_idx%3
        local b_idx = 0
        local e_idx = 0
        if  mod == 0 then
            b_idx = find_idx-2
            e_idx = find_idx
        elseif mod == 1 then
            b_idx = find_idx
            e_idx = find_idx+2
        else
            b_idx = find_idx-1
            e_idx = find_idx+1
        end
        if  e_idx > size then
            e_idx = size
        end

        for i = 1, size do

            if  i >= b_idx and i <= e_idx then

                sBarray[TABLE_SIZE(sBarray)+1] = sArray[i]
            else

                sParray[TABLE_SIZE(sParray)+1] = sArray[i]
            end
        end
    else

        self:push_back( sParray, sArray, 1, TABLE_SIZE( sArray))
    end
    
    return sParray, sBarray
end
----------------------------------------------------------------------------
-- 搜索指定对象是否存在
-- 参数: sArray数组, 要找的数值
function CDMahjongHCKWX:isFind( sArray, mahjong)

    local size = TABLE_SIZE( sArray)

    for i = 1, size do

        if  sArray[i] == mahjong then
            return true
        end
    end
    return false
end

----------------------------------------------------------------------------
-- 检查胡牌（递归处理)
-- 参数: 检查的普通牌组,检查的赖子组,是否有将牌,以配成的扑牌组,以配成的将牌组
function CDMahjongHCKWX:checkHuPai( sVecPai, sVecLai, bJiang, sVecSavePai, sVecSaveJiang)

    if  TABLE_SIZE( sVecPai) == 0 and TABLE_SIZE( sVecLai) == 0 then

        return true
    else

        -- 将牌没有的情况下先找将牌
        if  (not bJiang) and TABLE_SIZE( sVecPai) >= 2 and sVecPai[1] == sVecPai[2] then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}

            self:push_back( vecDelePai, sVecPai, 1, 2)
            self:push_back( vecNextPai, sVecPai, 3, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 1, TABLE_SIZE( sVecLai))

            self:push_back( sVecSaveJiang, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            if  self:checkHuPai( vecNextPai, vecNextLai, true, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSaveJiang, TABLE_SIZE(vecDelePai))
        end

        -- 三张牌组成刻子
        if  TABLE_SIZE( sVecPai) >= 3 and sVecPai[1] == sVecPai[2] and sVecPai[1] == sVecPai[3] then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}
            local vecDeleLai = {}

            self:push_back( vecDelePai, sVecPai, 1, 3)
            self:push_back( vecNextPai, sVecPai, 4, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 1, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            if  self:checkHuPai( vecNextPai, vecNextLai, bJiang, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
        end

        -- 三张组组成顺子
        if  TABLE_SIZE( sVecPai) >= 3 and self:isFind( sVecPai, sVecPai[1]+1) and self:isFind( sVecPai, sVecPai[1]+2) then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}

            vecDelePai[1] = sVecPai[1]
            vecDelePai[2] = sVecPai[1]+1
            vecDelePai[3] = sVecPai[1]+2

            self:push_back( vecNextPai, sVecPai, 1, TABLE_SIZE( sVecPai))
            self:pop_array( vecNextPai, vecDelePai)
            self:push_back( vecNextLai, sVecLai, 1, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            if  self:checkHuPai( vecNextPai, vecNextLai, bJiang, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
        end

        --=====以上是没有赖子的胡牌算法=====

        -- 一张牌和一个赖子组成将牌
        if  (not bJiang) and TABLE_SIZE( sVecPai) >= 1 and TABLE_SIZE( sVecLai) >= 1 then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}
            local vecDeleLai = {}

            self:push_back( vecDelePai, sVecPai, 1, 1)
            self:push_back( vecDeleLai, sVecLai, 1, 1)

            self:push_back( vecNextPai, sVecPai, 2, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 2, TABLE_SIZE( sVecLai))

            self:push_back( sVecSaveJiang, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            self:push_back( sVecSaveJiang, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkHuPai( vecNextPai, vecNextLai, true, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSaveJiang, TABLE_SIZE(vecDelePai))
            self:pop_back( sVecSaveJiang, TABLE_SIZE(vecDeleLai))
        end

        -- 两张牌和一个赖子组成刻子
        if  TABLE_SIZE( sVecPai) >= 2 and TABLE_SIZE( sVecLai) >= 1 and sVecPai[1] == sVecPai[2] then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}
            local vecDeleLai = {}

            self:push_back( vecDelePai, sVecPai, 1, 2)
            self:push_back( vecDeleLai, sVecLai, 1, 1)

            self:push_back( vecNextPai, sVecPai, 3, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 2, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            self:push_back( sVecSavePai, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkHuPai( vecNextPai, vecNextLai, bJiang, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDeleLai))
        end

        -- 两张牌和一个赖子组成顺子
        if  TABLE_SIZE( sVecPai) >= 2 and TABLE_SIZE( sVecLai) >= 1 and 
            ( ((sVecPai[1]%10 < 9) and self:isFind( sVecPai, sVecPai[1]+1)) or 
              ((sVecPai[1]%10 < 8) and self:isFind( sVecPai, sVecPai[1]+2))) then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}
            local vecDeleLai = {}

            self:push_back( vecDelePai, sVecPai, 1, 1)
            self:push_back( vecDeleLai, sVecLai, 1, 1)
            self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            if  self:isFind( sVecPai, sVecPai[1]+1) then

                vecDelePai[ TABLE_SIZE( vecDelePai)+1] = sVecPai[1]+1
                if  sVecPai[1]%10 == 8 then

                    sVecSavePai[ TABLE_SIZE( sVecSavePai)] = vecDeleLai[1]
                    sVecSavePai[ TABLE_SIZE( sVecSavePai)+1] = sVecPai[1]
                    sVecSavePai[ TABLE_SIZE( sVecSavePai)+1] = sVecPai[1]+1
                else
                    sVecSavePai[ TABLE_SIZE( sVecSavePai)+1] = sVecPai[1]+1
                    sVecSavePai[ TABLE_SIZE( sVecSavePai)+1] = vecDeleLai[1]
                end
            elseif self:isFind( sVecPai, sVecPai[1]+2) then

                vecDelePai[ TABLE_SIZE( vecDelePai)+1] = sVecPai[1]+2
                sVecSavePai[ TABLE_SIZE( sVecSavePai)+1] = vecDeleLai[1]
                sVecSavePai[ TABLE_SIZE( sVecSavePai)+1] = sVecPai[1]+2
            end

            self:push_back( vecNextPai, sVecPai, 1, TABLE_SIZE( sVecPai))
            self:pop_array( vecNextPai, vecDelePai)
            self:push_back( vecNextLai, sVecLai, 2, TABLE_SIZE( sVecLai))

            if  self:checkHuPai( vecNextPai, vecNextLai, bJiang, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDeleLai))
        end

        -- 一张牌和两个赖子组成的牌
        if  TABLE_SIZE( sVecPai) >= 1 and TABLE_SIZE( sVecLai) >= 2 then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}
            local vecDeleLai = {}

            self:push_back( vecDelePai, sVecPai, 1, 1)
            self:push_back( vecDeleLai, sVecLai, 1, 2)

            self:push_back( vecNextPai, sVecPai, 2, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 3, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            self:push_back( sVecSavePai, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkHuPai( vecNextPai, vecNextLai, bJiang, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDeleLai))
        end

        -- 三张赖子组成的牌
        if  TABLE_SIZE( sVecLai) >= 3 then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDeleLai = {}

            self:push_back( vecDeleLai, sVecLai, 1, 3)

            self:push_back( vecNextPai, sVecPai, 1, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 4, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkHuPai( vecNextPai, vecNextLai, bJiang, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDeleLai))
        end

        -- 两张赖子组成将牌
        if  (not bJiang) and TABLE_SIZE( sVecLai) >= 2 then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDeleLai = {}

            self:push_back( vecDeleLai, sVecLai, 1, 2)

            self:push_back( vecNextPai, sVecPai, 1, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 3, TABLE_SIZE( sVecLai))

            self:push_back( sVecSaveJiang, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkHuPai( vecNextPai, vecNextLai, true, sVecSavePai, sVecSaveJiang) then

                return true
            end
            self:pop_back( sVecSaveJiang, TABLE_SIZE(vecDeleLai))
        end

        return false
    end
end

-- 检查胡牌（7对子)
-- 参数: 检查的普通牌组,检查的赖子组,储存牌
function CDMahjongHCKWX:checkSevenJiang( sVecPai, sVecLai, sVecSavePai)

    if  TABLE_SIZE( sVecPai) == 0 and TABLE_SIZE( sVecLai) == 0 then

        return true
    else

        -- 两张相同牌组成对子
        if  TABLE_SIZE( sVecPai) >= 2 and sVecPai[1] == sVecPai[2] then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}

            self:push_back( vecDelePai, sVecPai, 1, 2)
            self:push_back( vecNextPai, sVecPai, 3, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 1, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            if  self:checkSevenJiang( vecNextPai, vecNextLai, sVecSavePai) then

                return true
            end

            self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
        end
        -- 一张牌一张赖子组成对子
        if  TABLE_SIZE( sVecPai) >= 1 and TABLE_SIZE( sVecLai) >= 1 then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDelePai = {}
            local vecDeleLai = {}

            self:push_back( vecDelePai, sVecPai, 1, 1)
            self:push_back( vecDeleLai, sVecLai, 1, 1)

            self:push_back( vecNextPai, sVecPai, 2, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 2, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDelePai, 1, TABLE_SIZE( vecDelePai))
            self:push_back( sVecSavePai, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkSevenJiang( vecNextPai, vecNextLai, sVecSavePai) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDelePai))
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDeleLai))
        end
        -- 两张赖子组成对子
        if  TABLE_SIZE( sVecLai) >= 2 then

            local vecNextPai = {}
            local vecNextLai = {}
            local vecDeleLai = {}

            self:push_back( vecDeleLai, sVecLai, 1, 2)

            self:push_back( vecNextPai, sVecPai, 1, TABLE_SIZE( sVecPai))
            self:push_back( vecNextLai, sVecLai, 3, TABLE_SIZE( sVecLai))

            self:push_back( sVecSavePai, vecDeleLai, 1, TABLE_SIZE( vecDeleLai))
            if  self:checkSevenJiang( vecNextPai, vecNextLai, sVecSavePai) then

                return true
            end
            self:pop_back( sVecSavePai, TABLE_SIZE(vecDeleLai))
        end

        return false
    end
end
----------------------------------------------------------------------------
-- 判断是否胡牌
-- 参数: 用于检查的有效并且排序（从小到大）过的牌组(牌结构(mahjong,index))
function CDMahjongHCKWX:canHuPai( v_mahjongs)

    local sVecHuPai = {}
    local sVecPai, sVecLai = self:getArray_Pai_Lai( v_mahjongs)
    if  TABLE_SIZE( sVecLai) > 1 then
        return false, sVecHuPai
    end

    local sVecJiang = {}
    local bHuPai = self:checkHuPai( sVecPai, sVecLai, false, sVecHuPai, sVecJiang)
    if  bHuPai then

        self:push_back( sVecHuPai, sVecJiang, 1, 2)
    end

    return bHuPai, sVecHuPai
end

----------------------------------------------------------------------------
-- 判断是否胡牌
-- 参数: 用于检查的有效并且排序（从小到大）过的牌组(mahjong))
function CDMahjongHCKWX:canHuPai_def( mahjongs)

    local sVecHuPai = {}
    local sVecPai, sVecLai = self:getArrayDef_Pai_Lai( mahjongs)
    if  TABLE_SIZE( sVecLai) > 1 then
        return false, sVecHuPai
    end

    local sVecJiang = {}
    local bHuPai = self:checkHuPai( sVecPai, sVecLai, false, sVecHuPai, sVecJiang)
    if  bHuPai then

        self:push_back( sVecHuPai, sVecJiang, 1, 2)
    end

    return bHuPai, sVecHuPai
end
-- 会去除杠的牌,判断能否胡牌
function CDMahjongHCKWX:canHuPai_defEX_old( mahjongs)

    local sVecHuPai = {}
    local sVecPai, sVecLai = self:getArrayDef_Pai_Lai( mahjongs)
    if  TABLE_SIZE( sVecLai) > 1 then
        return false, sVecHuPai
    end

    local gang, array = self:canGangPai_withAllEX( sVecPai)
    if  gang then

        if  TABLE_SIZE( array) >= 4 then        -- add
            self:pop_back( array, 1)            -- add
            self:pop_array( sVecPai, array)
        else                                    -- add
            gang = false                        -- add
        end                                     -- add
    end

    local sVecJiang = {}
    local bHuPai = self:checkHuPai( sVecPai, sVecLai, false, sVecHuPai, sVecJiang)
    if  bHuPai then

        if  gang then                                                  -- add
            self:push_back( sVecHuPai, array, 1, TABLE_SIZE(array))    -- add
        end                                                            -- add
        self:push_back( sVecHuPai, sVecJiang, 1, 2)
    end

    return bHuPai, sVecHuPai
end
-- 会去除杠的牌,判断能否胡牌(递归方式)
function CDMahjongHCKWX:canHuPai_defEX( mahjongs)

    local sVecHuPai = {}
    local sVecPai, sVecLai = self:getArrayDef_Pai_Lai( mahjongs)
    if  TABLE_SIZE( sVecLai) > 1 then
        return false, sVecHuPai
    end

    local bHuPai = false
    local sVecJiang = {}
    local gang, array = self:canGangPai_withAllEX( sVecPai)
    if  gang then

        local gang_pai = {}
        for i = 1, 3 do
            gang_pai[i] = array[1]
        end
        -- 先去除杠牌中的三张作为分开使用
        local temp_pai = {}
        self:push_back( temp_pai, sVecPai, 1, TABLE_SIZE( sVecPai))
        self:pop_array( temp_pai, gang_pai)

        local temp_lai = {}
        self:push_back( temp_lai, sVecLai, 1, TABLE_SIZE( sVecLai))

        bHuPai = self:checkHuPai( temp_pai, temp_lai, false, sVecHuPai, sVecJiang)
        if  bHuPai then

            local hu_pai = {}
            self:push_back( hu_pai, gang_pai,  1, TABLE_SIZE( gang_pai))
            self:push_back( hu_pai, sVecHuPai, 1, TABLE_SIZE( sVecHuPai))
            self:push_back( hu_pai, sVecJiang, 1, 2)
            return true, hu_pai
        end

        -- 去除杠牌中的两张牌作为分开使用
        self:pop_back( gang_pai, 1)
        temp_pai = {}
        self:push_back( temp_pai, sVecPai, 1, TABLE_SIZE( sVecPai))
        self:pop_array( temp_pai, gang_pai)

        temp_lai = {}
        self:push_back( temp_lai, sVecLai, 1, TABLE_SIZE( sVecLai))
        sVecHuPai = {}
        sVecJiang = {}

        bHuPai = self:checkHuPai( temp_pai, temp_lai, false, sVecHuPai, sVecJiang)
        if  bHuPai then

            local hu_pai = {}
            self:push_back( hu_pai, gang_pai,  1, TABLE_SIZE( gang_pai))
            self:push_back( hu_pai, sVecHuPai, 1, TABLE_SIZE( sVecHuPai))
            self:push_back( hu_pai, sVecJiang, 1, 2)
            return true, hu_pai
        end

        -- 没有胡牌
        sVecHuPai = {}
        return false, sVecHuPai
    else

        bHuPai = self:checkHuPai( sVecPai, sVecLai, false, sVecHuPai, sVecJiang)
        if  bHuPai then
            self:push_back( sVecHuPai, sVecJiang, 1, 2)
        end
    end
    return bHuPai, sVecHuPai
end
----------------------------------------------------------------------------
-- 判断是否胡牌根据自己的有效牌组＋别人打的一张牌
-- 参数: 有效牌组列表(牌结构(mahjong,index)), 别人打的牌, 是否可以用赖子(自己有赖子不能捉炮)
function CDMahjongHCKWX:canHuPai_WithOther( v_mahjongs, mahjong, use_laizi)

    local sVecHuPai = {}
    local sVecPai, sVecLai = self:getArray_Pai_Lai( v_mahjongs)
    if  TABLE_SIZE( sVecLai) > 1 then
        return false, sVecHuPai
    end

    sVecPai[ TABLE_SIZE( sVecPai)+1] = mahjong
    self:defMahjongSort_stb( sVecPai)

    if  use_laizi == nil then
        use_laizi = false
    end

    if  TABLE_SIZE(sVecLai) > 0 and (not use_laizi) then -- 有赖子就不能捉炮
        return false, sVecHuPai
    end

    local sVecJiang = {}
    local bHuPai = self:checkHuPai( sVecPai, sVecLai, false, sVecHuPai, sVecJiang)
    if  bHuPai then

        self:push_back( sVecHuPai, sVecJiang, 1, 2)
    end

    return bHuPai, sVecHuPai
end

----------------------------------------------------------------------------
-- 检测牌组＋别人打出的牌所构成的胡是否有效(递归)
-- 别人放胡，要判断我的胡牌里面的各种组合是否只是有别人的牌，而没赖子
-- 参数: 胡牌组，别人打出的牌
function CDMahjongHCKWX:checkHuPai_WithPai( sVecPai, mahjong)

    if  TABLE_SIZE( sVecPai) == 0 then

        return true
    else

        if  TABLE_SIZE( sVecPai) >= 3 then

            local vecDelePai = {}
            self:push_back( vecDelePai, sVecPai, 1, 3)

            local vecNextPai = {}
            self:push_back( vecNextPai, sVecPai, 4, TABLE_SIZE( sVecPai))

            local bFindLai = false
            local bFindMahjong = false
            for i = 1, 3 do

                if  vecDelePai[i] == self:getMahjongLaiZi() then

                    bFindLai = true

                elseif vecDelePai[i] == mahjong then

                    bFindMahjong = true
                end
            end

            -- 假如找到别人的牌，并且没有找到赖子那么胡牌有效
            if  bFindMahjong and (not bFindLai) then
                return true
            end

            return self:checkHuPai_WithPai( vecNextPai, mahjong)
        end

        if  TABLE_SIZE( sVecPai) == 2 then

            local bFindLai = false
            local bFindMahjong = false
            for i = 1, 2 do

                if  sVecPai[i] == self:getMahjongLaiZi() then

                    bFindLai = true
                elseif sVecPai[i] == mahjong then

                    bFindMahjong = true
                end
            end

            -- 假如找到别人的牌，并且没有找到赖子那么胡牌有效
            if  bFindMahjong and (not bFindLai) then
                return true
            end
        end

        return false
    end
end

----------------------------------------------------------------------------
-- 检测牌组＋别人打出的牌所构成的胡是否有效
-- 参数: 胡牌组, 别人打出的牌
function CDMahjongHCKWX:checkHuPai_WithOther( sVecPai, mahjong)

    return self:checkHuPai_WithPai( sVecPai, mahjong)
end

----------------------------------------------------------------------------
-- 判断是否听牌
-- 参数: 有效牌列表(牌结构(mahjong,index))
function CDMahjongHCKWX:canTingPai( v_mahjongs, mahjong)

    -- 分开牌组与赖子后默认添加一张赖子来判断是否胡牌
    local sVecPai, sVecLai = self:getArray_Pai_Lai( v_mahjongs)
    sVecLai[ TABLE_SIZE( sVecLai)+1] = self:getMahjongLaiZi()

    if  mahjong == self:getMahjongLaiZi() then
        self:pop_mahjong( sVecLai, mahjong)
    end
    if  TABLE_SIZE( sVecLai) > 2 then
        return false
    end

    local size = TABLE_SIZE( sVecPai)

    local bTing = false
    local sVecPaiNext = {}
    local sVecSavePai = {}
    local sVecSaveJiang = {}

    self:push_back( sVecPaiNext, sVecPai, 1, TABLE_SIZE( sVecPai))
    if  mahjong ~= self:getMahjongLaiZi() then
        self:pop_mahjong( sVecPaiNext, mahjong)
    end

    if  self:checkHuPai( sVecPaiNext, sVecLai, false, sVecSavePai, sVecSaveJiang) then
        bTing = true
    end

    -- 看看可不可以少一个赖子
    if  mahjong ~= self:getMahjongLaiZi() then

        self:push_back( sVecPaiNext, sVecPai, 1, TABLE_SIZE( sVecPai))
        table.remove( sVecLai, TABLE_SIZE( sVecLai))
        if  self:checkHuPai( sVecPaiNext, sVeclai, false, sVecSavePai, sVecSaveJiang) then
            bTing = true
        end
    end

    return bTing
end
--参数: 有效牌列表数字
--去除杠的牌，判断能否听牌
function CDMahjongHCKWX:canTingPaiEX( mahjongs)

    local sVecPai, sVecLai = self:getArray_Pai_Lai_ex( mahjongs)
    sVecLai[ TABLE_SIZE( sVecLai)+1] = self:getMahjongLaiZi()
    if  TABLE_SIZE( sVecLai) > 2 then
        return false
    end

    local size = TABLE_SIZE( sVecPai)

    local bTing = false
    local sVecPaiNext = {}
    local sVecSavePai = {}
    local sVecSaveJiang = {}

    self:push_back( sVecPaiNext, sVecPai, 1, TABLE_SIZE( sVecPai))
    local gang, array = self:canGangPai_withAllEX( sVecPaiNext)
    if  gang then

        self:pop_array( sVecPaiNext, array)
    end

    if  self:checkHuPai( sVecPaiNext, sVecLai, false, sVecSavePai, sVecSaveJiang) then
        bTing = true
    end
    return bTing
end
----------------------------------------------------------------------------
-- 判断是否杠牌(遍历所有牌)
-- 参数: 有效牌组, 摊开的牌组 (牌结构(mahjong,index)), 以前放弃杠的牌
function CDMahjongHCKWX:canGangPai_withAll( v_mahjongs, s_mahjongs, f_mahjongs)

    local v_size = TABLE_SIZE( v_mahjongs)
    local s_size = TABLE_SIZE( s_mahjongs)

    local v_array = {}
    for i = 1, v_size do
        v_array[i] = v_mahjongs[i].mahjong
    end

    local s_array = {}
    for i = 1, s_size do
        s_array[i] = s_mahjongs[i].mahjong
    end

    if  f_mahjongs ~= nil then

        self:pop_allMahjong( v_array, f_mahjongs)
        v_size = TABLE_SIZE( v_array)
    end

    local array = {}
    local index = 1
    local gang_size = 4
    for i = 1, v_size do

        local mahjong = v_array[i]
        -- cclog( "canGangPai_withAll mahjong => %u", mahjong)
        if mahjong ~= self:getMahjongLaiZi() then

            if  mahjong == self:getMahjongFan() then -- 翻牌3张杠,其他4张杠
                gang_size = 3
            else
                gang_size = 4
            end

            index = 1
            array[index] = mahjong
            for j = i+1, v_size do

                if  v_array[j] == mahjong then

                    array[ index] = mahjong
                    index = index + 1
                    if  index >= gang_size then
                        return true, array
                    end
                else
                    break
                end
            end

            for j = 1, s_size do

                if  s_array[j] == mahjong then

                    index = index + 1
                    if  index >= gang_size then
                        return true, array
                    end
                end
            end
        end
    end
    return false, array
end
function CDMahjongHCKWX:canGangPai_withAllEX( mahjongs)

    local size = TABLE_SIZE( mahjongs)

    local array = {}
    local index = 1
    local gang_size = 4
    for i = 1, size do

        local mahjong = mahjongs[i]
        if  mahjong ~= self:getMahjongLaiZi() then

            if  mahjong == self:getMahjongFan() then
                gang_size = 3
            else
                gang_size = 4
            end

            index = 1
            array[index] = mahjong
            for j = i+1, size do

                if  mahjongs[j] == mahjong then

                    array[ index] = mahjong
                    index = index + 1
                    if  index >= gang_size then
                        return true, array
                    end
                else
                    break
                end
            end
        end
    end
    return false, array
end
-- 参数：手牌或者摊派数组
function CDMahjongHCKWX:getValueFromArr( cards )
    local arr = {}
    if  cards and TABLE_SIZE(cards) > 0 then
        for  i,v in ipairs(cards) do
            if  type(v)=="table" then
                arr[TABLE_SIZE(arr)+1] = v.mahjong
            else
                arr[TABLE_SIZE(arr)+1] = v
            end
        end
        
    end
    return arr
end
-------------------------------------------
function CDMahjongHCKWX:checkAllHuType(sVecPai ,bJiang)
--七对和2，3，3，3，牌型

    local savePai = {}
    local saveJiang = {}
    if  TABLE_SIZE(sVecPai)  ==14 or bJiang then
        --七对
        if  self:checkSevenJiang(sVecPai,sVecLai,savePai) then
            return true,savePai,saveJiang,DEF_HCKWX_QD
        end
        savePai = {}
        saveJiang = {}
    end
    -- 对对胡
    if  self:checkHuPai(sVecPai,sVecLai,bJiang,savePai,saveJiang) then
        return true,savePai,saveJiang,DEF_HCKWX_DDH
    end
    return false
end

function CDMahjongHCKWX:findGang( allCards,value )
    local curCount = 0
    for i,v in ipairs(allCards) do
        if v == value then
            curCount = curCount+1
        end
    end
    if  curCount >=4 then
        return true
    end
    return false
end

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------以下是结算---------------------------------------------------

DEF_HCKWX_DDH     = 1000        -- 对对胡
DEF_HCKWX_QD      = 1001        -- 七对

DEF_HCKWX_TYPE_LD       = 5           -- 亮倒
DEF_HCKWX_TYPE_PH       = 200         -- 屁胡
DEF_HCKWX_TYPE_PPH      = 201         -- 碰碰胡
DEF_HCKWX_TYPE_MSGY     = 202         -- 明四归一
DEF_HCKWX_TYPE_ASGY     = 203         -- 暗四归一
DEF_HCKWX_TYPE_QD       = 204         -- 七对
DEF_HCKWX_TYPE_LQD      = 205         -- 龙七对
DEF_HCKWX_TYPE_SLQD     = 207         -- 双龙七对
DEF_HCKWX_TYPE_DSY      = 208         -- 大三元
DEF_HCKWX_TYPE_XSY      = 209         -- 小三元
DEF_HCKWX_TYPE_QYS      = 210         -- 清一色
DEF_HCKWX_TYPE_SZY      = 211         -- 手抓一
DEF_HCKWX_TYPE_KWX      = 212         -- 卡五星
DEF_HCKWX_TYPE_HDL      = 213         -- 海底捞

DEF_HCKWX_TYPE_ZM        = 214        -- 自摸（杠开，抢杠）
DEF_HCKWX_TYPE_ZC        = 215        -- 捉铳（杠后炮）
DEF_HCKWX_TYPE_FC        = 216        -- 放铳
DEF_HCKWX_TYPE_QG        = 217        -- 抢杠
DEF_HCKWX_TYPE_GSKH      = 218        -- 杠上开花

DEF_HCKWX_TYPE_DG        = 1        -- 点杠
DEF_HCKWX_TYPE_BG        = 2        -- 补杠
DEF_HCKWX_TYPE_AG        = 3        -- 暗杠
DEF_HCKWX_TYPE_GSG       = 8        -- 杠上杠
DEF_HCKWX_TYPE_FG        = 9        -- 放杠

function CDMahjongHCKWX:push_Type( sArray,_type,num )
    local size = TABLE_SIZE( sArray)
    sArray[size+1] = {}
    sArray[size+1].type = _type  -- 类型
    sArray[size+1].num  = num   -- 数量
end

-------明四归一,暗四归一 
-- 返回 0，没有 1，明  2 暗
function CDMahjongHCKWX:checkType_SGY (handCards,lastCard,_huType)
    if  _huType == DEF_HCKWX_QD then
        return false
    end

end


--对对胡
function CDMahjongHCKWX:checkType_DDH( handCards,isYH,_winType)
    if  _winType ~= DEF_HCKWX_DDH then
        return false
    end
    local size = TABLE_SIZE( handCards)
    if  size == 2 then
        return true
    end

    local isDDH = false
    
    local sVPai, sVLai = self:getArray_Pai_Lai_ex( handCards)
    if  isYH then
        self:push_back(sVPai,sVLai,1,TABLE_SIZE(sVLai))
        self:defMahjongSort_stb(sVPai)
        sVLai = {}
    end

    local curLai ={}
    local curCheckPai = {} 
    self:push_back(curLai,sVLai,1,TABLE_SIZE(sVLai))
    self:push_back(curCheckPai,sVPai,1,TABLE_SIZE(sVPai))

    local curMahjong = 0
    local curMatchArr = {}
    for i=1,TABLE_SIZE(curCheckPai) do
        if  curCheckPai[i]~= curMahjong then
            curMahjong = curCheckPai[i]
            local curArr = self:findKeZi(curCheckPai,curMahjong)
            curMatchArr[TABLE_SIZE(curMatchArr)+1] = curArr
        end
    end
    local newMatchArr = {}
    for i,v in ipairs(curMatchArr) do
        if  TABLE_SIZE(v)>3 then  -- 有杠牌在手
            local detailArr = {}
            self:push_back(detailArr,v,1,4)
            if  TABLE_SIZE(curLai)>1 then
                self:push_mahjong(detailArr,curLai[1])
                self:pop_mahjong(curLai,curLai[1])
                self:push_mahjong(detailArr,curLai[1])
                self:pop_mahjong(curLai,curLai[1])
            end
            newMatchArr[TABLE_SIZE(newMatchArr)+1]=detailArr
        elseif  TABLE_SIZE(v)==3 then
            local detailArr = {}
            self:push_back(detailArr,v,1,3)
            newMatchArr[TABLE_SIZE(newMatchArr)+1]=detailArr
        elseif TABLE_SIZE(v)==2 then
            local detailArr = {}
            self:push_back(detailArr,v,1,2)
            if  TABLE_SIZE(curLai)>0 then
                self:push_mahjong(detailArr,curLai[1])
                self:pop_mahjong(curLai,curLai[1])
            end
            newMatchArr[TABLE_SIZE(newMatchArr)+1]=detailArr
        elseif TABLE_SIZE(v)==1 then
            local detailArr = v
            if  TABLE_SIZE(curLai)>1 then
                self:push_mahjong(detailArr,curLai[1])
                self:pop_mahjong(curLai,curLai[1])
                self:push_mahjong(detailArr,curLai[1])
                self:pop_mahjong(curLai,curLai[1])
            end
            newMatchArr[TABLE_SIZE(newMatchArr)+1]=detailArr
        end
    end

    local oneIndex = 0
    local twoIndex = 0
    local fourIndex = 0
    for i,v in ipairs(newMatchArr) do
        if  TABLE_SIZE(v)==1 then
            oneIndex = oneIndex+1
        elseif TABLE_SIZE(v)==2 then
            twoIndex = twoIndex+1
        elseif TABLE_SIZE(v)==4 then
            fourIndex = fourIndex+1
        end
    end
    local leftCount = TABLE_SIZE(curLai)

    if  (twoIndex ==1 and fourIndex ==0 and oneIndex==0 and (leftCount==0 or (leftCount>0 and leftCount%3 == 0))) or
        (oneIndex ==1 and fourIndex ==0 and twoIndex==0 and (leftCount==1 or (leftCount>1 and (leftCount-1)%3==0))) or
        (oneIndex ==0 and fourIndex ==0 and twoIndex==0 and (leftCount==2 or (leftCount>2 and (leftCount-2)%3==0))) or
        (oneIndex ==0 and twoIndex ==0 and (fourIndex==1 and (leftCount==1 or (leftCount>1 and (leftCount-1)%3==0))))then

        isDDH = true
    end

    return isDDH
end

------七对，龙七对，双龙七对的判断
---------------------------------------------------
 function CDMahjongHCKWX:checkType_QD (_huType,handCards)
    if  _huType ~= DEF_HCKWX_QD then 
        return 0
    end
    -- 找到杠
    local curMahjong = 0
    local findNum = 0
    for i,v in ipairs(handCards) do
        if  vcurMahjong ~= v then
            curMahjong = v
            if  self:findGang(handCards,v) then
                findNum =findNum +1
            end
        end
    end

    if findNum == 0 then
        return DEF_HCKWX_TYPE_QD
    elseif findNum == 1 then
        return DEF_HCKWX_TYPE_LQD
    elseif findNum>=2 then
        return DEF_HCKWX_TYPE_SLQD
    end
    return 0
 end

-----大三元和小三元的判断
-- 参数：手牌，七对 或者是 对对胡
-- 返回 0 没有 1小三元  2 大三元
function CDMahjongHCKWX:checkType_DaOrXiaoSanYuan(mahjongs,_huType)

    if _huType ~= DEF_HCKWX_TYPE_DSY or _huType ~= DEF_HCKWX_TYPE_XSY then
        return 0
    end

    if TABLE_SIZE(mahjongs) < 8 then
        return 0
    end

    local array = {}

    for i ,v in ipairs(mahjongs) do 
        if v == 51 or v == 52 or v ==53 then
            if array[v] == nil then
                array[v] = {}
            end
            self:push_mahjong(array[v],v)
        end
    end
    if TABLE_SIZE(array) < 3 then
        return 0
    end
    local  countKeZi = 0
    local  countJiang = 0
    if TABLE_SIZE(array) == 3 then
        for j,k in ipairs(array) do
            if TABLE_SIZE(k) >= 3 then
                countKeZi = countKeZi +1
            elseif TABLE_SIZE(k) == 2 then
                countJiang =countJiang +1
            end
        end
        if countKeZi == 3 then
            return 2
        end
        if countKeZi == 2 and countJiang == 1 then
            return 1
        end
    end

    return 0 
end

-- 清一色
------------------------------------------------------------------------
function CDMahjongHCKWX:checkQYS( handPai,outCards, isCheckOutCards)
    local curMatchValue = 0
    local curOutCards = self:getValueFromArr(outCards)
    if  isCheckOutCards and TABLE_SIZE(curOutCards) > 0 then
        curMatchValue = self:checkWithQYSAndFYS(curOutCards[1])
        for i ,v in ipairs(curOutCards) do
            if self:checkWithQYSAndFYS(v) ~= curMatchValue then
                return false
            end
        end
    end
    local  curHandCard = self:getValueFromArr(handPai)
    local sVecPai, sVecLai = self:getArrayDef_Pai_Lai( curHandCard)
    if  TABLE_SIZE(sVecPai) > 0 then
        if  curMatchValue == 0 then
            curMatchValue = self:checkWithQYSAndFYS(sVecPai[1])
        end

        for i ,v in ipairs(sVecPai) do
            if self:checkWithQYSAndFYS(v) ~= curMatchValue then
                return false
            end
        end
    end
    return true
end

--  手抓一(sTarry:摊派组，mahjongs：手牌)
function CDMahjongHCKWX:checkSZY(sTarry,mahjongs)


end

--
-- 返回胡牌类型
function CDMahjongHCKWX:checkIsKWX( handCards,lastCard )
    
    if  math.floor(lastCard%10) == 5 then
        local curSaveArr = {}
        local curCheckArr = {}
        local isKWX = false
        self:push_back(curCheckArr,handCards,1,TABLE_SIZE(handCards))
        if  self:isFind(handCards,lastCard +1) then
            if  self:isFind(handCards,lastCard - 1) then
                self:push_mahjong(curSaveArr,lastCard)
                self:push_mahjong(curSaveArr,lastCard+1)
                self:push_mahjong(curSaveArr,lastCard-1)
                self:pop_array(curCheckArr,curSaveArr)
                local sVecPai,sVecLai = self:getArray_Pai_Lai_ex(curCheckArr)
                local saveHuPai = {}
                local saveJiang = {}
                if  self:checkHuPai(sVecPai,sVecLai,false,saveHuPai,saveJiang) then
                    return true
                end
            end
           
        end
    end
    return false
end

-- 参数：手牌 摊派 亮倒 海底捞 赢的方式（杠后开花 自摸捉炮 杠后跑）
function CDMahjongHCKWX:getAllType(handCards,outCards,isLD,isHDL,_winType )
    local allType = {}
    if  isLD then
        self:push_Type(allType,isLD,1)
    end
    if  isHDL then
        self:push_Type(allType,isHDL,1)
    end
    if  self:checkQYS(handCards,outCards) then
        self:push_Type(allType,DEF_HCKWX_TYPE_QYS,1)
    end
    self:push_Type(allType,_winType,1)

    if  TABLE_SIZE(handCards) == 14 then
        local sVecPai,sVecLai = self:getArray_Pai_Lai_ex(handCards)
        local savePai = {}
        local isQD = self:checkSevenJiang(sVecPai,sVecLai,savePai)
        local QDFan = 0
        local DDHFan = 0

        local QDTypeArr = {}
        if  isQD then
            local QDNum = self:checkType_QD(DEF_HCKWX_QD,handCards)
            if  QDNum == DEF_HCKWX_TYPE_SLQD then
                self:push_Type(allType,DEF_HCKWX_TYPE_SLQD,1)
                return allType
            end
            if  QDNum == DEF_HCKWX_TYPE_LQD then
                QDFan = 8
                local SYNum = self:checkType_DaOrXiaoSanYuan()
                if  SYNum == 1 then
                    QDFan = QDFan * 4
                elseif SYNum == 2 then
                    QDFan = QDFan *8 
                end
            elseif QDNum == DEF_HCKWX_TYPE_QD then
                QDFan = 4 
            end
        end

        local DDHTypeArr = {}
        if  self:checkIsKWX(handCards,lastCard) then
            DDHFan=2
            self:push_mahjong()
            local SGYNum = self:checkType_SGY(handCards,lastCard,DEF_HCKWX_DDH) 
            if  SGYNum == 1 then
                DDHFan = DDHFan *2
            elseif SGYNum == 2 then
                DDHFan = DDHFan*4
            end
            local SYNum = self:checkType_DaOrXiaoSanYuan()
            if  SYNum == 1 then
                DDHFan = DDHFan * 4
            elseif SYNum == 2 then
                DDHFan = DDHFan *8 
            end
            if  _winType == DEF_HCKWX_TYPE_GSKH then
                DDHFan = DDHFan * 2
            end
        else

        end

        if  DDHFan > QDFan then
            for i,v in ipairs(DDHTypeArr) do
            end
        else
            for i,v in ipairs(QDTypeArr) do
            end
        end

    else
        if  self:checkIsKWX(handCards,lastCard) then
            self:push_Type(allType,DEF_HCKWX_TYPE_KWX)
        end
    end
end  

----------------------------------------------------------------------------
-- 创建干瞪眼数学库
function CDMahjongHCKWX.create()
    cclog("CDMahjongHCKWX.create")
    local   instance = CDMahjongHCKWX.new()
    return  instance
end