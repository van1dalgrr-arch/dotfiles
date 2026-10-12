// rune-dot — расширение Rune: dotfiles прямо из командной строки Rune (:).
//
//	:work kinoza-back   режим проекта (dot work): контейнеры, редактор, ◆ в промпте
//	:work off           погасить всё до Finder, Happ, Ghostty
//	:projectdoctor      dot project doctor для файла в фокусе (или корня проекта)
//
// Rune запускает его дочерним процессом и говорит с ним по gRPC (rune-go-sdk).
// Сами команды — это bin/dot: расширение только вызывает его и показывает итог уведомлением.
// Собирает install.sh в ~/go/bin/rune-dot; подключено в rune/config.yaml (extensions.dot).
package main

import (
	"context"
	"fmt"
	"log/slog"
	"os"

	"github.com/unstablebuild/rune-go-sdk/api/config"
	"github.com/unstablebuild/rune-go-sdk/api/extensionapi"
	"github.com/unstablebuild/rune-go-sdk/api/textapi"
)

func main() {
	meta := extensionapi.Metadata{
		DeveloperID:      "van1dal",
		DeveloperKey:     "dotfiles",
		DeveloperEmail:   "van1dalgrr-arch@users.noreply.github.com",
		ExtensionID:      "dot",
		ExtensionName:    "dotfiles",
		ExtensionVersion: "0.1.0",
		Permissions: extensionapi.NewPermissions(
			extensionapi.PermissionCommands,
			extensionapi.PermissionNotifications,
		),
	}
	if err := extensionapi.ServeWorkspaceExtension(extensionapi.FuncWorkspaceExtension(run), meta); err != nil {
		slog.Error("rune-dot exited", "error", err)
		os.Exit(1)
	}
}

// run только связывает команды с обработчиком и возвращается — жизнью процесса управляет SDK
func run(ctx context.Context, ws *extensionapi.Workspace, _ config.Config) error {
	h := &handler{dot: newDot(), notify: ws.Notifications(ctx)}
	commands := []textapi.CommandManual{
		{Name: "work", Summary: "Режим проекта: поднять окружение (dot work <имя>) или погасить всё (off).", Synopsis: "[<имя>|off|list]"},
		{Name: "projectdoctor", Summary: "dot project doctor: что есть в проекте и чего не хватает.", Synopsis: ""},
	}
	for _, m := range commands {
		if err := ws.RegisterCommand(m, h); err != nil {
			return fmt.Errorf("register %s: %w", m.Name, err)
		}
	}
	return nil
}
