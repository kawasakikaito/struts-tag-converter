<%@ taglib uri="/WEB-INF/struts-test.tld" prefix="test" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>

<!-- html:text タグのテスト -->
<h2>HTML Text Tests</h2>
<html:text property="username" />
<html:text
  property="firstName"
  name="address.Form"
  styleId="firstNameInput"
  maxlength="50"
  styleClass="form-control"
  onblur="onbluertest"
  disabled="true"
  size="30"
/>
<html:text
  name="userForm"
  property="email"
  styleId="emailField"
  styleClass="input-text"
/>
<html:text property="phoneNumber" styleId="phone" maxlength="15" size="20" />
<html:text
  styleId="zip"
  name="address.Form"
  maxlength="10"
  styleClass="zip-input"
  size="10"
  property="zipCode"
/>

<!-- bean:write タグのテスト -->
<h2>Bean Write Tests</h2>
<bean:write name="user.test" property="fullName" />
<bean:write name="account" property="balance" scope="session" />
<bean:write name="settings" property="theme" filter="true" />
<bean:write name="notification" property="emailEnabled" ignore="true" />
<bean:write name="user" property="lastLogin" scope="request" filter="false" />

<!-- logic:equal と logic:notEqual タグのテスト -->
<h2>Logic Equal/NotEqual Tests</h2>
<logic:equal name="user" property="role" value="admin" scope="session">
  <div class="admin-panel">管理者向けコンテンツ</div>
</logic:equal>

<logic:notEqual name="user" property="status" value="inactive">
  <div class="user-content">アクティブユーザー向けコンテンツ</div>
</logic:notEqual>

<logic:equal name="userForm" property="verified" value="true">
  <div class="verified-badge">認証済みユーザー</div>
</logic:equal>

<logic:equal
  name="settings"
  property="darkMode"
  value="enabled"
  scope="application"
>
  <link rel="stylesheet" href="dark-theme.css" />
</logic:equal>

<logic:notEqual
  name="user"
  property="accountType"
  value="guest"
  scope="request"
>
  <div class="member-features">会員向け機能を表示</div>
</logic:notEqual>

<!-- logic:iterate タグのテスト -->
<h2>Logic Iterate Tests</h2>
<!-- 基本的な繰り返し -->
<logic:iterate id="item" name="shoppingCart" property="items">
  <div class="cart-item">
    <bean:write name="item" property="name" />
  </div>
</logic:iterate>

<!-- scope属性付きの繰り返し -->
<logic:iterate id="notification" name="notifications" scope="session">
  <div class="notification">
    <bean:write name="notification" property="message" />
  </div>
</logic:iterate>

<!-- collection属性を使用した繰り返し -->
<logic:iterate id="user" collection="requestScope.userList">
  <div class="user-item">
    <bean:write name="user" property="username" />
  </div>
</logic:iterate>

<!-- offset と length を使用した繰り返し -->
<logic:iterate id="message" name="messageList" offset="5" length="10">
  <div class="message">
    <bean:write name="message" property="content" />
  </div>
</logic:iterate>

<!-- すべての属性を使用した複雑な繰り返し -->
<logic:iterate
  id="product"
  name="catalog"
  property="products"
  indexId="index"
  scope="request"
  offset="0"
  length="5"
>
  <div class="product-item">
    <span class="index">${index}</span>
    <bean:write name="product" property="name" />
  </div>
</logic:iterate>

<!-- 追加テスト -->

<!-- Nested Tag Tests -->
<h2>Nested Tag Tests</h2>
<logic:equal name="user" property="isActive" value="true">
  <logic:iterate id="item" name="user" property="items">
    <bean:write name="item" property="description" />
  </logic:iterate>
</logic:equal>

<!-- Filtering Attributes Tests -->
<h2>Filtering Attributes Tests</h2>
<bean:write name="user" property="bio" filter="true" />
<bean:write name="user" property="rawHTML" filter="false" />
<bean:write name="user" property="optionalField" ignore="true" />

<!-- Attribute Order Tests -->
<h2>Attribute Order Tests</h2>
<logic:equal value="true" property="isActive" name="user">
  <div>順序が異なるロジックタグ</div>
</logic:equal>

<logic:notEqual
  value="guest"
  property="accountType"
  name="user"
  scope="session"
>
  <div>順序が異なるロジックタグ（スコープ付き）</div>
</logic:notEqual>

<!-- html:button タグのテスト -->
<h2>HTML Button Tests</h2>
<!-- 基本的なボタン -->
<html:button property="simpleButton" value="Click Me" />

<!-- スタイルクラス付きボタン -->
<html:button
  property="styledButton"
  styleClass="btn-primary"
  value="Styled Button"
/>

<!-- クリックイベント付きボタン -->
<html:button property="submitButton" onclick="submitForm()" value="Submit" />

<!-- すべての属性を組み合わせたボタン -->
<html:button
  property="complexButton"
  styleClass="btn-large"
  onclick="handleClick()"
  value="Complex Button"
>
  Complex Button Text
</html:button>

<!-- ボタンテキストのみ（value無し） -->
<html:button property="textButton"> Text Only Button </html:button>

<!-- イベントハンドラのみ -->
<html:button property="eventButton" onclick="showAlert()">
  Show Alert
</html:button>

<!-- スタイルクラスのみ -->
<html:button property="styledOnlyButton" styleClass="custom-button">
  Styled Button
</html:button>

<!-- 属性順序テスト -->
<html:button
  onclick="save()"
  value="Save"
  styleClass="save-btn"
  property="orderButton"
>
  Save Changes
</html:button>

<!-- Scriptlet Tests within Logic:iterate -->
<h2>Scriptlet Tests</h2>
<logic:iterate id="item" name="list" property="items" indexId="idx">
  <% if(idx == 0) { %>
  <div class="first-item">
    <bean:write name="item" property="name" />
  </div>
  <% } else { %>
  <div class="other-item">
    <bean:write name="item" property="name" />
  </div>
  <% } %> <% if(idx % 2 == 0) { %>
  <div class="even-row">偶数行</div>
  <% } else { %>
  <div class="odd-row">奇数行</div>
  <% } %> <% for(int i = 0; i < idx; i++) { %>
  <span class="indent">-</span>
  <% } %>
</logic:iterate>

<!-- Complex Nested Tags with Scriptlets -->
<logic:equal name="user" property="role" value="admin">
  <logic:iterate id="report" name="reportList" indexId="reportIdx">
    <% if(reportIdx < 5) { %>
    <div class="recent-report">
      <bean:write name="report" property="title" />
      <logic:iterate
        id="detail"
        name="report"
        property="details"
        indexId="detailIdx"
      >
        <% if(detailIdx == 0) { %>
        <div class="first-detail">
          <bean:write name="detail" property="description" />
        </div>
        <% } %>
      </logic:iterate>
    </div>
    <% } %>
  </logic:iterate>
</logic:equal>

<!-- Mixed Content Tests -->
<logic:iterate id="product" name="products" indexId="prodIdx">
  <div class="product-row">
    <% if(prodIdx == 0) { %>
    <div class="featured">Featured Product</div>
    <% } %>
    <span class="number"><%= prodIdx + 1 %></span>
    <bean:write name="product" property="name" />
    <logic:equal name="product" property="inStock" value="true">
      <% if(prodIdx < 3) { %>
      <span class="stock-status">Limited Stock</span>
      <% } else { %>
      <span class="stock-status">In Stock</span>
      <% } %>
    </logic:equal>
  </div>
</logic:iterate>

<!-- Complex Logic Tests -->
<logic:iterate id="order" name="orderList" indexId="orderIdx">
  <% String rowClass = ""; if(orderIdx == 0) { rowClass = "first-row"; } else
  if(orderIdx % 2 == 0) { rowClass = "even-row"; } else { rowClass = "odd-row";
  } %>
  <div class="<%= rowClass %>">
    <bean:write name="order" property="id" />
    <logic:iterate id="item" name="order" property="items" indexId="itemIdx">
      <% if(itemIdx < orderIdx) { %>
      <div class="sub-item">
        <bean:write name="item" property="name" />
      </div>
      <% } %>
    </logic:iterate>
  </div>
</logic:iterate>

<!-- Scriptlet Expression Tests -->
<h2>Scriptlet Expression Tests</h2>
<!-- 基本的なインデックス加算 -->
<logic:iterate id="item" name="itemList" indexId="idx">
  <div class="item">
    番号: <%=idx + 1%>
    <bean:write name="item" property="name" />
  </div>
</logic:iterate>

<!-- ネストされたイテレータでのスクリプトレット -->
<logic:iterate id="category" name="categories" indexId="catIdx">
  <div class="category">
    カテゴリ <%=catIdx + 1%>:
    <logic:iterate
      id="product"
      name="category"
      property="products"
      indexId="prodIdx"
    >
      <div class="product">
        商品 <%=prodIdx + 1%>:
        <bean:write name="product" property="name" />
      </div>
    </logic:iterate>
  </div>
</logic:iterate>

<!-- 複数のスクリプトレット式を含むケース -->
<logic:iterate id="user" name="userList" indexId="userIdx">
  <div class="user-row">
    <span class="number"><%=userIdx + 1%></span>
    <span class="alt-number">項目: <%=userIdx + 100%></span>
    <bean:write name="user" property="name" />
  </div>
</logic:iterate>

<!-- スクリプトレットと他のタグの組み合わせ -->
<logic:iterate id="task" name="taskList" indexId="taskIdx">
  <logic:equal name="task" property="status" value="active">
    <div class="active-task">
      タスク <%=taskIdx + 1%>:
      <bean:write name="task" property="description" />
    </div>
  </logic:equal>
</logic:iterate>

<!-- html:select と html:option, html:options タグのテスト -->
<h2>Select, Option, and Options Tests</h2>

<!-- 基本的なselectとoption -->
<html:select property="country">
  <html:option value="jp">日本</html:option>
  <html:option value="us">アメリカ</html:option>
  <html:option value="uk">イギリス</html:option>
</html:select>

<!-- im_boardとim_position属性のテスト -->
<h2>HTML Text with im_board and im_position Tests</h2>

<!-- 基本的な使用例 -->
<html:text im_board="board1" im_position="pos1" property="username" />

<!-- すべての属性を組み合わせた例 -->
<html:text
  im_board="mainBoard"
  im_position="header"
  property="title"
  styleId="titleInput"
  maxlength="100"
  styleClass="form-control"
  size="50"
/>

<!-- 属性の順序テスト（im_board、im_position、name、他の属性の順序を確認） -->
<html:text
  styleClass="input-field"
  im_position="footer"
  property="description"
  im_board="subBoard"
  size="30"
/>

<!-- name属性との組み合わせ -->
<html:text
  im_board="contentBoard"
  im_position="body"
  name="contentForm"
  property="content"
  styleClass="content-input"
/>

<!-- 一方の属性のみを使用 -->
<html:text im_board="singleBoard" property="singleAttribute" />

<html:text im_position="singlePosition" property="anotherAttribute" />

<!-- im_boardとim_position属性のテスト -->
<h2>HTML Text with im_board and im_position Tests</h2>

<!-- 基本的な使用例 -->
<html:text im_board="board1" im_position="pos1" property="username" />

<!-- すべての属性を組み合わせた例 -->
<html:text
  im_board="mainBoard"
  im_position="header"
  property="title"
  styleId="titleInput"
  maxlength="100"
  styleClass="form-control"
  size="50"
/>

<!-- 属性の順序テスト（im_board、im_position、name、他の属性の順序を確認） -->
<html:text
  styleClass="input-field"
  im_position="footer"
  property="description"
  im_board="subBoard"
  size="30"
/>

<!-- name属性との組み合わせ -->
<html:text
  im_board="contentBoard"
  im_position="body"
  name="contentForm"
  property="content"
  styleClass="content-input"
/>

<!-- 一方の属性のみを使用 -->
<html:text im_board="singleBoard" property="singleAttribute" />

<html:text im_position="singlePosition" property="anotherAttribute" />

<!-- bean:define タグのテスト -->
<h2>Bean Define Tests</h2>
<!-- 基本的な変数定義 -->
<bean:define name="user" property="name" id="userName" />

<!-- スコープ付きの変数定義 -->
<bean:define id="userAge" name="user" property="age" scope="session" />

<!-- スコープからスコープへの定義 -->
<bean:define
  id="userEmail"
  name="user"
  property="email"
  scope="request"
  toScope="session"
/>

<!-- 直接値の定義 -->
<bean:define id="maxResults" value="10" />

<!-- name属性のみの定義 -->
<bean:define id="userObject" name="user" />

<!-- スコープ指定での変数定義 -->
<bean:define id="preferences" name="userPreferences" scope="application" />

<!-- toScopeのみの定義 -->
<bean:define id="tempVar" name="tempObject" toScope="request" />

<!-- すべての属性を使用した定義 -->
<bean:define
  id="userStatus"
  name="user"
  property="status"
  scope="session"
  toScope="request"
/>

<!-- html:hidden タグのテスト -->
<h2>HTML Hidden Tests</h2>
<!-- 基本的な hidden フィールド -->
<html:hidden property="userId" />

<!-- name属性付きの hidden フィールド -->
<html:hidden property="sessionId" name="user.Session" />

<!-- Bean参照の hidden フィールド -->
<html:hidden property="authToken" name="securityForm" />

<!-- 複数の hidden フィールド -->
<html:hidden property="timestamp" name="auditForm" />
<html:hidden property="version" name="versionForm" />

<!-- フォーム内での hidden フィールド -->
<html:form action="/submit">
  <html:hidden property="formId" name="submitForm" />
  <html:hidden property="created" name="submitForm" />
</html:form>

<!-- ネストされたコンテキストでの hidden フィールド -->
<logic:equal name="user" property="isAdmin" value="true">
  <html:hidden property="adminKey" name="adminForm" />
  <logic:iterate id="permission" name="permissionList">
    <html:hidden property="permissionId" name="permission" />
  </logic:iterate>
</logic:equal>

<!-- スタイルクラス付きのselect -->
<html:select property="category" styleClass="form-select">
  <html:option value="1">1</html:option>
  <html:option value="2">2</html:option>
  <html:option value="3">3</html:option>
</html:select>

<!-- styleId付きのselect -->
<html:select property="region" styleId="regionSelect">
  <html:option value="north" />
  <html:option value="south" />
  <html:option value="east" />
  <html:option value="west" />
</html:select>

<!-- すべての属性を組み合わせたselect -->
<html:select
  name="productForm"
  property="productType"
  styleClass="custom-select"
  styleId="productTypeSelect"
>
  <html:option value="A" disabled>A</html:option>
  <html:option value="B">B</html:option>
  <html:option value="C">C</html:option>
</html:select>

<!-- 属性の順序を変えたselect -->
<html:select
  name="orderForm"
  styleId="orderSelect"
  styleClass="order-select"
  property="orderType"
>
  <html:option value="standard" />
  <html:option value="express" />
  <html:option value="priority" />
</html:select>

<!-- 大量のoptionを持つselect -->
<html:select property="number" styleClass="number-select">
  <html:option value="1" />
  <html:option value="2" />
  <html:option value="3" />
  <html:option value="4" />
  <html:option value="5" />
  <html:option value="6" />
  <html:option value="7" />
  <html:option value="8" />
  <html:option value="9" />
  <html:option value="10" />
</html:select>

<!-- name属性とselectした値の組み合わせテスト -->
<html:select name="userForm" property="selectedValue">
  <html:option value="active" />
  <html:option value="inactive" />
  <html:option value="pending" />
</html:select>

<!-- html:options タグのテスト -->
<h2>HTML Options Tests</h2>

<!-- 基本的な使用例（collection使用） -->
<html:select property="selectedItem">
  <html:options collection="itemList" property="id" labelProperty="name" />
</html:select>

<!-- name/property使用 -->
<html:select property="selectedDepartment">
  <html:options
    name="departmentForm"
    property="departments"
    labelProperty="departmentName"
  />
</html:select>

<!-- labelName使用 -->
<html:select property="selectedProduct">
  <html:options
    collection="productList"
    property="productId"
    labelName="productLabels"
    labelProperty="label"
  />
</html:select>

<!-- 複合的な使用例 -->
<html:select property="selectedOption" styleClass="custom-select">
  <html:options
    name="optionForm"
    property="availableOptions"
    labelProperty="displayName"
  />
</html:select>

<!-- collection属性のみ -->
<html:select property="simpleSelection">
  <html:options collection="simpleList" />
</html:select>

<!-- すべての属性を使用 -->
<html:select property="complexSelection">
  <html:options
    name="complexForm"
    property="items"
    labelName="labelContainer"
    labelProperty="displayLabel"
    collection="itemCollection"
  />
</html:select>

<!-- ネストされたコンテキストでの使用 -->
<logic:iterate id="category" name="categoryList">
  <html:select property="categorySelection">
    <html:options
      name="category"
      property="subItems"
      labelProperty="subItemName"
    />
  </html:select>
</logic:iterate>

<!-- フォーム内での使用 -->
<html:form action="/submit">
  <html:select property="formSelection">
    <html:options
      collection="formOptions"
      property="optionValue"
      labelProperty="optionLabel"
    />
  </html:select>
</html:form>

<!-- Dot notation conversion tests -->
<h2>Dot Notation Tests</h2>

<!-- bean:write with nested dots -->
<bean:write name="form.user.details" property="name" />
<bean:write
  name="company.department.manager"
  property="email"
  scope="session"
/>
<bean:write name="system.config.settings" property="value" filter="true" />

<!-- logic:equal with nested dots -->
<logic:equal name="form.user.settings" property="enabled" value="true">
  <div>Settings enabled</div>
</logic:equal>

<logic:notEqual name="app.user.preferences" property="theme" value="dark">
  <div>Not using dark theme</div>
</logic:notEqual>

<!-- logic:iterate with nested dots -->
<logic:iterate id="item" name="shop.cart.items" property="products">
  <bean:write name="item" property="name" />
</logic:iterate>

<!-- html form elements with nested dots -->
<html:text name="form.user.profile" property="firstName" />
<html:hidden name="checkout.order.details" property="orderId" />

<!-- bean:define with nested dots -->
<bean:define id="userProfile" name="form.user.profile" property="details" />

<!-- Complex nested structures with dots -->
<logic:equal name="company.department.team" property="active" value="true">
  <logic:iterate
    id="member"
    name="company.department.team.members"
    property="list"
  >
    <bean:write name="member.profile" property="name" />
  </logic:iterate>
</logic:equal>

<!-- Multiple dots in different positions -->
<bean:write name="app.config" property="version" />
<bean:write name="user.profile.settings" property="theme" />
<bean:write name="system.app.user.preferences" property="language" />

<!-- Combination of dots and other features -->
<logic:iterate id="item" name="store.inventory.items" indexId="idx">
  <div class="item">
    Item <%=idx + 1%>:
    <bean:write name="item.details" property="name" />
  </div>
</logic:iterate>

<!-- html:radio タグのテスト -->
<h2>HTML Radio Tests</h2>

<!-- 基本的なラジオボタン -->
<html:radio property="gender" value="male" />
<html:radio property="gender" value="female" />

<!-- name属性付きのラジオボタン -->
<html:radio name="userForm" property="subscriptionType" value="free" />
<html:radio name="userForm" property="subscriptionType" value="premium" />

<!-- スタイル属性付きのラジオボタン -->
<html:radio
  name="preferenceForm"
  property="theme"
  value="light"
  styleClass="radio-input"
  styleId="lightTheme"
/>
<html:radio
  name="preferenceForm"
  value="dark"
  styleClass="radio-input"
  property="theme"
  styleId="darkTheme"
/>

<!-- 無効化状態のラジオボタン -->
<html:radio
  property="notifications"
  name="settingsForm"
  value="enabled"
  disabled="true"
/>

<!-- クリックイベント付きのラジオボタン -->
<html:radio
  value="advanced"
  property="mode"
  name="configForm"
  onclick="handleModeChange()"
/>

<!-- すべての属性を組み合わせたラジオボタン -->
<html:radio
  name="complexForm"
  property="option"
  value="special"
  styleClass="custom-radio"
  styleId="specialOption"
  disabled="false"
  onclick="handleOptionSelect()"
/>

<!-- ネストされたコンテキストでのラジオボタン -->
<logic:iterate id="option" name="optionList">
  <html:radio
    name="selectionForm"
    property="selectedOption"
    value="${option}"
    styleClass="option-radio"
  />
</logic:iterate>

<!-- フォーム内での使用 -->
<html:form action="/submit">
  <div class="radio-group">
    <html:radio property="agreement" value="accept" /> 同意する
    <html:radio property="agreement" value="decline" /> 同意しない
  </div>
</html:form>

<!-- 属性の順序を変えたラジオボタン -->
<html:radio
  styleClass="order-radio"
  value="test"
  property="orderTest"
  name="orderForm"
  onclick="handleClick()"
/>

<!-- Dot notation を使用したラジオボタン -->
<html:radio
  name="form.user.preferences"
  property="receiveEmails"
  value="yes"
  styleClass="preference-radio"
/>

<!-- html:options の詳細テストケース -->
<h2>Detailed HTML Options Tests</h2>

<!-- スコープ指定のテスト -->
<html:select property="selectedItem">
  <html:options
    name="items"
    property="availableItems"
    labelProperty="itemName"
    scope="session"
  />
</html:select>

<html:select property="selectedDept">
  <html:options
    name="departments"
    property="list"
    labelProperty="deptName"
    scope="application"
  />
</html:select>

<html:select property="selectedUser">
  <html:options
    name="users"
    property="activeUsers"
    labelProperty="userName"
    scope="request"
  />
</html:select>

<!-- 入れ子構造のテスト -->
<logic:iterate id="category" name="categoryList">
  <html:select property="subCategory">
    <html:options name="category" property="items" labelProperty="itemName" />
  </html:select>
</logic:iterate>

<!-- Dot notation のテスト -->
<html:select property="selectedItem">
  <html:options
    name="form.master.items"
    property="available.items"
    labelProperty="item.name"
  />
</html:select>

<!-- 複合的なテスト -->
<logic:equal name="user" property="role" value="admin">
  <html:select property="adminSelection">
    <html:options
      name="admin.settings"
      property="available.options"
      labelName="admin.labels"
      labelProperty="display.name"
      scope="session"
    />
  </html:select>
</logic:equal>

<!-- collection と labelName の組み合わせ -->
<html:select property="productSelect">
  <html:options
    collection="product.list"
    labelName="product.labels"
    labelProperty="name.localized"
  />
</html:select>

<!-- すべての組み合わせ -->
<html:select property="complexSelect">
  <html:options
    name="form.data"
    property="items.list"
    labelName="form.labels"
    labelProperty="display.name"
    collection="data.collection"
    scope="request"
  />
</html:select>


<logic:greaterEqual name="form" property="age" value="20"></logic:greaterEqual>
    成人です
</logic:greaterEqual>

<html>
<head>
    <title>Logic Greater Equal Test Patterns</title>
</head>
<body>
    <!-- 1. 基本パターン -->
    <logic:greaterEqual name="form" property="age" value="20">
        成人です
    </logic:greaterEqual>

    <!-- 2. スコープ指定あり -->
    <logic:greaterEqual name="form" property="age" value="20" scope="session">
        成人です（セッションスコープ）
    </logic:greaterEqual>

    <!-- 3. プロパティなし、name属性のみ -->
    <logic:greaterEqual name="age" value="20">
        成人です（直接参照）
    </logic:greaterEqual>

    <!-- 4. 小数値との比較 -->
    <logic:greaterEqual name="form" property="temperature" value="36.5">
        平熱以上です
    </logic:greaterEqual>

    <!-- 5. マイナス値との比較 -->
    <logic:greaterEqual name="form" property="temperature" value="-10">
        氷点下ではありません
    </logic:greaterEqual>

    <!-- 6. 空白を含むコンテンツ -->
    <logic:greaterEqual name="form" property="score" value="80">
        
        合格です
        
    </logic:greaterEqual>
</body>
</html>