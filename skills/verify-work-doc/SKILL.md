---
name: verify-work-doc
description: >
  This skill should be used when Andy says "verify work doc",
  "/verify-work-doc", "驗工作稿", "5-dimension check", or otherwise asks
  for full 5-dimension verification on output that will be posted, sent,
  shared, or shown to engineering peers, customers, or leadership. Auto-
  invoked under triggers in standards.md "Trigger /verify-work-doc auto
  invoke" section.
metadata:
  version: "0.3.0"
  author: "Andy Lin"
---

# /verify-work-doc

對 work-bound output (Slack post / email / shared doc / customer-facing / leadership review) 跑完整 5-dimension verification, 比 `/verify-claims` 多 4 dimension。`/verify-claims` 只管 facts, 這個 skill 把 facts + coherence + tone + format + audience fit 一起看。

## 何時觸發

- Andy 明說 "verify work doc", "/verify-work-doc", "驗工作稿", "full 5 dimension check"
- 自動觸發 (不需 Andy 開口, 見 `context/standards.md` 的 `Trigger /verify-work-doc 自動 invoke` section), ANY of:
  - Andy 指明 output 要 post / send / share / submit
  - Output 提到 audience 名字 (Daly / Van / Amela / customer 名 / Slack channel)
  - Output 是 structured work deliverable (spec / draft / report / plan / 報告 / 簡報)
  - 含「draft」「proposal」「spec」「post to」keywords
  - Stakes high (peer engineer 看, customer commit, leadership)

## 5 dimension 各自怎麼 check

### 1. Facts

內部 invoke `/verify-claims`, 拿那個 report 的結果直接套進來。Facts 那個 row 的 status / issue / fix 直接從 `/verify-claims` 結論 copy 過來。

### 2. Coherence

LLM 再 read 一次 output, 問:
- 主張是否被 evidence 支援?
- 有沒有跳論點 (premise A → conclusion B 中間缺了步驟)?
- 結論跟前提矛盾?
- 同一個 claim 在文件不同位置寫法不一致?

⚠️ 範例: 「Premise 2 doesn't support conclusion 3」「結論說 X 但前面論證的是 Y」。

### 3. Tone

跟 audience 對嗎?
- 太諂媚 (sycophantic), 出現「great question」「wonderful idea」這類 filler 沒了。
- 太冷 / 太死板, 像 corporate template, 不像 peer 對 peer。
- 不合 Andy 偏好: peer-level, professional 但不死板, 直接結論不過度 hedge。
- 中英 mix 是否自然 (Andy 偏好繁中 + 名字 / 技術名詞英文, 不要 PRC calque)。

### 4. Format

對 target medium 而言格式對嗎?
- **Slack post**: 必須 mrkdwn syntax 不是 markdown。`*bold*` 不是 `**bold**`, `_italic_` 不是 `*italic*`, `~strikethrough~`, ``` `code` ``` , 沒 heading syntax (`#`, `##`)。
- **Email**: HTML 或純 plain, 視 audience。
- **docx / Google Doc**: 結構乾淨, heading hierarchy 對, table / bullet 該用就用。
- **markdown doc**: 標準 markdown, heading 階層合理, code block 標 language。

### 5. Audience fit

Given audience 名字, 用詞 / 深度 / jargon level 對嗎?
- Engineering peer (Daly / Van 等): 技術 jargon OK, 直接寫 API name / db schema / 工具名。
- Leadership (Amela 等): 抽象高一階, business outcome / risk / cost 為主, 技術細節用 footnote。
- Customer-facing: 不假設 internal 名詞, 任何 acronym 第一次出現 spell out。
- 一份 doc 同時要服務多 audience 時, 提示 Andy 是否要切版本。

## Output 結構

跑完 5 dimension, 出一份 markdown table report:

```markdown
# Work Doc Verification Report

| Dimension | Status | Issue | Fix Suggestion |
|---|---|---|---|
| Facts | ✅ | All citations verified | - |
| Coherence | ⚠️ | Premise 2 doesn't support conclusion 3 | Restate or remove |
| Tone | ✅ | Matches peer-level professional | - |
| Format | ❌ | Used `**bold**` for Slack, should be `*bold*` | Apply find-replace before posting |
| Audience fit | ⚠️ | Daly is engineering, "BRM workflow" jargon is OK; but for Amela (leadership), simplify | Consider audience-specific draft |

## Overall: NOT READY (1 ❌, 2 ⚠️). Fix above before delivering.
```

Status 規則:
- 全部 ✅ → Overall: READY
- 有 ⚠️ 沒 ❌ → Overall: READY WITH CAVEATS, list the warning items, Andy 自己決定要不要 fix
- 任何 ❌ → Overall: NOT READY, must fix

## 整合 `/verify-claims`

`/verify-work-doc` 跑 Facts dimension 時直接 invoke `/verify-claims` 拿結果, 不重做。所以 `/verify-claims` 是 building block, `/verify-work-doc` 是 superset。

如果 Andy 明確只要 facts pass, 用 `/verify-claims`。
要 work-doc 整體判定, 用 `/verify-work-doc`。

## 不要做

- 不要只跑部分 dimension 就回報「verified」, 必須 5 dimension 都跑完。
- 不要把 ⚠️ 直接吞掉當作 ✅, ⚠️ 必須在 report 內顯示讓 Andy 看到。
- 不要假設 audience, audience 不明寫時主動問 Andy 一句「這份要給誰看?」, 才能跑 dimension 5。
- 不要 silent-pass, 即使全 ✅ 也要明確回報「READY」。

## 對應規則

完整協議在 `context/standards.md` 的「外部輸出驗證規則」+「Auto-invoke verification rules」section。本 skill 是 work-doc-bound 的 full check, `/verify-claims` 是 facts-only 的 lighter check。
