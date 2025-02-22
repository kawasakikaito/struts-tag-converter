# Struts Tag Converter

Struts Tag Converterは、Struts 1.xのJSPカスタムタグを現代的なJSTL/EL式に変換するツールです。

## 機能

- Struts 1.xのカスタムタグをJSTL/EL式に変換
- 以下のタグをサポート：
  - `html:*` タグ（text, button, radio, select など）
  - `logic:*` タグ（equal, notEqual, iterate など）
  - `bean:*` タグ（define, write）
- タグライブラリ宣言の自動削除
- JSTLコアタグライブラリの自動追加

## 必要要件

- Java 11以上
- Maven 3.6以上

## インストール

```bash
git clone https://github.com/yourusername/struts-tag-converter.git
cd struts-tag-converter
mvn clean install
```

## 使用方法

1. 変換したいJSPファイルを`A`ディレクトリに配置
2. 以下のコマンドを実行：

```bash
java -jar target/struts-tag-converter-1.0-SNAPSHOT-jar-with-dependencies.jar
```

3. 変換されたファイルが`A_after`ディレクトリに出力されます

## 変換例

変換前（Struts 1.x）:
```jsp
<html:text property="username" styleClass="form-control"/>
```

変換後（JSTL/EL）:
```jsp
<input type="text" name="username" value="${form.username}" class="form-control"/>
```

より多くの例は`examples`ディレクトリを参照してください。

## 開発者向け情報

### プロジェクト構造

```
src/
├── main/
│   └── java/
│       └── com/
│           └── example/
│               ├── StrutsConverter.java
│               ├── converters/
│               └── model/
└── test/
    └── java/
        └── com/
            └── example/
                └── StrutsConverterTest.java
```

### ビルド方法

```bash
mvn clean package
```

### テストの実行

```bash
mvn test
```

## ライセンス

MITライセンス

## 貢献

1. このリポジトリをフォーク
2. 新しいブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成
