--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       CDMahjongHHLLKFKBNTMath(听牌高手数学库)
//File Name:    HHLLK_mahjong_fkbnt_math.h
//Author:       GostYe
//Start Data:   2018.09.12
//Language:     XCode 4.5
//Target:       IOS, Android
/****************************************************************************
-- 使用：（创建对象后）
]]

require( REQUIRE_PATH.."DCCBHHLLKBaseLayer")
require( REQUIRE_PATH.."DDefine")

CDMahjongHHLLKFKBNTMath = class("CDMahjongHHLLKFKBNTMath")
CDMahjongHHLLKFKBNTMath.__index = CDMahjongHHLLKFKBNTMath

----------------------------------------------------------------------------
-- 构造函数
function CDMahjongHHLLKFKBNTMath:ctor()
    cclog("CDMahjongHHLLKFKBNTMath::ctor")
    self:init()
end

----------------------------------------------------------------------------
-- 成员变量定义
CDMahjongHHLLKFKBNTMath.m_arrayHHLLKGridGroup = {}         -- 格子图像配置
CDMahjongHHLLKFKBNTMath.m_arrayHHLLKCheckerBoard = {}      -- 棋盘

----------------------------------------------------------------------------
-- 宏定义
DEF_HHLLK_FKBNY_MATH_ROW    = 10    -- 行
DEF_HHLLK_FKBNY_MATH_COLUMN = 10    -- 列

DEF_HHLLK_FKBNY_MATH_BASE_SCORE = 10    -- 消除基数积分

----------------------------------------------------------------------------
-- 释放
function CDMahjongHHLLKFKBNTMath:release()
    cclog("CDMahjongHHLLKFKBNTMath::release")
end

----------------------------------------------------------------------------
-- 初始化
function CDMahjongHHLLKFKBNTMath:init()
    -- 导入麻将牌型配置
    for i = 1, DEF_HHLLK_FKBNY_MATH_COLUMN do
        self.m_arrayHHLLKCheckerBoard[i] = {}
        for j = 1, DEF_HHLLK_FKBNY_MATH_ROW do
            local tmp = {}
            tmp.x = j
            tmp.y = i
            tmp.isVisible = false
            tmp.item = nil

            self:push_card(self.m_arrayHHLLKCheckerBoard[i], tmp)
        end
    end

    -- 生成供选择的方块集合
    self.m_arrayHHLLKGridGroup = {
        -- 图像:
        -- *
        [1]={{1}},

        -- 图像:
        -- **   *
        --    , *
        [2]={{1,1}},
        [3]={{1},{1}},

        -- 图像:
        -- ***   *
        --       *
        --     , *
        [4]={{1,1,1}},
        [5]={{1},{1},{1}},

        -- 图像:
        -- ****   *
        --        *
        --        *
        --      , *
        [6]={{1,1,1,1}},
        [7]={{1},{1},{1},{1}},

        -- 图像:
        -- *****   *
        --         *
        --         *
        --         *
        --       , *
        [8]={{1,1,1,1,1}},
        [9]={{1},{1},{1},{1},{1}},

        -- 图像:
        -- *    **   **    *
        -- ** ,  * , *  , ** 
        [10]={{1,1},{1,0}},
        [11]={{0,1},{1,1}},
        [12]={{1,0},{1,1}},
        [13]={{1,1},{0,1}},

        -- 图像:
        -- *     ***   ***     *
        -- *       *   *       *
        -- *** ,   * , *   , ***
        [14]={{1,1,1},{1,0,0},{1,0,0}},
        [15]={{0,0,1},{0,0,1},{1,1,1}},
        [16]={{1,0,0},{1,0,0},{1,1,1}},
        [17]={{1,1,1},{0,0,1},{0,0,1}},

        -- 图像:
        -- **
        -- **
        [18]={{1,1},{1,1}},

        -- 图像:
        -- ***
        -- ***
        -- ***
        [19]={{1,1,1},{1,1,1},{1,1,1}}
    }
end

----------------------------------------------------------------------------
---push_back 根据指定位置将数组压入到指定数组
---@param sArray table 指定被压入数组（返回）
---@param sVector table 需要压入的数组
---@param nBegin number 开始位置
---@param nEnd number 结束位置
function CDMahjongHHLLKFKBNTMath:push_back( sArray, sVector, nBegin, nEnd)
    if  TABLE_SIZE(sVector) < nEnd then
        return
    end
    if  nBegin and nEnd then
        for i = nBegin, nEnd do
            sArray[TABLE_SIZE(sArray) + 1] = sVector[i]
        end
    end
end

---push_card 将单牌添加入数组
---@param sArray table 指定被添加的数组(返回)
---@param value number 需要添加的牌
function CDMahjongHHLLKFKBNTMath:push_card( sArray,value)
    if  sArray and value then
        sArray[TABLE_SIZE(sArray)+1] = value
    end
end

---pop_back 删除数组从数组最后开始
---@param sArray table 被删除的指定数组
---@param count number 删除的数量
function CDMahjongHHLLKFKBNTMath:pop_back( sArray, count)
    local size = TABLE_SIZE(sArray)
    if  size == 0 or count > size then
        return
    end
    for i = 1, count do
        size = TABLE_SIZE( sArray)
        table.remove( sArray, size)
    end
end

---pop_array 删除数组从数组中找
---@param sArray table 需要进行删除的数组
---@param sVector table 用于删除的数组
function CDMahjongHHLLKFKBNTMath:pop_array( sArray, sVector)
    local size  = TABLE_SIZE(sArray)
    local count = TABLE_SIZE(sVector)

    if  size == 0 or count == 0 then
        return
    end
    for i = 1, count do
        size = TABLE_SIZE(sArray)
        for j = 1, size do
            if  sArray[j] == sVector[i] then
                table.remove( sArray, j)
                break
            end
        end
    end
end

---pop_card 删除数组从数组中找指定的牌（只删除一张相同的牌)
---@param sArray table 被删除的指定数组
---@param card number 要删除的牌
function CDMahjongHHLLKFKBNTMath:pop_card( sArray, card)
    local size = TABLE_SIZE(sArray)
    if  size == 0 then
        return
    end
    for i = 1, size do
        if  sArray[i] == card then
            table.remove(sArray, i)
            return
        end
    end
end

--- Describe what CDMahjongHHLLKFKBNTMath:randmSort 随机排序，打乱数组顺序 
-- @param _tArray table-array 需要乱序的数组
-- @return nil
function CDMahjongHHLLKFKBNTMath:randmSort(_tArray)
    local nSize = TABLE_SIZE(_tArray)
    if _tArray and nSize > 0 then
        -- 设置随机种子
        -- math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
        math.randomseed(tostring(socket.gettime()):reverse():sub(1, 6)) 

        local nTemp
        for i, v in ipairs(_tArray) do
            local nPos = math.random(1, TABLE_SIZE(_tArray));    --从10个数中取出一个和a[i]交换，可能是它自己。
            nTemp = _tArray[i];
            _tArray[i] = _tArray[nPos];
            _tArray[nPos] = nTemp;
        end
    end
end

----------------------------------------------------------------------------
-- 获取指定方块在格子中的实际位置
-- @param _nStart_x number:放置格子的起始x的index
-- @param _nStart_y number:放置格子的起始y的index
-- @param _nGroupIndex number:需要放置的格子index
-- @return table :放置格子的实际位置
function CDMahjongHHLLKFKBNTMath:getGridPos(_nStart_x, _nStart_y, _nGroupIndex)
    if  self.m_arrayHHLLKGridGroup[_nGroupIndex] == nil then
        return
    end

    local tTmpRet = {}
    for i, v1 in ipairs( self.m_arrayHHLLKGridGroup[_nGroupIndex] ) do
        for j, v2 in ipairs( v1 ) do
            if  v2 == 1 then
                local tTmp = {}
                tTmp.x = _nStart_x + j - 1
                tTmp.y = _nStart_y + i - 1

                self:push_card(tTmpRet, tTmp)
            end
        end
    end

    if self.m_arrayHHLLKGridGroup[_nGroupIndex][1][1] == 0 then
        for i, v in ipairs( tTmpRet ) do
            v.y = v.y - (TABLE_SIZE(self.m_arrayHHLLKGridGroup[_nGroupIndex]) - 1)
        end
    end
    return tTmpRet
end

-- 检测可消除的行、列
-- @return table tmpRetPos:可消除的格子
-- @return number tmpScore:每个方块的积分
-- @return number tmpTotleScore:消除后的总积分
function CDMahjongHHLLKFKBNTMath:checkEliminateRowAndColumn()
    local tmpRow = {}
    for i = 1, DEF_HHLLK_FKBNY_MATH_ROW do
        tmpRow[i] = true
    end

    local tmpColumn = {}
    for i = 1, DEF_HHLLK_FKBNY_MATH_COLUMN do
        tmpColumn[i] = true
    end

    for i, v1 in ipairs( self.m_arrayHHLLKCheckerBoard ) do
        for j, v2 in ipairs( v1 ) do
            tmpRow[v2.x] = v2.isVisible and tmpRow[v2.x]
            tmpColumn[v2.y] = v2.isVisible and tmpColumn[v2.y]
        end
    end

    local retRow = {}
    for i, v in ipairs( tmpRow ) do
        if  v then
            self:push_card(retRow, i)
        end
    end

    local retColumn = {} 
    for i, v in ipairs( tmpColumn ) do
        if  v then
            self:push_card(retColumn, i)
        end
    end

    local tmpScore = (TABLE_SIZE(retRow) + TABLE_SIZE(retColumn)) * DEF_HHLLK_FKBNY_MATH_BASE_SCORE
    local tmpRetPos = {}
    for i, v in ipairs( retRow ) do
        for j = 1, DEF_HHLLK_FKBNY_MATH_ROW do
            local tmp = {}
            tmp.x = v
            tmp.y = j 
            self:push_card(tmpRetPos, tmp)
        end
    end
    for i, v in ipairs( retColumn ) do
        for j = 1, DEF_HHLLK_FKBNY_MATH_COLUMN do
            local tmpIsExist = false
            local tmp = {}
            tmp.x = j
            tmp.y = v
            for i, v in ipairs( tmpRetPos ) do
                if  v.x == tmp.x and v.y == tmp.y then
                    tmpIsExist = true
                    break
                end
            end

            if  not tmpIsExist then
                self:push_card(tmpRetPos, tmp)
            end
        end
    end

    local tmpTotleScore = TABLE_SIZE(tmpRetPos) * tmpScore

    return tmpRetPos, tmpScore, tmpTotleScore
end

-- 检测指定格子图形是否可以放置
-- @param _gridPos array:图形样子
-- @return boolen:是否可以放置
function CDMahjongHHLLKFKBNTMath:checkIsPlaceGrid(_gridPos)
    for i, v in ipairs( _gridPos ) do
        -- 检测行有无超出棋盘
        if  v.x < 1 or v.x > DEF_HHLLK_FKBNY_MATH_ROW then
            return false
        end
        -- 检测列有无超出棋盘
        if  v.y < 1 or v.y > DEF_HHLLK_FKBNY_MATH_COLUMN then
            return false
        end
        -- 检测该位置是否已经有格子占有
        if  self.m_arrayHHLLKCheckerBoard[v.y][v.x].isVisible then
            return false
        end
    end

    return true
end

-- 检测指定剩余的格子是否还能放置在棋盘上
-- @param _arrayGridIndex array:格子的图样的Index
-- @return boolen:是否可以放置
function CDMahjongHHLLKFKBNTMath:checkLeftGridIsPlace(_arrayGridIndex)
    for iIndex, vIndex in ipairs( _arrayGridIndex ) do
        for i, v1 in ipairs( self.m_arrayHHLLKCheckerBoard ) do
            for j, v2 in ipairs( v1 ) do
                local tmpGrid = self:getGridPos(v2.x, v2.y, vIndex)
                if  self:checkIsPlaceGrid(tmpGrid) then
                    return true
                end
            end
        end
    end

    return false
end

-- 获取一个可以放置的格子
-- @return boolen:是否成功获取到
-- @return array:获取到的格子图形
function CDMahjongHHLLKFKBNTMath:getOneCanPlaceGrid()
    local tmpCanEliminateGroup = {}
    for index = TABLE_SIZE(self.m_arrayHHLLKGridGroup), 1, -1 do
        for i, v1 in ipairs( self.m_arrayHHLLKCheckerBoard ) do
            for j, v2 in ipairs( v1 ) do
                local tmpGrid = self:getGridPos(v2.x, v2.y, index)
                if  self:checkIsPlaceGrid(tmpGrid) then
                    self:push_card(tmpCanEliminateGroup, index)
                end
            end
        end
    end

    local tmpSize = TABLE_SIZE(tmpCanEliminateGroup)
    if  tmpSize > 0 then
        math.randomseed(tostring(socket.gettime()):reverse():sub(1, 6))
        local tmpIndex = 0
        for i = 1, 2 do
            tmpIndex = math.random(1, TABLE_SIZE(tmpCanEliminateGroup))
        end
        return true, tmpCanEliminateGroup[tmpIndex]
    else
        return false, nil      
    end
end

-- 获取三个放置的格子
-- @return boolen:是否成功获取到
-- @return array:获取到的三个格子图形组
function CDMahjongHHLLKFKBNTMath:getThreeGrid()
    local tmpThreeGrid = {}
    local tmpIsGetOk = false
    local tmpIsPlaceGrid = {}
    tmpIsGetOk, tmpIsPlaceGrid = self:getOneCanPlaceGrid()
    if  not tmpIsGetOk then
        return false, nil
    else
        self:push_card(tmpThreeGrid, tmpIsPlaceGrid)
    end

    for i = 1, 2 do
        local tmpIndex = math.random(1, TABLE_SIZE(self.m_arrayHHLLKGridGroup)) 
        self:push_card(tmpThreeGrid, tmpIndex)
    end
    return true, tmpThreeGrid
end

-- 获取3种颜色
-- @return array:乱序后的RGB颜色组
function CDMahjongHHLLKFKBNTMath:getThreeColor()
    local tmpColorGroup = {}
    tmpColorGroup[1] = cc.c3b(0,162,0)      -- 绿
    tmpColorGroup[2] = cc.c3b(254,226,62)   -- 黄
    tmpColorGroup[3] = cc.c3b(80,188,244)   -- 蓝

    -- 将颜色进行乱序
    self:randmSort(tmpColorGroup)

    return tmpColorGroup
end

-- 获取对应形状格子的类型值
-- @param _gridData array: 图形样子
-- @return number: 获取的类型值
function CDMahjongHHLLKFKBNTMath:getGridType(_nGridIndex)
    if  _nGridIndex == nil then
        return -1 
    end

    -- type类型定义
    -- -1: 获取类型失败
    -- 0: 左下角有方块类型
    -- 1: 左上角有方块类型
    if  self.m_arrayHHLLKGridGroup[_nGridIndex][1][1] == 1 then
        return 0
    else
        return 1
    end
end

----------------------------------------------------------------------------
-- 创建连连看数学库
function CDMahjongHHLLKFKBNTMath.create()
    cclog("CDMahjongHHLLKFKBNTMath.create")
    local   instance = CDMahjongHHLLKFKBNTMath.new()
    return  instance
end
