package com.example;

import java.nio.file.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

public class StrutsConverter {
    private static final String INPUT_DIR = "A";
    private static final String OUTPUT_DIR = "A_after";
    private static final String JSTL_CORE_TAGLIB =
        "<%@ taglib uri=\"http://java.sun.com/jsp/jstl/core\" prefix=\"c\" %>";
   
    // プラットフォーム固有の改行コードを取得
    private static final String LINE_SEPARATOR = System.lineSeparator();
   
    private final List<TagConverter> converters = new ArrayList<>();
    private final List<TaglibRemover> taglibRemovers = new ArrayList<>();
   
    public StrutsConverter() {
        // 既存のコンバーター初期化コード
        converters.add(new BeanDefineConverter());
        converters.add(new BeanWriteConverter());
        converters.add(new HtmlHiddenConverter());
        converters.add(new HtmlTextConverter());
        converters.add(new HtmlButtonConverter());
        converters.add(new HtmlRadioConverter());
        converters.add(new HtmlSelectConverter());
        converters.add(new LogicEqualConverter());
        converters.add(new LogicGreaterEqualConverter());
        converters.add(new LogicNotEqualConverter());
        converters.add(new LogicIterateConverter());
        converters.add(new NestedTagConverter());
       
        taglibRemovers.add(new StrutsTaglibRemover("html"));
        taglibRemovers.add(new StrutsTaglibRemover("logic"));
        taglibRemovers.add(new StrutsTaglibRemover("bean"));
    }
   
    public static void main(String[] args) {
        StrutsConverter converter = new StrutsConverter();
        try {
            converter.convertDirectory();
        } catch (IOException e) {
            System.err.println("ディレクトリ処理中にエラーが発生しました: " + e.getMessage());
        }
    }
   
    public void convertDirectory() throws IOException {
        Path inputRootDir = Paths.get(INPUT_DIR);
        Path outputRootDir = Paths.get(OUTPUT_DIR);
       
        if (!Files.exists(inputRootDir)) {
            System.err.println("入力ディレクトリ '" + INPUT_DIR + "' が見つかりません。");
            return;
        }

        // 出力ディレクトリが存在しない場合は作成
        if (!Files.exists(outputRootDir)) {
            Files.createDirectories(outputRootDir);
        }

        // ディレクトリを再帰的に処理
        try (Stream<Path> paths = Files.walk(inputRootDir)) {
            paths.filter(Files::isRegularFile)
                 .filter(path -> path.toString().toLowerCase().endsWith(".jsp"))
                 .forEach(inputPath -> {
                     try {
                         // 入力パスから相対パスを取得
                         Path relativePath = inputRootDir.relativize(inputPath);
                         // 出力パスを生成
                         Path outputPath = outputRootDir.resolve(relativePath);
                         // 出力ディレクトリが存在しない場合は作成
                         Files.createDirectories(outputPath.getParent());
                         
                         convertFile(inputPath, outputPath);
                     } catch (IOException e) {
                         System.err.println("ファイル処理中にエラーが発生しました: " + inputPath + " - " + e.getMessage());
                     }
                 });
        }
    }
   
    private void convertFile(Path inputPath, Path outputPath) throws IOException {
        System.out.println("処理中のファイル: " + inputPath + " -> " + outputPath);
       
        String content = Files.readString(inputPath);
        List<ConversionResult> results = new ArrayList<>();
       
        // タグの変換
        for (TagConverter converter : converters) {
            content = converter.convert(content, results);
        }
   
        boolean needsJstlCore = content.contains("<c:if") || content.contains("<c:forEach");
       
        // タグライブラリの削除
        for (TaglibRemover remover : taglibRemovers) {
            content = remover.remove(content);
        }
       
        if (needsJstlCore) {
            // 最後のtaglib宣言を探す
            Pattern taglibPattern = Pattern.compile("<%@\\s*taglib.*?%>\\R?");
            Matcher matcher = taglibPattern.matcher(content);
            int lastTaglibEnd = -1;
            while (matcher.find()) {
                lastTaglibEnd = matcher.end();
            }
           
            if (lastTaglibEnd != -1) {
                // 最後のtaglib宣言の後にJSTL taglibを挿入（改行を適切に処理）
                String beforeContent = content.substring(0, lastTaglibEnd);
                String afterContent = content.substring(lastTaglibEnd);
               
                // 改行が既にある場合は追加しない
                if (!beforeContent.endsWith("\n")) {
                    beforeContent += LINE_SEPARATOR;
                }
               
                content = beforeContent + JSTL_CORE_TAGLIB + LINE_SEPARATOR + afterContent;
            } else {
                // taglibが見つからない場合はファイルの先頭に追加
                content = JSTL_CORE_TAGLIB + LINE_SEPARATOR + content;
            }
        }
       
        Files.writeString(outputPath, content, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
       
        // 以下は変更なし
        System.out.println("変換完了: " + outputPath);
        results.forEach(System.out::println);
       
        if (needsJstlCore) {
            System.out.println("JSTL Core タグライブラリの宣言が追加されました。");
        }
        System.out.println("-------------------");
    }
}

interface TagConverter {
    String convert(String content, List<ConversionResult> results);
}

interface TaglibRemover {
    String remove(String content);
}

class NameConverter {
    public static String convertDotToUnderscore(String name) {
        return name != null ? name.replace('.', '_') : null;
    }
}

abstract class LogicComparisonConverter implements TagConverter {
    private final String tagName;

    protected LogicComparisonConverter(String tagName) {
        this.tagName = tagName;
    }

    @Override
    public String convert(String content, List<ConversionResult> results) {
        // 開始タグを処理
        Pattern startPattern = Pattern.compile(
            "<logic:" + tagName + "\\s+([^>]*?)>");
       
        // 閉じタグを処理
        Pattern endPattern = Pattern.compile(
            "</logic:" + tagName + ">");
       
        // 開始タグの変換
        Matcher startMatcher = startPattern.matcher(content);
        StringBuffer result = new StringBuffer();
       
        while (startMatcher.find()) {
            String attributes = startMatcher.group(1).trim();
            LogicComparison comparison = parseComparison(attributes);
           
            String convertedStart = String.format("<c:if test=\"%s\">",
                comparison.buildCondition(getOperator()));
               
            results.add(new ConversionResult("logic:" + tagName + " (開始タグ)",
                startMatcher.group(0), convertedStart));
               
            startMatcher.appendReplacement(result,
                Matcher.quoteReplacement(convertedStart));
        }
        startMatcher.appendTail(result);
        content = result.toString();
       
        // 閉じタグの変換
        Matcher endMatcher = endPattern.matcher(content);
        result = new StringBuffer();
       
        while (endMatcher.find()) {
            results.add(new ConversionResult("logic:" + tagName + " (閉じタグ)",
                endMatcher.group(0), "</c:if>"));
               
            endMatcher.appendReplacement(result, "</c:if>");
        }
        endMatcher.appendTail(result);
       
        return result.toString();
    }
   
    protected abstract String getOperator();
   
    private LogicComparison parseComparison(String attributes) {
        return new LogicComparison.Builder()
                .name(extractAttribute(attributes, "name"))
                .property(extractAttribute(attributes, "property"))
                .value(extractAttribute(attributes, "value"))
                .scope(extractAttribute(attributes, "scope"))
                .build();
    }
   
    private String extractAttribute(String attributes, String attributeName) {
        Pattern pattern = Pattern.compile(attributeName + "\\s*=\\s*\"(.*?)\"");
        Matcher matcher = pattern.matcher(attributes);
        return matcher.find() ? matcher.group(1) : null;
    }
}

class LogicEqualConverter extends LogicComparisonConverter {
    public LogicEqualConverter() {
        super("equal");
    }
   
    @Override
    protected String getOperator() {
        return "==";
    }
}

class LogicNotEqualConverter extends LogicComparisonConverter {
    public LogicNotEqualConverter() {
        super("notEqual");
    }
   
    @Override
    protected String getOperator() {
        return "!=";
    }
}

class LogicComparison {
    private final String name;
    private final String property;
    private final String value;
    private final String scope;

    private LogicComparison(Builder builder) {
        this.name = builder.name;
        this.property = builder.property;
        this.value = builder.value;
        this.scope = builder.scope;
    }

    public String buildCondition(String operator) {
        StringBuilder condition = new StringBuilder("${");
        
        if (name != null) {
            if (scope != null) {
                switch (scope.toLowerCase()) {
                    case "application":
                        condition.append("applicationScope.");
                        break;
                    case "session":
                        condition.append("sessionScope.");
                        break;
                    case "request":
                        condition.append("requestScope.");
                        break;
                    case "page":
                        condition.append("pageScope.");
                        break;
                }
            }
            
            condition.append(NameConverter.convertDotToUnderscore(name));
            
            if (property != null) {
                condition.append(".get")
                        .append(capitalize(property))
                        .append("()");
            }
        }
        
        condition.append(" ").append(operator).append(" ");
        
        // greaterEqual, lessThan などの数値比較の場合はクォートを外す
        if (operator.equals(">=") || operator.equals("<=") || 
            operator.equals(">") || operator.equals("<")) {
            condition.append(value);
        } else {
            // equal, notEqual の場合は従来通りクォートあり
            condition.append("'").append(value).append("'");
        }
        
        condition.append("}");
        
        return condition.toString();
    }

    private static String capitalize(String str) {
        return str == null || str.isEmpty() ? str
            : str.substring(0, 1).toUpperCase() + str.substring(1);
    }

    public static class Builder {
        private String name;
        private String property;
        private String value;
        private String scope;

        public Builder name(String name) {
            this.name = name;
            return this;
        }

        public Builder property(String property) {
            this.property = property;
            return this;
        }

        public Builder value(String value) {
            this.value = value;
            return this;
        }

        public Builder scope(String scope) {
            this.scope = scope;
            return this;
        }

        public LogicComparison build() {
            return new LogicComparison(this);
        }
    }
}

class StrutsTaglibRemover implements TaglibRemover {
    private final Pattern pattern;
   
    public StrutsTaglibRemover(String prefix) {
        // 改行を保持するように修正
        this.pattern = Pattern.compile(
            "<%@\\s*taglib\\s*uri=\"/WEB-INF/struts-" + prefix +
            "\\.tld\"\\s*prefix=\"" + prefix + "\"\\s*%>\\R?"
        );
    }
   
    @Override
    public String remove(String content) {
        return pattern.matcher(content).replaceAll("");
    }
}

class ConversionResult {
    private final String tagType;
    private final String originalTag;
    private final String convertedExpression;
   
    public ConversionResult(String tagType, String originalTag, String convertedExpression) {
        this.tagType = tagType;
        this.originalTag = originalTag;
        this.convertedExpression = convertedExpression;
    }
   
    @Override
    public String toString() {
        return String.format("変換: %s\n  元のタグ: %s\n  変換後: %s",
                tagType, originalTag, convertedExpression);
    }
}
class NestedTagConverter implements TagConverter {
    private static final Pattern NESTED_PATTERN = Pattern.compile(
        "(<logic:iterate\\s*[^>]*>)([\\s\\S]*?)(</logic:iterate>)|" +
        "(<logic:equal\\s*[^>]*>)([\\s\\S]*?)(</logic:equal>)|" +
        "(<logic:notEqual\\s*[^>]*>)([\\s\\S]*?)(</logic:notEqual>)",
        Pattern.DOTALL
    );

    @Override
    public String convert(String content, List<ConversionResult> results) {
        Matcher matcher = NESTED_PATTERN.matcher(content);
        StringBuffer result = new StringBuffer();
       
        while (matcher.find()) {
            String startTag = matcher.group(1) != null ? matcher.group(1) :
                            (matcher.group(4) != null ? matcher.group(4) : matcher.group(7));
            String body = matcher.group(2) != null ? matcher.group(2) :
                         (matcher.group(5) != null ? matcher.group(5) : matcher.group(8));
           
            String convertedTag;
            if (startTag.startsWith("<logic:iterate")) {
                convertedTag = convertIterateTag(startTag, body);
            } else if (startTag.startsWith("<logic:equal")) {
                convertedTag = convertEqualTag(startTag, body, false);
            } else {
                convertedTag = convertEqualTag(startTag, body, true);
            }
           
            matcher.appendReplacement(result, Matcher.quoteReplacement(convertedTag));
        }
        matcher.appendTail(result);
        return result.toString();
    }
   
    private String convertIterateTag(String startTag, String body) {
        Pattern attrPattern = Pattern.compile("(\\w+)=\"([^\"]*)\"");
        Matcher attrMatcher = attrPattern.matcher(startTag);
       
        String id = null;
        String name = null;
        String property = null;
        String scope = null;
        String offset = null;
        String length = null;
        String indexId = null;
        String collection = null;
       
        while (attrMatcher.find()) {
            String attrName = attrMatcher.group(1);
            String attrValue = attrMatcher.group(2);
           
            switch (attrName) {
                case "id": id = attrValue; break;
                case "name": name = attrValue; break;
                case "property": property = attrValue; break;
                case "scope": scope = attrValue; break;
                case "offset": offset = attrValue; break;
                case "length": length = attrValue; break;
                case "indexId": indexId = attrValue; break;
                case "collection": collection = attrValue; break;
            }
        }
       
        StringBuilder newTag = new StringBuilder("<c:forEach");
       
        if (id != null) {
            newTag.append(" var=\"").append(id).append("\"");
        }
       
        newTag.append(" items=\"${");
        if (collection != null) {
            newTag.append(NameConverter.convertDotToUnderscore(collection));
        } else {
            if (scope != null) {
                newTag.append(getScopePrefix(scope));
            }
            if (name != null) {
                newTag.append(NameConverter.convertDotToUnderscore(name));
                if (property != null) {
                    newTag.append(".get").append(capitalize(property)).append("()");
                }
            }
        }
        newTag.append("}\"");
       
        // varStatus attribute (formerly indexId)
        if (indexId != null) {
            newTag.append(" varStatus=\"").append(indexId).append("\"");
        }
       
        // offset and length
        if (offset != null) {
            newTag.append(" begin=\"").append(offset).append("\"");
        }
       
        if (length != null) {
            int end = Integer.parseInt(offset != null ? offset : "0") +
                     Integer.parseInt(length) - 1;
            newTag.append(" end=\"").append(end).append("\"");
        }
       
        newTag.append(">");
        newTag.append(body);
        newTag.append("</c:forEach>");
       
        return newTag.toString();
    }
   
    private String convertEqualTag(String startTag, String body, boolean isNotEqual) {
        Pattern attrPattern = Pattern.compile("(\\w+)=\"([^\"]*)\"");
        Matcher attrMatcher = attrPattern.matcher(startTag);
       
        String name = null;
        String property = null;
        String value = null;
       
        while (attrMatcher.find()) {
            String attrName = attrMatcher.group(1);
            String attrValue = attrMatcher.group(2);
           
            switch (attrName) {
                case "name": name = attrValue; break;
                case "property": property = attrValue; break;
                case "value": value = attrValue; break;
            }
        }
       
        StringBuilder newTag = new StringBuilder("<c:if test=\"${");
       
        if (name != null) {
            newTag.append(NameConverter.convertDotToUnderscore(name));
            if (property != null) {
                newTag.append(".get").append(capitalize(property)).append("()");
            }
        }
       
        newTag.append(" ").append(isNotEqual ? "!=" : "==").append(" '")
              .append(value).append("'}\">");
        newTag.append(body);
        newTag.append("</c:if>");
       
        return newTag.toString();
    }
   
    private String getScopePrefix(String scope) {
        switch (scope.toLowerCase()) {
            case "application": return "applicationScope.";
            case "session": return "sessionScope.";
            case "request": return "requestScope.";
            case "page": return "pageScope.";
            default: return "";
        }
    }
   
    private String capitalize(String str) {
        return str == null || str.isEmpty() ? str
            : str.substring(0, 1).toUpperCase() + str.substring(1);
    }
}

class LogicIterateConverter implements TagConverter {
    private static final Pattern START_PATTERN = Pattern.compile(
        "<logic:iterate\\s*([^>]*?)>",
        Pattern.DOTALL  // Enable multiline matching
    );
    private static final Pattern END_PATTERN = Pattern.compile(
        "</logic:iterate>");
    private static final Pattern JSP_EXPRESSION_PATTERN = Pattern.compile(
        "<%=\\s*(\\w+)\\s*\\+\\s*(\\d+)\\s*%>");
   
    @Override
    public String convert(String content, List<ConversionResult> results) {
        // First convert JSP expressions
        content = convertJspExpressions(content, results);
       
        // Then handle the iterate tags
        Matcher startMatcher = START_PATTERN.matcher(content);
        StringBuffer result = new StringBuffer();
       
        while (startMatcher.find()) {
            String attributes = startMatcher.group(1).trim();
            attributes = normalizeAttributes(attributes);
            IterateAttributes attrs = parseAttributes(attributes);
            String convertedStart = createForEachTag(attrs);
           
            results.add(new ConversionResult(
                "logic:iterate (開始タグ)",
                startMatcher.group(0),
                convertedStart
            ));
           
            startMatcher.appendReplacement(result,
                Matcher.quoteReplacement(convertedStart));
        }
        startMatcher.appendTail(result);
        content = result.toString();
       
        // Convert end tags
        Matcher endMatcher = END_PATTERN.matcher(content);
        result = new StringBuffer();
       
        while (endMatcher.find()) {
            results.add(new ConversionResult(
                "logic:iterate (閉じタグ)",
                endMatcher.group(0),
                "</c:forEach>"
            ));
           
            endMatcher.appendReplacement(result, "</c:forEach>");
        }
        endMatcher.appendTail(result);
       
        return result.toString();
    }
   
    private String convertJspExpressions(String content, List<ConversionResult> results) {
        Matcher exprMatcher = JSP_EXPRESSION_PATTERN.matcher(content);
        StringBuffer result = new StringBuffer();
       
        while (exprMatcher.find()) {
            String varName = exprMatcher.group(1);
            String number = exprMatcher.group(2);
            String convertedExpr = String.format("${%s.index + %s}", varName, number);
           
            results.add(new ConversionResult(
                "JSP Expression",
                exprMatcher.group(0),
                convertedExpr
            ));
           
            exprMatcher.appendReplacement(result,
                Matcher.quoteReplacement(convertedExpr));
        }
        exprMatcher.appendTail(result);
        return result.toString();
    }
   
    private String normalizeAttributes(String attributes) {
        // Normalize whitespace and line breaks
        return attributes.replaceAll("\\s+", " ").trim();
    }
   
    private IterateAttributes parseAttributes(String attributes) {
        return new IterateAttributes.Builder()
                .name(extractAttribute(attributes, "name"))
                .property(extractAttribute(attributes, "property"))
                .id(extractAttribute(attributes, "id"))
                .indexId(extractAttribute(attributes, "indexId"))
                .offset(extractAttribute(attributes, "offset"))
                .length(extractAttribute(attributes, "length"))
                .collection(extractAttribute(attributes, "collection"))
                .scope(extractAttribute(attributes, "scope"))
                .build();
    }
   
    private String extractAttribute(String attributes, String attributeName) {
        // ダブルクォートとシングルクォートの両方に対応
        Pattern pattern = Pattern.compile(attributeName + "\\s*=\\s*([\"'])(.*?)\\1");
        Matcher matcher = pattern.matcher(attributes);
        return matcher.find() ? matcher.group(2) : null;
    }
   
    private String createForEachTag(IterateAttributes attrs) {
        StringBuilder tag = new StringBuilder("<c:forEach");
       
        if (attrs.getId() != null) {
            tag.append(" var=\"").append(attrs.getId()).append("\"");
        }
       
        tag.append(" items=\"${");
        if (attrs.getCollection() != null) {
            tag.append(NameConverter.convertDotToUnderscore(attrs.getCollection()));
        } else {
            if (attrs.getScope() != null) {
                tag.append(getScopePrefix(attrs.getScope()));
            }
            if (attrs.getName() != null) {
                tag.append(NameConverter.convertDotToUnderscore(attrs.getName()));
                if (attrs.getProperty() != null) {
                    tag.append(".get").append(capitalize(attrs.getProperty())).append("()");
                }
            }
        }
        tag.append("}\"");
       
        if (attrs.getIndexId() != null) {
            tag.append(" varStatus=\"").append(attrs.getIndexId()).append("\"");
        }
       
        if (attrs.getOffset() != null) {
            tag.append(" begin=\"").append(attrs.getOffset()).append("\"");
        }
       
        if (attrs.getLength() != null) {
            int end;
            if (attrs.getOffset() != null) {
                end = Integer.parseInt(attrs.getOffset()) +
                      Integer.parseInt(attrs.getLength()) - 1;
            } else {
                end = Integer.parseInt(attrs.getLength()) - 1;
            }
            tag.append(" end=\"").append(end).append("\"");
        }
       
        tag.append(">");
        return tag.toString();
    }
   
    private String getScopePrefix(String scope) {
        switch (scope.toLowerCase()) {
            case "application": return "applicationScope.";
            case "session": return "sessionScope.";
            case "request": return "requestScope.";
            case "page": return "pageScope.";
            default: return "";
        }
    }
   
    private String capitalize(String str) {
        return str == null || str.isEmpty() ? str
            : str.substring(0, 1).toUpperCase() + str.substring(1);
    }
}

class IterateAttributes {
    private final String name;
    private final String property;
    private final String id;
    private final String indexId;
    private final String offset;
    private final String length;
    private final String collection;
    private final String scope;
   
    private IterateAttributes(Builder builder) {
        this.name = builder.name;
        this.property = builder.property;
        this.id = builder.id;
        this.indexId = builder.indexId;
        this.offset = builder.offset;
        this.length = builder.length;
        this.collection = builder.collection;
        this.scope = builder.scope;
    }
   
    public String getName() { return name; }
    public String getProperty() { return property; }
    public String getId() { return id; }
    public String getIndexId() { return indexId; }
    public String getOffset() { return offset; }
    public String getLength() { return length; }
    public String getCollection() { return collection; }
    public String getScope() { return scope; }
   
    public static class Builder {
        private String name;
        private String property;
        private String id;
        private String indexId;
        private String offset;
        private String length;
        private String collection;
        private String scope;
       
        public Builder name(String name) {
            this.name = name;
            return this;
        }
       
        public Builder property(String property) {
            this.property = property;
            return this;
        }
       
        public Builder id(String id) {
            this.id = id;
            return this;
        }
       
        public Builder indexId(String indexId) {
            this.indexId = indexId;
            return this;
        }
       
        public Builder offset(String offset) {
            this.offset = offset;
            return this;
        }
       
        public Builder length(String length) {
            this.length = length;
            return this;
        }
       
        public Builder collection(String collection) {
            this.collection = collection;
            return this;
        }
       
        public Builder scope(String scope) {
            this.scope = scope;
            return this;
        }
       
        public IterateAttributes build() {
            return new IterateAttributes(this);
        }
    }
}

class BeanWriteConverter implements TagConverter {
    private static final Pattern BEAN_WRITE_PATTERN = Pattern.compile(
        // 単独のbean:writeタグ
        "(?s)<bean:write\\s+([^>]*?)/?>"
    );
   
    @Override
    public String convert(String content, List<ConversionResult> results) {
        Matcher matcher = BEAN_WRITE_PATTERN.matcher(content);
        StringBuffer result = new StringBuffer();
       
        while (matcher.find()) {
            String attributes = matcher.group(1);
           
            // bean:writeの属性を解析して変換
            BeanWrite beanWrite = parseBeanWrite(attributes);
            String convertedEl = beanWrite.toEl();
           

            results.add(new ConversionResult("bean:write", matcher.group(0), convertedEl));
            matcher.appendReplacement(result, Matcher.quoteReplacement(convertedEl));
        }
       
        matcher.appendTail(result);
        return result.toString();
    }
   
    private BeanWrite parseBeanWrite(String attributes) {
        return new BeanWrite.Builder()
                .name(extractAttribute(attributes, "name"))
                .property(extractAttribute(attributes, "property"))
                .scope(extractAttribute(attributes, "scope"))
                .filter(extractAttribute(attributes, "filter"))
                .ignore(extractAttribute(attributes, "ignore"))
                .formatKey(extractAttribute(attributes, "formatKey"))
                .format(extractAttribute(attributes, "format"))
                .locale(extractAttribute(attributes, "locale"))
                .bundle(extractAttribute(attributes, "bundle"))
                .build();
    }
   
    private String extractAttribute(String attributes, String attributeName) {
        Pattern pattern = Pattern.compile(attributeName + "\\s*=\\s*([\"'])(.*?)\\1");
        Matcher matcher = pattern.matcher(attributes);
        return matcher.find() ? matcher.group(2) : null;
    }
}


class BeanWrite {
    private final String name;
    private final String property;
    private final String scope;
    private final Boolean filter;
    private final Boolean ignore;
    private final String formatKey;
    private final String format;
    private final String locale;

    private BeanWrite(Builder builder) {
        this.name = builder.name;
        this.property = builder.property;
        this.scope = builder.scope;
        this.filter = builder.filter;
        this.ignore = builder.ignore;
        this.formatKey = builder.formatKey;
        this.format = builder.format;
        this.locale = builder.locale;
    }

    public String toEl() {
        StringBuilder expression = new StringBuilder();
        String value = buildValueExpression();
       
        // フォーマット処理の適用
        if (format != null || formatKey != null) {
            value = applyFormatting(value);
            return value;
        }
       
        // filter属性が明示的に指定されている場合はc:outを使用
        if (filter != null && filter == true) {
            expression.append("<c:out value=\"").append(value).append("\"");
           
            // filter属性の値に基づいてescapeXmlを設定
            expression.append(" escapeXml=\"").append(filter).append("\"");
           
            // ignore属性の処理
            if (ignore != null && ignore) {
                expression.append(" default=\"\"");
            }
           
            expression.append(" />");
            return expression.toString();
        }
       
        // filter属性が未指定の場合は単純なEL式を出力
        return value;
    }
   
    private String buildValueExpression() {
        StringBuilder value = new StringBuilder("${");
       
        if (name != null) {
            if (scope != null) {
                switch (scope.toLowerCase()) {
                    case "application":
                        value.append("applicationScope.");
                        break;
                    case "session":
                        value.append("sessionScope.");
                        break;
                    case "request":
                        value.append("requestScope.");
                        break;
                    case "page":
                        value.append("pageScope.");
                        break;
                }
            }
           
            value.append(NameConverter.convertDotToUnderscore(name));
           
            if (property != null) {
                value.append(".get")
                     .append(capitalize(property))
                     .append("()");
            }
        }
       
        value.append("}");
        return value.toString();
    }
   
    private String applyFormatting(String value) {
        StringBuilder formatted = new StringBuilder();
       
        // fmt:formatDateやfmt:formatNumberを使用したフォーマット処理
        if (format != null || formatKey != null) {
            // 日付フォーマット
            if (isDateFormat()) {
                formatted.append("<fmt:formatDate value=\"")
                        .append(value)
                        .append("\" pattern=\"")
                        .append(format != null ? format : formatKey)
                        .append("\"");
               
                if (locale != null) {
                    formatted.append(" locale=\"").append(locale).append("\"");
                }
               
                formatted.append(" />");
            }
            // 数値フォーマット
            else if (isNumberFormat()) {
                formatted.append("<fmt:formatNumber value=\"")
                        .append(value)
                        .append("\" pattern=\"")
                        .append(format != null ? format : formatKey)
                        .append("\"");
               
                if (locale != null) {
                    formatted.append(" locale=\"").append(locale).append("\"");
                }
               
                formatted.append(" />");
            }
            // その他のフォーマット
            else {
                formatted.append(value);
            }
        } else {
            formatted.append(value);
        }
       
        return formatted.toString();
    }
   
    private boolean isDateFormat() {
        if (format != null) {
            return format.contains("y") || format.contains("M") ||
                   format.contains("d") || format.contains("H") ||
                   format.contains("m") || format.contains("s");
        }
        return false;
    }
   
    private boolean isNumberFormat() {
        if (format != null) {
            return format.contains("#") || format.contains("0") ||
                   format.contains(".") || format.contains(",");
        }
        return false;
    }

    private static String capitalize(String str) {
        return str == null || str.isEmpty() ? str
            : str.substring(0, 1).toUpperCase() + str.substring(1);
    }

    public static class Builder {
        private String name;
        private String property;
        private String scope;
        private Boolean filter;
        private Boolean ignore;
        private String formatKey;
        private String format;
        private String locale;
        private String bundle;

        public Builder name(String name) {
            this.name = name;
            return this;
        }

        public Builder property(String property) {
            this.property = property;
            return this;
        }

        public Builder scope(String scope) {
            this.scope = scope;
            return this;
        }

        public Builder filter(String filter) {
            if (filter != null) {
                this.filter = Boolean.parseBoolean(filter);
            }
            return this;
        }

        public Builder ignore(String ignore) {
            if (ignore != null) {
                this.ignore = Boolean.parseBoolean(ignore);
            }
            return this;
        }

        public Builder formatKey(String formatKey) {
            this.formatKey = formatKey;
            return this;
        }

        public Builder format(String format) {
            this.format = format;
            return this;
        }

        public Builder locale(String locale) {
            this.locale = locale;
            return this;
        }

        public Builder bundle(String bundle) {
            this.bundle = bundle;
            return this;
        }

        public BeanWrite build() {
            return new BeanWrite(this);
        }
    }
}


class HtmlTextConverter implements TagConverter {
    private static final Pattern HTML_TEXT_PATTERN = Pattern.compile(
        "<html:text([^>]*?)(/?>)",
        Pattern.DOTALL
    );

    @Override
    public String convert(String content, List<ConversionResult> results) {
        Matcher matcher = HTML_TEXT_PATTERN.matcher(content);
        StringBuffer result = new StringBuffer();
        
        while (matcher.find()) {
            String attributes = matcher.group(1);
            String endTag = matcher.group(2);
            
            // 必要な属性を抽出
            String name = extractAttribute(attributes, "name");
            String property = extractAttribute(attributes, "property");
            
            // 変換された属性文字列を生成
            String convertedAttributes = convertAttributes(attributes, name, property);
            
            // タグ全体を組み立て
            String convertedTag = "<input type=\"text\"" + convertedAttributes + ">";
            
            results.add(new ConversionResult("html:text", matcher.group(0), convertedTag));
            matcher.appendReplacement(result, Matcher.quoteReplacement(convertedTag));
        }
        
        matcher.appendTail(result);
        return result.toString();
    }
    
    private String convertAttributes(String originalAttributes, String name, String property) {
        StringBuilder converted = new StringBuilder(originalAttributes);
        
        // 属性の変換と削除を行う
        // property属性を削除
        converted = new StringBuilder(converted.toString().replaceAll("\\s*property=\"[^\"]+\"", ""));
        // styleId → id の変換
        converted = new StringBuilder(converted.toString().replaceAll("styleId=\"([^\"]+)\"", "id=\"$1\""));
        // styleClass → class の変換
        converted = new StringBuilder(converted.toString().replaceAll("styleClass=\"([^\"]+)\"", "class=\"$1\""));
        
        if (property != null) {
            // nameとpropertyが両方存在する場合の処理
            if (name != null) {
                // 既存のname属性を変換
                String nameWithUnderscores = name.replace('.', '_');
                String replacement = "name=\"" + property + "\" value=\"${" + nameWithUnderscores + 
                                   ".get" + capitalize(property) + "()}\"";
                // Matcher.quoteReplacementを使用して$や{をエスケープ
                converted = new StringBuilder(converted.toString().replaceAll(
                    "name=\"[^\"]+\"",
                    Matcher.quoteReplacement(replacement)
                ));
            } else {
                // name属性が存在しない場合は、propertyの値をname属性として追加
                converted.append(" name=\"").append(property).append("\"");
            }
        }
        
        return converted.toString();
    }
    
    private String extractAttribute(String attributes, String attributeName) {
        Pattern pattern = Pattern.compile(attributeName + "\\s*=\\s*\"(.*?)\"");
        Matcher matcher = pattern.matcher(attributes);
        return matcher.find() ? matcher.group(1) : null;
    }
    
    private String capitalize(String str) {
        return str == null || str.isEmpty() ? str
            : str.substring(0, 1).toUpperCase() + str.substring(1);
    }
}

class HtmlButtonConverter implements TagConverter {
    private static final Pattern HTML_BUTTON_PATTERN = Pattern.compile(
        "<html:button([^>]*?)(/?>|>(.*?)</html:button>)",
        Pattern.DOTALL
    );
    
    @Override
    public String convert(String content, List<ConversionResult> results) {
        Matcher matcher = HTML_BUTTON_PATTERN.matcher(content);
        StringBuffer result = new StringBuffer();
        
        while (matcher.find()) {
            String originalAttributes = matcher.group(1);
            String endTag = matcher.group(2);
            
            // 属性文字列を変換
            String convertedAttributes = convertAttributes(originalAttributes);
            
            // タグ全体を組み立て（html:button → input type="button"への変換）
            String convertedTag = "<input type=\"button\"" + convertedAttributes + ">";
            
            results.add(new ConversionResult("html:button", matcher.group(0), convertedTag));
            matcher.appendReplacement(result, Matcher.quoteReplacement(convertedTag));
        }
        
        matcher.appendTail(result);
        return result.toString();
    }
    
    private String convertAttributes(String originalAttributes) {
        StringBuilder converted = new StringBuilder(originalAttributes);
        
        // styleClass → class の変換
        converted = new StringBuilder(converted.toString().replaceAll(
            "styleClass=\"([^\"]+)\"",
            "class=\"$1\""
        ));
        
        // property → name の変換
        converted = new StringBuilder(converted.toString().replaceAll(
            "property=\"([^\"]+)\"",
            "name=\"$1\""
        ));
        
        return converted.toString();
    }
}

class BeanDefineConverter implements TagConverter {
    private static final Pattern BEAN_DEFINE_PATTERN = Pattern.compile(
        "(?s)<bean:define([^>]*?)(/?>)",
        Pattern.DOTALL
    );
   
    @Override
    public String convert(String content, List<ConversionResult> results) {
        Matcher matcher = BEAN_DEFINE_PATTERN.matcher(content);
        StringBuffer result = new StringBuffer();
       
        while (matcher.find()) {
            String attributes = matcher.group(1);
            String endTag = matcher.group(2);
            
            // 属性の変換
            String convertedAttributes = convertAttributes(attributes);
            
            // タグ全体を組み立て
            String convertedTag = "<c:set" + convertedAttributes + endTag;
            
            results.add(new ConversionResult("bean:define", matcher.group(0), convertedTag));
            matcher.appendReplacement(result, Matcher.quoteReplacement(convertedTag));
        }
       
        matcher.appendTail(result);
        return result.toString();
    }
    
    private String convertAttributes(String originalAttributes) {
        if (originalAttributes == null || originalAttributes.trim().isEmpty()) {
            return "";
        }
        
        // 属性と空白を保持しながら処理
        Pattern attrPattern = Pattern.compile("([ \\t\\n\\r]*)(\\w+)(\\s*=\\s*\"[^\"]*\")");
        Matcher attrMatcher = attrPattern.matcher(originalAttributes);
        StringBuilder convertedAttrs = new StringBuilder();
        
        while (attrMatcher.find()) {
            String whitespace = attrMatcher.group(1);  // 属性前の空白
            String attrName = attrMatcher.group(2);    // 属性名
            String attrValue = attrMatcher.group(3);   // ="値"部分
            
            // 属性名の変換とEL式の構築
            switch (attrName) {
                case "id":
                    convertedAttrs.append(whitespace).append("var").append(attrValue);
                    break;
                case "name":
                    // name属性は一時的に保持し、property属性と組み合わせて後でvalue属性として出力
                    String name = extractQuotedValue(attrValue);
                    String property = extractAttribute(originalAttributes, "property");
                    String scope = extractAttribute(originalAttributes, "scope");
                    
                    convertedAttrs.append(whitespace).append("value=\"${");
                    if (scope != null) {
                        switch (scope.toLowerCase()) {
                            case "application": convertedAttrs.append("applicationScope."); break;
                            case "session": convertedAttrs.append("sessionScope."); break;
                            case "request": convertedAttrs.append("requestScope."); break;
                            case "page": convertedAttrs.append("pageScope."); break;
                        }
                    }
                    convertedAttrs.append(NameConverter.convertDotToUnderscore(name));
                    if (property != null) {
                        convertedAttrs.append(".get")
                                    .append(capitalize(property))
                                    .append("()");
                    }
                    convertedAttrs.append("}\"");
                    break;
                case "toScope":
                    convertedAttrs.append(whitespace).append("scope").append(attrValue);
                    break;
                case "value":
                    convertedAttrs.append(whitespace).append("value").append(attrValue);
                    break;
                case "property":
                    // propertyは既にname属性の処理で扱われているため、ここでは出力しない
                    break;
                case "scope":
                    // scopeは既にname属性の処理で扱われているため、ここでは出力しない
                    break;
                default:
                    convertedAttrs.append(whitespace).append(attrName).append(attrValue);
            }
        }
        
        return convertedAttrs.toString();
    }
    
    private String extractQuotedValue(String attrValue) {
        // ="値" の形式から値のみを抽出
        Pattern valuePattern = Pattern.compile("=\\s*\"([^\"]*)\"");
        Matcher valueMatcher = valuePattern.matcher(attrValue);
        return valueMatcher.find() ? valueMatcher.group(1) : "";
    }
    
    private String extractAttribute(String attributes, String attributeName) {
        Pattern pattern = Pattern.compile(attributeName + "\\s*=\\s*\"([^\"]+)\"");
        Matcher matcher = pattern.matcher(attributes);
        return matcher.find() ? matcher.group(1) : null;
    }
    
    private String capitalize(String str) {
        return str == null || str.isEmpty() ? str
            : str.substring(0, 1).toUpperCase() + str.substring(1);
    }
}

class HtmlHiddenConverter implements TagConverter {
    private static final Pattern HTML_HIDDEN_PATTERN = Pattern.compile(
        "<html:hidden([^>]*?)(/?>)",
        Pattern.DOTALL
    );
    
    @Override
    public String convert(String content, List<ConversionResult> results) {
        Matcher matcher = HTML_HIDDEN_PATTERN.matcher(content);
        StringBuffer result = new StringBuffer();
        
        while (matcher.find()) {
            String attributes = matcher.group(1);
            String endTag = matcher.group(2);
            
            // 必要な属性を抽出
            String name = extractAttribute(attributes, "name");
            String property = extractAttribute(attributes, "property");
            
            // 属性文字列を変換
            String convertedAttributes = convertAttributes(attributes, name, property);
            
            // タグ全体を組み立て
            String convertedTag = "<input type=\"hidden\"" + convertedAttributes + endTag;
            
            results.add(new ConversionResult("html:hidden", matcher.group(0), convertedTag));
            matcher.appendReplacement(result, Matcher.quoteReplacement(convertedTag));
        }
        
        matcher.appendTail(result);
        return result.toString();
    }
    
    private String convertAttributes(String originalAttributes, String name, String property) {
        StringBuilder converted = new StringBuilder(originalAttributes);
        
        if (property != null) {
            // property属性を削除
            converted = new StringBuilder(converted.toString().replaceAll(
                "\\s*property=\"[^\"]+\"",
                ""
            ));
            
            // name属性の処理
            if (name != null) {
                // 既存のname属性を変換
                String nameWithUnderscores = name.replace('.', '_');
                // propertyの値をname属性に設定し、その後にvalue属性を追加
                converted = new StringBuilder(converted.toString().replaceAll(
    "name=\"[^\"]+\"",
    "name=\"" + property + "\" value=\"\\$\\{" + nameWithUnderscores + 
    ".get" + capitalize(property) + "\\(\\)}\""
));
            } else {
                // name属性がない場合は、propertyの値をname属性として追加
                converted.append(" name=\"").append(property).append("\"");
            }
        }
        
        return converted.toString();
    }
    
    private String extractAttribute(String attributes, String attributeName) {
        Pattern pattern = Pattern.compile(attributeName + "\\s*=\\s*\"(.*?)\"");
        Matcher matcher = pattern.matcher(attributes);
        return matcher.find() ? matcher.group(1) : null;
    }
    
    private String capitalize(String str) {
        return str == null || str.isEmpty() ? str
            : str.substring(0, 1).toUpperCase() + str.substring(1);
    }
}

class HtmlSelectConverter implements TagConverter {
    private static final Pattern HTML_SELECT_PATTERN = Pattern.compile(
        "([ \\t]*)<html:select([^>]*?)>(([\\s\\S]*?))([ \\t]*)</html:select>",
        Pattern.DOTALL
    );

    @Override
    public String convert(String content, List<ConversionResult> results) {
        Matcher matcher = HTML_SELECT_PATTERN.matcher(content);
        StringBuffer result = new StringBuffer();
        
        while (matcher.find()) {
            String leadingWhitespace = matcher.group(1);  // タグ前の空白
            String attributes = matcher.group(2);         // 属性部分
            String innerContent = matcher.group(3);       // 内部コンテンツ
            String trailingWhitespace = matcher.group(5); // 閉じタグ前の空白
            
            // 元の空白を保持したまま属性を変換
            String convertedAttributes = convertAttributes(attributes);
            
            // name属性とproperty属性を取得（HtmlOptionConverter用）
            String name = extractAttribute(attributes, "name");
            String property = extractAttribute(attributes, "property");
            
            // 内部コンテンツを変換（改行を保持）
            String convertedInnerContent = convertInnerContent(
                innerContent,
                name,
                property
            );
            
            // 全体を組み立て
            String convertedTag = leadingWhitespace + "<select" + convertedAttributes + ">" + 
                                convertedInnerContent + 
                                trailingWhitespace + "</select>";
            
            results.add(new ConversionResult(
                "html:select",
                matcher.group(0),
                convertedTag
            ));
            
            matcher.appendReplacement(
                result,
                Matcher.quoteReplacement(convertedTag)
            );
        }
        
        matcher.appendTail(result);
        return result.toString();
    }
    
    private String convertAttributes(String originalAttributes) {
        if (originalAttributes == null || originalAttributes.trim().isEmpty()) {
            return "";
        }
        
        Pattern attrPattern = Pattern.compile("([ \\t\\n\\r]*)(\\w+)(\\s*=\\s*\"[^\"]*\")");
        Matcher attrMatcher = attrPattern.matcher(originalAttributes);
        StringBuilder convertedAttrs = new StringBuilder();
        
        while (attrMatcher.find()) {
            String whitespace = attrMatcher.group(1);  // 属性前の空白
            String attrName = attrMatcher.group(2);    // 属性名
            String attrValue = attrMatcher.group(3);   // ="値"部分
            
            switch (attrName) {
                case "styleClass":
                    convertedAttrs.append(whitespace).append("class").append(attrValue);
                    break;
                case "styleId":
                    convertedAttrs.append(whitespace).append("id").append(attrValue);
                    break;
                case "property":
                    convertedAttrs.append(whitespace).append("name").append(attrValue);
                    break;
                case "name":
                    // nameは出力しない
                    break;
                default:
                    convertedAttrs.append(whitespace).append(attrName).append(attrValue);
            }
        }
        
        return convertedAttrs.toString();
    }
    
    private String convertInnerContent(String content, String selectName, String selectProperty) {
        if (selectName == null) {
            // name属性がない場合は、改行を保持しつつ単純変換
            return content.replaceAll("<html:option", "<option")
                         .replaceAll("</html:option>", "</option>")
                         .replaceAll("/>", ">");
        }
        
        HtmlOptionConverter optionConverter = new HtmlOptionConverter(selectName, selectProperty);
        String converted = optionConverter.convert(content, new ArrayList<>());
        
        // 余分な改行を削除しないよう、optionタグの前後の空白を保持
        return converted;
    }
    
    private String extractAttribute(String attributes, String attributeName) {
        Pattern pattern = Pattern.compile(attributeName + "\\s*=\\s*\"([^\"]*)\"");
        Matcher matcher = pattern.matcher(attributes);
        return matcher.find() ? matcher.group(1) : null;
    }
}

class HtmlSelect {
    private final String name;
    private final String property;
    private final String styleClass;
    private final String styleId;
    private final String onblur;
    private final String style;

    private HtmlSelect(Builder builder) {
        this.name = builder.name;
        this.property = builder.property;
        this.styleClass = builder.styleClass;
        this.styleId = builder.styleId;
        this.onblur = builder.onblur;
        this.style = builder.style;
       
    }

    // Getter methods added
    public String getName() { return name; }
    public String getProperty() { return property; }

    public String toJstl(String innerContent) {
        StringBuilder html = new StringBuilder("<select");
       
        if (property != null) {
            html.append(" name=\"").append(property).append("\"");
        }
       
        if (styleClass != null) {
            html.append(" class=\"").append(styleClass).append("\"");
        }
       
        if (styleId != null) {
            html.append(" id=\"").append(styleId).append("\"");
        }

        if (onblur != null) {
            html.append(" onblur=\"").append(onblur).append("\"");
        }
       
        if (style != null) {
            html.append(" style=\"").append(style).append("\"");
        }
       
        html.append(">");
        html.append(innerContent);
        html.append("</select>");
       
        return html.toString();
    }

    public static class Builder {
        private String name;
        private String property;
        private String styleClass;
        private String styleId;
        private String onblur;
        private String style;

        public Builder name(String name) {
            this.name = name;
            return this;
        }

        public Builder property(String property) {
            this.property = property;
            return this;
        }

        public Builder styleClass(String styleClass) {
            this.styleClass = styleClass;
            return this;
        }

        public Builder styleId(String styleId) {
            this.styleId = styleId;
            return this;
        }

        public Builder onblur(String onblur) {
            this.onblur = onblur;
            return this;
        }
   
        public Builder style(String style) {
            this.style = style;
            return this;
        }
   
        public HtmlSelect build() {
            return new HtmlSelect(this);
        }
    }
}

class HtmlOptionConverter implements TagConverter {
    private static final Pattern HTML_OPTION_PATTERN = Pattern.compile(
        "<html:option\\s*([^>]*?)(?:/>|>(.*?)</html:option>)",
        Pattern.DOTALL
    );
   
    private final String selectName;
    private final String selectProperty;
   
    public HtmlOptionConverter(String selectName, String selectProperty) {
        this.selectName = selectName;
        this.selectProperty = selectProperty;
    }
   
    @Override
    public String convert(String content, List<ConversionResult> results) {
        Matcher matcher = HTML_OPTION_PATTERN.matcher(content);
        StringBuffer result = new StringBuffer();
       
        while (matcher.find()) {
            String attributes = matcher.group(1).trim();
            String value = extractAttribute(attributes, "value");
            String text = matcher.group(2);
            
            StringBuilder convertedTag = new StringBuilder("<option");
            
            // 属性の処理
            if (!attributes.isEmpty()) {
                String cleanedAttributes = attributes
                    .replaceAll("\\bhtml:option\\b", "")
                    .trim();
                
                if (!cleanedAttributes.isEmpty()) {
                    convertedTag.append(" ").append(cleanedAttributes);
                }
            }
            
            // selected条件を追加（定数を左側に置く）
            if (selectName != null && value != null) {
                convertedTag.append(String.format("${ '%s' == %s.get%s() ? ' selected' : '' }",
                    value,
                    NameConverter.convertDotToUnderscore(selectName),
                    capitalize(selectProperty != null ? selectProperty : "")));
            }
            
            // 終了タグの処理
            if (text != null && !text.trim().isEmpty()) {
                convertedTag.append(">").append(text.trim()).append("</option>");
            } else {
                convertedTag.append(">");
            }
            
            results.add(new ConversionResult(
                "html:option",
                matcher.group(0),
                convertedTag.toString()
            ));
            
            matcher.appendReplacement(
                result,
                Matcher.quoteReplacement(convertedTag.toString())
            );
        }
       
        matcher.appendTail(result);
        return result.toString();
    }
   
    private String extractAttribute(String attributes, String attributeName) {
        Pattern pattern = Pattern.compile(attributeName + "\\s*=\\s*\"(.*?)\"");
        Matcher matcher = pattern.matcher(attributes);
        return matcher.find() ? matcher.group(1) : null;
    }
    
    private String capitalize(String str) {
        return str == null || str.isEmpty() ? str
            : str.substring(0, 1).toUpperCase() + str.substring(1);
    }
}

class HtmlRadioConverter implements TagConverter {
    private static final Pattern HTML_RADIO_PATTERN = Pattern.compile(
        "<html:radio([^>]*?)(/?>|>(.*?)</html:radio>)",
        Pattern.DOTALL
    );

    @Override
    public String convert(String content, List<ConversionResult> results) {
        Matcher matcher = HTML_RADIO_PATTERN.matcher(content);
        StringBuffer result = new StringBuffer();
        
        while (matcher.find()) {
            String attributes = matcher.group(1);
            String endTag = matcher.group(2);
            String innerText = matcher.group(3);
            
            // 必要な属性を抽出
            String name = extractAttribute(attributes, "name");
            String property = extractAttribute(attributes, "property");
            String value = extractAttribute(attributes, "value");
            
            // propertyをname属性に変換し、元のname属性を削除
            String convertedAttributes = attributes
                .replaceAll("\\s*name=\"[^\"]+\"", "") // まず既存のname属性を削除
                .replaceAll("property=\"([^\"]+)\"", "name=\"$1\"")
                .replaceAll("styleClass=\"([^\"]+)\"", "class=\"$1\"")
                .replaceAll("styleId=\"([^\"]+)\"", "id=\"$1\""); // styleIdをidに変換
                

            StringBuilder convertedTag = new StringBuilder("<input type=\"radio\"");
            convertedTag.append(convertedAttributes);
            
            // checked条件を追加（余分なスペースを入れない）
            if (name != null && property != null && value != null) {
                // value属性が${...}形式かどうかをチェック
                boolean isDynamicValue = value.startsWith("${") && value.endsWith("}");
                String checkedCondition;
                
                if (isDynamicValue) {
                    // 動的な値の場合（${option}など）
                    checkedCondition = String.format("<c:if test=\"${%s.get%s() == %s}\"> checked</c:if>",
                        NameConverter.convertDotToUnderscore(name),
                        capitalize(property),
                        value); // クォートなしで値を使用
                } else {
                    // 静的な値の場合
                    checkedCondition = String.format("<c:if test=\"${%s.get%s() == '%s'}\"> checked</c:if>",
                        NameConverter.convertDotToUnderscore(name),
                        capitalize(property),
                        value);
                }
                convertedTag.append(checkedCondition);
            }
            
            // 終了タグを追加
            convertedTag.append(">");
            
            // 内部テキストがある場合は追加
            if (innerText != null && !innerText.trim().isEmpty()) {
                convertedTag.append(innerText);
            }
            
            results.add(new ConversionResult("html:radio", matcher.group(0), convertedTag.toString()));
            matcher.appendReplacement(result, Matcher.quoteReplacement(convertedTag.toString()));
        }
        
        matcher.appendTail(result);
        return result.toString();
    }
    
    private String extractAttribute(String attributes, String attributeName) {
        Pattern pattern = Pattern.compile(attributeName + "\\s*=\\s*\"(.*?)\"");
        Matcher matcher = pattern.matcher(attributes);
        return matcher.find() ? matcher.group(1) : null;
    }
    
    private String capitalize(String str) {
        return str == null || str.isEmpty() ? str
            : str.substring(0, 1).toUpperCase() + str.substring(1);
    }
}
class LogicGreaterEqualConverter extends LogicComparisonConverter {
    public LogicGreaterEqualConverter() {
        super("greaterEqual");
    }
   
    @Override
    protected String getOperator() {
        return ">=";
    }
}