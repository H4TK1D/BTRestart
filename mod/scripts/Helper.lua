local Helper = {}

function Helper.SearchTable(tbl, val)
	for _, v in pairs(tbl) do
		if v == val then
			return true
		end
	end
	return false
end

return Helper
