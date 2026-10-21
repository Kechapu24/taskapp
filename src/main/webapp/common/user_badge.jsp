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

		<a class="user-badge__trigger"
			href="${pageContext.request.contextPath}/account.jsp"
			aria-describedby="userBadgeCard"> <span class="avatar avatar--sm"
			style="--h:${(loginUser.userId * 67) % 360}"> <c:choose>
					<c:when test="${loginUser.iconSet}">
						<img
							src="${pageContext.request.contextPath}/icon?userId=${loginUser.userId}"
							alt="">
					</c:when>
					<c:otherwise>
						<c:out value="${fn:substring(loginUser.userName, 0, 1)}" />
					</c:otherwise>
				</c:choose>
		</span> <span class="user-badge__name"><c:out
					value="${loginUser.userName}" /></span>
		</a>

		<div class="user-badge__card" id="userBadgeCard" role="tooltip">
			<div class="user-badge__card-inner">

				<div class="user-badge__card-head">
					<span class="avatar avatar--lg"
						style="--h:${(loginUser.userId * 67) % 360}"> <c:choose>
							<c:when test="${loginUser.iconSet}">
								<img
									src="${pageContext.request.contextPath}/icon?userId=${loginUser.userId}"
									alt="">
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
				</dl>

				<a class="user-badge__card-link"
					href="${pageContext.request.contextPath}/account.jsp">アカウント情報を開く</a>
			</div>
		</div>
	</div>

	<%-- ホバーカードを「ユーザーボタンのすぐ右・画面の下から少し上」に出す。
	     カードは position: fixed(画面基準)なので、サイドバーの
	     overflow に切り取られず、サイドバーの外に表示できる。 --%>
	<script>
	(function () {
	    var badge = document.querySelector('.user-badge');
	    if (!badge) { return; }
	    var card = badge.querySelector('.user-badge__card');

	    function placeCard() {
	        var r = badge.getBoundingClientRect();
	        card.style.left = r.right + 'px';
	        card.style.bottom = (window.innerHeight - r.bottom + 12) + 'px'; // 画面の下端にくっつかないよう12px上げる
	    }

	    badge.addEventListener('mouseenter', placeCard);
	    badge.addEventListener('focusin', placeCard); // Tabキーで来たとき
	    window.addEventListener('resize', placeCard);
	})();
	</script>
</c:if>



