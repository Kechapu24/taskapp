<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description"
	content="宮﨑実可のシステム開発演習 個人ページ。タスク管理アプリ開発における担当内容・進捗・学びをまとめています。">
<title>宮﨑 実可 | 個人ページ</title>

<link rel="stylesheet" href="m.style.css">
</head>

<body>
	<header>
		<p>専門学校湖東カレッジ IT経済学科</p>
		<h1>宮﨑 実可</h1>
		<p>システム開発演習 個人ページ</p>

	</header>

	<nav>
		<a href="#profile">自己紹介</a> <a href="#team">私たちのチーム</a> <a
			href="#progress">開発工程・進捗</a> <a href="#myprogress">現在の進捗状況</a> <a
			href="#role">担当内容</a> <a href="#contribution">チームへの貢献</a> <a
			href="#struggle">苦労したこと</a> <a href="#learning">学んだこと</a> <a
			href="#works">制作物</a> <a href="#goal">今後の目標</a> <a
			href="https://172.16.1.119/index.jsp" class="app-link-btn"
			target="_blank" rel="noopener"> 作成中のアプリを見る </a>

	</nav>

	<div class="container">

		<section id="profile">
			<h2>自己紹介</h2>

			<p>Java・JSP・Linux・Git・Tomcat・PostgreSQLを学習しています。
				システム開発演習では、チームでタスク管理アプリケーションの開発に取り組んでいます。</p>

			<p>これまでは個人でコードを書く機会が中心でしたが、この演習を通じて
				チームでひとつのアプリケーションを作り上げる経験を積んでいます。 特にGitでのバージョン管理やサーバーへのデプロイ作業など、
				実務に近い開発の流れを体験できている点が大きな学びになっています。</p>
		</section>

		<section id="team">
			<h2>私たちのチーム</h2>

			<p>私たちのチームは、細かな設計を最初に全て決めるのではなく、
				まず動くものを作りながら改善していくアジャイル型の開発を意識して進めています。</p>

			<p>メンバー同士で相談しながら機能追加や修正を行い、 実際に動作確認を繰り返しながら開発しています。</p>
		</section>

		<section id="progress">
			<h2>開発工程・進捗</h2>

			<p>本演習では、V字モデルに沿った開発工程を意識して進めています。
				要件定義でシステムの目的を決め、基本設計でユーザ目線の画面や機能を、 詳細設計で内部の処理やデータの流れを決めたうえで開発を行い、
				単体テスト・結合テスト・総合テストの順に検証範囲を広げていく流れです。</p>

			<table class="progress-table">
				<thead>
					<tr>
						<th scope="col">工程</th>
						<th scope="col">内容</th>
						<th scope="col">時期</th>
						<th scope="col">状況</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td>環境構築</td>
						<td>個人サーバ・グループサーバの構築（AlmaLinux / Apache / Tomcat /
							PostgreSQL）</td>
						<td>5月</td>
						<td><span class="status done">完了</span></td>
					</tr>
					<tr>
						<td>要件定義・基本設計</td>
						<td>タスク管理アプリの機能一覧・画面構成の検討</td>
						<td>6月上旬</td>
						<td><span class="status done">完了</span></td>
					</tr>
					<tr>
						<td>詳細設計・開発</td>
						<td>ログイン画面・新規登録画面・ダッシュボードの実装</td>
						<td>6月中旬〜10月</td>
						<td><span class="status inprogress">進行中</span></td>
					</tr>
					<tr>
						<td>単体テスト（UT）</td>
						<td>実装済み画面ごとの動作確認</td>
						<td>10月</td>
						<td><span class="status inprogress">進行中</span></td>
					</tr>
					<tr>
						<td>結合テスト（CT）</td>
						<td>他機能・チームメンバーの実装との連携確認</td>
						<td>11月以降予定</td>
						<td><span class="status todo">未着手</span></td>
					</tr>
				</tbody>
			</table>

			<p>現在は詳細設計・開発フェーズの後半で、各画面の実装と単体テストを並行して進めています。
				今後はメンバーの実装した機能と連携させる結合テストに進む予定です。</p>
		</section>

		<section id="myprogress">
			<h2>現在の進捗状況（宮﨑）</h2>

			<p>私は主にログイン画面と新規登録画面を担当しています。 現在、画面レイアウトと入力フォームの実装まで完了し、
				認証処理やデータベース連携の実装を進めています。</p>

			<ul>
				<li>ログイン画面作成：完了</li>
				<li>新規登録画面作成：完了</li>
				<li>入力フォーム実装：完了</li>
				<li>ログイン認証処理：作業中</li>
				<li>DB連携：未着手</li>
				<li>結合テスト：未着手</li>
			</ul>

			<p>現在の個人進捗率（開発工程）：約60％（7月時点）</p>

			<p>今後はログイン認証処理やデータベース連携の実装を進め、 チームメンバーが担当する機能との結合テストを実施する予定です。</p>
		</section>

		<section id="role">
			<h2>担当内容（宮﨑）</h2>

			<p>個人として担当している作業は以下の通りです。</p>

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

			<p>自分の担当作業だけでなく、チーム全体の開発が円滑に進むよう、以下のような形で貢献しています。</p>

			<ul>
				<li>チーム全員が開発を始められるよう、環境構築の手順を整理してメンバーに共有</li>
				<li>担当外である個人ページのリンクエラーを発見し、原因調査から修正まで対応</li>
				<li>GitHubでのプルリクエストや作業内容をこまめに共有し、メンバーが進捗を把握しやすい状態を維持</li>
				<li>自分の実装だけでなく、他メンバーの画面についても動作確認・不具合報告を実施</li>
			</ul>
		</section>

		<section id="struggle">
			<h2>苦労したこと</h2>

			<h3>個人ページのリンクエラー</h3>

			<p>開発メンバー一覧から個人ページへ遷移できない問題が発生しました。調査の結果、以下の状態にあることが分かりました。</p>

			<ul>
				<li>GitHub上では修正済みだったが、学校サーバーのtaskappは古い状態のままだった。</li>
				<li>Tomcatへの反映も行われていなかった。</li>
			</ul>

			<p>ログ調査やgrepコマンドを利用してリンク切れの原因箇所を特定し、 git pull と再デプロイによって解決しました。
				担当外の問題であっても、原因を切り分けて対応する経験を積めたのは大きな収穫でした。</p>

			<h3>Git操作とディレクトリ構造の理解</h3>

			<p>当初はホームディレクトリとカレントディレクトリの違いが理解出来ず、git pullをどこで実行すればよいのかわからなかった。</p>
			<p>調査を進める中で、taskappがGitリポジトリであり、その中にある.gitフォルダによってGit管理されていることを理解した。また、pwd・ls・cdコマンドを用いて現在位置やディレクトリ構造を理解しながら作業できるようになった。</p>

			<h3>ナビゲーションのレイアウト崩れ</h3>

			<p>
			<p>ナビゲーションを&lt;ul&gt;と&lt;li&gt;を用いた構造へ変更したところ、
				リンクが縦並びになりレイアウトが崩れてしまった。</p>
			</p>

			<ul>
				<li>CSSを確認し、サーバー反映の確認を行った。</li>
			</ul>

			<p>原因調査を行った結果、CSSの適用範囲や学校サーバーの反映状況は影響していることが分かり、修正することで解決した。</p>


		</section>

		<section id="learning">
			<h2>学んだこと</h2>

			<div class="card-grid">
				<div class="card">
					<h3>Git</h3>
					<p>pushだけではサーバーは更新されず、 pullによる最新ソース取得が必要であることを学びました。</p>
				</div>

				<div class="card">
					<h3>Tomcat</h3>
					<p>webapps/ROOTへ配置し直してデプロイする流れを理解しました。</p>
				</div>

				<div class="card">
					<h3>ApacheとTomcat</h3>
					<p>Apacheがリクエストを受け取り、 Tomcatへ転送してJSPを実行していることを理解しました。</p>
				</div>

				<div class="card">
					<h3>調査力</h3>
					<p>URL・grep・Git・Tomcatの状態を確認しながら、 問題を切り分ける方法を学びました。</p>
				</div>
				<div class="card">
					<h3>Linux</h3>
					<p>ホームディレクトリとカレントディレクトリの違い、pwd・ls・cdコマンドの使い方を学んだ。</p>
				</div>

				<div class="card">
					<h3>Servlet</h3>
					<p>Servletの役割やパッケージ構成を理解し、 ログイン処理実装に向けた準備を行った。</p>
				</div>

			</div>
		</section>

		<section id="works">
			<h2>制作物</h2>

			<p>チームでタスク管理アプリを開発しています。</p>

			<div class="gallery">
				<figure>
					<img src="img/taskapp-login.png" alt="メールアドレスとパスワードを入力するログインフォーム"
						class="screenshot">
					<figcaption>ログイン画面</figcaption>
				</figure>

				<figure>
					<img src="img/loginshot.png" alt="タスクボード画面（サイドバー表示）"
						class="screenshot">
					<figcaption>タスク管理画面（サイドバー）</figcaption>
				</figure>

				<figure>
					<img src="img/register.png" alt="ユーザー名・メールアドレス・パスワードを入力する新規登録フォーム"
						class="screenshot">
					<figcaption>新規登録画面</figcaption>
				</figure>

				<figure>
					<img src="img/taskboard.png" alt="タスクをカード形式で表示するダッシュボード画面"
						class="screenshot">
					<figcaption>タスクボード画面</figcaption>
				</figure>
			</div>

			<ul>
				<li>タスク管理画面</li>
				<li>JSPによる画面作成</li>
			</ul>
		</section>

		<section id="goal">
			<h2>今後の目標</h2>

			<p>基本的な機能実装を終えたら、演習要項にある発展的な内容にも挑戦していきたいと考えています。</p>

			<ul>
				<li>Javaの理解を深める</li>
				<li>データベース設計を学ぶ</li>
				<li>SQLインジェクションやCSRFなど、セキュリティ対策を実装する</li>
				<li>AJAXを取り入れ、ログイン画面や新規登録画面の入力チェックを非同期化する</li>
				<li>チーム開発経験を積み、結合テスト・総合テストまで責任を持って進める</li>
			</ul>
		</section>

	</div>

	<footer>
		<p>
			&copy;
			<%=java.time.Year.now()%>
			宮﨑 実可
		</p>
	</footer>

</body>
</html>
