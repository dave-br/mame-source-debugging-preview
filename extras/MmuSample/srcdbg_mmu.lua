-- Example script which detects changes to the Coco 3 MMU and change
-- which MAME source debugging information files shall be enabled in
-- response.  This allows for automated, clean source debugging as
-- code gets moved in and out of the same logical address space.
-- To customize, go down to the on_mmu_register_write function
-- and modify the mmu_state_to_sd_enable table.  Also modify the
-- global call to do_sd_enable near the bottom.


print("lua says... " .. emu.app_name() .. " " .. emu.app_version())
cpu = manager.machine.devices[':maincpu']
mem = cpu.spaces["program"]
debugger = manager.machine.debugger

-- This assumes mmu_state represents only the executive set,
-- but it's straightforward to change to task set or both
function does_mmu_state_match(mmu_state, write_addr, write_val)
    addr = 0xFFA0       -- Start with first register of executive set
    for i=1,8 do
		val = mmu_state[i]

        -- First, check for mmu_state nil: nil entries are an automatic match
        if val == nil then
            goto continue
        end

        -- Supersede a memory read with write_addr,write_val.
        -- write_addr,write_val will be set if we're inside a
        -- a memory write-tap, in which case the new values
        -- will not be written to memory yet.  Pretend they were
        -- while doing the comparison
        if addr == write_addr then
            if val == write_val then
                goto continue
            end
            return false
        end

        -- Do an actual memory read to compare what's in the
        -- MMU register with what the mmu_state is matching for
        if mem:read_u8(addr) ~= val then
            return false
        end
        ::continue::
        addr = addr + 1
    end

    -- Still here, everything must have matched
    return true
end

function do_sd_enable(sd_enable)
    -- Converts 0 and 1 to the proper command
    command = { "sddisable", "sdenable" }

    -- Execute sddisable or sdenable for each MDI, as per the data
    -- in sd_enable array
    for i = 1, #sd_enable, 1 do
        debugger:command(string.format(
			"%s #%d",
			command[sd_enable[i]+1],		-- lua arrays are 1-based, so convert 0,1 to 1,2 for indexing into command
			i-1))							-- lua arrays are 1-based, so convert i to 0-based as param for sdenable/disable commands
    end
end


function on_mmu_register_write(offset, val, mask)
    -- This table is a set of if / thens. This script scans through
    -- each element of the table, asking if mmu_state matches the
    -- actual state of the Coco 3 MMU, and if so performs the
    -- enable / disable actions encoded in sd_enable. 
    --
    -- NOTE: If your app uses both executive set and task set, consult
    -- 0xFF91 to see which one is active.  For this sample, we assume
    -- only the executive set is of interest
    mmu_state_to_sd_enable =
    {
        {
            -- Each mmu_state lists hypothetical values that each MMU register
            -- might contain.  The values are listed in order from what might
            -- appear at address FFA0 through what might appear at FFA7. Note
            -- that these are just the executive set (but you can change that!).
            -- This script will compare the actual state of the MMU registers
            -- with these values.  A nil in this array matches any
            -- actual value stored in the corresponding MMU register
            mmu_state = { nil, 0, nil, nil, nil, nil, nil, nil },

            -- If the above mmu_state matches, then this takes control. It
            -- causes a series of sdenable / sddisable commands to run in
            -- the MAME debugger console. 1 indicates sdenable and 0 indicates.
            -- sddisable.  These are listed in the same order that you would find
            -- the MAME debugging information files listed if you ran the sdlist
            -- command. So the first element corresponds to MAME debugging information
            -- file index 0, and so on.  This very simple example only has one debugging
            -- information file enabled at a time. But in many cases you would have
            -- debugging information files that remain enabled regardless of the state
            -- of the MMU, and so there would always be a 1 in this array for each
            -- of them.
            sd_enable = { 1, 0, 0, 0 }
        },
        {
            mmu_state = { nil, 1, nil, nil, nil, nil, nil, nil },
            sd_enable = { 0, 1, 0, 0 }
        },
        {
            mmu_state = { nil, 2, nil, nil, nil, nil, nil, nil },
            sd_enable = { 0, 0, 1, 0 }
        },
        {
            mmu_state = { nil, 3, nil, nil, nil, nil, nil, nil },
            sd_enable = { 0, 0, 0, 1 }
        },
    }

    for i = 1,#mmu_state_to_sd_enable do
		entry = mmu_state_to_sd_enable[i]
        if does_mmu_state_match(entry.mmu_state, offset, val) then
            do_sd_enable(entry.sd_enable)
            break
        end
    end

    -- Must return the val parameter to allow the write to happen
    return val
end

-- Initial enabled / disabled state.
-- You will want to change this to reflect the state you would like the
-- MAME debugging information files to be in on startup. See the comments
-- before the sd_enable array above for information on what this represents. 
do_sd_enable({ 1, 0, 0, 0 })

-- This is triggered if any of the executive set or task set registers are written
handler1 = mem:install_write_tap(0xFFA0, 0xFFAF, "on_mmu_register_write1", on_mmu_register_write)

-- This is triggered if the executive vs. task set is selected
handler2 = mem:install_write_tap(0xFF91, 0xFF91, "on_mmu_register_write2", on_mmu_register_write)