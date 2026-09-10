<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ja">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>SAKATA // PORTFOLIO</title>

<link rel="stylesheet" href="Sakata.css">

</head>

<body>


	<!-- ========================================
	     ヘッダー
	======================================== -->

	<header class="header">

		<div class="logo">
			<h1>SAKATA // PORTFOLIO</h1>
		</div>


		<nav>

			<ul class="menu">

				<li>
					<a href="#">HOME</a>
				</li>

				<li>
					<a href="#profile">PROFILE</a>
				</li>

				<li>
					<a href="#works">WORKS</a>
				</li>

				<li>
					<a href="#skill">SKILLS</a>
				</li>

				<li>
					<a href="#contact">CONTACT</a>
				</li>

			</ul>

		</nav>

	</header>



	<!-- ========================================
	     メインコンテンツ
	======================================== -->

	<div class="container">


		<!-- ====================================
		     トップ・自己紹介
		===================================== -->

		<section class="hero">

			<h2>SAKATA</h2>

			<p>
				STUDENT / DEVELOPER<br>
				IT ECONOMICS / WEB DEVELOPMENT
			</p>

			<p>
				Java・JSP・HTML・CSS・SQLを学習しながら<br>
				システム開発に取り組んでいます。
			</p>

		</section>



		<!-- ====================================
		     プロフィール
		===================================== -->

		<section id="profile" class="card">

			<h2>PROFILE</h2>

			<table>

				<tr>

					<th>NAME</th>

					<td>坂田 駿右</td>

				</tr>


				<tr>

					<th>SCHOOL</th>

					<td>湖東カレッジ</td>

				</tr>


				<tr>

					<th>DEPARTMENT</th>

					<td>IT経済学科</td>

				</tr>


				<tr>

					<th>HOBBY</th>

					<td>ゲーム</td>

				</tr>


				<tr>

					<th>GOAL</th>

					<td>システムエンジニア</td>

				</tr>

			</table>

		</section>



		<!-- ====================================
		     制作物
		===================================== -->

		<section id="works" class="card">

			<h2>WORKS</h2>


			<div class="work-box">

				<h3>TASK MANAGEMENT APP</h3>

				<p>
					4人チームで開発しているタスク管理Webアプリケーションです。
					プロジェクト管理、タスク管理、通知機能などの実装に取り組んでいます。
				</p>

			</div>


			<div class="work-box">

				<h3>JAVA PROGRAMMING</h3>

				<p>
					Javaの基本構文、配列、メソッド、
					オブジェクト指向、継承、カプセル化などを学習しました。
				</p>

			</div>


			<div class="work-box">

				<h3>PERSONAL HOMEPAGE</h3>

				<p>
					JSP・HTML・CSSを使用して制作している個人ホームページです。
				</p>

			</div>

		</section>



		<!-- ====================================
		     スキル
		===================================== -->

		<section id="skill" class="card">

			<h2>SKILLS</h2>


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



		<!-- ====================================
		     お問い合わせ
		===================================== -->

		<section id="contact" class="card">

			<h2>CONTACT</h2>

			<p>
				ご連絡はメールまたは学校でお願いします。
			</p>

		</section>


	</div>



	<!-- ========================================
	     フッター
	======================================== -->

	<footer>

		<p>
			SYSTEM // SAKATA PORTFOLIO
		</p>

		<p>
			© 2026 SAKATA
		</p>

	</footer>


</body>

</html>