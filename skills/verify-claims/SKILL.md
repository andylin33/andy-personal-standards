---
name: verify-claims
description: >
  This skill should be used when Andy says "verify claims", "/verify-claims",
  "fact check this", "驗一下", "check the citations", or otherwise asks for an
  explicit verification pass over recent output before sharing externally.
  Also trigger before any output that will be posted, sent, shared, or shown
  to engineering peers, customers, or leadership (see standards.md for full
  trigger conditions).
metadata:
  version: "0.1.0"
  author: "Andy Lin"
---

# /verify-claims

對最近的 output 跑一輪明確的 fact-check pass, 對照 official docs 驗證每個 vendor / product / API / 數字 claim, 標 ✅⚠️❌, 回報結果。

## 何時觸發

- Andy 明說 "verify", "/verify-claims", "fact check", "驗一下", "double check this"
- Andy 提到要 post / send / share 出去 (Slack post, email, doc, customer 回覆, engineering peer audience, leadership 報告)
- Output 含 vendor 或 product 名稱當 precedent (例如「Fivetran 是這樣做的」「Ironclad 用 OAuth」)
- Output 含 specific API name, OAuth scope name, quota number, version number, TTL, rate limit
- Stakes 高 (任何「Andy 說錯就尷尬」的 audience)

## 執行步驟

1. **掃過最近的 output** (這個 session 內的, 或 Andy 指明的範圍), 列出所有需要驗證的 claim, 分類:

   - **Vendor / product precedent**: 「X 公司用 Y pattern」「Z 服務支援 W feature」
   - **API / scope name**: 「用 `drive.file` scope」「call `/files.list` endpoint」
   - **Quota / limit / version 數字**: 「rate limit 是 100/min」「v3 API」「TTL 1 hour」
   - **Behavioral claim**: 「這個 service 預設啟用 SSO」「這個 OAuth flow 不需要 refresh token」

2. **對每一條 claim, 找 official source**:
   - 優先順序: 該 vendor 自己的 official docs > vendor 的 GitHub / changelog > 其他官方 source。
   - **不接受**: third-party blog, Stack Overflow, Reddit, AI-generated summary, 上次的對話 context。
   - 用 WebFetch 或 WebSearch 抓 source。

3. **打標**:
   - ✅ 對照 official source 確認屬實, 附 URL。
   - ⚠️ Source 部分支持 / 已過時 / 需要 caveat, 附 URL 加說明。
   - ❌ 找不到 source 或 source 直接反駁。建議改寫或砍掉。

4. **回報 Andy 一份結構化 verification report**:

   ```
   Verification pass on <output 描述>:

   ✅ 通過 (N 條)
   - claim 1 — source URL
   - claim 2 — source URL

   ⚠️ 需要 hedge (M 條)
   - claim 3 — 原本說 X, official docs 說 Y, 建議改成 Z — source URL

   ❌ 砍掉或重寫 (K 條)
   - claim 4 — 找不到 source, 建議刪除
   - claim 5 — 跟 official docs 直接矛盾 — source URL

   建議的 revised output: ...
   ```

5. **如果有 ❌ 或多條 ⚠️**, 主動提供改寫版本給 Andy, 不要只是回報問題。

## 不要做

- 不要把 third-party blog 當 source 過關。
- 不要因為「之前對話這樣說」就當 source。Auto-memory 不算 source。
- 不要 silent-pass, 即使全部 ✅ 也要明確回報「verified, all clear」。
- 不要在 verification 還沒做之前就跟 Andy 說「應該沒問題吧」。

## 對應規則

完整規則在 `context/standards.md` 的「外部輸出驗證規則」section。本 skill 是顯式 trigger, 但驗證的觸發條件、source 標準、為什麼要做, 全部依 standards.md。
