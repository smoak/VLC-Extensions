--[[
 Enqueue a number of random songs from your media library to your current playlist.

 Copyright © 2011 Scott Moak (scott.moak@gmail.com)

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
--]]

dlg = nil
text_bx = nil


-- Script descriptor, called when the extensions are scanned
function descriptor()
    return { title = "Random Songs" ;
             version = "0.1" ;
             author = "Scott Moak" ;
             url = '';
             shortdesc = "Enqueues a number of random songs to your current playlist";
             description = "<center><b>Random Songs</b></center><br />"
                        .. "Enqueue random songs into your current playlist from "
                        .. "your media library.<br />This Extension will prompt "
                        .. "for a number of random songs to enqueue from your "
						.. "media library into your current playlist.";
             capabilities = { "input-listener" } }
end

-- Called when extension is activated
function activate()
    make_prompt()
end

-- Called when extension is deactivated (i.e. done executing)
function deactivate()

end

function reset_variables_and_deactivate()
    text_bx = nil
    if dlg ~= nil then dlg:delete() end
    dlg = nil
    vlc.deactivate()
end

function cancel()
    reset_variables_and_deactivate()
end

function close_and_enqueue()
    local num_to_enqueue = text_bx:get_text()
    vlc.msg.dbg("Enqueuing " .. num_to_enqueue)
    enqueue(num_to_enqueue)
    reset_variables_and_deactivate() 
end

function enqueue(num_songs)
    local ml = vlc.playlist.get("ml")
    num_songs = tonumber(num_songs)
    if ml == nil then
        vlc.msg.warn("Could not get media library...aborting...")
        return false
    end
    if #ml.children == 0 then
        vlc.msg.warn("Media library is empty?")
        return false
    end
    -- at this point the media library is populated
    -- ml.name is just Media Library

    -- Initialize the pseudo random number generator
    math.randomseed( os.time() )
    math.random(); math.random(); math.random()
    -- done. :-)

    local file_list = {}
    local i = 1
    for n in get_songs_from_media_library(ml) do
        file_list[i] = n
        i = i + 1
    end
    if num_songs > #file_list then
        vlc.msg.warn("Requested number of random songs is bigger than size of your library!")
        return false
    end
    shuffle(file_list)
    for j=1, num_songs do
         enqueue_song(file_list[j])
    end
end

function enqueue_song(song)
    vlc.msg.dbg("Enqueuing song " .. song.name)
    vlc.playlist.enqueue({song})
end

function shuffle(t)
    local n = #t
 
    while n > 2 do
        -- n is now the last pertinent index
        local k = math.random(n) -- 1 <= k <= n
        -- Quick swap
        t[n], t[k] = t[k], t[n]
        n = n - 1
    end
 
    return t
end

function get_songs_from_media_library(node)
    local function yieldtree(node)
        for _, c in ipairs(node.children) do
            if string.find(c.path, "vlc://nop") == nil then
                coroutine.yield(c)
            end
            if c.children and #c.children > 0 then
                yieldtree(c)
            end
        end
    end
    return coroutine.wrap(function() yieldtree(node) end)
end

function make_prompt()
  dlg = vlc.dialog("Random Songs")
  dlg:add_label("How many random songs?", 1, 1, 1, 1)
  text_bx = dlg:add_text_input("", 2, 1, 1, 1)
  dlg:add_button("Enqueue", close_and_enqueue, 3, 1, 1, 1)
  dlg:add_button("Cancel", cancel, 3, 2, 1, 1)
  dlg:show()
end
