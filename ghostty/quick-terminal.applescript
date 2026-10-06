-- Выпадающий терминал Ghostty по ctrl+` — вызывает AeroSpace (у него уже есть «Универсальный доступ»,
-- поэтому Ghostty это разрешение не нужно).
-- macOS не даёт фоновому приложению забрать фокус самому: после toggle выпадающий терминал выезжал,
-- но клавиатура оставалась в прошлом приложении, и автоскрытие не срабатывало — терминал «залипал».
-- Поэтому, если Ghostty не впереди, после показа активируем его хелпером (только ключевое окно,
-- без подъёма обычных окон Ghostty — их поднимала AppleScript-команда activate) и фокусируем терминал.
-- Запускается из ghostty/quick-terminal.sh, первый аргумент — путь к хелперу активации.

-- выпадающий терминал — тот, что не лежит ни в одном окне
on quickTerminal()
	tell application "Ghostty"
		set inWindows to {}
		repeat with w in windows
			repeat with t in tabs of w
				repeat with s in terminals of t
					set end of inWindows to id of s
				end repeat
			end repeat
		end repeat
		repeat with s in terminals
			if inWindows does not contain (id of s) then return s
		end repeat
	end tell
	return missing value
end quickTerminal

on run argv
set activator to ""
if (count argv) > 0 then set activator to item 1 of argv
tell application "Ghostty"
	if (count terminals) = 0 then
		-- после входа терминалов ещё нет: создаём окно, открываем выпадающий и закрываем окно
		set w to new window
		perform action "toggle_quick_terminal" on first terminal of w
		close window w
	else if frontmost then
		perform action "toggle_quick_terminal" on first terminal
		return
	else
		perform action "toggle_quick_terminal" on first terminal
	end if
end tell

-- Ghostty был в фоне: значит, терминал должен появиться — отдать ему фокус
delay 0.05
if activator is not "" then do shell script quoted form of activator
set q to quickTerminal()
if q is not missing value then tell application "Ghostty" to focus q
end run
