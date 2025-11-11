#!/bin/bash

# ドキュメント初期化スクリプト
# プロジェクトルートにdocsディレクトリを作成

# 現在のディレクトリ名が .claude であることを確認
CURRENT_DIR_NAME="$(basename "$(pwd)")"
if [ "$CURRENT_DIR_NAME" != ".claude" ]; then
    echo "エラー: このスクリプトは .claude ディレクトリから実行する必要があります。"
    echo "現在のディレクトリ: $(pwd)"
    exit 1
fi

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# docsディレクトリのパス
DOCS_DIR="$PROJECT_ROOT/docs"

# docsディレクトリを作成
if [ -d "$DOCS_DIR" ]; then
    echo "docsディレクトリは既に存在します: $DOCS_DIR"
else
    mkdir -p "$DOCS_DIR"
    echo "docsディレクトリを作成しました: $DOCS_DIR"
fi

# サブディレクトリを作成
SUBDIRS=("specifications" "internal")

for subdir in "${SUBDIRS[@]}"; do
    SUBDIR_PATH="$DOCS_DIR/$subdir"
    if [ -d "$SUBDIR_PATH" ]; then
        echo "  - $subdir ディレクトリは既に存在します"
    else
        mkdir -p "$SUBDIR_PATH"
        echo "  - $subdir ディレクトリを作成しました"
    fi
done

# 基本設計書のテンプレートファイルを作成
SPEC_DIR="$DOCS_DIR/specifications"
SPEC_FILES=(
    "00.はじめに.md"
    "01.システム概要.md"
    "02.システム構成.md"
    "03.機能設計.md"
    "04.データ設計.md"
    "05.画面設計.md"
    "06.インターフェース設計.md"
    "07.セキュリティ設計.md"
    "08.性能設計.md"
    "09.運用設計.md"
    "10.付録.md"
)

echo ""
echo "基本設計書テンプレートを作成:"
for file in "${SPEC_FILES[@]}"; do
    FILE_PATH="$SPEC_DIR/$file"
    if [ -f "$FILE_PATH" ]; then
        echo "  - $file は既に存在します"
    else
        # ファイル名から章タイトルを抽出（番号と拡張子を除去）
        TITLE=$(echo "$file" | sed 's/^[0-9]\{2\}\.//' | sed 's/\.md$//')

        cat > "$FILE_PATH" << EOF
# $TITLE

## 概要

ここに$TITLEの概要を記述します。

## 詳細

ここに詳細な内容を記述します。
EOF
        echo "  - $file を作成しました"
    fi
done

# 内部用ファイルを作成
INTERNAL_DIR="$DOCS_DIR/internal"
INTERNAL_FILES=(
    "01.開発ログ.md"
    "02.技術ノート.md"
    "03.判断理由.md"
)

echo ""
echo "内部用ファイルを作成:"
for file in "${INTERNAL_FILES[@]}"; do
    FILE_PATH="$INTERNAL_DIR/$file"
    if [ -f "$FILE_PATH" ]; then
        echo "  - $file は既に存在します"
    else
        # ファイル名から章タイトルを抽出（番号と拡張子を除去）
        TITLE=$(echo "$file" | sed 's/^[0-9]\{2\}\.//' | sed 's/\.md$//')

        # ファイル名に応じて異なる内容を作成
        case "$file" in
            *"開発ログ"*)
                cat > "$FILE_PATH" << 'EOF'
# 開発ログ

## 最新のログ

### YYYY-MM-DD

- 作業内容や変更点を記録します
- 実装した機能や修正したバグを記録します

## 過去のログ

### YYYY-MM-DD

- 作業内容
EOF
                ;;
            *"技術ノート"*)
                cat > "$FILE_PATH" << 'EOF'
# 技術ノート

## 技術スタック

ここに使用している技術スタックを記述します。

## 技術的な検討事項

### 項目1

技術的な検討内容や調査結果を記録します。

## 参考資料

- 参考にしたドキュメントやURLを記録します
EOF
                ;;
            *"判断理由"*)
                cat > "$FILE_PATH" << 'EOF'
# 判断理由

## 設計判断

### 項目1

**判断内容:**
どのような判断を行ったか

**理由:**
なぜその判断をしたか

**代替案:**
他にどのような選択肢があったか

**影響範囲:**
この判断が与える影響

## アーキテクチャ判断

記録が必要な設計判断や技術選択の理由を記述します。
EOF
                ;;
        esac

        echo "  - $file を作成しました"
    fi
done

# .claude/commands/update-docs.md を作成
mkdir -p "$SCRIPT_DIR/commands"
PROMPT_FILE="$SCRIPT_DIR/commands/update-docs.md"

echo ""
echo "ドキュメント更新プロンプトを作成:"
if [ -f "$PROMPT_FILE" ]; then
    echo "  - update-docs.md は既に存在します"
else
    cat > "$PROMPT_FILE" << 'EOF'
---
description: セッションの作業内容をドキュメントに反映
allowed-tools: Bash(git diff:*), Bash(git status:*), FileEdit, serena
---
# ドキュメント更新指示

今回のセッションで行った変更をドキュメントに反映してください。

## 更新手順

### 1. 変更内容の確認
- `git status` で変更ファイルをリストアップ
- `git diff` で具体的な変更内容を確認

### 2. 内部資料の更新 (対象がinternal ディレクトリ にある場合)
`docs/internal/01.開発ログ.md` に以下を追記:

\`\`\`markdown
## YYYY-MM-DD

### 実装内容
- [変更されたファイルと主な変更内容を箇条書き]

### 技術的な決定事項
- [重要な判断があれば記載]

### 残課題
- [TODO項目があれば記載]
\`\`\`

`docs/internal/02.技術ノート` に重要な技術的記述があれば記載

`docs/internal/03.判断理由` に重要な技術的判断がればその理由とともに記載

### 3. 仕様書ドキュメントの更新 (対象がspecificationsディレクトリにある場合)

#### 00.はじめに.md
- ステークホルダーやプロジェクト名など、非常に大きな更新があれば記述

#### 01.システム概要.md
- システムの概要に関する更新があれば記述

#### 02.システム構成.md 
- システム構成に関する更新があれば記述

#### 03.機能設計.md
- 機能設計に関する更新があれば記述

#### 04.データ設計.md
- データ設計、データベースに関する更新があれば記述

#### 05.画面設計.md
- 画面に関する更新があれば記述

#### 06.インターフェース設計.md
- 外部システムとのインターフェースに関する更新があれば記述

#### 07.セキュリティ設計.md
- セキュリティに関する更新があれば記述

#### 08.性能設計.md
- システムの処理速度やデータ容量に関する更新があれば記述

#### 09.運用設計.md
- システムの運用に関する更新があれば記述

#### 10.付録.md
- システム特有の用語や、コード定義に関する更新があれば記述

### 4. 最終確認
- すべてのコードサンプルが最新版であることを確認
- 日付・バージョン情報を更新

## 出力形式
更新したファイルのリストと、主な変更点のサマリーを簡潔に報告してください。
EOF
    echo "  - update-docs.md を作成しました"
fi

# .claude/commands/update-docs-init.md を作成
PROMPT_INIT_FILE="$SCRIPT_DIR/commands/update-docs-init.md"

echo ""
echo "ドキュメント初期化プロンプトを作成:"
if [ -f "$PROMPT_INIT_FILE" ]; then
    echo "  - update-docs-init.md は既に存在します"
else
    cat > "$PROMPT_INIT_FILE" << 'EOF'
---
description: コードベースの内容をドキュメントに反映
allowed-tools: Bash(git diff:*), Bash(git status:*), FileEdit, serena
---

# ドキュメント更新指示

コードベースの内容をドキュメントに反映してください。
元のファイルの内容は上書きしてください。

## 更新手順

### 1. 変更内容の確認(特に作業無し)

### 2. 内部資料の更新 (特に作業無し)

### 3. 仕様書ドキュメントの更新 (対象が specifications ディレクトリにある場合)

#### 00.はじめに.md

- ステークホルダーやプロジェクト名、プロジェクト概要などを記述

#### 01.システム概要.md

- システムの概要に関して記述

#### 02.システム構成.md

- システム構成に関して記述

#### 03.機能設計.md

- 機能設計に関して記述

#### 04.データ設計.md

- データ設計、データベースに関して記述

#### 05.画面設計.md

- 画面に関して記述

#### 06.インターフェース設計.md

- 外部システムとのインターフェースに関して記述

#### 07.セキュリティ設計.md

- セキュリティに関して記述

#### 08.性能設計.md

- システムの処理速度やデータ容量に関して記述

#### 09.運用設計.md

- システムの運用に関して記述

#### 10.付録.md

- システム特有の用語や、コード定義に関して記述

### 4. 最終確認

- 日付・バージョン情報を更新、初期化

## 出力形式

更新したファイルのリストと、主な変更点のサマリーを簡潔に報告してください。
EOF
    echo "  - update-docs-init.md を作成しました"
fi
