<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="../../css/Higashi.css">
<title>資料 開発演習 個人ページ</title>
</head>
<body>
	<div class="page-layout">
		<aside class="side-menu">
			<h1>Higashi</h1>
			<p>個人ページ</p>

			<nav>
				<a href="Higashi.jsp">トップページ</a> <a href="report.jsp">作業報告</a> <a
					href="works.jsp">成果物</a> <a href="docs.jsp" class="active">資料</a>
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
				<h1>資料</h1>
			</header>
			<p>システム開発演習で制作した資料をまとめています</p>

			<div class="filter-menu">
				<button class="filter-btn active" data-filter="all">すべて</button>
				<button class="filter-btn" data-filter="requirements">要件定義</button>
				<button class="filter-btn" data-filter="sitemap">サイトマップ</button>
				<button class="filter-btn" data-filter="database">DB設計</button>
				<button class="filter-btn" data-filter="screen">画面設計</button>
				<button class="filter-btn" data-filter="manual">マニュアル</button>
			</div>

			<div class="card-grid">

				<div class="work-card" data-category="requirements">
					<span class="category-label">要件定義</span>
					<h3>要件定義書</h3>
					<p>システムの目的、機能要件、非機能要件、業務フローなどをまとめた資料です。</p>
					<p class="meta">
						更新日：2026/06/04<br>形式：Googleドキュメント
					</p>
					<a href="GoogleドキュメントのURL" target="_blank" class="card-link">資料を見る</a>
				</div>

				<div class="work-card" data-category="sitemap">
					<span class="category-label">サイトマップ</span>
					<h3>サイトマップ</h3>
					<p>Webサイトの構成やページ間の関係性を整理した資料です。</p>
					<p class="meta">
						更新日：2026/06/04<br>形式：画像
					</p>
					<a href="画像のURL" target="_blank" class="card-link">画像を見る</a>
				</div>

				<div class="work-card" data-category="database">
					<span class="category-label">DB設計</span>
					<h3>DB設計資料</h3>
					<p>タスク、プロジェクト、ユーザー、コメントなどのテーブル構成をまとめた資料です。</p>
					<p class="meta">
						更新日：2026/06/11<br>形式：Googleドキュメント
					</p>
					<a href="GoogleドキュメントのURL" target="_blank" class="card-link">資料を見る</a>
				</div>

				<div class="work-card" data-category="screen">
					<span class="category-label">画面設計</span>
					<h3>タスクボード画面</h3>
					<p>タスクを状態ごとに表示し、詳細確認や編集ができる画面です。</p>
					<p class="meta">
						更新日：2026/06/17<br>形式：画像
					</p>
					<a href="画像のURL" target="_blank" class="card-link">画面を見る</a>
				</div>

				<div class="work-card" data-category="manual">
					<span class="category-label">マニュアル</span>
					<h3>DB連携マニュアル</h3>
					<p>JSPからPostgreSQLへ接続し、データを取得して表示する手順をまとめました。</p>
					<p class="meta">
						更新日：2026/06/18<br>形式：Googleドキュメント
					</p>
					<a href="GoogleドキュメントのURL" target="_blank" class="card-link">マニュアルを見る</a>
				</div>

			</div>

		</main>

	</div>

	<script>
		const filterButtons = document.querySelectorAll(".filter-btn");
		const workCards = document.querySelectorAll(".work-card");

		filterButtons.forEach(function(button) {
			button.addEventListener("click", function() {
				const filter = button.dataset.filter;

				filterButtons.forEach(function(btn) {
					btn.classList.remove("active");
				});

				button.classList.add("active");

				workCards.forEach(function(card) {
					const category = card.dataset.category;

					if (filter === "all" || filter === category) {
						card.style.display = "block";
					} else {
						card.style.display = "none";
					}
				});
			});
		});
	</script>
	
</body>
</html>