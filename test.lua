

print("-----------")
-- local a = {}

-- setmetatable(a,{__mode = "k"})

-- local key = {}

-- a[key] = 1 



local arr = {
	[8] = 1,

	[16] = 3
}


for n in pairs(arr) do
	print("n-------->",n)
end




function pairsByKeys(t)
	local a = {}

	for n in pairs(t) do
		a[#a+1] = n
	end

	table.sort(a)

	local i = 0

	return function ()
		i = i +1

		return a[i],t[a[i]]
	end

end





















