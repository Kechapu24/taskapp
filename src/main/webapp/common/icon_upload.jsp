<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%--
  アイコン画像の設定フォーム。account.jsp の中に置く:
      <jsp:include page="/common/icon_upload.jsp" />
  UploadIconServlet が ?iconResult=... を付けて account.jsp に戻してくる。
--%>
<c:if test="${not empty loginUser}">
	<link rel="stylesheet"
		href="${pageContext.request.contextPath}/css/user_badge.css">

	<section class="icon-upload">
		<h3>プロフィール画像</h3>

		<c:choose>
			<c:when test="${param.iconResult == 'ok'}">
				<p class="icon-upload__msg icon-upload__msg--ok">画像を更新しました。</p>
			</c:when>
			<c:when test="${param.iconResult == 'deleted'}">
				<p class="icon-upload__msg icon-upload__msg--ok">画像を削除しました。</p>
			</c:when>
			<c:when test="${param.iconResult == 'empty'}">
				<p class="icon-upload__msg icon-upload__msg--ng">ファイルを選択してください。</p>
			</c:when>
			<c:when test="${param.iconResult == 'invalid'}">
				<p class="icon-upload__msg icon-upload__msg--ng">PNG / JPEG / GIF /
					WebP の画像を選んでください。</p>
			</c:when>
			<c:when test="${param.iconResult == 'toolarge'}">
				<p class="icon-upload__msg icon-upload__msg--ng">画像は2MB以下にしてください。</p>
			</c:when>
		</c:choose>

		<div class="icon-upload__row">
			<span class="avatar avatar--lg"
				style="--h:${(loginUser.userId * 67) % 360}"> <c:choose>
					<c:when test="${loginUser.iconSet}">
						<img
							src="${pageContext.request.contextPath}/icon?userId=${loginUser.userId}"
							alt="現在のプロフィール画像">
					</c:when>
					<c:otherwise>
						<c:out value="${fn:substring(loginUser.userName, 0, 1)}" />
					</c:otherwise>
				</c:choose>
			</span>
			<div>
				<form action="${pageContext.request.contextPath}/uploadIcon"
					method="post" enctype="multipart/form-data">
					<input type="file" name="icon"
						accept="image/png,image/jpeg,image/gif,image/webp" required>
					<button type="submit">アップロード</button>
				</form>
				<p class="icon-upload__note">PNG / JPEG / GIF / WebP、2MBまで</p>
			</div>
		</div>

		<c:if test="${loginUser.iconSet}">
			<form action="${pageContext.request.contextPath}/uploadIcon"
				method="post">
				<input type="hidden" name="action" value="delete">
				<button type="submit">画像を削除する</button>
			</form>
		</c:if>
	</section>
</c:if>
