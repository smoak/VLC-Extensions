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
    if ml == nil then
        vlc.msg.warn("Could not get media library...aborting...")
        return false
    end
    if #ml.children == 0 then
        vlc.msg.warn("Media library is empty?")
        return false
    end
    -- at this point the media library is populated
    for i, node in ipairs(ml.children) do
        if type(node.children) == "table" then
            for ii, node2 in ipairs(node.children) do
                if ii == 1 then
                  for iii, node3 in ipairs(node2.children) do
                      vlc.msg.dbg("type(Node3.children) = " .. type(node3.children))
                      for i4, node4 in ipairs(node3.children) do
                        vlc.msg.dbg("type(node4) = " .. type(node4))
                        vlc.msg.dbg(node4.path)
                      end
                  end
                  vlc.msg.dbg(#node2.children)
                  vlc.msg.dbg(node2.path)
                  vlc.msg.dbg(type(node2.children))
                  break
                end
            end
        end 
    end
end

function make_prompt()
  dlg = vlc.dialog("Random Songs")
  dlg:add_label("How many random songs?", 1, 1, 1, 1)
  text_bx = dlg:add_text_input("", 2, 1, 1, 1)
  dlg:add_button("Enqueue", close_and_enqueue, 3, 1, 1, 1)
  dlg:add_button("Cancel", cancel, 3, 2, 1, 1)
  dlg:show()
end
