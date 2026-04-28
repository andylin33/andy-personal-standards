# Andy's Personal Standards

跨機器、跨專案的個人工作標準, 打包成可 install 的 Cowork plugin。

裝在哪台機器, 哪個 session, 都會 auto-load 同一份語言偏好、格式規則、外部輸出驗證規則、記憶同步協議。

## 它做什麼

每次 Cowork session 開始, plugin 用 `SessionStart` hook 把 `context/standards.md` 注入 Claude 的脈絡。內容包括:

- **User preferences**: 繁體中文為主、不用 simplified Chinese、不用 em dash、對話式語氣、直接給結論。
- **外部輸出驗證規則**: share 給外部 (Slack, email, doc, customer, peers) 的內容, 必須對 vendor citation / API name / quota / version 數字做第二輪 fact-check 對照 official docs, 標 ✅⚠️❌。
- **記憶同步協議**: 透過每個專案根目錄的 `_memory.md` 在不同機器之間同步 auto-memory, 包含手動指令與自動觸發規則。

## Slash commands (skills)

| Command | 做什麼 |
| --- | --- |
| `/sync-out` | Consolidate auto-memory, 寫到當前專案的 `_memory.md` (覆蓋) |
| `/sync-in` | 從當前專案的 `_memory.md` 讀記憶 merge 進 auto-memory (不覆蓋) |
| `/verify-claims` | 對最近 output 的 vendor / API / 數字 claim 跑 fact-check pass, 對照 official docs |

## Install

### 一次性: download `.plugin` 檔案

從 [GitHub Releases](https://github.com/andylin33/andy-personal-standards/releases) 抓最新的 `andy-personal-standards.plugin`, 或從 source build (見下方)。

### 在 Cowork (Mac) install

雙擊 `andy-personal-standards.plugin`, Claude 會打開 plugin install 視窗, 按 Install。

或在 Cowork 對話框拖進 `.plugin` 檔, Claude 會 prompt 安裝。

### 驗證裝好了

開新 session, 跟 Claude 講「我的個人偏好是什麼?」, 應該回繁體中文、不用 em dash、提到 verification 規則。

或執行 `/sync-out` (在沒有 `_memory.md` 的專案), 應該寫一份 `_memory.md` 到當前資料夾。

### Mini 跟 Air 各自怎麼裝

兩台機器步驟一樣:

1. `git clone https://github.com/andylin33/andy-personal-standards.git ~/code/andy-personal-standards` (或 download zip)
2. `cd ~/code/andy-personal-standards && ./build.sh` (or 手動 zip 見下)
3. 雙擊產生的 `andy-personal-standards.plugin` 在 Cowork install
4. Restart Cowork session

## 改規則的工作流程

當你要改規則 (例如改 verification 觸發條件、加新 user preference):

1. 在 `~/code/andy-personal-standards/` 編輯對應檔案:
   - 改 standards 內容 → `context/standards.md`
   - 改 skill 行為 → `skills/<name>/SKILL.md`
   - 加新 skill → `skills/<new-name>/SKILL.md`
2. Bump `.claude-plugin/plugin.json` 的 `version`。
3. Commit + push 到 GitHub。
4. Rebuild `.plugin`:
   ```bash
   cd ~/code/andy-personal-standards
   zip -r /tmp/andy-personal-standards.plugin . -x "*.DS_Store" -x ".git/*"
   ```
5. 在 Mini + Air 各自 reinstall (Cowork 會用新版蓋掉舊的)。

如果常常改, 寫一個 GitHub Action 自動 release `.plugin` 比較順。

## Build from source

```bash
git clone https://github.com/andylin33/andy-personal-standards.git
cd andy-personal-standards
zip -r /tmp/andy-personal-standards.plugin . -x "*.DS_Store" -x ".git/*" -x "*.plugin"
```

`.plugin` 檔會在 `/tmp/andy-personal-standards.plugin`。

## Plugin 結構

```
andy-personal-standards/
├── .claude-plugin/
│   └── plugin.json           # manifest
├── context/
│   └── standards.md          # auto-loaded 內容
├── hooks/
│   └── hooks.json            # SessionStart hook
├── skills/
│   ├── sync-out/SKILL.md
│   ├── sync-in/SKILL.md
│   └── verify-claims/SKILL.md
└── README.md
```

## v2 idea (還沒做)

- `alta-*` PM skills: 把 Alta AI 專案專屬的 PRD format、stakeholder list、metric definitions 包成 skill (但只在 alta-* 專案用, 用 trigger phrase gate)。
- `/list-vendors-to-verify` skill: 給一段草稿, 列出裡面所有需要 verify 的 vendor / API / 數字, 但先不去 verify, 讓 Andy 決定要不要 run `/verify-claims`。
- 跟 productivity plugin 的 memory-management 整合, 把 sync-out 的 dedupe 用同一套 logic。
- GitHub Action: push 到 main 自動 build `.plugin` 並 attach 到 release, 兩台機器可以直接抓。

## Changelog

### v0.2.0 (2026-04-27)

Strengthened verification rule: mandatory default for any output going beyond Andy's private chat. No more 'judgement call' on whether to verify; auto-verify if external.

### v0.1.0

Initial release: standards.md auto-load via SessionStart hook, `/sync-out`, `/sync-in`, `/verify-claims` skills.

## License

MIT
