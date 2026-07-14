<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>個人ホームページ</title>

<link rel="stylesheet" href="css/style.css">

</head>
<body>

	<!-- ヘッダー -->
	<header class="header">

		<div class="logo">
			<h1>My Portfolio</h1>
		</div>

		<nav>
			<ul class="menu">

				<li><a href="#">ホーム</a></li>
				<li><a href="#profile">プロフィール</a></li>
				<li><a href="#works">制作物</a></li>
				<li><a href="#skill">スキル</a></li>
				<li><a href="#contact">お問い合わせ</a></li>

			</ul>
		</nav>

	</header>

	<div class="container">

		<!-- 自己紹介 -->
		<section class="hero">

			<h2>こんにちは</h2>

			<p>
				私のホームページをご覧いただきありがとうございます。<br>
				Java・JSP・HTML・CSS・SQLを学習しながらシステム開発を行っています。
			</p>

		</section>

		<!-- プロフィール -->
		<section id="profile" class="card">

			<h2>プロフィール</h2>

			<table>

				<tr>
					<th>名前</th>
					<td>坂田 駿右</td>
				</tr>

				<tr>
					<th>学校</th>
					<td>湖東カレッジ</td>
				</tr>

				<tr>
					<th>学科</th>
					<td>IT経済学科</td>
				</tr>

				<tr>
					<th>趣味</th>
					<td>ゲーム</td>
				</tr>

				<tr>
					<th>目標</th>
					<td>システムエンジニア</td>
				</tr>

			</table>

		</section>

		<!-- 制作物 -->
		<section id="works" class="card">

			<h2>制作物</h2>

			<div class="work-box">

				<h3>タスク管理アプリ</h3>

				<p>4人チームで開発しているWebアプリケーションです。</p>

			</div>

			<div class="work-box">

				<h3>Java課題</h3>

				<p>Javaの基本構文やオブジェクト指向を学習しました。</p>

			</div>

			<div class="work-box">

				<h3>個人ホームページ</h3>

				<p>HTML・CSS・JSPを使って制作しています。</p>

			</div>

		</section>

		<!-- スキル -->
		<section id="skill" class="card">

			<h2>スキル</h2>

			<div class="skill-list">

				<span>Java</span>
				<span>JSP</span>
				<span>Servlet</span>
				<span>HTML</span>
				<span>CSS</span>
				<span>SQL</span>
				<span>GitHub</span>
				<span>Eclipse</span>

			</div>

		</section>

		<!-- お問い合わせ -->
		<section id="contact" class="card">

			<h2>お問い合わせ</h2>

			<p>ご連絡はメールまたは学校でお願いします。</p>

		</section>

	</div>

	<footer>

		<p>© 2026</p>

	</footer>

</body>
</html>