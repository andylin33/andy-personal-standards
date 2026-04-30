---
name: sync
description: >
  This skill should be used when Andy says "sync", "/sync", "sync 一下",
  "reconcile memory", "同步記憶", or otherwise asks to reconcile the
  current session's auto-memory against the shared `_memory.md` files on
  Google Drive. Replaces the old `/sync-in` and `/sync-out` skills with a
  single bidirectional reconcile pass. Default is dry-run, only `--apply`
  actually writes.
metadata:
  version: "0.3.0"
  author: "Andy Lin"
---

# /sync

雙向 reconcile, 把當前 session auto-memory 跟 Google Drive 上 5 個 `_memory.md` 檔案對齊。一個 skill 處理過去 `/sync-in` + `/sync-out` 的所有 case, 不再分方向。

## 何時觸發

- Andy 明說 "sync", "/sync", "sync 一下", "reconcile memory", "同步記憶"
- Andy 說 "save memory to drive" / "load memory from drive" (照舊 alias, 都進這個 skill)
- 自動觸發: session 產生明顯成果, 或 Andy 提到 auto-memory 找不到的人 / 決策 / 專案脈絡時 (見 `context/standards.md` 的記憶同步協議)

## 預設 dry-run, 顯式 `--apply` 才寫

預設執行只 print plan, **不實寫任何檔案**:

```
Plan (dry-run, no files written):

PUSH local → drive
  - entry "alta_partnership_funnel" (scope: project:Alta AI) NEW

PULL drive → local
  - entry "daly_review_style" (scope: project:Alta AI) NEW

CONFLICT (pending Andy 裁決, skipped)
  - entry "verification_default" (scope: global) , 2 versions

To apply, re-run with `--apply`.
```

只有 Andy 顯式說 "sync --apply" / "sync 真的寫" / "/sync --apply" 才動檔。

**第一次裝完 plugin 後第一次 invoke `/sync`, 強制 dry-run, 即使 Andy 說 `--apply`**, 並提醒 Andy「這是這台機器第一次 sync, 先看 plan, 確認沒問題再 `--apply`」。判定方式: plugin 目錄下找 `~/.andy-personal-standards/.sync_initialized` (絕對路徑可調), 不存在就視為第一次, dry-run 結束後寫一個 marker file。

## Sync targets (一次掃 5 處)

每次 `/sync` 都掃下面 5 個 file, 不選擇性 sync 單個。

1. `~/Library/CloudStorage/GoogleDrive-s.y.lin.andy@gmail.com/My Drive/AI Tools and Projects/Alta AI/_memory.md`
2. `~/Library/CloudStorage/GoogleDrive-s.y.lin.andy@gmail.com/My Drive/AI Tools and Projects/Get a job/_memory.md`
3. `~/Library/CloudStorage/GoogleDrive-s.y.lin.andy@gmail.com/My Drive/AI Tools and Projects/Slack Virtual Office/_memory.md`
4. `~/Library/CloudStorage/GoogleDrive-s.y.lin.andy@gmail.com/My Drive/AI Tools and Projects/AI Morning Debrife/_memory.md`
5. `~/Library/CloudStorage/GoogleDrive-s.y.lin.andy@gmail.com/My Drive/AI Tools and Projects/_global_memory.md` (新建檔, 給 scope 是 global 的 entry)

每個 entry 依自己的 `scope` 路由到正確的目標檔, project entry 進對應專案 `_memory.md`, global entry 進 `_global_memory.md`。

## `_memory.md` 格式

```markdown
# Memory for [Project Name OR Global]

Last synced: 2026-04-30T14:32 by Mini

---

## entry_name_1

**type**: feedback
**description**: ...
**scope**: global
**last_updated**: 2026-04-30T14:32 by Mini

content body, 多段都 OK

---

## entry_name_2

**type**: project
**description**: ...
**scope**: project:Alta AI
**last_updated**: 2026-04-29T11:02 by Air

content body
```

兩條 entry 之間用 `---` 分隔。`scope` 寫 `global` 或 `project:<exact project folder name>`。

## Per-entry frontmatter (local auto-memory)

寫進 auto-memory 的 entry 一律加上 `scope` field:

```yaml
---
name: ...
description: ...
type: feedback
scope: global
last_updated: 2026-04-30T14:32 by Mini
---
```

或 project-scoped:

```yaml
---
name: ...
description: ...
type: project
scope: "project:Alta AI"
last_updated: 2026-04-29T11:02 by Air
---
```

**舊 entry 沒 `scope` field**: 視為 `scope: global`, sync 時補上。
**舊 entry 有 `originSessionId`**: sync 時 strip 掉, 不再保留。

## 動態解析 auto-memory 路徑

不要 hardcode `/sessions/<some-name>/mnt/.auto-memory/`。每次 invoke skill 時依下列順序找 path:

1. `$AUTO_MEMORY_DIR` env var (若設了直接用)
2. 從 CWD 往上找直到看到 `mnt/.auto-memory/` 目錄
3. `${CLAUDE_PLUGIN_ROOT}/../.auto-memory/`
4. 找不到就跟 Andy 說「auto-memory dir 找不到, 請設 `AUTO_MEMORY_DIR` 或 cd 到正確的位置」, 中止

這樣 Mini 跟 Air 不同 agent ID / session name 都能 work。

## 執行步驟

1. **Resolve auto-memory dir** (依上面順序)。

2. **Read 當前 auto-memory** 跟 5 個 `_memory.md` 全部檔案 (不存在的 file 視為空)。

3. **Index by name + scope**, 建一個 entry map:
   - Local (auto-memory) entries
   - Drive entries (從 5 個 file 合併)

4. **比對, 對每個 entry name 三種 case**:
   - **Only local**: PUSH (寫去對應 scope 的 file)
   - **Only drive**: PULL (加進 auto-memory)
   - **Both, content 相同**: skip
   - **Both, content 不同**: CONFLICT (見下面)
   - **Drive entry `status: conflict_pending`**: 整個 entry skip 不動

5. **Print plan** (dry-run output 上面範例的那種), 顯示:
   - Push 幾條, 列出 name + scope
   - Pull 幾條, 列出 name + scope
   - Conflict 幾條, 列出 name + scope
   - 已經 `conflict_pending` 又被 skip 的有幾條
   - 所有目標 file 路徑

6. **若不是 `--apply`**: 結束。**若是 `--apply` 且不是首次**: 進第 7 步。

7. **Atomic write** 每個目標 file (見下面 atomic write protocol)。Push 完才寫 auto-memory (新 entry 加進去)。

8. **回報**: 每個 file 寫了幾條, 路徑, conflict 數量, conflict 列表。

## Conflict resolution

同 name 但內容 / `last_updated` 不同, 在 drive `_memory.md` entry section 內保留多 version, 加 marker:

```markdown
## entry_name

**type**: feedback
**description**: ...
**scope**: global
**status**: conflict_pending

### Version 1 , Mini, 2026-04-29T14:32

content from version 1...

### Version 2 , Air, 2026-04-29T16:15

content from version 2...
```

**`/sync` 看到 `status: conflict_pending` 整個 entry 完全不動, 等 Andy 手動 resolve。**

Andy resolve 流程 (記在 SKILL.md 給他自己看):
1. Andy 開 `_memory.md`, 找到 conflict_pending entry。
2. 留下要保留的那個 version 內容 body, 砍掉其他 version block 跟 marker (`### Version N` heading)。
3. 移除 `**status**: conflict_pending` 行。
4. 更新 `**last_updated**` 為當前時間 + 機器名。
5. 下次 `/sync --apply` 就會 propagate 這個 resolved 版本到 auto-memory。

Sync output 顯示「N entries pending conflict resolution, skipped」, 提醒 Andy 去看哪些。

## Atomic write protocol

寫 `_memory.md` 時:

1. `stat` 目標 file 拿 mtime 當 token (race detection 基準)。
2. 寫到 `_memory.md.tmp` 在同一目錄 (確保 cross-fs rename 不會發生)。
3. fsync 那個 tmp file。
4. 再 `stat` 一次目標 file, 比對 mtime 跟 step 1 拿到的。**不一樣表示寫入過程中有別人改了, 中止這次 write, tmp 不刪 (留給 Andy 看), 報錯**。
5. mtime 一致才 `mv` (POSIX atomic rename)。

不存在的目標 file 用 mtime=0 當基準。

## 新建 `_global_memory.md`

第一次 `/sync --apply` 偵測到有 `scope: global` 的 entry 但 `_global_memory.md` 不存在, 直接建檔 (不要當錯誤)。標題「# Memory for Global」。

## 不要做

- 不要靜默執行, dry-run 跟 apply 兩種都要明確回報結果。
- 不要 partial sync, 一次掃 5 個 target 全部。
- 不要把 sensitive data (API keys, passwords, OAuth tokens) 寫進任何 `_memory.md`, 偵測到就標 ⚠️ 警告 Andy 並 skip 該 entry。
- 不要動 `status: conflict_pending` 的 entry, 那是 Andy 還沒裁決的。
- 不要 hardcode auto-memory path (見上面動態解析)。

## 對應規則

完整協議在 `context/standards.md` 的「記憶同步協議」section。本 skill 是 manual + auto trigger 的 reconcile 實作。

## v0.3.0 changes from v0.1.0

- 砍掉 `/sync-in` + `/sync-out` 兩個 skill, 整合成單一 `/sync`
- 預設 dry-run, 加 `--apply` 才寫
- 加 5 個 sync target (4 project + 1 global)
- entry 加 `scope` field, strip 舊 `originSessionId`
- conflict 用 in-place multi-version block + `conflict_pending` marker
- atomic write + mtime race detection
- 動態 auto-memory path 解析, 不 hardcode session 名稱
- 第一次 install 後第一次 invoke 強制 dry-run 安全 net
