--[[
 Clears your playlist

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

-- Script descriptor, called when the extensions are scanned
function descriptor()
    return { title = "Clear Playlist" ;
             version = "0.1" ;
             author = "Scott Moak" ;
             url = '';
             shortdesc = "Clears Playlist";
             description = "<center><b>Clear Playlist</b></center><br />"
                        .. "Clears your current playlist";
             capabilities = {  } }
end

function activate()
	clear_playlist()
	vlc.deactivate()
end

function clear_playlist()
	vlc.msg.dbg("Clearing playlist")
	vlc.playlist.clear()
end

function deactivate()

end