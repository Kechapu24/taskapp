<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>宮﨑 実可 | 個人ページ</title>

<link rel="stylesheet" href="m.style.css">
</head>

<body>
	<header>
		<h1>宮﨑 実可</h1>
		<p>システム開発演習 個人ページ</p>
	</header>

	<nav>
		<a href="#profile">自己紹介</a>
		<a href="#team">私たちのチーム</a>
		<a href="#progress">開発工程・進捗</a>
		<a href="#role">担当内容</a>
		<a href="#contribution">チームへの貢献</a>
		<a href="#struggle">苦労したこと</a>
		<a href="#learning">学んだこと</a>
		<a href="#works">制作物</a>
		<a href="#goal">今後の目標</a>
	</nav>

	<div class="container">

		<section id="profile">
			<h2>自己紹介</h2>

			<p>Java・JSP・Linux・Git・Tomcat・PostgreSQLを学習しています。
				システム開発演習では、チームでタスク管理アプリケーションの開発に取り組んでいます。</p>

			<p>これまでは個人でコードを書く機会が中心でしたが、この演習を通じて
				チームでひとつのアプリケーションを作り上げる経験を積んでいます。
				特にGitでのバージョン管理やサーバーへのデプロイ作業など、
				実務に近い開発の流れを体験できている点が大きな学びになっています。</p>
		</section>

		<section id="team">
			<h2>私たちのチーム</h2>

			<p>私たちのチームは、細かな設計を最初に全て決めるのではなく、
				まず動くものを作りながら改善していくアジャイル型の開発を意識して進めています。</p>

			<p>メンバー同士で相談しながら機能追加や修正を行い、
				実際に動作確認を繰り返しながら開発しています。</p>
		</section>

		<section id="progress">
			<h2>開発工程・進捗</h2>

			<p>本演習では、V字モデルに沿った開発工程を意識して進めています。
				要件定義でシステムの目的を決め、基本設計でユーザ目線の画面や機能を、
				詳細設計で内部の処理やデータの流れを決めたうえで開発を行い、
				単体テスト・結合テスト・総合テストの順に検証範囲を広げていく流れです。</p>

			<table class="progress-table">
				<thead>
					<tr>
						<th>工程</th>
						<th>内容</th>
						<th>状況</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td>環境構築</td>
						<td>個人サーバ・グループサーバの構築（AlmaLinux / Apache / Tomcat / PostgreSQL）</td>
						<td><span class="status done">完了</span></td>
					</tr>
					<tr>
						<td>要件定義・基本設計</td>
						<td>タスク管理アプリの機能一覧・画面構成の検討</td>
						<td><span class="status done">完了</span></td>
					</tr>
					<tr>
						<td>詳細設計・開発</td>
						<td>ログイン画面・新規登録画面・ダッシュボードの実装</td>
						<td><span class="status inprogress">進行中</span></td>
					</tr>
					<tr>
						<td>単体テスト（UT）</td>
						<td>実装済み画面ごとの動作確認</td>
						<td><span class="status inprogress">進行中</span></td>
					</tr>
					<tr>
						<td>結合テスト（CT）</td>
						<td>他機能・チームメンバーの実装との連携確認</td>
						<td><span class="status todo">未着手</span></td>
					</tr>
				</tbody>
			</table>

			<p>現在は詳細設計・開発フェーズの後半で、各画面の実装と単体テストを並行して進めています。
				今後はメンバーの実装した機能と連携させる結合テストに進む予定です。</p>
		</section>

		<section id="role">
			<h2>担当内容(宮﨑)</h2>

			<ul>
				<li>Eclipseプロジェクト作成</li>
				<li>ログイン画面の作成</li>
				<li>ID入力欄の実装</li>
				<li>パスワード入力欄の実装</li>
				<li>名前入力欄の実装</li>
				<li>新規登録ポップアップ画面の作成</li>
				<li>画面レイアウト調整</li>
			</ul>
		</section>

		<section id="contribution">
			<h2>チームへの貢献</h2>

			<ul>
				<li>開発開始のための環境準備</li>
				<li>ログイン機能の画面作成</li>
				<li>新規登録画面のUI実装</li>
				<li>GitHubによる共同開発への参加</li>
				<li>不具合の原因調査と修正対応</li>
			</ul>
		</section>

		<section id="struggle">
			<h2>苦労したこと</h2>

			<h3>個人ページのリンクエラー</h3>

			<p>開発メンバー一覧から個人ページへ遷移できない問題が発生しました。</p>

			<ul>
				<li>GitHub上では修正済み</li>
				<li>学校サーバーのtaskappは古い状態</li>
				<li>Tomcatへの反映も未実施</li>
			</ul>

			<p>ログ調査やgrepコマンドを利用して原因を特定し、
				git pull と再デプロイによって解決しました。</p>
		</section>

		<section id="learning">
			<h2>学んだこと</h2>

			<div class="card-grid">
				<div class="card">
					<h3>Git</h3>
					<p>pushだけではサーバーは更新されず、
						pullによる最新ソース取得が必要であることを学びました。</p>
				</div>

				<div class="card">
					<h3>Tomcat</h3>
					<p>webapps/ROOTへ配置し直してデプロイする流れを理解しました。</p>
				</div>

				<div class="card">
					<h3>ApacheとTomcat</h3>
					<p>Apacheがリクエストを受け取り、
						Tomcatへ転送してJSPを実行していることを理解しました。</p>
				</div>

				<div class="card">
					<h3>調査力</h3>
					<p>URL・grep・Git・Tomcatの状態を確認しながら、
						問題を切り分ける方法を学びました。</p>
				</div>
			</div>
		</section>

		<section id="works">
			<h2>制作物</h2>

			<p>チームでタスク管理アプリを開発しています。</p>

			<div class="gallery">
				<figure>
					<img src="img/taskapp-login.png" alt="タスクボード画面（サイドバー表示）" class="screenshot">
					<figcaption>タスク管理画面（サイドバー）</figcaption>
				</figure>

				<figure>
					<img src="img/loginshot.png" alt="メールアドレスとパスワードを入力するログインフォーム" class="screenshot">
					<figcaption>ログイン画面</figcaption>
				</figure>

				<figure>
					<img src="img/register.png" alt="ユーザー名・メールアドレス・パスワードを入力する新規登録フォーム" class="screenshot">
					<figcaption>新規登録画面</figcaption>
				</figure>

				<figure>
					<img src="img/taskboard.png" alt="タスクをカード形式で表示するダッシュボード画面" class="screenshot">
					<figcaption>タスクボード画面</figcaption>
				</figure>
			</div>

			<ul>
				<li>ログイン機能</li>
				<li>ユーザー登録機能</li>
				<li>タスク管理機能</li>
				<li>JSPによる画面作成</li>
			</ul>
		</section>

		<section id="goal">
			<h2>今後の目標</h2>

			<ul>
				<li>Javaの理解を深める</li>
				<li>データベース設計を学ぶ</li>
				<li>セキュリティの知識を身につける</li>
				<li>チーム開発経験を積む</li>
			</ul>
		</section>

	</div>

	<footer>
		<p>&copy; 2026 宮﨑 実可</p>
	</footer>

</body>
</html>
