---
name: sync-in
description: >
  This skill should be used when Andy says "sync in", "sync 進來", "/sync-in",
  "load memory from drive", "import memory", or otherwise asks to pull the
  project's shared `_memory.md` into the current session's auto-memory.
metadata:
  version: "0.1.0"
  author: "Andy Lin"
---

# /sync-in

從當前專案根目錄的 `_memory.md` 把記憶讀進當前 session 的 auto-memory, merge 不覆蓋。

## 何時觸發

- Andy 明說 "sync in", "sync 進來", "/sync-in"
- Andy 說 "load my memory", "import memory from drive", "pull memory"
- 自動觸發: Andy 提到的人 / 決策 / 專案 / 事物在當前 auto-memory 找不到時 (見 `context/standards.md` 「自動 sync-in」section)

## 執行步驟

1. **找專案根目錄**, 邏輯同 `/sync-out`。

2. **檢查 `<project-root>/_memory.md` 是否存在**:
   - 不存在: 告訴 Andy「這個專案還沒有 `_memory.md`, 沒東西可以 sync-in」, 結束。
   - 存在: 繼續。

3. **讀進來**, parse 出每一條記憶 (依 markdown bullet 切)。

4. **逐條對照當前 auto-memory**:
   - 已存在 (依名稱 / 描述 fuzzy match): 跳過, 不覆蓋。
   - 不存在: 加進當前 auto-memory。
   - 矛盾 (相同主題但內容衝突): 不覆蓋, 標記為「需要 Andy 裁決」。

5. **回報 Andy** (一行 + 細節):
   ```
   從 _memory.md 同步: 新增 N 條, 已存在 M 條跳過, K 條矛盾待裁決。
   ```
   矛盾的條目用 short bullet 列出來給 Andy 看。

## 不要做

- **不要覆蓋已有記憶**, 除非 Andy 明確說「以 `_memory.md` 為準」。
- 不要靜默執行, 完成後一定要告知 Andy。
- 如果 `_memory.md` 看起來明顯過時 (例如 last sync-out 是好幾個月前) 或結構壞掉, 先警告 Andy 再決定要不要 import。

## 對應規則

完整協議在 `context/standards.md` 的「記憶同步協議」section。
