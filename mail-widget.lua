local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local beautiful = require("beautiful")

email_icon = wibox.widget.imagebox()
email_icon:set_image("/usr/share/pixmaps/mutt.xpm")

local ms = require("mailsettings")

local mail_stat_cmd = [[bash -c '/home/lama7/bin/mbstat.lua ]]..ms.server..' '..ms.user..' '..ms.pw..[[']]

local mailbox_rows = {
    spacing = 4,
    layout = wibox.layout.fixed.vertical,
}

local mailbox_header = {
    {
        markup = '<b>Mailbox</b>',
        forced_width = 80,
        widget = wibox.widget.textbox,
    },
    {
        widget = wibox.widget.textbox,
    },
    {
        {
            markup = '<b>Total</b>',
            forced_width = 60,
            align = "right",
            widget = wibox.widget.textbox,
        },
        {
            markup = '<b>UnRead</b>',
            forced_width = 60,
            align = "right",
            widget = wibox.widget.textbox,
        },
        layout = wibox.layout.fixed.horizontal
    },
    layout = wibox.layout.align.horizontal
}

local popup = awful.popup {
    ontop = true,
    visible = false,
    shape = gears.shape.rounded_rect,
    border_width = 5,
    border_color = beautiful.bg_normal,
    maximum_width = 300,
    offset = { y = 5 },
    widget = {}
}

function show_emails()
    awful.spawn.easy_async(mail_stat_cmd,
        function(stdout, stderr, reason, exit_code)
            local i = 1
            for line in stdout:gmatch("[^\r\n]+") do
                local columns = {}
                for s in line:gmatch("([^|]+)") do
                    table.insert(columns, s)
                end
                -- build the widget
                mailbox_rows[i] = wibox.widget {
                    {
                        {
                            {
                                text = columns[1], -- mailbox name
                                forced_width = 80,
                                widget = wibox.widget.textbox
                            },
                            {
                                widget = wibox.widget.textbox
                            },
                            {
                                {
                                    text = columns[2],  -- mail count
                                    forced_width = 60,
                                    align = "right",
                                    widget = wibox.widget.textbox
                                },
                                {
                                    text = columns[3],  -- unread count
                                    forced_width = 60,
                                    align = "right",
                                    widget = wibox.widget.textbox
                                },
                                layout = wibox.layout.fixed.horizontal
                            },
                            layout = wibox.layout.align.horizontal
                        },
                        widget = wibox.container.margin,
                        right = 6,
                        left = 6,
                    },
                    widget = wibox.container.background,
                    shape = gears.shape.rounded_rect,
                }
                -- now add some fancy mouse stuff
                mailbox_rows[i]:connect_signal( "mouse::enter", 
                                                function (c)
                                                    -- c is the background container widget
                                                    c:set_bg( beautiful.bg_focus )
                                                end )
                mailbox_rows[i]:connect_signal( "mouse::leave", 
                                                function (c)
                                                    c:set_bg( beautiful.bg_normal )
                                                end )

                -- launch mutt to open this particular mailbox
                mailbox_rows[i]:buttons(
                    awful.util.table.join(
                        awful.button({}, 
                                     1, 
                                     function ()
                                         popup.visible = false
                                         awful.spawn("x-terminal-emulator -e mutt -f =".. columns[1])
                                     end
                        )
                    )
                )
                i = i + 1
            end
            popup:setup {
                {
                    mailbox_header,
                    {
                        orientation = 'horizontal',
                        forced_height = 15,
                        color = beautiful.bg_focus,
                        widget = wibox.widget.separator
                    },
                    mailbox_rows,
                    layout = wibox.layout.fixed.vertical,
                },
                margins = 8,
                widget = wibox.container.margin
            }
        end
    )
end

email_icon:connect_signal("mouse::enter", function() 
                                              popup:move_next_to(mouse.current_widget_geometry)
                                              show_emails() 
                                              popup.visible = true
                                          end)

email_icon:buttons(
        awful.util.table.join(
            awful.button({}, 1, function()
                                    popup.visible = false
                                end)
            )
        )
