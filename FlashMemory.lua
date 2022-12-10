-- Retro Gadgets
local Mem:FlashMemory = gdt.FlashMemory0

-- update function is repeated every time tick
function update()
		Mem:Save({420,590,220})
		memTable = Mem:Load()
		for i, num in ipairs(memTable) do
			log(tostring(num))
		end
end
