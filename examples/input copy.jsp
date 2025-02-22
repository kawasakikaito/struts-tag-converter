<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %> <%@ taglib
uri="/WEB-INF/struts-logic.tld" prefix="logic" %> <%@ taglib
uri="/WEB-INF/struts-bean.tld" prefix="bean" %>

<!-- html:text タグのテスト -->
<h2>HTML Text Tests</h2>
<html:text property="username" />
<html:text
  property="firstName"
  styleId="firstNameInput"
  maxlength="50"
  styleClass="form-control"
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
  name="addressForm"
  property="zipCode"
  styleId="zip"
  maxlength="10"
  styleClass="zip-input"
  size="10"
/>

<!-- bean:write タグのテスト -->
<h2>Bean Write Tests</h2>
<bean:write name="user" property="fullName" />
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

<!-- 属性付きのselect -->
<html:select
  property="prefecture"
  styleId="prefSelect"
  styleClass="form-control"
  onchange="updateCity(this.value)"
>
  <html:option value="">選択してください</html:option>
  <html:option value="tokyo">東京都</html:option>
  <html:option value="osaka">大阪府</html:option>
</html:select>

<!-- optionsを使用したリスト表示 -->
<html:select property="category">
  <html:options collection="categoryList" property="id" labelProperty="name" />
</html:select>

<!-- スコープ付きのoptions -->
<html:select property="department" styleClass="department-select">
  <html:options
    collection="departmentList"
    property="deptId"
    labelProperty="deptName"
    scope="session"
  />
</html:select>

<!-- 複数選択可能なselect -->
<html:select
  property="selectedSkills"
  multiple="true"
  size="5"
  styleClass="multi-select"
>
  <html:options
    collection="skillsList"
    property="skillCode"
    labelProperty="skillName"
  />
</html:select>

<!-- disabled属性付きのoption -->
<html:select property="status">
  <html:option value="active">有効</html:option>
  <html:option value="inactive" disabled="true">無効</html:option>
  <html:option value="pending">保留</html:option>
</html:select>

<!-- フィルタリング付きのoptions -->
<html:select property="role">
  <html:options
    collection="roleList"
    property="roleId"
    labelProperty="roleName"
    filter="true"
  />
</html:select>

<!-- Beanプロパティと組み合わせたselect -->
<html:select
  property="selectedCity"
  name="locationForm"
  styleId="citySelect"
  scope="request"
>
  <html:options
    collection="cityList"
    property="cityCode"
    labelProperty="cityName"
  />
</html:select>

<!-- ネストされたタグとの組み合わせ -->
<logic:equal name="user" property="isAdmin" value="true">
  <html:select property="userGroup" styleClass="admin-select">
    <html:options
      collection="adminGroups"
      property="groupId"
      labelProperty="groupName"
    />
  </html:select>
</logic:equal>

<!-- 属性順序のテスト -->
<html:select
  styleClass="custom-select"
  name="productForm"
  property="productType"
  styleId="productSelect"
  onchange="updatePrice()"
>
  <html:option value="basic">Basic</html:option>
  <html:option styleClass="premium-option" value="premium">Premium</html:option>
  <html:option disabled="true" value="enterprise">Enterprise</html:option>
</html:select>
