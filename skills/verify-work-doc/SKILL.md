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
  version: "0.3.1"
  author: "Andy Lin"
---

# /verify-work-doc

對 work-bound output (Slack post / email / shared doc / customer-facing / leadership review) 跑完整 5-dimension verification, 比 `/verify-claims` 多 4 dimension。`/verify-claims` 只管 facts, 這個 skill 把 facts + coherence + tone + format + audience fit 一起看。

## 何時觸發

- Andy 明說 "verify work doc", "/verify-work-doc", "驗工作稿", "full 5 dimension check"
- 自動觸發 (不需 Andy 開口, 見 `context/standards.md` 的 `Trigger /verify-work-doc 自動 invoke` section), 條件是 **audience indicator AND deliverable verb 雙條件同時成立**, 不是 OR。詳細 condition list + 對照例子在 standards.md。

## 5 dimension 各自怎麼 check

### Dimension 1: Facts

內部 invoke `/verify-claims`, 拿那個 report 的結果直接套進來。Facts 那個 row 的 status / issue / fix 直接從 `/verify-claims` 結論 copy 過來。

### Dimension 2: Coherence (4-step structure, do not skip steps)

Step 1 , Decompose:
  List EVERY claim / conclusion in the doc. Number them C1, C2, ...

Step 2 , Map premises:
  For each Cn, identify supporting premise(s) (cite specific sentence or data source).
  If no premise → mark "(no support)".

Step 3 , Tag issues:
  - **Gap**: claim has no supporting premise
  - **Contradiction**: premises conflict with each other or with the claim
  - **Leap**: premise → claim has unstated assumption that isn't in the doc

Step 4 , Steel-man counter-argument (for top 3 conclusions):
  For each major conclusion, generate the strongest counter-argument someone could make.
  Check: does the doc address this counter? If not, flag.

Output: a numbered table per claim with status [✅/Gap/Contradiction/Leap] + suggested fix.

四步不能跳, 不能合併。即使 doc 很短, 也照走 (短 doc 走得快, 但 step 還是要明確踩到)。

### Dimension 3: Tone

Tone check 拆兩個 anti-pattern reference list, 視 output 語言走對應 list:

#### 3.1 English work-doc anti-patterns (主要, work doc 都英文)

不准出現:

- **Sycophantic opener**: "I'd be happy to", "Happy to help with this", "I'd love to"
- **Hedge stacking**: "perhaps maybe possibly", "I think I believe I feel"
- **Filler / softeners**: "It's worth noting that...", "I'd argue that...", "To be honest..."
- **Anthropic-flagged**: "honestly", "genuinely", "straightforward"
- **Generic closer**: "Let me know if you have any questions", "Hope this helps", "Happy to discuss"
- **Corporate buzzwords**: leverage (as verb), synergize, touch base, circle back, ladder up, low-hanging fruit, boil the ocean, move the needle, deep dive (as verb), unpack (in business sense)
- **Emoji** (unless audience already uses them in same channel)
- **Em dash (—)**, use comma instead (Andy preference)
- **Long bullet lists when prose works**, prefer paragraph
- **Redundant qualifiers**: "very", "really", "basically", "actually" usually cuttable

要呈現:

- **Declarative tone**, no "I think..." wrapping every statement
- **Audience-matched register**:
  - Engineering peer (Daly / Van): tech jargon OK, direct
  - Leadership (Amela): frame in outcome / risk / trade-off, less jargon
  - Customer-facing: no internal acronym, plain English, benefit-focused
- **Concise**, cut every redundant qualifier

#### 3.2 Chinese chat anti-patterns (跟 Andy 私下對話 separate reference)

不准出現:

- 簡體中文 (Andy 是台灣人)
- PRC corporate calque: 對齊 / 賦能 / 視頻 / 軟件 / 鼠標 / 打印機 / 登錄 / 默認 / 服務器 / 質量 (技術語境) / 信息 / 數據 (當資訊用)
- Em dash (—), 用逗號

要呈現:

- 繁體中文為主
- 名字 / 技術名詞 / 產品名 / 客戶名用英文
- 對話式語氣, 少用 bullet, 少用 heading
- Taiwanese register: 取得共識 / 達到共識 (不用對齊), 影片 (不用視頻), 軟體 (不用軟件), 滑鼠 (不用鼠標), 印表機 (不用打印機), 登入 (不用登錄), 預設 (不用默認), 伺服器 (不用服務器), 品質 (不用質量), 訊息 (不用信息), 資料 (不用數據, 當 info 解時)

#### 3.3 怎麼套

- Output 是英文 work doc → 套 3.1 list, 把違規處標出來。
- Output 是中文跟 Andy 對話 → 套 3.2 list (work-doc 場景下少見, 但 Andy 私下 chat 出 review report 時用)。
- Output 是中英混 → 兩個 list 都掃一遍, 各自 flag 違規。

### Dimension 4: Format

對 target medium 而言格式對嗎?
- **Slack post**: 必須 mrkdwn syntax 不是 markdown。`*bold*` 不是 `**bold**`, `_italic_` 不是 `*italic*`, `~strikethrough~`, ``` `code` ``` , 沒 heading syntax (`#`, `##`)。
- **Email**: HTML 或純 plain, 視 audience。
- **docx / Google Doc**: 結構乾淨, heading hierarchy 對, table / bullet 該用就用。
- **markdown doc**: 標準 markdown, heading 階層合理, code block 標 language。

### Dimension 5: Audience fit

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
| Coherence | ⚠️ | C3 has Gap (no premise for "X causes Y"); C5 Leap on assumed industry baseline | See per-claim table below |
| Tone | ❌ | "I'd be happy to" opener + 3 em dashes + "leverage" used as verb | Replace per anti-pattern list 3.1 |
| Format | ❌ | Used `**bold**` for Slack, should be `*bold*` | Apply find-replace before posting |
| Audience fit | ⚠️ | Daly is engineering, "BRM workflow" jargon OK; for Amela (leadership), simplify | Consider audience-specific draft |

## Coherence per-claim table

| Claim | Status | Issue | Fix |
|---|---|---|---|
| C1: ... | ✅ | - | - |
| C2: ... | Gap | No premise cited | Add data source or remove |
| C3: ... | Leap | Assumes industry baseline not stated | State assumption explicitly |

## Steel-man counters (top 3 conclusions)

- Conclusion A: counter-argument is X. Doc addresses? [yes / no, flag]
- ...

## Overall: NOT READY (2 ❌, 2 ⚠️). Fix above before delivering.
```

Status 規則:
- 全部 ✅ → Overall: READY
- 有 ⚠️ 沒 ❌ → Overall: READY WITH CAVEATS, list the warning items, Andy 自己決定要不要 fix
- 任何 ❌ → Overall: NOT READY, must fix

## 整合 `/verify-claims`

`/verify-work-doc` 跑 Facts dimension 時直接 invoke `/verify-claims` 拿結果, 不重做。所以 `/verify-claims` 是 building block, `/verify-work-doc` 是 superset。

如果 Andy 明確只要 facts pass, 用 `/verify-claims` (跑 ~30 sec)。
要 work-doc 整體判定, 用 `/verify-work-doc` (跑 60-120 sec, Coherence 4-step + Tone 兩 list 比較花時間)。

## 不要做

- 不要只跑部分 dimension 就回報「verified」, 必須 5 dimension 都跑完。
- 不要把 Coherence 4 step 合併成一段 prose, 必須四步分開, 每步輸出可見。
- 不要把 ⚠️ 直接吞掉當作 ✅, ⚠️ 必須在 report 內顯示讓 Andy 看到。
- 不要假設 audience, audience 不明寫時主動問 Andy 一句「這份要給誰看?」, 才能跑 dimension 5。
- 不要 silent-pass, 即使全 ✅ 也要明確回報「READY」。

## 對應規則

完整協議在 `context/standards.md` 的「外部輸出驗證規則」+「Auto-invoke verification rules」section。本 skill 是 work-doc-bound 的 full check (audience AND deliverable verb 才 fire), `/verify-claims` 是 facts-only 的 lighter check。
