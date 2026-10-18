# GitHubでの公開手順

このリポジトリのルート（.vscode と 00-使用例 があるフォルダ）全体を公開します。
共有設定は .vscode/、公開用サンプルは 00-使用例/ にまとまっています。
元の個人用プロファイルや実際の提出レポートを加える必要はありません。

## VS Codeから公開する

1. リポジトリのルートをVS Codeで開きます。
2. ソース管理で、初回コミットに含めるファイルを確認してコミットします。
3. Publish to GitHubで公開リポジトリを作るか、GitHubで作成した空のリポジトリへpushします。
4. Actionsの「Build sample PDFs」を確認します。
5. 配布用ひな形にする場合は、リポジトリ設定のTemplate repositoryを有効にします。

リポジトリ名の例は latex-environment です。
説明文の例: Portable LaTeX setup for per-experiment reports, VS Code and latexmk.

## コマンドで公開する

リポジトリのルートで実行します。既に初期化済みなら最初の行は省略します。

```sh
git init -b main
git add .
git diff --cached --stat
git commit -m "Add portable LaTeX environment and report examples"
```

GitHubで空のリポジトリを作成し、その画面の実際のURLでoriginを登録してpushします。
認証用トークンをURLや設定ファイルへ記載する必要はありません。

## 公開するもの

共有設定、00-使用例、ビルドヘルパー、説明書、完成見本、GitHub Actions、MITライセンスです。
学校形式の例に使う school-report-example.sty は新規作成した公開用スタイルです。
学校の r08ec-exp.sty や個人情報のある元レポートは含めていません。
自分の実験フォルダも公開する場合は、その本文や画像等も公開対象になります。

## 完成見本の更新

| ビルド結果 | 公開するPDF |
| --- | --- |
| 00-使用例/01-学校形式-upLaTeX/export/実験報告書.pdf | docs/samples/school-uplatex.pdf |
| 00-使用例/02-学校形式-pLaTeX/export/実験報告書.pdf | docs/samples/school-platex.pdf |
| 00-使用例/03-数式とグラフ/export/main.pdf | docs/samples/report.pdf |
| 00-使用例/04-欧文/export/main.pdf | docs/samples/english.pdf |
| 00-使用例/05-biblatexとBiber/export/main.pdf | docs/samples/bibliography.pdf |

READMEの表紙プレビューは docs/images/school.png です。
GitHub ActionsはPDFをArtifactsに保存し、完成見本を自動コミットしません。
更新時は必要な見本を明示的にコピーしてコミットしてください。
