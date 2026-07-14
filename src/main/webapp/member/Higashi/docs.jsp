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
				<button class="filter-btn" data-filter="planning">企画・構成</button>
				<button class="filter-btn" data-filter="database">DB設計</button>
				<button class="filter-btn" data-filter="screen">画面設計</button>
				<button class="filter-btn" data-filter="manual">マニュアル</button>
			</div>

			<div class="card-grid">

				<div class="work-card" data-category="planning">
					<span class="category-label">企画・構成</span>
					<h3>要件定義書</h3>
					<p>システムの目的、機能要件、非機能要件、業務フローなどをまとめた資料です。</p>
					<p class="meta">
						更新日：2026/06/04<br>形式：Googleドキュメント
					</p>
					<a href="GoogleドキュメントのURL" target="_blank" class="card-link">資料を見る</a>
				</div>

				<div class="work-card" data-category="planning">
					<span class="category-label">企画・構成 </span>
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
						更新日：2026/06/11<br>形式：Googleドキュメント・画像
					</p>
					<a
						href="https://docs.google.com/document/d/18JocBzKV1NvO4i1Fk5y7DczQ5QyGgMpbzW-w6hjGvtg/edit?tab=t.0"
						target="_blank" class="card-link">資料を見る</a> <a
						href="img/DB設計図_ERD.png" target="_blank" class="card-link">画像を見る</a>
				</div>

				<div class="work-card" data-category="screen">
					<span class="category-label">画面設計</span>
					<h3>タスクボード画面</h3>
					<p>タスクを状態ごとに表示し、詳細確認や編集ができる画面です。</p>
					<p class="meta">
						更新日：2026/06/17<br>形式：画像
					</p>
					<a href="img/タスクボード画面設計AI.png" target="_blank" class="card-link">画面を見る</a>
					<a href="img/タスクボード画面設計.jpeg" target="_blank" class="card-link">画面を見る</a>
				</div>

				<div class="work-card" data-category="manual">
					<span class="category-label">マニュアル</span>
					<h3>DB連携マニュアル</h3>
					<p>JSPからPostgreSQLへ接続し、データを取得して表示する手順をまとめました。</p>
					<p class="meta">
						更新日：2026/06/18<br>形式：Googleドキュメント
					</p>
					<a
						href="https://docs.google.com/document/d/1GbtfcZ_ujy8cuBMa1MbV_9eSQ083WbBSeeKhQOtI11Q/edit?tab=t.989reewvcl8w"
						target="_blank" class="card-link">マニュアルを見る</a>
				</div>

				<div class="work-card" data-category="manual">
					<span class="category-label">マニュアル</span>
					<h3>デプロイマニュアル</h3>
					<p>AlmaLinux上でGitHubのファイルをTomcatに反映する手順をまとめました。</p>
					<p class="meta">
						更新日：2026/06/18<br>形式：Googleドキュメント
					</p>
					<a
						href="https://docs.google.com/document/d/1GbtfcZ_ujy8cuBMa1MbV_9eSQ083WbBSeeKhQOtI11Q/edit?tab=t.jtkxe2u9i6cq"
						target="_blank" class="card-link">マニュアルを見る</a>
				</div>

				<div class="work-card" data-category="manual">
					<span class="category-label">マニュアル</span>
					<h3>Github・Eclipse連携マニュアル</h3>
					<p>GitHubのデータをプロジェクトとしてEclipseにインポートする手順をまとめました。</p>
					<p class="meta">
						更新日：2026/06/18<br>形式：Googleドキュメント
					</p>
					<a
						href="https://docs.google.com/document/d/1GbtfcZ_ujy8cuBMa1MbV_9eSQ083WbBSeeKhQOtI11Q/edit?tab=t.vqqxls94r4fa#heading=h.24dfz4dggf0z"
						target="_blank" class="card-link">マニュアルを見る</a>
				</div>

				<div class="work-card" data-category="manual">
					<span class="category-label">マニュアル</span>
					<h3>Linux頻出コマンドマニュアル</h3>
					<p>AlmaLinuxで何度も使ったコマンドをまとめました。</p>
					<p class="meta">
						更新日：2026/06/18<br>形式：Googleドキュメント
					</p>
					<a
						href="https://docs.google.com/document/d/1GbtfcZ_ujy8cuBMa1MbV_9eSQ083WbBSeeKhQOtI11Q/edit?tab=t.1lee12d3vatq#heading=h.7i3m6o78zena"
						target="_blank" class="card-link">マニュアルを見る</a>
				</div>

				<div class="work-card" data-category="manual">
					<span class="category-label">マニュアル</span>
					<h3>開発環境構築マニュアル</h3>
					<p>
						以下のURL参照した手順で仮想マシンからサーバー設定、プログラミング言語、DBの設定までをまとめています<br>
						http://172.16.1.200/sd/environment-setup_b.html
					</p>
					<p class="meta">
						更新日：2026/06/18<br>形式：Googleドキュメント
					</p>
					<a
						href="https://docs.google.com/document/d/1GbtfcZ_ujy8cuBMa1MbV_9eSQ083WbBSeeKhQOtI11Q/edit?tab=t.0#heading=h.14okyaorbmez"
						target="_blank" class="card-link">マニュアルを見る</a>
				</div>

				<div class="work-card" data-category="manual">
					<span class="category-label">マニュアル</span>
					<h3>Spring Bootプログラムマニュアル</h3>
					<p>今回の開発では使いませんでしたが、Maven,Git,Spring Bootのプロジェクトを設定する手順をまとめました。</p>
					<p class="meta">
						更新日：2026/06/18<br>形式：Googleドキュメント
					</p>
					<a
						href="https://docs.google.com/document/d/1GbtfcZ_ujy8cuBMa1MbV_9eSQ083WbBSeeKhQOtI11Q/edit?tab=t.8w6ulz832dm2#heading=h.hxso464jqmnb"
						target="_blank" class="card-link">マニュアルを見る</a>
				</div>

				<div class="work-card" data-category="screen">
					<span class="category-label">画面設計</span>
					<h3>ダッシュボード画面</h3>
					<p>タスクの確認とカレンダーによるスケジュール確認などができる画面です。</p>
					<p class="meta">
						更新日：2026/06/17<br>形式：画像
					</p>
					<a href="img/ダッシュボード画面設計AI.png" target="_blank" class="card-link">画面を見る</a>
					<a href="img/ダッシュボード画面設計.jpeg" target="_blank" class="card-link">画面を見る</a>
				</div>
				
				<div class="work-card" data-category="screen">
					<span class="category-label">画面設計</span>
					<h3>プロジェクト画面</h3>
					<p>プロジェクトの進捗状況の確認と設定ができる画面です。</p>
					<p class="meta">
						更新日：2026/06/17<br>形式：画像
					</p>
					<a href="img/プロジェクト画面設計AI.png" target="_blank" class="card-link">画面を見る</a>
					<a href="img/プロジェクト画面設計.jpeg" target="_blank" class="card-link">画面を見る</a>
				</div>
				
				<div class="work-card" data-category="screen">
					<span class="category-label">画面設計</span>
					<h3>マイタスク画面</h3>
					<p>担当タスクの確認と個人設定できる簡易タスク管理ができる画面です。</p>
					<p class="meta">
						更新日：2026/06/17<br>形式：画像
					</p>
					<a href="img/マイタスク画面設計AI.png" target="_blank" class="card-link">画面を見る</a>
					<a href="img/マイタスク画面設計.jpeg" target="_blank" class="card-link">画面を見る</a>
				</div>
				
				<div class="work-card" data-category="screen">
					<span class="category-label">画面設計</span>
					<h3>設定画面</h3>
					<p>アカウントの権限や通知、テーマ色設定などができる画面です。</p>
					<p class="meta">
						更新日：2026/06/17<br>形式：画像
					</p>
					<a href="img/設定画面設計AI.png" target="_blank" class="card-link">画面を見る</a>
					<a href="img/設定画面設計.jpeg" target="_blank" class="card-link">画面を見る</a>
				</div>
				
				<div class="work-card" data-category="screen">
					<span class="category-label">画面設計</span>
					<h3>通知画面</h3>
					<p>通知の詳細が確認できる画面です。</p>
					<p class="meta">
						更新日：2026/06/17<br>形式：画像
					</p>
					<a href="img/通知センター画面設計AI.png" target="_blank" class="card-link">画面を見る</a>
					<a href="img/通知センター画面設計.jpeg" target="_blank" class="card-link">画面を見る</a>
				</div>
				
				<div class="work-card" data-category="database">
					<span class="category-label">DB設計</span>
					<h3>サンプルデータ①</h3>
					<p>最初に作った3つのタスクデータが入ったサンプルデータのSQL文です。</p>
					<p class="meta">
						更新日：2026/06/11<br>形式：Googleドキュメント・画像
					</p>
					<a
						href="https://docs.google.com/document/d/18JocBzKV1NvO4i1Fk5y7DczQ5QyGgMpbzW-w6hjGvtg/edit?tab=t.7zud46w646e9"
						target="_blank" class="card-link">資料を見る</a> 
				</div>
				
				<div class="work-card" data-category="database">
					<span class="category-label">DB設計</span>
					<h3>サンプルデータ②</h3>
					<p>20個のタスクデータが入ったサンプルデータのSQL文です。</p>
					<p class="meta">
						更新日：2026/06/11<br>形式：Googleドキュメント
					</p>
					<a
						href="https://docs.google.com/document/d/18JocBzKV1NvO4i1Fk5y7DczQ5QyGgMpbzW-w6hjGvtg/edit?tab=t.hfs03lvefyuj"
						target="_blank" class="card-link">資料を見る</a>
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