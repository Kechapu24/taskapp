<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>アカウント情報</title>
</head>
<body>

<h2>アカウント情報</h2>

<h3>モード切替</h3>

<form action="${pageContext.request.contextPath}/switchOrg" method="post">

    <select name="orgId">
        <option value="">個人モード</option>
        <c:forEach var="org" items="${sessionScope.orgList}">
            <option value="${org.orgId}"
                <c:if test="${org.orgId == sessionScope.activeOrgId}">selected</c:if>>
                ${org.orgName}
            </option>
        </c:forEach>
    </select>

    <button type="submit">切り替え</button>

</form>

<hr>

<form action="${pageContext.request.contextPath}/logout" method="post">
    <button type="submit">ログアウト</button>
</form>

</body>
</html>