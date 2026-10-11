# berth

🇬🇧 [English version](README.md)

Команда `orbstack`: контейнеры в терминале, на Go и [Bubble Tea](https://github.com/charmbracelet/bubbletea).
`install.sh` и `update` собирают её в `~/go/bin/berth`, `.zshrc` делает `orbstack` её псевдонимом.

```bash
orbstack                 # живая панель
orbstack run postgres    # запуск по шаблону: сначала покажет команду docker run
orbstack watch           # живая сборка compose-проекта в этой папке
orbstack help            # всё остальное
```

Панель — один живой экран: таблица контейнеров с CPU и памятью, лог выбранного контейнера и лента
событий (запуск, остановка, падение, нехватка памяти). Всё на клавишах; `enter` — действия с контейнером,
у каждого пояснение и команда docker, которая за ним стоит. `?` — все клавиши.

| Файл | Что это |
|---|---|
| `main.go` | подкоманды (`orbstack ps`, `logs`, `run`, `watch`…) |
| `ui.go` | панель: модель, клавиши, раскладка |
| `docker.go` | работа с docker CLI (следует текущему context: OrbStack, Colima, Docker Desktop) |
| `templates.go` | postgres, redis, nginx, mongo, mysql, rabbitmq |
| `watch.go` | добавляет в compose блок `develop.watch`, комментарии сохраняются |
| `style.go` | цвета и логотип с градиентом |
| `berth_test.go` | разбор вывода docker, шаблоны, правка compose, отрисовка на разных размерах |

```bash
cd berth && go test ./...                               # входит в make check и CI
BERTH_RENDER=/tmp/b.ansi go test -run TestRender .      # снимок панели с живыми данными
```

[← dotfiles](../README.md)
