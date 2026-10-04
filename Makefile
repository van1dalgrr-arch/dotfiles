# make install — программы, симлинки, тема · make devops — необязательный DevOps-набор
# make check — те же проверки, что в CI · make test — смоук-тесты dot · make update — обслуживание
.PHONY: install devops check test update

SCRIPTS = bin/dot lib/*.sh install.sh uninstall.sh macos.sh themes/apply.sh tests/smoke.sh git/hooks/_chain git/hooks/pre-commit

install:
	brew bundle
	./install.sh

devops:
	brew bundle --file Brewfile.devops
	bin/dot tools install devops

check:
	shellcheck -S warning -e SC1090 $(SCRIPTS)
	for f in $(SCRIPTS); do /bin/bash -n $$f || exit 1; done   # системный bash 3.2 на чистом Mac
	for f in zsh/.zshrc zsh/*.zsh; do zsh -n $$f || exit 1; done
	ruby -c Brewfile >/dev/null && ruby -c Brewfile.devops >/dev/null
	for f in zed/themes/*.json zed/icon-theme/icon_themes/*.json; do jq empty $$f || exit 1; done
	python3 -m py_compile themes/set-wallpaper.py
	gitleaks git --no-banner --redact .
	@echo "✓ всё чисто"

test:
	tests/smoke.sh

update:
	zsh -ic update
