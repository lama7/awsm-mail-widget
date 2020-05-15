# awsm-mail-widget

An overly complicated mail widget for the awesome window manager.  Places an
icon in task bar and on mouse/pointer over, creates a popup that displays a list
of mailboxes with the mail count for the mailbox and the number of unread mails
in the mailbox.  A user can then select a mailbox with the mouse and open that
particular folder using **mutt**.

## Install

Copy the `mail-widget.lua` and `mailsettings.lua` files to the same directory as
your `rc.lua`, typically the `~/.config/awesome/` directory.  Set your server,
username and password in the `mailsettings.lua` file.  Then add the mail widget 
to your task list as follows:

```
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
            email_icon,  -- created in mail-widget.lua file
            wibox.widget.systray(),
        .
        .
        .
 
```
### mail_stat_cmd & mbstat.lua

A script file is required to connect to a mail server and pull down the
necessary information for the widget.  The command is invoked in the
`mail_stat_cmd` in the `mail-widget.lua` file.  The script needs to return
`\r\n` terminated lines on `stdout`.  Each line should consist of 3 `|`
separated fields where *field 1 is the mailbox name*; *field 2 is the overall mail
count*; and *field 3 is the number of unread mails in the mailbox*.

Sample output from the script file:

```
INBOX|1234|4
friend|5|0
amazon|3456|10
```

The `mbstat.lua` file is included as a courtesy but requires an [IMAP lua
library][1].  See the library for install instructions.  **Be sure to update the
path to the script in the `mail-widget.lua` file.**

The `mutt.xpm` file can either be copied to `/usr/share/pixmaps/` or change the
directory specified in the `mail-widget.lua` file.

    [1]: https://github.com/lama7/luaimap4 "IMAP4 lua library"
