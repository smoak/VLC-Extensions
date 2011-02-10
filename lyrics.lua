--[[
 Get lyrics about a song from chartlyrics.com

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

-- Lua modules
require "simplexml"

-- Some global variables: widgets
dlg = nil          -- dialog
okay = nil
lyrics_txtbox = nil
artist_label = nil
song_title_label = nil
lyrics_url = "http://api.chartlyrics.com/apiv1.asmx/SearchLyricDirect?artist="

-- Script descriptor, called when the extensions are scanned
function descriptor()
    return { title = "Lyrics" ;
             version = "0.1" ;
             author = "Scott Moak" ;
             url = '';
             shortdesc = "Fetches Song Lyrics";
             description = "<center><b>Fetch Song Lyrics</b></center><br />"
                        .. "Get lyrics about songs from "
                        .. "chartlyrics.<br />This Extension will show "
                        .. "you the lyrics of the current song";
             capabilities = { "input-listener" } }
end

function reset_global_variables()
	okay = nil
	lyrics_txtbox = nil
	artist_label = nil
	song_title_label = nil
end

-- Remove trailing & leading spaces
function trim(str)
    if not str then return "" end
    return string.gsub(str, "^%s*(.*)+%s$", "%1")
end

-- First function to be called when the extension is activated
function activate()
	vlc.msg.dbg("Activating lyrics dialog...")
    create_dialog()
end

-- This function is called when the extension is disabled
function deactivate()
	vlc.msg.dbg("Deactivating lyrics dialog...")
	
end

-- This function is called when the dialog is closed
function close()
	vlc.msg.dbg("Lyrics Dialog closed")
	reset_global_variables()
	if dlg ~= nil then dlg:delete() end
	dlg = nil
	vlc.deactivate()
end

function close_clicked()
	close()
end

function input_changed()
	local item = vlc.input.item()
	if item == nil then return false end

	local title = item:name()	-- It return the internal title or the filename if the first is missing
	local metas = item:metas()
	local artist = ""
	if metas and metas["artist"] then
		artist = metas["artist"]
	end
	if title ~= nil then
		title = string.gsub(title, "(.*)%.%w+$", "%1")	-- Removes file extension
		if title ~= "" then
			song_title_label:set_text("<b>Title:</b> " .. title)
			artist_label:set_text("<b>Artist:</b> " .. artist)
			dlg:update()
		end
	end
	local lyrics = get_lyrics()
	if lyrics then
		--lyrics_txtbox:set_text(lyrics)
	end
	return true
end

function sleep(sec)
	local t = vlc.misc.mdate()
	vlc.misc.mwait(t + sec*1000*1000)
end

-- Get clean title from filename
function get_title(str)
    local item = vlc.item or vlc.input.item()
    if not item then
        return ""
    end
    local metas = item:metas()
    if metas and metas["title"] then
        return metas["title"]
    else
        local filename = string.gsub(item:name(), "^(.+)%.%w+$", "%1")
        return trim(filename or item:name())
    end
end

function get_lyrics()
	local title = get_title()
	local artist = get_artist()
	if title == nil or title == "" or artist == nil or artist == "" then 
		return ""
	end
	vlc.msg.dbg("Artist: " .. artist)
	vlc.msg.dbg("Title: " .. title)
	lyrics_url = lyrics_url .. vlc.strings.encode_uri_component(artist) .. "&song=" .. vlc.strings.encode_uri_component(title)
	vlc.msg.dbg("Fetching from " .. lyrics_url)
	local s, msg = vlc.stream(lyrics_url)
	if not s then
        vlc.msg.warn("Weird: " .. msg)
		return msg
    end
	local data = s:read( 65535 )
	
    s = nil
	if data then
		vlc.msg.dbg(data)
		local xml = simplexml.parse_string(data)
		data = nil
		if xml then
			for _, v in ipairs(xml.children) do
				if v.name == "Lyric" and type(v.children[1]) == "string" then
					return htmlize(v.children[1])
				end
			end
		end
	end
	
	return "Could not find lyrics"
end

-- Replaces newlines with <br /> so the text looks pretty :)
function htmlize(str)
	return string.gsub(str, "\n", "<br />")
end

function get_artist(str)
	local item = vlc.item or vlc.input.item()
    if not item then
        return ""
    end
    local metas = item:metas()
    if metas and metas["artist"] then
        return metas["artist"]
    else
        local filename = string.gsub(item:name(), "^(.+)%.%w+$", "%1")
        return trim(filename or item:name())
    end
end

-- Create the main dialog 
function create_dialog()
	vlc.msg.dbg("Creating lyrics dialog...")
	dlg = vlc.dialog("Lyrics")
	-- col, row, row_span, col_span
	artist_label = dlg:add_label("<b>Artist:</b> " .. get_artist(), 1, 1, 1, 1)
	song_title_label = dlg:add_label("<b>Title:</b> " .. get_title(), 1, 2, 1, 1)
	lyrics_txtbox = dlg:add_html(get_lyrics(), 1, 3, 1, 1)
	okay = dlg:add_button("Close", close_clicked, 1, 4, 1, 1)
	-- Show, if not already visible
    dlg:show()
end