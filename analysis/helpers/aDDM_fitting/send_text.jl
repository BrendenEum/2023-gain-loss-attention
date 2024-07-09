function send_imessage(phone_number::String, message::String)
    apple_script = """
    tell application "Messages"
        set targetService to 1st service whose service type = iMessage
        set targetBuddy to buddy "#{phone_number}" of targetService
        send "#{message}" to targetBuddy
    end tell
    """
    apple_script = replace(apple_script, r"#\{phone_number\}" => phone_number)
    apple_script = replace(apple_script, r"#\{message\}" => message)
    command = `osascript -e $apple_script`
    run(command)
end