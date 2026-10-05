-- Выпадающий терминал Ghostty по ctrl+` — вызывает AeroSpace (у него уже есть «Универсальный доступ»,
-- поэтому Ghostty это разрешение не нужно). toggle_quick_terminal выполняется «на» любом терминале;
-- если после входа их ещё нет — создаём окно, открываем выпадающий терминал и закрываем окно.
tell application "Ghostty"
	if (count terminals) > 0 then
		perform action "toggle_quick_terminal" on first terminal
	else
		set w to new window
		perform action "toggle_quick_terminal" on first terminal of w
		close window w
	end if
end tell
