# 第二份作業使用指南

作業截止時間：2026 年 11 月 18 日 23:59（台灣時間）。

## 已準備的內容

- 四個程式各有 C 與手寫 RV32I 組語版本，放在 `src/`。
- 英文報告：[`REPORT.md`](REPORT.md)。可貼入一篇 HackMD，程式碼連結已固定到實作版本。
- 量測、環境版本與驗證紀錄：[`evidence/`](evidence/)。本機官方評分為 100/100，這不包含人工審查的報告和面試。
- 額外檢查：`mytests/`，包括全部 2,644 個距離 11 的 Rubik 狀態與數值誤差分析。
- CodeTrial 已從原始碼建置；本機資料夾為 `/Users/lannn/codetrial`。

## CodeTrial 設定

開啟 [本機設定頁](http://127.0.0.1:3000)，直接填入自己的四項設定。不要把金鑰貼到聊天、報告或 GitHub。

| 設定 | 來源 |
|---|---|
| Gemini / Google API key | [Google AI Studio](https://aistudio.google.com/apikey) |
| LiveKit URL | [LiveKit Cloud](https://cloud.livekit.io) 中自己的專案 |
| LiveKit API key | 同一個 LiveKit 專案 |
| LiveKit API secret | 同一個 LiveKit 專案，與該 API key 配對 |

曾貼到聊天中的金鑰請先撤銷、重建；在設定頁使用新的金鑰。頁面會檢查設定，成功後寫入 CodeTrial 的本機設定檔。該檔案不屬於作業程式庫。

若重開電腦後設定頁沒有運作，在終端機執行：

```sh
cd /Users/lannn/codetrial
/Users/lannn/.cargo/bin/cargo run --locked -- web --task-mode
```

正式錄製前，依作業要求先更新 CodeTrial 並重建。不要在進行中的面試更新、關閉或重新啟動伺服器。

## 練習與正式錄製

1. 使用桌面 Chrome 或 Chromium，接上電源，關閉通知，先走完一次練習流程。
2. 進入預設的 `rubik` task，選擇 C；全程用英文與 Jim 討論。這一部分是 C 面試，與本作業的 RV32I 組語程式分開。
3. 允許麥克風、鏡頭並完成校正。在準備階段、進入全螢幕前，啟動 CodeTrial 的本機錄影，選取 CodeTrial 分頁並勾選分享分頁音訊，才能收進 Jim 與自己的聲音。錄影須涵蓋規則頁到 Finish 後的 learning review。
4. 先檢查練習影片有畫面、有雙方聲音、能完整播放；練習影片不提交。
5. 正式面試開始後，維持全螢幕與頁面可見，依校正後的規則保持臉部在畫面內。切換分頁、離開全螢幕、重新整理可能使這次嘗試失效。
6. 正式面試必須由自己說明與寫程式。作業禁止在嘗試期間使用外部 AI、翻譯、AI 補全或語音代答；可使用 CodeTrial 內建提示。
7. 按 Finish 得到完成的 learning review；invalid 或 interrupted 的嘗試需要重做。立刻下載 result、code 和 WebM 錄影，確認檔案保存後再關閉分頁。

這些流程依 [作業要求](https://hackmd.io/@sysprog/2026-arch-homework2) 與 [CodeTrial task mode 文件](https://github.com/sysprog21/codetrial/blob/0406460cb9e7f96196bd278fc0a2d3cedb6a8fe1/docs/task-mode.md) 整理。錄影提交方式以老師最新公告為準。

## 送出前

- GitHub fork 的預設分支應為 `main`，確認最新提交已推送，且 CI 的 `lint`、`chain`、`grade` 與整體 `ci` 通過。
- 把英文報告放進一篇 HackMD，檢查公式、表格、程式片段與來源連結。報告的面試狀態應在實際完成後更新，不能保留「尚未完成」卻宣稱已完成。
- 面試錄影、result 與 code 需由自己完成並保存。
- 最終送出前依作業要求再更新 rv32emu 並評分，量測版本若改變，也要更新報告。
- 不要把解答向教師的原始程式庫開 pull request。

## 本機重新檢查

在 `/Users/lannn/arch2026-progs` 中：

```sh
./mytests/run.sh make test
./mytests/run.sh make sanitize
./mytests/run.sh make dump
./mytests/run.sh make cycles
./mytests/run.sh python3 mytests/analyze_errors.py
./mytests/run.sh sh mytests/check_hard.sh
```

`run.sh` 選用這台 Mac 已安裝的 GCC 15.2 與必要工具。官方 Makefile、測試、預算和合約標頭保持原樣。其他電腦請先依程式庫 README 安裝工具。
