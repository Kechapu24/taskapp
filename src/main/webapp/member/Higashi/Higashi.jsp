<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="css/Higashi.css">
<title>開発演習 個人ページ</title>
</head>
<body>
	<div class="page-layout">
		<aside class="side-menu">
			<h1>Higashi</h1>
			<p>個人ページ</p>

			<nav>
				<a href="Higashi.jsp" class="active">トップページ</a> <a href="report.jsp">作業報告</a>
				<a href="works.jsp">成果物</a> <a href="docs.jsp">資料</a>
			</nav>

			<section>
				<p class="title">プロフィール</p>
				<p>東 辰賢</p>
				<p>専門学校湖東カレッジ</p>
				<p>IT経済学科</p>
				<p class="space">SEコース</p>
				<p>Java / JSP / HTML / CSS / JavaScript / PostgreSQL / Tomcat /
					Apache / Github / Git / Alumalinux / Hyper-V</p>
			</section>

			<a href="../../index.jsp" class="task_app">タスク管理アプリ</a>
		</aside>

		<main class="main-content">

			<header>
				<h1>システム開発演習 個人ページ</h1>
			</header>
			<section class="top-section">
				<h2>このページについて</h2>
				<p>このページでは、システム開発演習で取り組んだ作業内容や、 担当した成果物、作成した資料をまとめています。
					タスク管理アプリの開発を通して行った設計・実装・環境構築について確認できます。</p>
			</section>

			<section class="top-section">
				<h2>担当した内容</h2>
				<p>システム開発演習では、主にタスクボード画面の開発、DB設計、 環境構築、要件設計資料の作成に取り組みました。
					特に、DBと連携するタスクボード画面では、タスクカード表示、
					詳細モーダル、編集モーダル、期限が近いタスクの強調表示などを実装しました。</p>
			</section>

			<section class="top-section">
				<h2>使用した技術</h2>
				<p>Java、JSP、HTML、CSS、JavaScript、PostgreSQL、Apache、Tomcat、
					GitHub、Git、AlmaLinux、Hyper-V </p>
			</section>

			<section class="top-section">
				<h2>ページ一覧</h2>

				<div class="top-card-grid">
					<a href="report.jsp" class="top-card">
						<h3>作業報告</h3>
						<p>日付ごとの作業内容をまとめています。</p>
					</a> <a href="works.jsp" class="top-card">
						<h3>成果物</h3>
						<p>担当した実装機能やDB設計、環境構築についてまとめています。</p>
					</a> <a href="docs.jsp" class="top-card">
						<h3>資料</h3>
						<p>要件定義書、設計資料、マニュアルなどをまとめています。</p>
					</a> <a href="../../index.jsp" class="top-card">
						<h3>タスク管理アプリ</h3>
						<p>チームで開発したタスク管理アプリのページへ移動します。</p>
					</a>
				</div>
			</section>
		</main>

	</div>
</body>
</html>