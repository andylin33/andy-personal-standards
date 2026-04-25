---
name: sync-out
description: >
  This skill should be used when Andy says "sync out", "sync 出去", "/sync-out",
  "save my memory to drive", "export memory", or otherwise asks to push the
  current session's auto-memory to the project's shared `_memory.md` file.
metadata:
  version: "0.1.0"
  author: "Andy Lin"
---

# /sync-out

把當前 session 的 auto-memory 匯出到當前專案根目錄的 `_memory.md`, 讓其他機器、其他 session 可以讀到同一份記憶。

## 何時觸發

- Andy 明說 "sync out", "sync 出去", "/sync-out"
- Andy 說 "save my memory", "export memory to drive", "push memory"
- 自動觸發: session 產生明顯成果時 (見 `context/standards.md` 「自動 sync-out」section)

## 執行步驟

1. **找專案根目錄**。優先順序:
   - 當前工作目錄如果有 `.git`, 用它當根。
   - 沒有的話往上找最近的 `.git` 目錄。
   - 都找不到, 用當前工作目錄, 並提醒 Andy。

2. **Consolidate auto-memory** (dedupe + 整理):
   - 把語意相同的條目合併。
   - 移除已過時的項目 (例如已完成的 task、已離職的人物 context)。
   - 把同一個人物 / 專案 / 主題的散落條目歸到一起。

3. **Export 成 markdown**, 結構如下:

   ```markdown
   # _memory.md

   Last sync-out: YYYY-MM-DD by [machine name if known]

   ## User memories
   ...
   ## Feedback memories
   ...
   ## Project memories
   ...
   ## Reference memories
   ...
   ```

   每條記憶用 bullet, 保留原本 auto-memory 的措辭。

4. **寫入 `<project-root>/_memory.md`**, 覆蓋舊的。

5. **回報 Andy** (一行):
   ```
   剛剛同步了 N 條記憶到 <absolute path to _memory.md>。 (consolidated: X 條合併, Y 條淘汰)
   ```

## 不要做

- 不要靜默執行, 完成後一定要告知 Andy。
- 不要 partial sync, 每次 sync-out 是完整覆蓋。
- 不要把 sensitive data (API keys, passwords, OAuth tokens) 寫進 `_memory.md`。如果 auto-memory 裡有, 標 ⚠️ 警告 Andy 並省略。

## 對應規則

完整協議在 `context/standards.md` 的「記憶同步協議」section。本 skill 只是 manual trigger, 自動觸發邏輯遵守 standards.md 的規定。
