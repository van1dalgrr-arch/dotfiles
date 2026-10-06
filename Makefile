# make install — программы, симлинки, тема · make devops — необязательный DevOps-набор
# make check — те же проверки, что в CI · make test — смоук-тесты dot · make update — обслуживание
.PHONY: install devops check test update

SCRIPTS = bin/dot lib/*.sh bootstrap.sh install.sh git/repo-hooks/pre-push uninstall.sh macos.sh themes/apply.sh tests/smoke.sh git/hooks/_chain git/hooks/pre-commit ghostty/fx.sh ghostty/quick-terminal.sh

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
	for f in zed/dev-night-theme/themes/*.json zed/dev-night-icons/icon_themes/*.json; do jq empty $$f || exit 1; done
	python3 -m py_compile themes/set-wallpaper.py zed/tools/light.py zed/tools/preview.py jetbrains/build.py
	@# шейдеры Ghostty — тем же компилятором, что внутри Ghostty (если glslang стоит: brew install glslang)
	@if command -v glslangValidator >/dev/null; then for f in ghostty/shaders/*.glsl; do \
		d=$$(mktemp -d); tmp=$$d/shader.frag; cat ghostty/shaders/.prefix.glsl $$f > $$tmp && glslangValidator -G -S frag $$tmp -o /dev/null >/dev/null; ok=$$?; rm -rf $$d; \
		[ $$ok = 0 ] || { echo "шейдер не компилируется: $$f"; exit 1; }; done; fi
	gitleaks git --no-banner --redact .
	@echo "✓ всё чисто"

test:
	tests/smoke.sh

update:
	zsh -ic update
