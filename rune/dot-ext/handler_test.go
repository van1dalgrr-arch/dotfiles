package main

import (
	"context"
	"strings"
	"testing"

	"github.com/unstablebuild/rune-go-sdk/api/browserapi"
	"github.com/unstablebuild/rune-go-sdk/api/textapi"
	"github.com/unstablebuild/rune-go-sdk/iterator"
)

type fakeDot struct {
	gotDir  string
	gotArgs []string
	out     string
	code    int
}

func (f *fakeDot) Run(_ context.Context, dir string, args ...string) (string, int, error) {
	f.gotDir, f.gotArgs = dir, args
	return f.out, f.code, nil
}
func (f *fakeDot) Modes() []string { return []string{"kinoza-back", "notes"} }

type fakeNotify struct {
	level browserapi.NotificationLevel
	msg   string
}

func (f *fakeNotify) Notify(l browserapi.NotificationLevel, msg string, args ...any) (string, error) {
	f.level, f.msg = l, strings.ReplaceAll(msg, "%s", args[0].(string))
	return "", nil
}

func TestWorkPassesArgsAndReportsSuccess(t *testing.T) {
	d := &fakeDot{out: "\n◆ kinoza-back\n  ✓ контейнер kinoza-pg\n  · погасить всё: dot work off\n"}
	n := &fakeNotify{}
	h := &handler{dot: d, notify: n}
	if err := h.HandleCommand(context.Background(), textapi.Command{Name: "work", Args: []string{"kinoza-back"}}); err != nil {
		t.Fatal(err)
	}
	if strings.Join(d.gotArgs, " ") != "work kinoza-back" {
		t.Fatalf("args = %v", d.gotArgs)
	}
	if n.level != browserapi.LevelSuccess || !strings.Contains(n.msg, "◆ kinoza-back") {
		t.Fatalf("notify = %v %q", n.level, n.msg)
	}
}

func TestDoctorFailureIsError(t *testing.T) {
	d := &fakeDot{code: 1, out: "  ✓ go.mod\n  ✗ .env не в .gitignore → добавь\n\n3 ок · 0 предупреждений · 1 ошибок\n"}
	n := &fakeNotify{}
	h := &handler{dot: d, notify: n}
	if err := h.HandleCommand(context.Background(), textapi.Command{Name: "projectdoctor"}); err != nil {
		t.Fatal(err)
	}
	if n.level != browserapi.LevelError || !strings.Contains(n.msg, ".env не в .gitignore") || !strings.Contains(n.msg, "1 ошибок") {
		t.Fatalf("notify = %v %q", n.level, n.msg)
	}
	if d.gotArgs[0] != "project" || d.gotArgs[1] != "doctor" {
		t.Fatalf("args = %v", d.gotArgs)
	}
}

func TestBadUsageReturnsError(t *testing.T) {
	h := &handler{dot: &fakeDot{code: 2, out: "dot work [имя|off|list]"}, notify: &fakeNotify{}}
	if err := h.HandleCommand(context.Background(), textapi.Command{Name: "work", Args: []string{"--x"}}); err == nil {
		t.Fatal("ждали ошибку")
	}
}

func TestCompleteModes(t *testing.T) {
	h := &handler{dot: &fakeDot{}, notify: &fakeNotify{}}
	it, err := h.Complete(context.Background(), "work", []string{"k"})
	if err != nil {
		t.Fatal(err)
	}
	got, _ := iterator.ToSlice(context.Background(), it)
	if strings.Join(got, ",") != "kinoza-back" {
		t.Fatalf("complete = %v", got)
	}
}
