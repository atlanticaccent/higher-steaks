local HigherSteaks = SMODS.current_mod

HigherSteaks.modded_stakes = {}
HigherSteaks.original_applies = {}

local tartare_key = 'stake_highsteak_tartare'

local config = HigherSteaks.config

local applied_stakes = {'stake_gold'}
local mod_names = {}
local highest_stake = nil
for id, stake in pairs(SMODS.Stakes) do
    if stake.original_mod then
        local mod_name = stake.original_mod.name
        if not HigherSteaks.modded_stakes[mod_name] then
        	HigherSteaks.modded_stakes[mod_name] = {}
        	mod_names[#mod_names+1] = mod_name
    	end
    	HigherSteaks.modded_stakes[mod_name][#HigherSteaks.modded_stakes[mod_name]+1] = stake
        
    	if config[stake.key] == nil then
    		config[stake.key] = true
		end
		
		if config[stake.key] then
			applied_stakes[#applied_stakes+1] = id
    	end
    end
end
table.sort(mod_names)

SMODS.Stake {
    name = "Tartare Stake",
    key = "tartare",
    loc_txt = {
        name = "Tartare Stake",
        text = { "Applies all modded stakes" },
        stickers = {
            name = "Tartare Stake",
            text = "waow"
        }
    },
    applied_stakes = applied_stakes,
    -- above_stake = highest_stake,
    prefix_config = {
        applied_stakes = false, 
        -- above_stake = false,
    },
    -- order = #SMODS.Stakes * 3,
    unlocked = true,
}
SMODS.Stakes[tartare_key].order = #SMODS.Stakes * 3

SMODS.current_mod.config_tab = function()
	local toggles_container = {n = G.UIT.O, config = {
		 id = 'toggle_container',
     	object = UIBox {
     		definition = HigherSteaks.mod_stake_toggles(mod_names[1]),
     		config = {align = "cm", minw = 1, minh = 3, outline = "1", outline_colour = G.C.BLUE}
    	}
	}}
	
    return {n = G.UIT.ROOT, config = {r = 0.1, minw = 8, minh = 6, align = "cm", padding = 0.2, colour = G.C.BLACK}, nodes = {
    	{n = G.UIT.C, config = {minw = 3, minh = 4, colour = G.C.CLEAR, padding = 0.15}, nodes = {
        	{n = G.UIT.R, config = {minw = 3, minh = 3, align = "cm"}, nodes = {toggles_container}},
        	{n = G.UIT.R, config = {minw = 7, minh = 1, align = "cm"}, nodes = {
        		create_option_cycle {
        			options = mod_names,
        			opt_callback = 'hs_switch_mod',
        			w = 7
    			}
    		}}
        }}
    }}
end

G.FUNCS.hs_switch_mod = function(args)
	local toggles_container = G.OVERLAY_MENU:get_UIE_by_ID('toggle_container')
	toggles_container.config.object:remove()
	toggles_container.config.object = UIBox {
		definition = HigherSteaks.mod_stake_toggles(args.to_val),
		config = {align = "cm", minw = 1, minh = 3, parent = toggles_container}
	}
	toggles_container.UIBox:recalculate()
end

function HigherSteaks.mod_stake_toggles(mod_name)
	local toggles = {}
	for _, stake in ipairs(HigherSteaks.modded_stakes[mod_name]) do
    	toggles[#toggles+1] = create_toggle {
    		row = true,
    		label = localize { type = 'name_text', key = stake.key, set = stake.set },
    		ref_table = config,
    		ref_value = stake.key,
		}
		
		local desc_rows = {}
		local desc_nodes = HigherSteaks.get_stake_desc(stake)
		local _full_desc = {}
        for _, nodes in ipairs(desc_nodes) do
            desc_rows[#desc_rows + 1] = {n = G.UIT.R, config = {align = "cm"}, nodes = nodes}
        end
        toggles[#toggles + 1] = {n = G.UIT.R, config = {align = "cm", maxh = 1.8, r = 0.1, padding = 0.2, colour = G.C.WHITE}, nodes = {
            {n = G.UIT.C, config = {align = "cm", minw = 1}, nodes = desc_rows}
        }}
    end
	return {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.BLACK, minw = 1, minh = 3, padding = 0.2}, nodes = {
		{n = G.UIT.C, config = {align = "cm", minw = 1, minh = 3}, nodes = toggles}
	}}
end

function HigherSteaks.get_stake_desc(stake)
	local nodes, res = {}, {}
	if stake.loc_vars and type(stake.loc_vars) == 'function' then
		res = stake:loc_vars() or {}
	end
	vars = res.vars or {}
	key = res.key or stake.key
	set = res.set or stake.set
	
	localize{type = 'descriptions', key = key, set = set, vars = vars, nodes = nodes}
	nodes[#nodes] = nil
	return nodes
end

SMODS.current_mod.extra_tabs = function()
	return {
		{
			label = 'Preview',
			tab_definition_function = function()
                local tartare = SMODS.Stakes[tartare_key]
                
                local stake_desc_rows = {}
                for stake in HSUtils.rev_iter(HSUtils.non_cont_arr_iter(G.P_CENTER_POOLS.Stake)) do
                    if HSUtils.contains_value(tartare.applied_stakes, stake.key) then
                    	-- modified from SMODS.applied_stakes_UI
                    	local _full_desc, _stake_desc = {}, HigherSteaks.get_stake_desc(stake)
						for k, v in ipairs(_stake_desc) do
							_full_desc[#_full_desc + 1] = {n = G.UIT.R, config = {align = "cm"}, nodes = v}
						end
						stake_desc_rows[#stake_desc_rows + 1] = {n = G.UIT.R, config = {align = "cm" }, nodes = {
							{n = G.UIT.C, config = {align = 'cm'}, nodes = {
								{n = G.UIT.C, config = {align = "cm", colour = get_stake_col(i), r = 0.1, minh = 0.35, minw = 0.35, emboss = 0.05 }, nodes = {}},
								{n = G.UIT.B, config = {w = 0.1, h = 0.1}}}},
							{n = G.UIT.C, config = {align = "cm", padding = 0.03, colour = G.C.WHITE, outline = 0.5, outline_colour = G.C.WHITE, r = 0.1, minh = 0.7, minw = 4.8 }, nodes =
								_full_desc},}}
                    end
                end
                
				return {n = G.UIT.ROOT, config = {r = 0.1, minw = 8, minh = 6, align = "cm", colour = G.C.BLACK}, nodes = {
					{n = G.UIT.C, config = {align = "cm", minw = 7, minh = 3, padding = 0.2}, nodes = stake_desc_rows}
				}}
			end,
		},
	}
end

HSUtils = {
    index_of = function(table, value)
        for k, v in pairs(table) do
            if v == value then
            	return k
        	end
        end
    end,
    contains_value = function(table, value)
        return not not HSUtils.index_of(table, value)
    end,
    non_cont_arr_iter = function(arr)
    	local idx, returned, total = 1, 0, #arr
    	return function()
    		if returned == total then
    			return nil
    		end
    		
    		while arr[idx] == nil do
    			idx = idx + 1
    		end
    		
    		returned = returned + 1
    		local val = arr[idx]
    		-- so next iteration doesn't return same element,
    		-- and cause iter to get permanently stuck
    		idx = idx + 1
    		return val
    	end
    end,
    rev_iter = function(iter)
    	local vals = {}
    	for val in iter do
    		vals[#vals + 1] = val
    	end
    	
    	local idx = #vals
    	return function()
    		if idx == 0 then return nil end
    		
    		local next = vals[idx]
    		idx = idx - 1
    		return next
    	end
    end,
    filter = function(table, fn)
        local len = #table
        local lag_idx = 1
    
        for idx = 1, len do
            if (fn(table[idx])) then
                -- Move i's kept value to j's position, if it's not already there.
                if (idx ~= lag_idx) then
                    t[lag_idx] = t[idx]
                    t[idx] = nil
                end
                lag_idx = lag_idx + 1 -- Increment position of where we'll place the next kept value.
            else
                table[idx] = nil
            end
        end
    
        return table
    end,
    shallow_copy = function(table)
        local copy = {}
        for k, v in pairs(table) do
            copy[k] = v
        end
        return copy
    end
}

--[[
SMODS.current_mod.calculate = function(mod, context)
    print("new context")
    local output = ""
    for k, v in pairs(context) do output = output .. k .. ': ' .. type(v) .. ' / ' end
    print(output)
end
--]]

local function dbg_table(table)
    local output = ""
    for k, v in pairs(table) do output = output .. k .. ': ' .. type(v) .. ' / ' end
    return output
end

local start_run_ref = Game.start_run
Game.start_run = function(game, args)
    print("in start_run wrapper")
    local stake_tartare = SMODS.Stakes[tartare_key]
    
    print("start_run args " .. args)
    if args.stake == stake_tartare.order then
        print("in tartare case")
        for _, applied in ipairs(stake_tartare.applied_stakes) do
            local applied_stake = SMODS.Stakes[applied]
            if applied_stake.original_mod and not HigherSteaks.original_applies[applied] then
                HigherSteaks.original_applies[applied] = shallow_copy(applied_stake.applied_stakes)
                local filtered_applied = HSUtils.filter(
                    shallow_copy(applied_stake.applied_stakes),
                    function(key)
                        return not SMODS.Stakes[key].original_mod or
                            HSUtils.contains_value(stake_tartare.applied_stakes, key)
                    end
                )
                SMODS.Stake:take_ownership(
                    applied,
                    {applied_stakes = filtered_applied},
                    true -- silent
                )
                print(SMODS.Stakes[applied].applied_stakes)
            end
        end
    else
        print("non-tartare case")
        for stake_key, original_applies in pairs(HigherSteaks.original_applies) do
            SMODS.Stake:take_ownership(
                stake_key,
                {applied_stakes = original_applies},
                true
            )
        end
    end
    
    return start_run_ref(game, args)
end
