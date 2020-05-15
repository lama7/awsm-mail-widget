#!/usr/bin/env lua
--[[
Copyright (c) <2010> <Gerry LaMontagne>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

--[[
    Sample program to check for mail on an IMAP4Rev1 server.

    Command line arguments:
        mailserver url
        user
        password

    Example usage: mbstat.lua my.mail.server user secret [optional mailbox list]

    author: G.LaMontagne 10/2010

--]]

local imaplib = require("imap4")
local string = require("string")

local mb_list = { "INBOX",
                }

function chk_result(r)
    if r:getTaggedResult() ~= 'OK' then
        imap:shutdown()
        error("Imap command failed")
    end
    return r
end

-- start by creating the imap object
imap = imaplib.IMAP4:new(arg[1])

-- make sure server supports IMAP4rev1
r = chk_result(imap:CAPABILITY())
capability = r:getUntaggedContent('CAPABILITY')[1]
if not capability:find('IMAP4rev1') then
    imap:shutdown()
    error("Server does not support IMAP4Rev1")
end
if not capability:find('STARTTLS') then
    error([[Server does not support STARTTLS, aborting to avoid sending login
            credentials in the clear.]])
end
chk_result(imap:STARTTLS())
chk_result(imap:LOGIN(arg[2], arg[3]))

-- make sure mb_list is populated with something.  If it's prepopulated above,
-- leave it be.  Otherwise, check the arg list for how to populate it
if ( #mb_list == 0 ) then
    if ( arg[4] == nil ) then
        table.insert( mb_list, "INBOX" )
    else
        mb_list = { table.unpack(arg, 4) }
    end
end

-- go through the mailbox list and check for unseen mail in them
for _, mb in ipairs( mb_list ) do
    local rs = chk_result(imap:SELECT(mb))  -- start by selecting
    local exists = rs:getUntaggedContent('EXISTS')[1]
    local unseen = 0
    -- the UNSEEN response code from the select will contain the msg id of the 
    -- first unseen msg in the selected mailbox.  If there is NO unseen 
    -- response code then there are no unseen messages and we can save
    -- ourselves the search time
    if rs:getResponseCodeContent('UNSEEN') then
        rs = chk_result(imap:SEARCH('UNSEEN')) -- now search for unseen
        msg_ids = rs:getUntaggedContent('SEARCH')[1] -- get the results 
        -- msg_ids will be a string of space separated msg_ids
        -- we'll assume there is at least 1 since the above response code check
        -- got us to this point
        -- just count the number of ids in the string
        for id in msg_ids:gmatch("%d+") do
            unseen = unseen + 1
        end
    end
    print(string.format("%s|%s|%u", mb, exists, unseen))

end

-- this logs us out and shuts down the network connection
imap:shutdown()
