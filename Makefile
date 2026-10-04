# make install — симлинки и тема · make check — те же проверки, что в CI · make update — обслуживание
.PHONY: install check update wallpapers

install:
	brew bundle
	./install.sh

check:
	shellcheck -S warning -e SC1090 install.sh macos.sh themes/apply.sh borders/bordersrc git/hooks/_chain git/hooks/pre-commit
	for f in zsh/.zshrc zsh/*.zsh; do zsh -n $$f || exit 1; done
	for f in zed/themes/*.json zed/icon-theme/icon_themes/*.json; do jq empty $$f || exit 1; done
	python3 -m py_compile themes/set-wallpaper.py
	gitleaks git --no-banner --redact .
	@echo "✓ всё чисто"

update:
	zsh -ic update
