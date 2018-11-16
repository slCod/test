--[[
	数字消消乐
	点击加1 相同的至少三个相邻则保留一个最后点击的数字（若没有点击 则随机保留一个数字）加1 其他消除 并且上面的掉落下来 形成新的布局
	消除方向 从左往右 从上往下  x或y相差1 并且数字相同的个数 >= 3 即可满足消除
	布局  横向 DEF_NUMGAME_MAXH  纵向 DEF_NUMGAME_MAXV 生成的数字 （1,DEF_NUMGAME_MAXINDEX） 最大点击次数 DEF_NUMGAME_MAXCHANGE   每个数字的得分为 DEF_NUMGAME_ONESCORE
	每次成功消除则DEF_NUMGAME_MAXCHANGE 加1 最大为 DEF_NUMGAME_MAXCHANGE
	计算得分公示是 allScore = 基础得分*合并的数字*合并的数量
	DEF_NUMGAME_MAXCHANGE 为0，并且没有消除的时候 则结束游戏

--]]
require( REQUIRE_PATH.."DCCBLayer")
require( REQUIRE_PATH.."DDefine")

CDGameNumDestory = class("CDGameNumDestory")
CDGameNumDestory.__index = CDGameNumDestory

DEF_NUMGAME_MAXH = 8
DEF_NUMGAME_MAXV = 8
DEF_NUMGAME_MAXINDEX = 6
DEF_NUMGAME_MAXCHANGE = 6 
DEF_NUMGAME_ONESCORE = 10

----------------------------------------------------------------------------
-- 构造函数
function CDGameNumDestory:ctor()
    cclog("CDGameNumDestory::ctor")
    self:init()
end
----------------------------------------------------------------------------
-- 初始化
function CDGameNumDestory:init()
	self.m_nLastShowNum = 0
	self.m_nSameNumCount = 1
	-- 从上往下生成
	self.m_sNumGroup = {}
	local index = 1
	for i = 1,DEF_NUMGAME_MAXV do
		for j=1,DEF_NUMGAME_MAXH do
			self.m_sNumGroup[index] = {}
			self.m_sNumGroup[index].item = nil  					-- item类
			self.m_sNumGroup[index].num = 0							-- 数字
			self.m_sNumGroup[index].index_h = j 					-- 横向的索引
			self.m_sNumGroup[index].index_v = i  					-- 纵向的索引
			self.m_sNumGroup[index].init_h  = j 					-- 出生的横向索引
			self.m_sNumGroup[index].init_v  = i-7 					-- 出生的纵向索引
			self.m_sNumGroup[index].move_v  = 0         			-- 向下移动的纵向索引
			self.m_sNumGroup[index].bvisible = false    			-- 
			index = index+1
		end
	end

	self.m_nLeftChange = self:getMaxChange()
	self.m_sChangeArr = {}

	self.m_nMaxCount = DEF_NUMGAME_MAXH * DEF_NUMGAME_MAXV

	self.m_sColorArr = {[0]={r=250,g=114,b=184},
						[1]={r=130,g=228,b=82},[2]={r=23,g=215,b=86},[3]={r=97,g=184,b=19},[4]={r=34,g=139,b=246},
						[5]={r=60,g=103,b=240},[6]={r=27,g=195,b=244},[7]={r=132,g=35,b=214},[8]={r=183,g=39,b=237},
						[9]={r=255,g=215,b=29},[10]={r=252,g=176,b=55},[11]={r=254,g=122,b=34},[12]={r=254,g=98,b=78},
					   	[13]={r=244,g=70,b=52},[14]={r=215,g=47,b=99},[15]={r=245,g=50,b=146},[16]={r=243,g=61,b=241},
					   	[17]={r=195,g=207,b=3},[18]={r=255,g=230,b=141},[19]={r=11,g=225,b=157},[20]={r=49,g=240,b=247},
					   	[21]={r=111,g=182,b=255},[22]={r=103,g=75,b=225},[23]={r=168,g=110,b=255},[24]={r=217,g=25,b=224},
					   	[25]={r=70,g=70,b=236},[26]={r=73,g=182,b=51},[27]={r=165,g=253,b=70},[28]={r=13,g=162,b=38},
					   	[29]={r=240,g=139,b=255},[30]={r=236,g=229,b=31},[31]={r=226,g=253,b=73},[32]={r=201,g=126,b=6},
						}
    
end

function CDGameNumDestory:getMaxCount( ... )
	return self.m_nMaxCount
end

function CDGameNumDestory:getMaxChange( ... )
	return DEF_NUMGAME_MAXCHANGE
end

function CDGameNumDestory:resetLeftChange( ... )
	self.m_nLeftChange = self:getMaxChange()
end

--flag 1, 2 
function CDGameNumDestory:insRandomNum( _index,flag)
	local needRandNum = 0
	local configArr = nil
	if flag == 1 then 
		configArr = {	[1]= {1,3,5},
						[2]= {2,4,6},
					 }
		needRandNum = 3
	else 
		configArr = {	[1]= {11,13,15,17},
						[2]= {12,14,16,18},
					}
		needRandNum = 4
	end
	local newArr = configArr[_index%2+1]
	local randNum = newArr[math.random(1,needRandNum)] 
	if 	self.m_nLastShowNum == randNum then
		if self.m_nSameNumCount == 2 then
		
			for i,v in ipairs(newArr) do
				if 	v == randNum then
					table.remove(newArr,i)
					break
				end
			end
			randNum = newArr[math.random(1,needRandNum-1)]
			self.m_nSameNumCount = 1
		else
			self.m_nSameNumCount = self.m_nSameNumCount+1
		end
	end
	self.m_nLastShowNum = randNum
	return randNum
	
end

----------------------------------------------------------------------------
-- 释放
function CDGameNumDestory:release()
    cclog("CDGameNumDestory::release")
    for i,v in ipairs(self.m_sNumGroup) do
    	self.m_sNumGroup[i]= {}
    end
    self.m_sNumGroup[i] = {}
end

----------------------------------------------------------------------------
-- 检测是否可以消除  -- 从上往下检测，x或y相差1 并且数字相同的个数 >= 3 即可满足消除

-- 寻找对应位置的item元素
-- 参数：横向索引 纵向索引
function CDGameNumDestory:findMatchItem( _h,_v )
	for i,v in ipairs(self.m_sNumGroup) do
		if 	v.index_h == _h and v.index_v == _v then
			return v
		end
	end
	return nil
end

-- 检测是否含有相同的元素
-- 参数：保存的数字，需要添加的元素
function CDGameNumDestory:checkHadSameItem( _saveArr,_value )
	for i,v in ipairs(_saveArr) do
		if 	v.index_h == _value.index_h and v.index_v == _value.index_v then
			return false
		end
	end
	return true
end

-- 寻找相同的元素
-- 参数：检查的元素
function CDGameNumDestory:checkSameItem( _saveArr,_item )

	local curSaveArr = {}
	local check_h = _item.index_h
	local check_v = _item.index_v
	local check_num = _item.num

	if 	self:checkHadSameItem(_saveArr,_item) then
		table.insert(_saveArr,_item)
	end
	
	local item_h = self:findMatchItem(check_h+1,check_v)
	
	if 	item_h and item_h.num == check_num then

		table.insert(curSaveArr,item_h)
	end

	local item_h_1 = self:findMatchItem(check_h-1,check_v)
	
	if 	item_h_1 and item_h_1.num == check_num then

		table.insert(curSaveArr,item_h_1)
	end

	local item_v = self:findMatchItem(check_h,check_v+1)
	
	if 	item_v and item_v.num == check_num then

		table.insert(curSaveArr,item_v)
	end

	if 	TABLE_SIZE(curSaveArr) == 0 then
		return false,_saveArr
	end
	local loopArr = {}
	for i,v in ipairs(curSaveArr) do
		if 	self:checkHadSameItem(_saveArr,v) then
			table.insert(loopArr,v)
			table.insert(_saveArr,v)
		end
	end
	local matchCount = TABLE_SIZE(loopArr)

	if 	matchCount == 1 then
		if 	not self:checkSameItem(_saveArr,loopArr[1]) then
			return false,_saveArr
		end

	elseif matchCount == 2 then
		if 	not self:checkSameItem(_saveArr,loopArr[1]) and 
			not self:checkSameItem(_saveArr,loopArr[2]) then

			return false,_saveArr
		end
	elseif matchCount == 3 then
		if 	not self:checkSameItem(_saveArr,loopArr[1]) and 
			not self:checkSameItem(_saveArr,loopArr[2]) and 
			not self:checkSameItem(_saveArr,loopArr[3]) then

			return false,_saveArr
		end
	end
	
	return false,_saveArr
end


-- 检测可以消除的数字 每次点击一次和生成新的数字的时候调用
-- 参数：null
-- 返回：可以消除的item数组
function CDGameNumDestory:checkCanDestory()
	local isFindSame = false
	local destoryArr = {}

	for i = 1,DEF_NUMGAME_MAXH do
		for j=1,DEF_NUMGAME_MAXV do
			local curIndex = 8 * (i-1) + j
			local saveArr = {}
			self:checkSameItem(saveArr,self.m_sNumGroup[curIndex])
			if 	TABLE_SIZE(saveArr) >= 3 then
				isFindSame = true
				for i,v in ipairs(saveArr) do
					table.insert(destoryArr,v)
				end
				break
			end
		end
		if 	isFindSame then
			break
		end
	end

	return destoryArr
end

function CDGameNumDestory:checkDestoryItem(flag,_destoryArr,touch_h,touch_v)
	local curItem = nil
	self.m_sChangeArr = {}
	self.m_pChangeItem = nil
	if 	touch_h and touch_h > 0 and touch_v and touch_v > 0 then
		curItem = self:findMatchItem(touch_h,touch_v)
	else

		local curSize = TABLE_SIZE(_destoryArr) 
		local stayIndex = math.random(1,curSize)
		curItem = _destoryArr[stayIndex]
	end

	local curItemNum = curItem.num
	if 	curItem then
		local item_num = curItem.num
		for i,v in ipairs(self.m_sNumGroup) do
			if 	v.index_h == curItem.index_h and v.index_v == curItem.index_v then

				self.m_pChangeItem = self.m_sNumGroup[i].item

				print("curItem.num1111111111111111--->",curItem.num)
				self.m_sNumGroup[i].num = item_num+1

				if flag == 2 then
					if self.m_sNumGroup[i].num == 20  then
						self.m_sNumGroup[i].num = 41
					elseif self.m_sNumGroup[i].num == 45 then
						self.m_sNumGroup[i].num = 51
					elseif self.m_sNumGroup[i].num == 54 then
						self.m_sNumGroup[i].num = 53
					end
				end
				
				self.m_sNumGroup[i].item:setItemNum(self.m_sNumGroup[i].num)
				-- self.m_sNumGroup[i].item:setShowNum(self.m_sNumGroup[i].num)
				-- self.m_sNumGroup[i].item:setRGBColor(self.m_sColorArr[self.m_sNumGroup[i].num%32])
				break
			end
		end
	else
		return
	end
	--模式2下不要删除白板
	if flag == 2  and curItemNum == 53 then
		print("11111111111111")
	else
		for i,v in ipairs(_destoryArr) do
			if 	v.index_h ==curItem.index_h and v.index_v ==curItem.index_v then
				table.remove(_destoryArr,i)
				break
			end
		end
	end

	for i,v in ipairs(_destoryArr) do
		table.insert(self.m_sChangeArr,v)
		for j,k in ipairs(self.m_sNumGroup) do
			if 	v.index_h == k.index_h and v.index_v == k.index_v then
				self.m_sNumGroup[j].bvisible = false
				-- self.m_sNumGroup[j].item:setBVisible(self.m_sNumGroup[j].bvisible)
				break
			end
		end	
	end

end

function CDGameNumDestory:getChangeArr( ... )
	if 	not self.m_sChangeArr then
		self.m_sChangeArr = {}
	end
	return self.m_sChangeArr
end

function CDGameNumDestory:getChangeItem( ... )
	if 	self.m_pChangeItem == nil then
		return
	else
		self.m_pChangeItem:setShowNum(self.m_pChangeItem:getShowNum())
		self.m_pChangeItem:setRGBColor(self.m_sColorArr[self.m_pChangeItem:getShowNum()%32])
	end
end

function CDGameNumDestory:onClickItem( touch_h,touch_v,flag)
	for i,v in ipairs(self.m_sNumGroup) do
		if 	v.index_h == touch_h and v.index_v == touch_v then
			self.m_sNumGroup[i].num = self.m_sNumGroup[i].num+1

			if flag == 2 then
				if self.m_sNumGroup[i].num == 20  then
					self.m_sNumGroup[i].num = 41
				elseif self.m_sNumGroup[i].num == 45 then
					self.m_sNumGroup[i].num = 51
				elseif self.m_sNumGroup[i].num == 54 then
					self.m_sNumGroup[i].num = 53
				end
			end
			self.m_sNumGroup[i].item:setShowNum(self.m_sNumGroup[i].num)
			self.m_sNumGroup[i].item:setRGBColor(self.m_sColorArr[self.m_sNumGroup[i].num%32])
			break
		end
	end
end

function CDGameNumDestory:getNumArr( ... )
	if 	not self.m_sNumGroup then
		self.m_sNumGroup = {}
	end
	return self.m_sNumGroup
end

function CDGameNumDestory:setGroupItem( index,_itemNode,bvisible )
	if 	self.m_sNumGroup[index] then
		if 	_itemNode then
			self.m_sNumGroup[index].item = _itemNode	
		end
		self.m_sNumGroup[index].bvisible = bvisible
		self.m_sNumGroup[index].item:setBVisible(bvisible)
	end
end

function CDGameNumDestory:resetGroupItem( _item,bvisible )
	local curItemNode = self:findMatchItem(_item.index_h,_item.index_v)
	if 	curItemNode then
		curItemNode.bvisible = bvisible
		curItemNode.num = _item.num
		curItemNode.item:setBVisible(bvisible)
		curItemNode.item:setShowNum(_item.num)
		curItemNode.item:setRGBColor(self.m_sColorArr[_item.num%32])
	end

end

function CDGameNumDestory:onResetItemPos( _flag)
	local curIndex = 1
	for i,v in ipairs(self.m_sNumGroup) do
		if 	i%8 == 1 and i ~= 1 then
			curIndex = curIndex+1
		end
		v.num = self:insRandomNum(curIndex,_flag)
		v.item:setShowNum(v.num)
		v.item:setItemInitPosition(v.init_h,v.init_v)
		v.item:setItemPosition(v.index_h,v.index_v)
		v.item:setRGBColor(self.m_sColorArr[v.num%32])
		v.bvisible = true
		v.item:setBVisible(v.bvisible)

	end

end

function CDGameNumDestory:setGroupItemAndChange( flag)
	local needRefreshArr = {}
	if 	TABLE_SIZE(self.m_sChangeArr) > 0 then
		local addArr = {}
		for i=1,DEF_NUMGAME_MAXH do
			addArr[i] = {}
			addArr[i].items = {}
			addArr[i].max_v = 0
			addArr[i].count = 0
		end

		for i,v in ipairs(self.m_sChangeArr) do
			if 	addArr[v.index_h] then
				addArr[v.index_h].count = addArr[v.index_h].count+1
				table.insert(addArr[v.index_h].items,v)
				if 	addArr[v.index_h].max_v == 0 then
					addArr[v.index_h].max_v = v.index_v
				else
					if 	addArr[v.index_h].max_v < v.index_v then
						addArr[v.index_h].max_v = v.index_v
					end
				end
			end	
		end

		--获取点击的麻将的位置
		local  itemY,itemX =  self.m_pChangeItem:getTargetIndex()

		for i,v in ipairs(addArr) do
			if v.max_v > 0 then
				local minIndex = 0
				for j = 1,v.max_v do

					local firstItemNode = self:findMatchItem(i,j)
					if 	not firstItemNode.bvisible then
						minIndex = j
						break
					end
				end

				print("minIndex------------>",minIndex)

				local detailNodeArr = {}
				local newNodeArr = {}

				for j = 1,v.max_v do
					local curItemNode = self:findMatchItem(i,j)
					table.insert(detailNodeArr,curItemNode.item)
				end

				local spaceY = 1


				for j = minIndex, v.max_v do
					--将不是点击的牌先放入数组中
					if i == itemX then
						if j ~= itemY then
							detailNodeArr[j]:setItemInitPosition(i,1-spaceY)
							spaceY = spaceY+1
							table.insert(newNodeArr,detailNodeArr[j])
						end
					else
						detailNodeArr[j]:setItemInitPosition(i,1-spaceY)
						spaceY = spaceY+1
						table.insert(newNodeArr,detailNodeArr[j])
					end
				end

				for j = 1,minIndex-1 do
					table.insert(newNodeArr,detailNodeArr[j])
				end

				--将点击的麻将放到数组最后
				if i == itemX then
					local touchItem = self:findMatchItem(i,itemY) 
					if touchItem then
						table.insert(newNodeArr,touchItem.item)
					end
				end

				for j = 1,v.max_v do
					local firstItemNode = self:findMatchItem(i,j)
					firstItemNode.item = newNodeArr[j]
					if 	firstItemNode.item:isVisible() then
						firstItemNode.num = firstItemNode.item:getShowNum()
					else
						---另一种模式下添加随机范围
						if flag == 1 then
							firstItemNode.num = math.random(1,6)
						else
							firstItemNode.num = math.random(11,18)
						end

						firstItemNode.item:setRGBColor(self.m_sColorArr[firstItemNode.num%32])
					end
					firstItemNode.item:setItemPosition(i,j)
				end

				for j = v.max_v,1,-1 do
					
					local firstItemNode = self:findMatchItem(i,j)
					if 	self:checkHadSameItem(needRefreshArr,firstItemNode) then
						table.insert(needRefreshArr,firstItemNode)
					end
				end
			end
		end

	end
	return needRefreshArr
end

function CDGameNumDestory:isFindIndex( _arr,_index )
	for i,v in ipairs(_arr) do
		if 	v == _index then
			return false
		end
	end
	return true
end

function CDGameNumDestory:lessLeftChange( ... )
	self.m_nLeftChange = self.m_nLeftChange - 1
	if 	self.m_nLeftChange <= 0 then
		self.m_nLeftChange = 0
	end
end

function CDGameNumDestory:addLeftChange( ... )
	self.m_nLeftChange = self.m_nLeftChange + 1
	if 	self.m_nLeftChange >= DEF_NUMGAME_MAXCHANGE then
		self.m_nLeftChange = DEF_NUMGAME_MAXCHANGE
	end
end

function CDGameNumDestory:getLeftChange( ... )
	return self.m_nLeftChange
end

-- 检测游戏是否可以继续下去
function CDGameNumDestory:checkGameOver()
	if 	self.m_nLeftChange <= 0 then
		return true
	end
	return false
end

function CDGameNumDestory:getDestoryScore( _destoryArr )
	local curCount = TABLE_SIZE(_destoryArr)
	if 	curCount > 0 then
		local curNum = _destoryArr[1].num
		local curScore = 10*curNum*curCount
		return curScore
	end
	return curScore
end
----------------------------------------------------------------------------
-- 创建干瞪眼数学库
function CDGameNumDestory.create()
    cclog("CDGameNumDestory.create")
    local   instance = CDGameNumDestory.new()
    return  instance
end