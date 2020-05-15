# awsm-mail-widget

An overly complicated mail widget for the awesome window manager.  Places an
icon task bar and on mouse over displays a list of mailboxes with the mail count
and the number of unread mails.  A user can then select a mailbox with the mouse
and open that particular folder using mutt.

## Install

Copy the `mail-widget.lua` and `mailsettings.lua` files to the same directory as
your `rc.lua`, typically the `~/.config/awesome/` directory.  Set your server,
username and password in the `mailsettings.lua` file.  Then add the mail widget 
to your task list as follows:

'''
require("mail-widget")

        .
        .
        .

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            email_icon,
            wibox.widget.systray(),
        .
        .
        .
 
'''
