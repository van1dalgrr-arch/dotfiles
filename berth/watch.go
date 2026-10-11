package main

import (
	"bytes"
	"fmt"
	"os"

	"gopkg.in/yaml.v3"
)

// Live rebuild is `docker compose watch`: save code → the image is rebuilt and the
// container restarted. It needs a develop.watch block on every service with build:.
// For Go, rebuild is the right action — compiled code can't be synced into a container.

var watchIgnore = []string{".git/", "tmp/", "*_test.go", "*.md"}

// missingWatch lists services that build from source but have no develop.watch.
func missingWatch(data []byte) ([]string, error) {
	var doc yaml.Node
	if err := yaml.Unmarshal(data, &doc); err != nil {
		return nil, err
	}
	services := mapValue(docRoot(&doc), "services")
	if services == nil {
		return nil, fmt.Errorf("в compose-файле нет services:")
	}
	var missing []string
	for i := 0; i+1 < len(services.Content); i += 2 {
		name, svc := services.Content[i].Value, services.Content[i+1]
		if mapValue(svc, "build") == nil {
			continue
		}
		if dev := mapValue(svc, "develop"); dev != nil && mapValue(dev, "watch") != nil {
			continue
		}
		missing = append(missing, name)
	}
	return missing, nil
}

// addWatch appends a rebuild watch block to the given services, keeping comments.
func addWatch(data []byte, names []string) ([]byte, error) {
	var doc yaml.Node
	if err := yaml.Unmarshal(data, &doc); err != nil {
		return nil, err
	}
	services := mapValue(docRoot(&doc), "services")
	want := map[string]bool{}
	for _, n := range names {
		want[n] = true
	}
	for i := 0; i+1 < len(services.Content); i += 2 {
		if !want[services.Content[i].Value] {
			continue
		}
		svc := services.Content[i+1]
		path := buildContext(mapValue(svc, "build"))
		entry := mapping(
			"action", scalar("rebuild"),
			"path", scalar(path),
			"ignore", flowSeq(watchIgnore...),
		)
		watch := &yaml.Node{Kind: yaml.SequenceNode, Content: []*yaml.Node{entry}}
		if dev := mapValue(svc, "develop"); dev != nil {
			dev.Content = append(dev.Content, scalar("watch"), watch)
		} else {
			svc.Content = append(svc.Content, scalar("develop"), mapping("watch", watch))
		}
	}
	var buf bytes.Buffer
	enc := yaml.NewEncoder(&buf)
	enc.SetIndent(2)
	if err := enc.Encode(&doc); err != nil {
		return nil, err
	}
	return buf.Bytes(), enc.Close()
}

func addWatchToFile(file string, names []string) error {
	data, err := os.ReadFile(file)
	if err != nil {
		return err
	}
	out, err := addWatch(data, names)
	if err != nil {
		return err
	}
	return os.WriteFile(file, out, 0o644)
}

// buildContext: `build: ./api` or `build: {context: ./api}` → the folder to watch.
func buildContext(b *yaml.Node) string {
	if b == nil {
		return "."
	}
	if b.Kind == yaml.ScalarNode && b.Value != "" {
		return b.Value
	}
	if c := mapValue(b, "context"); c != nil && c.Value != "" {
		return c.Value
	}
	return "."
}

const watchSnippet = `    develop:
      watch:
        - action: rebuild      # пересобрать образ и перезапустить контейнер
          path: .              # за какой папкой следить
          ignore: [.git/, tmp/, "*_test.go", "*.md"]   # это не пересобирает`

func docRoot(doc *yaml.Node) *yaml.Node {
	if doc.Kind == yaml.DocumentNode && len(doc.Content) > 0 {
		return doc.Content[0]
	}
	return doc
}

func mapValue(m *yaml.Node, key string) *yaml.Node {
	if m == nil || m.Kind != yaml.MappingNode {
		return nil
	}
	for i := 0; i+1 < len(m.Content); i += 2 {
		if m.Content[i].Value == key {
			return m.Content[i+1]
		}
	}
	return nil
}

func scalar(v string) *yaml.Node { return &yaml.Node{Kind: yaml.ScalarNode, Value: v} }

func mapping(kv ...any) *yaml.Node {
	n := &yaml.Node{Kind: yaml.MappingNode}
	for i := 0; i+1 < len(kv); i += 2 {
		n.Content = append(n.Content, scalar(kv[i].(string)), kv[i+1].(*yaml.Node))
	}
	return n
}

func flowSeq(vals ...string) *yaml.Node {
	n := &yaml.Node{Kind: yaml.SequenceNode, Style: yaml.FlowStyle}
	for _, v := range vals {
		n.Content = append(n.Content, scalar(v))
	}
	return n
}
