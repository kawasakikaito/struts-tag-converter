# Struts Tag Converter

Struts 1.xのJSPカスタムタグを現代的なJSTL/EL式に変換するツールです。

## 概要

レガシーシステムのモダナイゼーションを支援するツールとして開発しました。
以下のような変換に対応しています：

- `html:*` タグ → 標準的なHTML要素
- `logic:*` タグ → JSTL条件分岐・繰り返し
- `bean:*` タグ → EL式

## 変換例

変換前（Struts 1.x）:
```jsp
<html:text property="username" styleClass="form-control"/>
```

変換後（JSTL/EL）:
```jsp
<input type="text" name="username" value="${form.username}" class="form-control"/>
```

## 使用方法

1. JSPファイルを`A`ディレクトリに配置
2. `java StrutsConverter`を実行
3. 変換結果が`A_after`ディレクトリに出力されます

## 技術スタック

- Java
- 正規表現によるパターンマッチング
- ビルダーパターンの実装

## ライセンス

MITライセンス
