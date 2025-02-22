# Struts Tag Converter

Struts 1.xのJSPカスタムタグを現代的なJSTL/EL式に変換するツールです。

## 開発の背景

実際のStrutsタグ廃止プロジェクトで使用した、自動化ツールです。

### きっかけ
- プロジェクトでは大量のJSPファイルのStruts 1.xタグを手作業で変換する必要がありました
- Excelを使用した半手動の変換作業が行われていましたが、非効率な状況でした
- 手作業による時間的コストとヒューマンエラーが課題でした
- 当初の見積もりでは約2人月の工数が必要とされていました

### 開発の経緯
- プロジェクト参画初期という状況で、PLの信頼もなく工数の正式な確保は難しい状況でした
- しかし、技術的な観点から自動化による解決は十分可能と判断
- 個人の技術研鑽も兼ねて、プライベートプロジェクトとして着手
- まずは実証実験的なアプローチで開発を進めることにしました

### 導入までの道のり
- 業務時間外を活用して開発を進行
- ある程度の完成度に達した段階で、チームの飲み会の場を活用して提案
  - 「趣味で開発した変換ツールですが、もし良ければ導入してみませんか」
- このカジュアルなアプローチにより、チームからの自然な受け入れを実現
- 実際の検証で高い評価を獲得し、本格導入が決定しました

### 成果
- 2人月の工数を数分程度まで削減
- 手作業によるヒューマンエラーを排除し、品質を向上
- チームメンバーの工数を、より本質的な開発業務にシフト
- 個人開発から始まり、実務で価値を生み出せるツールとして成長

## 変換対応

以下のような変換に対応しています：

- Strutsタグのtaglibインポート文の削除
- `html:*` タグ → 標準的なHTML要素
- `logic:*` タグ → JSTL条件分岐・繰り返し
- `bean:*` タグ → EL式
- 必要に応じてJSTLのcタグライブラリを追加

## 変換例

変換前（Struts 1.x）:
```jsp
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:text property="username" styleClass="form-control"/>
```

変換後（JSTL/EL）:
```jsp
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<input type="text" name="username" value="${form.username}" class="form-control"/>
```

## 使用方法

1. JSPファイルを`A`ディレクトリに配置
2. `java StrutsConverter`を実行
3. 変換結果が`A_after`ディレクトリに出力されます

## 技術的特徴

- Java言語による実装
- 正規表現を活用した効率的なパターンマッチング
- ビルダーパターンによる拡張性の確保
- 実務での使用実績あり

## ライセンス

MITライセンス
