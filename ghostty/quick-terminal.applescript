-- Выпадающий терминал Ghostty по ctrl+` — вызывает AeroSpace (у него уже есть «Универсальный доступ»,
-- поэтому Ghostty это разрешение не нужно).
-- macOS не даёт фоновому приложению забрать фокус самому: после toggle выпадающий терминал выезжал,
-- но клавиатура оставалась в прошлом приложении, и автоскрытие не срабатывало — терминал «залипал».
-- Поэтому, если Ghostty не впереди, после показа явно фокусируем выпадающий терминал.

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
set q to quickTerminal()
tell application "Ghostty"
	activate
	if q is not missing value then focus q
end tell
