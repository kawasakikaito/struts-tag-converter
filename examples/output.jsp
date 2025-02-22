<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!-- html:text タグのテスト -->
<h2>HTML Text Tests</h2>
<input type="text" name="username">
<input type="text" name="firstName" size="30" id="firstNameInput" maxlength="50" class="form-control">
<input type="text" name="email" value="${userForm.getEmail()}" id="emailField" class="input-text">
<input type="text" name="phoneNumber" size="20" id="phone" maxlength="15">
<input type="text" name="zipCode" value="${addressForm.getZipCode()}" size="10" id="zip" maxlength="10" class="zip-input">

<!-- bean:write タグのテスト -->
<h2>Bean Write Tests</h2>
${user.getFullName()}
${sessionScope.account.getBalance()}
<c:out value="${settings.getTheme()}" escapeXml="true" />
${notification.getEmailEnabled()}
<c:out value="${requestScope.user.getLastLogin()}" escapeXml="false" />

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
<c:forEach var="user" items="${requestScope.userList}">
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
    ${product.getName()}<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!-- html:text タグのテスト -->
<h2>HTML Text Tests</h2>
<input type="text" name="username">
<input type="text" name="firstName" size="30" id="firstNameInput" maxlength="50" class="form-control">
<input type="text" name="email" value="${userForm.getEmail()}" id="emailField" class="input-text">
<input type="text" name="phoneNumber" size="20" id="phone" maxlength="15">
<input type="text" name="zipCode" value="${addressForm.getZipCode()}" size="10" id="zip" maxlength="10" class="zip-input">

<!-- bean:write タグのテスト -->
<h2>Bean Write Tests</h2>
${user.getFullName()}
${sessionScope.account.getBalance()}
<c:out value="${settings.getTheme()}" escapeXml="true" />
${notification.getEmailEnabled()}
<c:out value="${requestScope.user.getLastLogin()}" escapeXml="false" />

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
<c:forEach var="user" items="${requestScope.userList}">
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
<c:out value="${user.getRawHTML()}" escapeXml="false" />
${user.getOptionalField()}

<!-- Attribute Order Tests -->
<h2>Attribute Order Tests</h2>
<c:if test="${user.getIsActive() == 'true'}">
  <div>順序が異なるロジックタグ</div>
</c:if>

<c:if test="${sessionScope.user.getAccountType() != 'guest'}">
  <div>順序が異なるロジックタグ（スコープ付き）</div>
</c:if>
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
<c:out value="${user.getRawHTML()}" escapeXml="false" />
${user.getOptionalField()}

<!-- Attribute Order Tests -->
<h2>Attribute Order Tests</h2>
<c:if test="${user.getIsActive() == 'true'}">
  <div>順序が異なるロジックタグ</div>
</c:if>

<c:if test="${sessionScope.user.getAccountType() != 'guest'}">
  <div>順序が異なるロジックタグ（スコープ付き）</div>
</c:if>