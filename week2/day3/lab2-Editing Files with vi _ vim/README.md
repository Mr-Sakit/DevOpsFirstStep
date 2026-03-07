# Lab 2 — Editing Files with vi / vim

In this lab, the fundamentals of the `vi`/`vim` text editor were practiced — opening files, switching between Normal and Insert modes, navigating efficiently, editing text, and performing search-and-replace operations.

---

## 📌 Part A — Set Up a Safe Playground

A dedicated directory was created and a sample file was prepared for editing practice.

```bash
cd ~
mkdir -p vim-lab
cd vim-lab
echo "First line" > notes.txt
echo "Second line" >> notes.txt
```

![Part A — Creating vim-lab directory and notes.txt](Screenshots/Screenshot%202026-02-25%20111915.png)

---

## 📌 Part B — Open a File & Understand Modes

### Opening the File

```bash
vi notes.txt
```

### vi/vim Modes

| Mode | Purpose | How to Enter |
|------|---------|-------------|
| **Normal** | Keys are commands (move, delete, copy) | Press `[Esc]` |
| **Insert** | Type text normally | Press `i` |

### Steps Performed

1. Opened `notes.txt` in vi — file displayed "First Line" and "Second Line"
2. Pressed `i` to enter Insert mode, typed: `Hello from vim!`
3. Pressed `[Esc]` to return to Normal mode
4. Saved and quit with `:wq`

![Part B — notes.txt opened in vi](Screenshots/Screenshot%202026-02-25%20111945.png)

![Part B — Editing and saving with :wq](Screenshots/Screenshot%202026-02-25%20112050.png)

### Key Save/Quit Commands

| Command | Description |
|---------|-------------|
| `:w` | Save and keep editing |
| `:wq` | Save and quit |
| `:q!` | Quit without saving |

---

## 📌 Part C — Move with Confidence

In Normal mode, the following navigation commands were practiced:

### Character Movement (Home-Row)

| Key | Action |
|-----|--------|
| `h` | Move left |
| `j` | Move down |
| `k` | Move up |
| `l` | Move right |

### Word Movement

| Key | Action |
|-----|--------|
| `w` | Jump to next word |
| `b` | Jump back a word |
| `e` | Jump to end of current word |

### Line & File Movement

| Key | Action |
|-----|--------|
| `0` | Go to start of line |
| `$` | Go to end of line |
| `gg` | Go to top of file |
| `G` | Go to bottom of file |
| `Ngg` | Jump to line N (e.g. `5gg`) |

### Line Numbers

```vim
:set number
```

> **Note:** Line numbers are a view-only setting — they do not modify the file content.

![Part C — Line numbers enabled in vim](Screenshots/Screenshot%202026-02-25%20112919.png)

---

## 📌 Part D — Insert and Delete

### Insert Commands

| Key | Action |
|-----|--------|
| `i` | Insert before cursor |
| `a` | Insert after cursor |
| `o` | Open new line below and insert |
| `O` | Open new line above and insert |

[Part D — Insert and Delete](OoINS.mp4)
<video src="OoINS.mp4" width="600" controls></video>

### Delete Commands

| Key | Action |
|-----|--------|
| `x` | Delete character under cursor |
| `dw` | Delete word (from cursor) |
| `dd` | Delete (cut) the whole line |
| `D` | Delete to end of line |

> **Tip:** Numbers repeat commands — e.g. `3dd` deletes 3 lines, `5x` deletes 5 characters.

### Practice Steps

1. Go to the top (`gg`), press `O`, type `Title: My Notes`, then `[Esc]`
2. Move to a typo word and press `dw` to delete it
3. Delete a whole line with `dd`
4. Save: `:w [Enter]`

---

## 📌 Part E — Copy (Yank), Paste, Change, Undo/Redo

### Copy & Paste

| Key | Action |
|-----|--------|
| `yy` | Copy (yank) current line |
| `3yy` | Copy 3 lines |
| `p` | Paste below / after cursor |
| `P` | Paste above / before cursor |

### Change Text

| Key | Action |
|-----|--------|
| `cw` | Change word (delete + enter Insert mode) |
| `cc` | Change whole line |

### Undo / Redo / Repeat

| Key | Action |
|-----|--------|
| `u` | Undo last change |
| `Ctrl+R` | Redo |
| `.` | Repeat last action |

### Practice Steps

1. On a line: `yy`, move somewhere else, `p` to paste
2. On a word: `cw`, type a replacement, `[Esc]`
3. Press `u` to undo, `Ctrl+R` to redo, `.` to repeat the last edit
4. Save: `:w [Enter]`

![Part E — Further editing in vim](Screenshots/Screenshot%202026-02-25%20113042.png)

---

## 📌 Part F — Search and Find-Replace

### Search Commands

| Command | Action |
|---------|--------|
| `/text` | Search forward for "text" |
| `?text` | Search backward for "text" |
| `n` | Next match |
| `N` | Previous match |

### Find & Replace

| Command | Action |
|---------|--------|
| `:s/old/new/` | Replace first occurrence on current line |
| `:%s/old/new/g` | Replace all occurrences in whole file |
| `:%s/old/new/gc` | Replace all with confirmation (y/n each) |

### Practice Steps

1. Search: `/line [Enter]`, press `n` to jump through matches
2. Replace with confirmation:

```vim
:%s/line/LINE/gc
```

3. Press `y` to confirm, `n` to skip for each match
4. Save: `:w [Enter]`

---

## 📌 Part G — Create and Edit a New File from Scratch

### Steps Performed

1. Quit current file: `:q [Enter]`
2. Create a new file:

```bash
vi todo.txt
```

3. Press `i` and type:

```
Learn vi basics
Practice navigation
Automate with scripts
```

4. Press `[Esc]`, write & quit: `:wq [Enter]`
5. Verify:

```bash
cat todo.txt
```

---

## 🧠 Key Takeaways

| Category | Command | Description |
|----------|---------|-------------|
| **Modes** | `i` | Enter Insert mode |
| | `[Esc]` | Return to Normal mode |
| **Save/Quit** | `:w` | Save file |
| | `:wq` | Save and quit |
| | `:q!` | Quit without saving |
| **Navigation** | `h` `j` `k` `l` | Left, down, up, right |
| | `w` / `b` / `e` | Word forward / back / end |
| | `0` / `$` | Line start / end |
| | `gg` / `G` | File top / bottom |
| **Insert** | `i` / `a` / `o` / `O` | Before / after / below / above |
| **Delete** | `x` / `dw` / `dd` / `D` | Char / word / line / to end |
| **Copy/Paste** | `yy` / `p` / `P` | Yank / paste below / paste above |
| **Change** | `cw` / `cc` | Change word / change line |
| **Undo/Redo** | `u` / `Ctrl+R` / `.` | Undo / redo / repeat |
| **Search** | `/text` / `n` / `N` | Find / next / previous |
| **Replace** | `:%s/old/new/g` | Global find-and-replace |
| **View** | `:set number` | Show line numbers |
