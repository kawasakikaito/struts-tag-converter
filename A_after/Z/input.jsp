<%@ taglib uri="/WEB-INF/struts-test.tld" prefix="test" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
   
<!-- html:text タグのテスト -->
<h2>HTML Text Tests</h2>
<input type="text"  name="username">
<input type="text"
  name="firstName" value="${address_Form.getFirstName()}"
  id="firstNameInput"
  maxlength="50"
  class="form-control"
  onblur="onbluertest"
  disabled="true"
  size="30"
>
<input type="text"
  name="email" value="${userForm.getEmail()}"
  id="emailField"
  class="input-text"
>
<input type="text" id="phone" maxlength="15" size="20"  name="phoneNumber">
<input type="text"
  id="zip"
  name="zipCode" value="${address_Form.getZipCode()}"
  maxlength="10"
  class="zip-input"
  size="10"
>

<!-- bean:write タグのテスト -->
<h2>Bean Write Tests</h2>
${user_test.getFullName()}
${sessionScope.account.getBalance()}
<c:out value="${settings.getTheme()}" escapeXml="true" />
${notification.getEmailEnabled()}
${requestScope.user.getLastLogin()}

<!-- logic:equal と logic:notEqual タグのテスト -->
<h2>Logic Equal/NotEqual Tests</h2>
<c:if test="${sessionScope.user.getRole() == 'admin'}">
  <div class="admin-panel">管理者向けコンテンツ</div>
</c:if>

<c:if test="${user.getStatus() != 'inactive'}">
  <div class="user-content">アクティブユーザー向けコンテンツ</div>
</c:if>

<c:if test="${userForm.getVerified() == 'true'}">
  <div class="verified-badge">認証済みユーザー</div>
</c:if>

<c:if test="${applicationScope.settings.getDarkMode() == 'enabled'}">
  <link rel="stylesheet" href="dark-theme.css" />
</c:if>

<c:if test="${requestScope.user.getAccountType() != 'guest'}">
  <div class="member-features">会員向け機能を表示</div>
</c:if>

<!-- logic:iterate タグのテスト -->
<h2>Logic Iterate Tests</h2>
<!-- 基本的な繰り返し -->
<c:forEach var="item" items="${shoppingCart.getItems()}">
  <div class="cart-item">
    ${item.getName()}
  </div>
</c:forEach>

<!-- scope属性付きの繰り返し -->
<c:forEach var="notification" items="${sessionScope.notifications}">
  <div class="notification">
    ${notification.getMessage()}
  </div>
</c:forEach>

<!-- collection属性を使用した繰り返し -->
<c:forEach var="user" items="${requestScope_userList}">
  <div class="user-item">
    ${user.getUsername()}
  </div>
</c:forEach>

<!-- offset と length を使用した繰り返し -->
<c:forEach var="message" items="${messageList}" begin="5" end="14">
  <div class="message">
    ${message.getContent()}
  </div>
</c:forEach>

<!-- すべての属性を使用した複雑な繰り返し -->
<c:forEach var="product" items="${requestScope.catalog.getProducts()}" varStatus="index" begin="0" end="4">
  <div class="product-item">
    <span class="index">${index}</span>
    ${product.getName()}
  </div>
</c:forEach>

<!-- 追加テスト -->

<!-- Nested Tag Tests -->
<h2>Nested Tag Tests</h2>
<c:if test="${user.getIsActive() == 'true'}">
  <c:forEach var="item" items="${user.getItems()}">
    ${item.getDescription()}
  </c:forEach>
</c:if>

<!-- Filtering Attributes Tests -->
<h2>Filtering Attributes Tests</h2>
<c:out value="${user.getBio()}" escapeXml="true" />
${user.getRawHTML()}
${user.getOptionalField()}

<!-- Attribute Order Tests -->
<h2>Attribute Order Tests</h2>
<c:if test="${user.getIsActive() == 'true'}">
  <div>順序が異なるロジックタグ</div>
</c:if>

<c:if test="${sessionScope.user.getAccountType() != 'guest'}">
  <div>順序が異なるロジックタグ（スコープ付き）</div>
</c:if>

<!-- html:button タグのテスト -->
<h2>HTML Button Tests</h2>
<!-- 基本的なボタン -->
<input type="button" name="simpleButton" value="Click Me" >

<!-- スタイルクラス付きボタン -->
<input type="button"
  name="styledButton"
  class="btn-primary"
  value="Styled Button"
>

<!-- クリックイベント付きボタン -->
<input type="button" name="submitButton" onclick="submitForm()" value="Submit" >

<!-- すべての属性を組み合わせたボタン -->
<input type="button"
  name="complexButton"
  class="btn-large"
  onclick="handleClick()"
  value="Complex Button"
>
  Complex Button Text
</html:button>

<!-- ボタンテキストのみ（value無し） -->
<input type="button" name="textButton"> Text Only Button </html:button>

<!-- イベントハンドラのみ -->
<input type="button" name="eventButton" onclick="showAlert()">
  Show Alert
</html:button>

<!-- スタイルクラスのみ -->
<input type="button" name="styledOnlyButton" class="custom-button">
  Styled Button
</html:button>

<!-- 属性順序テスト -->
<input type="button"
  onclick="save()"
  value="Save"
  class="save-btn"
  name="orderButton"
>
  Save Changes
</html:button>

<!-- Scriptlet Tests within Logic:iterate -->
<h2>Scriptlet Tests</h2>
<c:forEach var="item" items="${list.getItems()}" varStatus="idx">
  <% if(idx == 0) { %>
  <div class="first-item">
    ${item.getName()}
  </div>
  <% } else { %>
  <div class="other-item">
    ${item.getName()}
  </div>
  <% } %> <% if(idx % 2 == 0) { %>
  <div class="even-row">偶数行</div>
  <% } else { %>
  <div class="odd-row">奇数行</div>
  <% } %> <% for(int i = 0; i < idx; i++) { %>
  <span class="indent">-</span>
  <% } %>
</c:forEach>

<!-- Complex Nested Tags with Scriptlets -->
<c:if test="${user.getRole() == 'admin'}">
  <c:forEach var="report" items="${reportList}" varStatus="reportIdx">
    <% if(reportIdx < 5) { %>
    <div class="recent-report">
      ${report.getTitle()}
      <c:forEach var="detail" items="${report.getDetails()}" varStatus="detailIdx">
        <% if(detailIdx == 0) { %>
        <div class="first-detail">
          ${detail.getDescription()}
        </div>
        <% } %>
      </c:forEach>
    </div>
    <% } %>
  </c:forEach>
</c:if>

<!-- Mixed Content Tests -->
<c:forEach var="product" items="${products}" varStatus="prodIdx">
  <div class="product-row">
    <% if(prodIdx == 0) { %>
    <div class="featured">Featured Product</div>
    <% } %>
    <span class="number">${prodIdx.index + 1}</span>
    ${product.getName()}
    <c:if test="${product.getInStock() == 'true'}">
      <% if(prodIdx < 3) { %>
      <span class="stock-status">Limited Stock</span>
      <% } else { %>
      <span class="stock-status">In Stock</span>
      <% } %>
    </c:if>
  </div>
</c:forEach>

<!-- Complex Logic Tests -->
<c:forEach var="order" items="${orderList}" varStatus="orderIdx">
  <% String rowClass = ""; if(orderIdx == 0) { rowClass = "first-row"; } else
  if(orderIdx % 2 == 0) { rowClass = "even-row"; } else { rowClass = "odd-row";
  } %>
  <div class="<%= rowClass %>">
    ${order.getId()}
    <c:forEach var="item" items="${order.getItems()}" varStatus="itemIdx">
      <% if(itemIdx < orderIdx) { %>
      <div class="sub-item">
        ${item.getName()}
      </div>
      <% } %>
    </c:forEach>
  </div>
</c:forEach>

<!-- Scriptlet Expression Tests -->
<h2>Scriptlet Expression Tests</h2>
<!-- 基本的なインデックス加算 -->
<c:forEach var="item" items="${itemList}" varStatus="idx">
  <div class="item">
    番号: ${idx.index + 1}
    ${item.getName()}
  </div>
</c:forEach>

<!-- ネストされたイテレータでのスクリプトレット -->
<c:forEach var="category" items="${categories}" varStatus="catIdx">
  <div class="category">
    カテゴリ ${catIdx.index + 1}:
    <c:forEach var="product" items="${category.getProducts()}" varStatus="prodIdx">
      <div class="product">
        商品 ${prodIdx.index + 1}:
        ${product.getName()}
      </div>
    </c:forEach>
  </div>
</c:forEach>

<!-- 複数のスクリプトレット式を含むケース -->
<c:forEach var="user" items="${userList}" varStatus="userIdx">
  <div class="user-row">
    <span class="number">${userIdx.index + 1}</span>
    <span class="alt-number">項目: ${userIdx.index + 100}</span>
    ${user.getName()}
  </div>
</c:forEach>

<!-- スクリプトレットと他のタグの組み合わせ -->
<c:forEach var="task" items="${taskList}" varStatus="taskIdx">
  <c:if test="${task.getStatus() == 'active'}">
    <div class="active-task">
      タスク ${taskIdx.index + 1}:
      ${task.getDescription()}
    </div>
  </c:if>
</c:forEach>

<!-- html:select と html:option, html:options タグのテスト -->
<h2>Select, Option, and Options Tests</h2>

<!-- 基本的なselectとoption -->
<select name="country">
  <option value="jp">日本</option>
  <option value="us">アメリカ</option>
  <option value="uk">イギリス</option>
</select>

<!-- im_boardとim_position属性のテスト -->
<h2>HTML Text with im_board and im_position Tests</h2>

<!-- 基本的な使用例 -->
<input type="text" im_board="board1" im_position="pos1"  name="username">

<!-- すべての属性を組み合わせた例 -->
<input type="text"
  im_board="mainBoard"
  im_position="header"
  id="titleInput"
  maxlength="100"
  class="form-control"
  size="50"
 name="title">

<!-- 属性の順序テスト（im_board、im_position、name、他の属性の順序を確認） -->
<input type="text"
  class="input-field"
  im_position="footer"
  im_board="subBoard"
  size="30"
 name="description">

<!-- name属性との組み合わせ -->
<input type="text"
  im_board="contentBoard"
  im_position="body"
  name="content" value="${contentForm.getContent()}"
  class="content-input"
>

<!-- 一方の属性のみを使用 -->
<input type="text" im_board="singleBoard"  name="singleAttribute">

<input type="text" im_position="singlePosition"  name="anotherAttribute">

<!-- im_boardとim_position属性のテスト -->
<h2>HTML Text with im_board and im_position Tests</h2>

<!-- 基本的な使用例 -->
<input type="text" im_board="board1" im_position="pos1"  name="username">

<!-- すべての属性を組み合わせた例 -->
<input type="text"
  im_board="mainBoard"
  im_position="header"
  id="titleInput"
  maxlength="100"
  class="form-control"
  size="50"
 name="title">

<!-- 属性の順序テスト（im_board、im_position、name、他の属性の順序を確認） -->
<input type="text"
  class="input-field"
  im_position="footer"
  im_board="subBoard"
  size="30"
 name="description">

<!-- name属性との組み合わせ -->
<input type="text"
  im_board="contentBoard"
  im_position="body"
  name="content" value="${contentForm.getContent()}"
  class="content-input"
>

<!-- 一方の属性のみを使用 -->
<input type="text" im_board="singleBoard"  name="singleAttribute">

<input type="text" im_position="singlePosition"  name="anotherAttribute">

<!-- bean:define タグのテスト -->
<h2>Bean Define Tests</h2>
<!-- 基本的な変数定義 -->
<c:set value="${user.getName()}" var="userName"/>

<!-- スコープ付きの変数定義 -->
<c:set var="userAge" value="${sessionScope.user.getAge()}"/>

<!-- スコープからスコープへの定義 -->
<c:set
  var="userEmail"
  value="${requestScope.user.getEmail()}"
  scope="session"/>

<!-- 直接値の定義 -->
<c:set var="maxResults" value="10"/>

<!-- name属性のみの定義 -->
<c:set var="userObject" value="${user}"/>

<!-- スコープ指定での変数定義 -->
<c:set var="preferences" value="${applicationScope.userPreferences}"/>

<!-- toScopeのみの定義 -->
<c:set var="tempVar" value="${tempObject}" scope="request"/>

<!-- すべての属性を使用した定義 -->
<c:set
  var="userStatus"
  value="${sessionScope.user.getStatus()}"
  scope="request"/>

<!-- html:hidden タグのテスト -->
<h2>HTML Hidden Tests</h2>
<!-- 基本的な hidden フィールド -->
<input type="hidden"  name="userId"/>

<!-- name属性付きの hidden フィールド -->
<input type="hidden" name="sessionId" value="${user_Session.getSessionId()}" />

<!-- Bean参照の hidden フィールド -->
<input type="hidden" name="authToken" value="${securityForm.getAuthToken()}" />

<!-- 複数の hidden フィールド -->
<input type="hidden" name="timestamp" value="${auditForm.getTimestamp()}" />
<input type="hidden" name="version" value="${versionForm.getVersion()}" />

<!-- フォーム内での hidden フィールド -->
<html:form action="/submit">
  <input type="hidden" name="formId" value="${submitForm.getFormId()}" />
  <input type="hidden" name="created" value="${submitForm.getCreated()}" />
</html:form>

<!-- ネストされたコンテキストでの hidden フィールド -->
<c:if test="${user.getIsAdmin() == 'true'}">
  <input type="hidden" name="adminKey" value="${adminForm.getAdminKey()}" />
  <c:forEach var="permission" items="${permissionList}">
    <input type="hidden" name="permissionId" value="${permission.getPermissionId()}" />
  </c:forEach>
</c:if>

<!-- スタイルクラス付きのselect -->
<select name="category" class="form-select">
  <option value="1">1</option>
  <option value="2">2</option>
  <option value="3">3</option>
</select>

<!-- styleId付きのselect -->
<select name="region" id="regionSelect">
  <option value="north" >
  <option value="south" >
  <option value="east" >
  <option value="west" >
</select>

<!-- すべての属性を組み合わせたselect -->
<select
  name="productType"
  class="custom-select"
  id="productTypeSelect">
  <option value="A" disabled${ 'A' == productForm.getProductType() ? ' selected' : '' }>A</option>
  <option value="B"${ 'B' == productForm.getProductType() ? ' selected' : '' }>B</option>
  <option value="C"${ 'C' == productForm.getProductType() ? ' selected' : '' }>C</option>
</select>

<!-- 属性の順序を変えたselect -->
<select
  id="orderSelect"
  class="order-select"
  name="orderType">
  <option value="standard"${ 'standard' == orderForm.getOrderType() ? ' selected' : '' }>
  <option value="express"${ 'express' == orderForm.getOrderType() ? ' selected' : '' }>
  <option value="priority"${ 'priority' == orderForm.getOrderType() ? ' selected' : '' }>
</select>

<!-- 大量のoptionを持つselect -->
<select name="number" class="number-select">
  <option value="1" >
  <option value="2" >
  <option value="3" >
  <option value="4" >
  <option value="5" >
  <option value="6" >
  <option value="7" >
  <option value="8" >
  <option value="9" >
  <option value="10" >
</select>

<!-- name属性とselectした値の組み合わせテスト -->
<select name="selectedValue">
  <option value="active"${ 'active' == userForm.getSelectedValue() ? ' selected' : '' }>
  <option value="inactive"${ 'inactive' == userForm.getSelectedValue() ? ' selected' : '' }>
  <option value="pending"${ 'pending' == userForm.getSelectedValue() ? ' selected' : '' }>
</select>

<!-- html:options タグのテスト -->
<h2>HTML Options Tests</h2>

<!-- 基本的な使用例（collection使用） -->
<select name="selectedItem">
  <options collection="itemList" property="id" labelProperty="name" >
</select>

<!-- name/property使用 -->
<select name="selectedDepartment">
  <options
    name="departmentForm"
    property="departments"
    labelProperty="departmentName"
  >
</select>

<!-- labelName使用 -->
<select name="selectedProduct">
  <options
    collection="productList"
    property="productId"
    labelName="productLabels"
    labelProperty="label"
  >
</select>

<!-- 複合的な使用例 -->
<select name="selectedOption" class="custom-select">
  <options
    name="optionForm"
    property="availableOptions"
    labelProperty="displayName"
  >
</select>

<!-- collection属性のみ -->
<select name="simpleSelection">
  <options collection="simpleList" >
</select>

<!-- すべての属性を使用 -->
<select name="complexSelection">
  <options
    name="complexForm"
    property="items"
    labelName="labelContainer"
    labelProperty="displayLabel"
    collection="itemCollection"
  >
</select>

<!-- ネストされたコンテキストでの使用 -->
<c:forEach var="category" items="${categoryList}">
  <select name="categorySelection">
    <options
      name="category"
      property="subItems"
      labelProperty="subItemName"
    >
  </select>
</c:forEach>

<!-- フォーム内での使用 -->
<html:form action="/submit">
  <select name="formSelection">
    <options
      collection="formOptions"
      property="optionValue"
      labelProperty="optionLabel"
    >
  </select>
</html:form>

<!-- Dot notation conversion tests -->
<h2>Dot Notation Tests</h2>

<!-- bean:write with nested dots -->
${form_user_details.getName()}
${sessionScope.company_department_manager.getEmail()}
<c:out value="${system_config_settings.getValue()}" escapeXml="true" />

<!-- logic:equal with nested dots -->
<c:if test="${form_user_settings.getEnabled() == 'true'}">
  <div>Settings enabled</div>
</c:if>

<c:if test="${app_user_preferences.getTheme() != 'dark'}">
  <div>Not using dark theme</div>
</c:if>

<!-- logic:iterate with nested dots -->
<c:forEach var="item" items="${shop_cart_items.getProducts()}">
  ${item.getName()}
</c:forEach>

<!-- html form elements with nested dots -->
<input type="text" name="firstName" value="${form_user_profile.getFirstName()}" >
<input type="hidden" name="orderId" value="${checkout_order_details.getOrderId()}" />

<!-- bean:define with nested dots -->
<c:set var="userProfile" value="${form_user_profile.getDetails()}"/>

<!-- Complex nested structures with dots -->
<c:if test="${company_department_team.getActive() == 'true'}">
  <c:forEach var="member" items="${company_department_team_members.getList()}">
    ${member_profile.getName()}
  </c:forEach>
</c:if>

<!-- Multiple dots in different positions -->
${app_config.getVersion()}
${user_profile_settings.getTheme()}
${system_app_user_preferences.getLanguage()}

<!-- Combination of dots and other features -->
<c:forEach var="item" items="${store_inventory_items}" varStatus="idx">
  <div class="item">
    Item ${idx.index + 1}:
    ${item_details.getName()}
  </div>
</c:forEach>

<!-- html:radio タグのテスト -->
<h2>HTML Radio Tests</h2>

<!-- 基本的なラジオボタン -->
<input type="radio" name="gender" value="male" >
<input type="radio" name="gender" value="female" >

<!-- name属性付きのラジオボタン -->
<input type="radio" name="subscriptionType" value="free" <c:if test="${userForm.getSubscriptionType() == 'free'}"> checked</c:if>>
<input type="radio" name="subscriptionType" value="premium" <c:if test="${userForm.getSubscriptionType() == 'premium'}"> checked</c:if>>

<!-- スタイル属性付きのラジオボタン -->
<input type="radio"
  name="theme"
  value="light"
  class="radio-input"
  id="lightTheme"
<c:if test="${preferenceForm.getTheme() == 'light'}"> checked</c:if>>
<input type="radio"
  value="dark"
  class="radio-input"
  name="theme"
  id="darkTheme"
<c:if test="${preferenceForm.getTheme() == 'dark'}"> checked</c:if>>

<!-- 無効化状態のラジオボタン -->
<input type="radio"
  name="notifications"
  value="enabled"
  disabled="true"
<c:if test="${settingsForm.getNotifications() == 'enabled'}"> checked</c:if>>

<!-- クリックイベント付きのラジオボタン -->
<input type="radio"
  value="advanced"
  name="mode"
  onclick="handleModeChange()"
<c:if test="${configForm.getMode() == 'advanced'}"> checked</c:if>>

<!-- すべての属性を組み合わせたラジオボタン -->
<input type="radio"
  name="option"
  value="special"
  class="custom-radio"
  id="specialOption"
  disabled="false"
  onclick="handleOptionSelect()"
<c:if test="${complexForm.getOption() == 'special'}"> checked</c:if>>

<!-- ネストされたコンテキストでのラジオボタン -->
<c:forEach var="option" items="${optionList}">
  <input type="radio"
    name="selectedOption"
    value="${option}"
    class="option-radio"
  <c:if test="${selectionForm.getSelectedOption() == ${option}}"> checked</c:if>>
</c:forEach>

<!-- フォーム内での使用 -->
<html:form action="/submit">
  <div class="radio-group">
    <input type="radio" name="agreement" value="accept" > 同意する
    <input type="radio" name="agreement" value="decline" > 同意しない
  </div>
</html:form>

<!-- 属性の順序を変えたラジオボタン -->
<input type="radio"
  class="order-radio"
  value="test"
  name="orderTest"
  onclick="handleClick()"
<c:if test="${orderForm.getOrderTest() == 'test'}"> checked</c:if>>

<!-- Dot notation を使用したラジオボタン -->
<input type="radio"
  name="receiveEmails"
  value="yes"
  class="preference-radio"
<c:if test="${form_user_preferences.getReceiveEmails() == 'yes'}"> checked</c:if>>

<!-- html:options の詳細テストケース -->
<h2>Detailed HTML Options Tests</h2>

<!-- スコープ指定のテスト -->
<select name="selectedItem">
  <options
    name="items"
    property="availableItems"
    labelProperty="itemName"
    scope="session"
  >
</select>

<select name="selectedDept">
  <options
    name="departments"
    property="list"
    labelProperty="deptName"
    scope="application"
  >
</select>

<select name="selectedUser">
  <options
    name="users"
    property="activeUsers"
    labelProperty="userName"
    scope="request"
  >
</select>

<!-- 入れ子構造のテスト -->
<c:forEach var="category" items="${categoryList}">
  <select name="subCategory">
    <options name="category" property="items" labelProperty="itemName" >
  </select>
</c:forEach>

<!-- Dot notation のテスト -->
<select name="selectedItem">
  <options
    name="form.master.items"
    property="available.items"
    labelProperty="item.name"
  >
</select>

<!-- 複合的なテスト -->
<c:if test="${user.getRole() == 'admin'}">
  <select name="adminSelection">
    <options
      name="admin.settings"
      property="available.options"
      labelName="admin.labels"
      labelProperty="display.name"
      scope="session"
    >
  </select>
</c:if>

<!-- collection と labelName の組み合わせ -->
<select name="productSelect">
  <options
    collection="product.list"
    labelName="product.labels"
    labelProperty="name.localized"
  >
</select>

<!-- すべての組み合わせ -->
<select name="complexSelect">
  <options
    name="form.data"
    property="items.list"
    labelName="form.labels"
    labelProperty="display.name"
    collection="data.collection"
    scope="request"
  >
</select>


<c:if test="${form.getAge() >= 20}"></c:if>
    成人です
</c:if>

<html>
<head>
    <title>Logic Greater Equal Test Patterns</title>
</head>
<body>
    <!-- 1. 基本パターン -->
    <c:if test="${form.getAge() >= 20}">
        成人です
    </c:if>

    <!-- 2. スコープ指定あり -->
    <c:if test="${sessionScope.form.getAge() >= 20}">
        成人です（セッションスコープ）
    </c:if>

    <!-- 3. プロパティなし、name属性のみ -->
    <c:if test="${age >= 20}">
        成人です（直接参照）
    </c:if>

    <!-- 4. 小数値との比較 -->
    <c:if test="${form.getTemperature() >= 36.5}">
        平熱以上です
    </c:if>

    <!-- 5. マイナス値との比較 -->
    <c:if test="${form.getTemperature() >= -10}">
        氷点下ではありません
    </c:if>

    <!-- 6. 空白を含むコンテンツ -->
    <c:if test="${form.getScore() >= 80}">
        
        合格です
        
    </c:if>
</body>
</html>