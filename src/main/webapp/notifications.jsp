<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>タスク管理アプリ</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>

	<%
	request.setAttribute("pageTitle", "通知センター");
	request.setAttribute("currentPage", "notifications");
	%>

	<div class="app-container">

		<%@ include file="common/sidebar.jsp"%>

		<main class="main-content">

			<%@ include file="common/header.jsp"%>

			<div class="content-body">

				<div class="notification-item unread">
					<!-- 期限が近い通知 -->
					<div class="notification-item unread">
						<span class="notification-dot"></span>

						<div class="notification-content">

							<div class="notification-title">期限が近づいています</div>

							<div class="notification-task">タスク：ログイン機能実装</div>

							<div class="notification-project">プロジェクト：タスク管理アプリ</div>

							<div class="notification-detail">期限まであと1日です。早めに対応してください。</div>

							<div class="notification-date">2026/06/17 09:00</div>

						</div>
					</div>


					<!-- 期限切れ通知 -->
					<div class="notification-item unread">
						<span class="notification-dot"></span>

						<div class="notification-content">

							<div class="notification-title">期限を過ぎています</div>

							<div class="notification-task">タスク：データベース設計</div>

							<div class="notification-project">プロジェクト：タスク管理アプリ</div>

							<div class="notification-detail">
								このタスクは期限を過ぎています。対応状況を確認してください。</div>

							<div class="notification-date">2026/06/17 08:30</div>

						</div>
					</div>
					<span class="notification-dot"></span>

					<div class="notification-content">
						<div class="notification-title">メンションされました</div>

						<div class="notification-task">タスク：ログイン機能実装</div>

						<div class="notification-project">プロジェクト：タスク管理アプリ</div>

						<div class="notification-detail">坂田さんがあなたをメンションしました</div>

						<div class="notification-date">2026/06/17 10:30</div>
					</div>
				</div>

			</div>

			<%@ include file="common/footer.jsp"%>
			
			<script>

function showNotification(message){

    const toast =
        document.getElementById("toastNotification");

    toast.innerText = message;

    toast.style.display = "block";

    setTimeout(() => {
        toast.style.display = "none";
    }, 3000);
}



// テスト用
showNotification("メンションされました");

</script>

		</main>

	</div>
	<div id="toastNotification" class="toast">メンションされました</div>
</body>
</html>
