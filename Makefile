# make install — программы, симлинки, тема · make devops — необязательный DevOps-набор
# make check — те же проверки, что в CI (+ go vet и тесты berth) · make test — смоук-тесты dot и install/uninstall во временном HOME · make update — обслуживание
.PHONY: install devops check test update

SCRIPTS = bin/dot bin/rune-go lib/*.sh bootstrap.sh install.sh git/repo-hooks/pre-push uninstall.sh macos.sh themes/apply.sh tests/smoke.sh tests/install.sh git/hooks/_chain git/hooks/pre-commit ghostty/fx.sh ghostty/quick-terminal.sh

install:
	brew bundle
	./install.sh

devops:
	brew bundle --file Brewfile.devops
	bin/dot tools install devops

check:
	shellcheck -S warning -e SC1090 $(SCRIPTS)
	for f in $(SCRIPTS); do /bin/bash -n $$f || exit 1; done   # системный bash 3.2 на чистом Mac
	@! perl -ne 'print "$$ARGV:$$.: $$_" if /\$$[A-Za-z_]\w*[\x80-\xff]/; close ARGV if eof' $(SCRIPTS) | grep . || { echo '↑ bash 3.2 читает байты UTF-8 после $$var как часть имени — пиши $${var}'; exit 1; }
	for f in zsh/.zshrc zsh/*.zsh; do zsh -n $$f || exit 1; done
	ruby -c Brewfile >/dev/null && ruby -c Brewfile.devops >/dev/null
	for f in zed/dev-night-theme/themes/*.json zed/dev-night-icons/icon_themes/*.json; do jq empty $$f || exit 1; done
	python3 -m py_compile themes/set-wallpaper.py zed/tools/light.py zed/tools/preview.py jetbrains/build.py
	@# шейдеры Ghostty — тем же компилятором, что внутри Ghostty (если glslang стоит: brew install glslang)
	@if command -v glslangValidator >/dev/null; then for f in ghostty/shaders/*.glsl; do \
		d=$$(mktemp -d); tmp=$$d/shader.frag; cat ghostty/shaders/.prefix.glsl $$f > $$tmp && glslangValidator -G -S frag $$tmp -o /dev/null >/dev/null 2>&1; ok=$$?; rm -rf $$d; \
		[ $$ok = 0 ] || { echo "шейдер не компилируется: $$f"; exit 1; }; done; fi
	cd berth && go vet ./... && go test ./...
	cd rune/dot-ext && go vet ./... && go test ./...
	gitleaks git --no-banner --redact .
	@echo "✓ всё чисто"

test:
	tests/smoke.sh
	tests/install.sh

update:
	zsh -ic update
