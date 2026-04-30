# Andy's Personal Standards

跨機器、跨專案的個人工作標準, 打包成可 install 的 Cowork plugin。

裝在哪台機器, 哪個 session, 都會 auto-load 同一份語言偏好、格式規則、外部輸出驗證規則 (含 work-doc 5-dimension)、dispatch verification protocol、記憶同步協議。

## 它做什麼

每次 Cowork session 開始, plugin 用 `SessionStart` hook 把 `context/standards.md` 注入 Claude 的脈絡。內容包括:

- **User preferences**: 繁體中文為主、不用 simplified Chinese、不用 em dash、不用 PRC calque、對話式語氣、直接給結論。
- **外部輸出驗證規則**: share 給外部 (Slack, email, doc, customer, peers) 的內容, MANDATORY 驗證 vendor citation / API name / quota / version 數字, 對照 official docs。
- **Auto-invoke verification rules**: Claude 不靠 Andy 開口, 自己依條件決定 invoke `/verify-claims` (light) 或 `/verify-work-doc` (full 5 dimension)。
- **Dispatch verification protocol**: 派 sub-agent 時 MANDATORY 在 prompt 末尾 paste verification template (general 或 work-doc-bound), 沒例外。
- **記憶同步協議**: 透過 Google Drive 上 5 個 `_memory.md` 檔案 (4 project + 1 global) 在不同機器之間同步 auto-memory, 統一用 `/sync` skill (預設 dry-run)。

## Slash commands (skills)

| Command | 做什麼 |
| --- | --- |
| `/sync` | Bidirectional reconcile, 把當前 auto-memory 跟 Google Drive 上 5 個 `_memory.md` 對齊。預設 dry-run, 加 `--apply` 才寫。Replaces 舊的 `/sync-in` + `/sync-out` |
| `/verify-claims` | Light fact-check pass, 對最近 output 的 vendor / API / 數字 claim 對照 official docs, 標 ✅⚠️❌ |
| `/verify-work-doc` | Full 5-dimension verification (Facts, Coherence, Tone, Format, Audience fit), 給 work-bound output (Slack post / email / shared doc / customer / leadership) |

## Install

### 一次性: download `.plugin` 檔案

從 [GitHub Releases](https://github.com/andylin33/andy-personal-standards/releases) 抓最新的 `andy-personal-standards.plugin`, 或從 source build (見下方)。

### 在 Cowork (Mac) install

雙擊 `andy-personal-standards.plugin`, Claude 會打開 plugin install 視窗, 按 Install。

或在 Cowork 對話框拖進 `.plugin` 檔, Claude 會 prompt 安裝。

### 驗證裝好了

開新 session, 跟 Claude 講「我的個人偏好是什麼?」, 應該回繁體中文、不用 em dash、提到 verification + dispatch + 5-dimension 規則。

或執行 `/sync` (dry-run), 應該 print plan 列出 5 個 sync target 的 push / pull / conflict。

### Mini 跟 Air 各自怎麼裝

兩台機器步驟一樣:

1. `git clone https://github.com/andylin33/andy-personal-standards.git ~/code/andy-personal-standards` (或 download zip)
2. `cd ~/code/andy-personal-standards && ./build.sh`
3. 雙擊產生的 `andy-personal-standards.plugin` 在 Cowork install
4. Restart Cowork session

## 改規則的工作流程

當你要改規則:

1. 在 plugin source 編輯對應檔案:
   - 改 standards 內容 → `context/standards.md`
   - 改 skill 行為 → `skills/<name>/SKILL.md`
   - 加新 skill → `skills/<new-name>/SKILL.md`
2. Bump `.claude-plugin/plugin.json` 的 `version`。
3. 同步 4 個 project CLAUDE.md (如果改的是 verification / sync 那一塊)。
4. Commit + push 到 GitHub。
5. Rebuild `.plugin`: `./build.sh`
6. 在 Mini + Air 各自 reinstall。

## Build from source

```bash
git clone https://github.com/andylin33/andy-personal-standards.git
cd andy-personal-standards
./build.sh
```

`.plugin` 檔會在 `/tmp/andy-personal-standards.plugin`。

## Plugin 結構

```
andy-personal-standards/
├── .claude-plugin/
│   └── plugin.json            # manifest
├── context/
│   └── standards.md           # auto-loaded 內容
├── hooks/
│   └── hooks.json             # SessionStart hook
├── skills/
│   ├── sync/SKILL.md          # bidirectional reconcile, dry-run default
│   ├── verify-claims/SKILL.md # light fact-check
│   └── verify-work-doc/SKILL.md # full 5-dimension
├── build.sh
└── README.md
```

## v2 idea (還沒做)

- `alta-*` PM skills: 把 Alta AI 專案專屬的 PRD format、stakeholder list、metric definitions 包成 skill (但只在 alta-* 專案用, 用 trigger phrase gate)。
- `/list-vendors-to-verify` skill: 給一段草稿, 列出裡面所有需要 verify 的 vendor / API / 數字, 但先不去 verify, 讓 Andy 決定要不要 run `/verify-claims`。
- 跟 productivity plugin 的 memory-management 整合, 把 `/sync` 的 dedupe 用同一套 logic。
- GitHub Action: push 到 main 自動 build `.plugin` 並 attach 到 release。

## Changelog

### v0.3.0 (2026-04-30)

Major refactor. Three big shifts:

- **Sync 重做**: 砍掉 `/sync-in` + `/sync-out` 兩個 skill, 整合成單一 `/sync`。預設 dry-run, 加 `--apply` 才寫。Sync 5 個 target file (4 project + 1 global), entry 加 `scope` field, conflict 用 in-place multi-version block + `conflict_pending` marker, atomic write + mtime race detection, 動態 auto-memory path 解析。
- **Work-doc verification**: 新 skill `/verify-work-doc` 跑 full 5-dimension check (Facts / Coherence / Tone / Format / Audience fit), 給 Slack post / email / shared doc / customer-facing / leadership 用。`/verify-claims` 維持 light fact-check 角色。
- **Dispatch verification template**: standards.md 加 `Dispatch verification protocol` section, 派 sub-agent 時 MANDATORY 在 prompt 末尾 paste 兩個 template 之一 (general 或 work-doc-bound), 沒例外。`Auto-invoke verification rules` section 把觸發條件寫死, Claude 不靠 Andy 開口自己決定哪個 skill 該跑。

4 project CLAUDE.md (Alta AI / Get a job / Slack Virtual Office / AI Morning Debrife) 同步更新 v0.3.0 規則, 保留各自 project context。

### v0.2.0 (2026-04-27)

Strengthened verification rule: mandatory default for any output going beyond Andy's private chat. No more 'judgement call' on whether to verify; auto-verify if external.

### v0.1.0

Initial release: standards.md auto-load via SessionStart hook, `/sync-out`, `/sync-in`, `/verify-claims` skills.

## License

MIT
