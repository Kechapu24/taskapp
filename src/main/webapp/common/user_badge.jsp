<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%--
  サイドバー下部の「ユーザーボタン」。アイコンと名前を表示し、
  マウスを乗せると、サイドバーの右側にユーザー情報のカードが出る。

  使い方(sidebar.jsp の最下部に置く):
      <div class="sidebar-user">
          <jsp:include page="/common/user_badge.jsp" />
      </div>

  前提: セッションに loginUser / orgList / activeOrgId が入っていること(LoginServletが設定)。
  ※ password は絶対に表示しない。
--%>
<c:if test="${not empty loginUser}">

	<%-- いま選択中の団体を、orgList から探す(無ければ「個人モード」) --%>
	<c:set var="activeOrgName" value="" />
	<c:set var="activeOrgRole" value="" />
	<c:forEach items="${orgList}" var="o">
		<c:if test="${o.orgId == activeOrgId}">
			<c:set var="activeOrgName" value="${o.orgName}" />
			<c:set var="activeOrgRole" value="${o.orgRole}" />
		</c:if>
	</c:forEach>

	<link rel="stylesheet"
		href="${pageContext.request.contextPath}/css/user_badge.css">

	<div class="user-badge">

		<!-- ユーザーボタン（左下の固定部分） -->
		<a class="user-badge__trigger"
			href="${pageContext.request.contextPath}/account.jsp"
			aria-describedby="userBadgeCard">
			<span class="avatar avatar--sm" style="--h: ${(loginUser.userId * 67) % 360};">
				<c:choose>
					<c:when test="${loginUser.iconSet}">
						<img src="${pageContext.request.contextPath}/icon?userId=${loginUser.userId}" alt="">
					</c:when>
					<c:otherwise>
						<c:out value="${fn:substring(loginUser.userName, 0, 1)}" />
					</c:otherwise>
				</c:choose>
			</span>
			<span class="user-badge__name"><c:out value="${loginUser.userName}" /></span>
		</a>

		<!-- ホバーカード（マウスを乗せると右側に現れる） -->
		<div class="user-badge__card" id="userBadgeCard" role="tooltip">
			<div class="user-badge__card-inner">

				<div class="user-badge__card-head">
					<span class="avatar avatar--lg" style="--h: ${(loginUser.userId * 67) % 360};">
						<c:choose>
							<c:when test="${loginUser.iconSet}">
								<img src="${pageContext.request.contextPath}/icon?userId=${loginUser.userId}" alt="">
							</c:when>
							<c:otherwise>
								<c:out value="${fn:substring(loginUser.userName, 0, 1)}" />
							</c:otherwise>
						</c:choose>
					</span>
					<div>
						<div class="user-badge__card-name">
							<c:out value="${loginUser.userName}" />
						</div>
						<div class="user-badge__card-email">
							<c:out value="${loginUser.email}" />
						</div>
					</div>
				</div>


				<dl class="user-badge__list">
					<dt>システム権限</dt>
					<dd>
						<c:choose>
							<c:when test="${loginUser.admin}">システム管理者</c:when>
							<c:otherwise>一般メンバー</c:otherwise>
						</c:choose>
					</dd>

					<dt>現在のモード</dt>
					<dd>
						<c:choose>
							<c:when test="${not empty activeOrgName}">
								<c:out value="${activeOrgName}" />
								(<c:choose>
									<c:when test="${activeOrgRole == 'admin'}">団体の管理者</c:when>
									<c:otherwise>団体メンバー</c:otherwise>
								</c:choose>)
							</c:when>
							<c:otherwise>個人モード</c:otherwise>
						</c:choose>
					</dd>
									<!-- ▼▼ 団体切り替えフォーム ▼▼ -->
				<div class="org-switcher" style="margin: 15px 0; padding-top: 15px; border-top: 1px solid #eee;">
					<form action="${pageContext.request.contextPath}/switchOrg" method="post">
						<label for="orgSelect" style="display: block; font-size: 16px; color: #666; margin-bottom: 6px; font-weight: bold;">作業する団体:</label>
						<select name="orgId" id="orgSelect" onchange="this.form.submit()" style="width: 100%; padding: 10px; border-radius: 8px; border: 1px solid #d0d7de; font-size: 16px; background: #f6f8fa; cursor: pointer;">
							<!-- 個人モード -->
							<option value="0" ${empty activeOrgId ? 'selected' : ''}>個人モード</option>
							
							<!-- 所属団体の一覧ループ -->
							<c:forEach var="org" items="${orgList}">
								<option value="${org.orgId}" ${activeOrgId == org.orgId ? 'selected' : ''}>
									<c:out value="${org.orgName}" /> (${org.orgRole})
								</option>
							</c:forEach>
						</select>
					</form>
				</div>
				<!-- ▲▲ 団体切り替えフォームここまで ▲▲ -->
					
				</dl>

				<a class="user-badge__card-link"
					href="${pageContext.request.contextPath}/account.jsp">アカウント情報を開く</a>
				<div style="margin-top: 10px; text-align: center;">
					<a href="${pageContext.request.contextPath}/logout" style="color: #d9534f; text-decoration: none; font-weight: bold;">ログアウト</a>
				</div>
			</div>
		</div>
	</div>

	<%-- ホバーカードの位置を計算して綺麗に表示するスクリプト --%>
	<script>
	(function () {
	    var badge = document.querySelector('.user-badge');
	    if (!badge) { return; }
	    var card = badge.querySelector('.user-badge__card');

	    function placeCard() {
	        var r = badge.getBoundingClientRect();
	        card.style.left = r.right + 'px';
	        card.style.bottom = (window.innerHeight - r.bottom + 12) + 'px'; // 画面下端から12px上げる
	    }

	    badge.addEventListener('mouseenter', placeCard);
	    badge.addEventListener('focusin', placeCard);
	    window.addEventListener('resize', placeCard);
	})();
	</script>
</c:if>