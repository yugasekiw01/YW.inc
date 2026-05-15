import tkinter as tk
from tkinter import font as tkfont
import json
import os

DATA_FILE = os.path.join(os.path.dirname(__file__), "todos.json")

BG = "#1e1e2e"
SURFACE = "#2a2a3e"
ACCENT = "#7c6af7"
ACCENT_DONE = "#44475a"
FG = "#cdd6f4"
FG_MUTED = "#6e7b9a"
RED = "#f38ba8"
GREEN = "#a6e3a1"
FONT_MAIN = ("Segoe UI", 11)
FONT_BOLD = ("Segoe UI", 11, "bold")
FONT_TITLE = ("Segoe UI", 16, "bold")
FONT_SMALL = ("Segoe UI", 9)


def load_todos():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return []


def save_todos(todos):
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(todos, f, ensure_ascii=False, indent=2)


class TodoApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Yuja-Wang Todo")
        self.geometry("520x620")
        self.minsize(400, 480)
        self.configure(bg=BG)
        self.resizable(True, True)

        self.todos = load_todos()
        self.filter_mode = tk.StringVar(value="all")

        self._build_ui()
        self._refresh()

    def _build_ui(self):
        # タイトルバー
        header = tk.Frame(self, bg=BG, pady=12)
        header.pack(fill="x", padx=20)
        tk.Label(header, text="Yuja-Wang Todo", font=FONT_TITLE,
                 bg=BG, fg=ACCENT).pack(side="left")

        # 入力エリア
        input_frame = tk.Frame(self, bg=SURFACE, padx=10, pady=8)
        input_frame.pack(fill="x", padx=20, pady=(0, 12))

        self.entry = tk.Entry(input_frame, font=FONT_MAIN, bg=SURFACE,
                              fg=FG, insertbackground=FG,
                              relief="flat", bd=0)
        self.entry.pack(side="left", fill="x", expand=True, ipady=4)
        self.entry.bind("<Return>", lambda e: self._add_todo())
        self.entry.focus_set()

        add_btn = tk.Button(input_frame, text="追加", font=FONT_BOLD,
                            bg=ACCENT, fg="#ffffff", relief="flat",
                            padx=14, pady=4, cursor="hand2",
                            activebackground="#6a58e0", activeforeground="#ffffff",
                            command=self._add_todo)
        add_btn.pack(side="right", padx=(8, 0))

        # フィルタタブ
        filter_frame = tk.Frame(self, bg=BG)
        filter_frame.pack(fill="x", padx=20, pady=(0, 8))
        for label, value in [("すべて", "all"), ("未完了", "active"), ("完了済み", "done")]:
            rb = tk.Radiobutton(filter_frame, text=label, variable=self.filter_mode,
                                value=value, font=FONT_SMALL,
                                bg=BG, fg=FG_MUTED, selectcolor=BG,
                                activebackground=BG, activeforeground=ACCENT,
                                indicatoron=False, relief="flat", padx=10, pady=4,
                                cursor="hand2",
                                command=self._refresh)
            rb.pack(side="left", padx=2)

        # タスクリスト（スクロール対応）
        list_outer = tk.Frame(self, bg=BG)
        list_outer.pack(fill="both", expand=True, padx=20, pady=(0, 8))

        canvas = tk.Canvas(list_outer, bg=BG, highlightthickness=0)
        scrollbar = tk.Scrollbar(list_outer, orient="vertical", command=canvas.yview)
        self.list_frame = tk.Frame(canvas, bg=BG)

        self.list_frame.bind("<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all")))

        canvas.create_window((0, 0), window=self.list_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        canvas.bind_all("<MouseWheel>",
            lambda e: canvas.yview_scroll(-1 * (e.delta // 120), "units"))

        # フッター：残件数
        self.footer_label = tk.Label(self, text="", font=FONT_SMALL,
                                     bg=BG, fg=FG_MUTED)
        self.footer_label.pack(pady=(0, 12))

    def _add_todo(self):
        text = self.entry.get().strip()
        if not text:
            return
        self.todos.append({"text": text, "done": False})
        save_todos(self.todos)
        self.entry.delete(0, tk.END)
        self._refresh()

    def _toggle_done(self, idx):
        self.todos[idx]["done"] = not self.todos[idx]["done"]
        save_todos(self.todos)
        self._refresh()

    def _delete_todo(self, idx):
        self.todos.pop(idx)
        save_todos(self.todos)
        self._refresh()

    def _refresh(self):
        for w in self.list_frame.winfo_children():
            w.destroy()

        mode = self.filter_mode.get()
        filtered = [(i, t) for i, t in enumerate(self.todos)
                    if mode == "all"
                    or (mode == "active" and not t["done"])
                    or (mode == "done" and t["done"])]

        if not filtered:
            tk.Label(self.list_frame, text="タスクがありません",
                     font=FONT_MAIN, bg=BG, fg=FG_MUTED).pack(pady=20)
        else:
            for i, (real_idx, todo) in enumerate(filtered):
                self._build_row(real_idx, todo, i)

        remaining = sum(1 for t in self.todos if not t["done"])
        self.footer_label.config(
            text=f"未完了: {remaining} / 合計: {len(self.todos)}")

    def _build_row(self, real_idx, todo, row_num):
        color = ACCENT_DONE if todo["done"] else SURFACE
        row = tk.Frame(self.list_frame, bg=color, pady=6, padx=8)
        row.pack(fill="x", pady=3)

        var = tk.BooleanVar(value=todo["done"])
        cb = tk.Checkbutton(row, variable=var, bg=color,
                            activebackground=color,
                            command=lambda idx=real_idx: self._toggle_done(idx),
                            cursor="hand2")
        cb.pack(side="left")

        text_color = FG_MUTED if todo["done"] else FG
        text_style = ("Segoe UI", 11, "overstrike") if todo["done"] else FONT_MAIN
        lbl = tk.Label(row, text=todo["text"], font=text_style,
                       bg=color, fg=text_color, anchor="w", wraplength=350)
        lbl.pack(side="left", fill="x", expand=True, padx=6)

        del_btn = tk.Button(row, text="✕", font=FONT_SMALL,
                            bg=color, fg=RED, relief="flat",
                            activebackground=color, activeforeground=RED,
                            cursor="hand2", bd=0,
                            command=lambda idx=real_idx: self._delete_todo(idx))
        del_btn.pack(side="right", padx=4)


if __name__ == "__main__":
    app = TodoApp()
    app.mainloop()
