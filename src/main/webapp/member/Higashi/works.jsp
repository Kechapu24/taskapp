<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="css/Higashi.css">
<title>成果物 開発演習 個人ページ</title>
</head>
<body>
	<div class="page-layout">
		<aside class="side-menu">
			<h1>Higashi</h1>
			<p>個人ページ</p>

			<nav>
				<a href="Higashi.jsp">トップページ</a> <a href="report.jsp">作業報告</a> <a
					href="works.jsp" class="active">成果物</a> <a href="docs.jsp">資料</a>
			</nav>

			<section>
				<p class="title">プロフィール</p>
				<p>東 辰賢</p>
				<p>専門学校湖東カレッジ</p>
				<p>IT経済学科</p>
				<p class="space">SEコース</p>
				<p>Java / JSP / HTML / CSS / JavaScript / PostgreSQL / Tomcat /
					Apache / Github / Git / AlmaLinux / Hyper-V</p>
			</section>

			<a href="../../index.jsp" class="task_app">タスク管理アプリ</a>
		</aside>

		<main class="main-content">

			<header id="works-top">
				<h1>成果物</h1>
			</header>

			<p class="page-description">
				システム開発演習で担当したタスクボード画面、DB設計、環境構築、要件設計資料についてまとめています。
				各項目では、作成した内容・工夫した点・今後の課題を確認できます。</p>

			<div class="works-category-menu">
				<a href="#taskboard" class="works-category-card"> <span>01</span>
					<h3>タスクボード</h3>
					<p>DBと連携するタスク管理画面の実装</p>
				</a> <a href="#database" class="works-category-card"> <span>02</span>
					<h3>DB設計</h3>
					<p>テーブル設計・サンプルデータ・SQL作成</p>
				</a> <a href="#environment" class="works-category-card"> <span>03</span>
					<h3>環境構築</h3>
					<p>学校サーバー・Eclipse・GitHub関連の整理</p>
				</a> <a href="#requirements" class="works-category-card"> <span>04</span>
					<h3>要件設計資料</h3>
					<p>要件定義・サイトマップ・画面設計</p>
				</a>
			</div>

			<!-- タスクボード -->
			<section id="taskboard" class="works-group">
				<div class="works-group-heading">
					<span class="works-group-number">01</span>
					<div>
						<h2>タスクボード画面</h2>
						<p>DB設計を担当したため、DBと密に接するタスクボード画面の開発を行いました。
							タスク情報を画面上で確認・編集できるようにし、実際のタスク管理に近い操作を目指しました。</p>
					</div>
				</div>

				<div class="works-link-menu">
					<a href="#task-column">タスクコラム・カード表示</a> <a
						href="#task-detail-modal">詳細モーダル表示</a> <a href="#task-edit-modal">編集モーダル表示</a>
					<a href="#deadline-highlight">期限強調表示</a> <a
						href="#taskboard-future">未実装機能</a>
				</div>
			</section>

			<section id="task-column" class="works-detail">
				<div class="works-detail-text">
					<span class="works-label">タスクボード</span>
					<h3>タスクコラム・タスクカードの表示</h3>
					<p>タスクを状態ごとにコラムで分け、カード形式で表示する画面を作成しました。
						タスク名、プロジェクト名、担当者、期限などを一覧で確認できるようにしました。</p>

					<h4>実装した内容</h4>
					<ul>
						<li>未着手・進行中・完了などの状態別コラム表示</li>
						<li>タスクカードのHTML/CSS作成</li>
						<li>DBから取得したタスク情報の表示</li>
						<li>プロジェクト名、担当者、期限などの表示</li>
					</ul>

					<h4>改善点</h4>
					<p>一覧画面のタスクの表示量を増やすためにフォントサイズや空白サイズ、表示情報の調整をする予定です。</p>
				</div>

				<div class="works-detail-image">
					<a href="img/タスクボード画面.png" target="_blank"> <img
						src="img/タスクボード画面.png" alt="タスクボード画面">
					</a>
					<p>タスクボード画面</p>
				</div>
			</section>

			<section id="task-detail-modal" class="works-detail reverse">
				<div class="works-detail-text">
					<span class="works-label">タスクボード</span>
					<h3>タスク詳細表示モーダルの作成</h3>
					<p>タスクカードから詳細情報を確認できるように、タスク詳細表示モーダルを作成しました。
						一覧画面では表示しきれない説明文やコメント、添付情報などを確認できる構成にしました。</p>

					<h4>実装した内容</h4>
					<ul>
						<li>タスク詳細表示用モーダルの作成</li>
						<li>タスク名、説明、状態、優先度、期限などの表示</li>
						<li>コメント・添付情報を表示する領域の作成</li>
						<li>一覧画面から画面遷移せずに詳細確認できる構成</li>
					</ul>

					<h4>工夫した点</h4>
					<p>タスク一覧画面をすっきり見せるため、詳細情報は別画面ではなくモーダルで表示するようにしました。
						これにより、利用者が現在の画面を保ったまま情報を確認できるようにしました。</p>
				</div>

				<div class="works-detail-image">
					<a href="img/タスク詳細表示モーダル.png" target="_blank"> <img
						src="img/タスク詳細表示モーダル.png" alt="タスク詳細表示モーダル">
					</a>
					<p>タスク詳細表示モーダル</p>
				</div>
			</section>

			<section id="task-edit-modal" class="works-detail">
				<div class="works-detail-text">
					<span class="works-label">タスクボード</span>
					<h3>タスク編集モーダルの作成</h3>
					<p>タスク情報を後から変更できるように、編集用のモーダルを作成しました。
						タスク名、状態、優先度、開始日、期限日、説明、担当者などを編集できる画面を目指しました。</p>

					<h4>実装した内容</h4>
					<ul>
						<li>タスク編集用フォームの作成</li>
						<li>状態・優先度の選択項目作成</li>
						<li>開始日・期限日の入力欄追加</li>
						<li>説明文や担当者情報の編集欄作成</li>
					</ul>

					<h4>改善点</h4>
					<p>権限によって表示する内容を変えたり、表示UIを別ページと統一し改善する予定です。</p>
				</div>

				<div class="works-detail-image">
					<a href="img/タスク編集モーダル.png" target="_blank"> <img
						src="img/タスク編集モーダル.png" alt="タスク編集モーダル">
					</a>
					<p>タスク編集モーダル</p>
				</div>
			</section>

			<section id="deadline-highlight" class="works-detail reverse">
				<div class="works-detail-text">
					<span class="works-label">タスクボード</span>
					<h3>期限が近いタスクの強調表示</h3>
					<p>期限が近いタスクや期限を過ぎたタスクを見つけやすくするために、 タスクカードの表示を強調する機能を実装しました。</p>

					<h4>実装した内容</h4>
					<ul>
						<li>枠を期限日3日前で黄色表示</li>
						<li>枠を期限日1日前で赤色表示</li>
						<li>枠を期限日超過で黒色表示</li>
					</ul>

					<h4>改善点</h4>
					<p>色遣いや周りのUIとの統一感改善による見た目の改善、期限日の調整をする予定です。</p>
				</div>

				<div class="works-detail-image">
					<a href="img/期限強調表示.png" target="_blank"> <img
						src="img/期限強調表示.png" alt="期限強調表示" class="vertical-image">
					</a>
					<p>期限が近いタスクの強調表示</p>
				</div>
			</section>

			<section id="taskboard-future" class="works-detail future">
				<div class="works-detail-text">
					<span class="works-label">今後の課題</span>
					<h3>タスクボード画面の未実装機能</h3>
					<p>タスクボード画面では基本的な表示・詳細確認・編集機能を中心に実装しました。
						今後は、より実用的なタスク管理画面に近づけるため、以下の機能を追加したいと考えています。</p>

					<ul class="future-list">
						<li>タスク絞り込み・並び替え機能</li>
						<li>タスク検索機能</li>
						<li>担当者の複数割り当て</li>
						<li>利用者権限との連携</li>
						<li>ドラッグアンドドロップによる操作</li>
					</ul>
				</div>
			</section>

			<!-- DB設計 -->
			<section id="database" class="works-group">
				<div class="works-group-heading">
					<span class="works-group-number">02</span>
					<div>
						<h2>DB設計</h2>
						<p>ある程度のアプリケーション構築ができるDBの構築を行いました。
							今後の機能追加に合わせて、テーブル構成やデータの持ち方をアップデートする予定です。</p>
					</div>
				</div>

				<div class="works-link-menu">
					<a href="#base-table">基幹テーブル設計</a> <a href="#sample-data">サンプルデータ追加</a>
					<a href="#sql-file">DB編集用SQLファイル</a> <a href="#database-future">未完成部分</a>
				</div>
			</section>

			<section id="base-table" class="works-detail">
				<div class="works-detail-text">
					<span class="works-label">DB設計</span>
					<h3>タスク・プロジェクトなどの基幹テーブル設計</h3>
					<p>タスク管理アプリで必要になるタスク、プロジェクト、ユーザーなどの情報を管理するため、
						基幹となるテーブル構成を設計しました。</p>

					<h4>設計した内容</h4>
					<ul>
						<li>タスク情報を管理するテーブル</li>
						<li>プロジェクト情報を管理するテーブル</li>
						<li>ユーザー情報を管理するテーブル</li>
						<li>タスクと関連情報を結び付ける構成</li>
					</ul>

					<h4>工夫した点</h4>
					<p>画面表示で必要な情報を取得しやすくするため、タスクとプロジェクト、担当者などを関連付けて管理できるようにしました。</p>
				</div>

				<div class="works-detail-image">
					<a href="img/DB設計図_ERD.png" target="_blank"> <img
						src="img/DB設計図_ERD.png" alt="DB設計図">
					</a>
					<p>DB設計図</p>
				</div>
			</section>

			<section id="sample-data" class="works-detail reverse">
				<div class="works-detail-text">
					<span class="works-label">DB設計</span>
					<h3>サンプルデータ追加</h3>
					<p>画面表示やDB連携の動作確認を行うために、サンプルデータを作成しました。
						最初は少数のデータで確認し、その後タスク数を増やして表示確認を行いました。</p>

					<h4>作成した内容</h4>
					<ul>
						<li>最初の動作確認用タスクデータ</li>
						<li>20件程度のタスクデータ</li>
						<li>プロジェクト・担当者と紐づくデータ</li>
					</ul>

					<h4>工夫した点</h4>
					<p>タスクの状態や期限、担当者などにばらつきを持たせることで、 一覧表示や期限強調表示の確認がしやすいようにしました。</p>
				</div>

				<div class="works-detail-image">
					<a
						href="https://docs.google.com/document/d/18JocBzKV1NvO4i1Fk5y7DczQ5QyGgMpbzW-w6hjGvtg/edit?tab=t.hfs03lvefyuj"
						target="_blank" class="works-doc-card">
						<h4>サンプルデータ資料</h4>
						<p>作成したサンプルデータのSQL文を確認できます。</p>
					</a>
				</div>
			</section>

			<section id="sql-file" class="works-detail">
				<div class="works-detail-text">
					<span class="works-label">DB設計</span>
					<h3>DB編集用SQLファイル作成</h3>
					<p>DBの作成やサンプルデータの追加を行いやすくするために、 SQL文をファイルとして整理しました。</p>

					<h4>作成した内容</h4>
					<ul>
						<li>テーブル作成用SQL</li>
						<li>サンプルデータ追加用SQL</li>
						<li>動作確認用のSELECT文</li>
					</ul>

					<h4>工夫した点</h4>
					<p>手作業で何度もSQLを入力しなくても済むように、再利用しやすい形でSQLファイルを整理しました。</p>
				</div>

				<div class="works-detail-image">
					<a
						href="https://docs.google.com/document/d/18JocBzKV1NvO4i1Fk5y7DczQ5QyGgMpbzW-w6hjGvtg/edit?tab=t.0"
						target="_blank" class="works-doc-card">
						<h4>DB設計資料</h4>
						<p>DB設計資料とSQL関連資料を確認できます。</p>
					</a>
				</div>
			</section>

			<section id="database-future" class="works-detail future">
				<div class="works-detail-text">
					<span class="works-label">今後の課題</span>
					<h3>DB設計の未実装・未完成部分</h3>
					<p>現在はタスク管理の基本機能に必要なテーブルを中心に作成しました。
						今後はアカウント管理や通知機能など、より実用的な機能に対応できるDBへ改善していきたいです。</p>

					<ul class="future-list">
						<li>アカウント情報テーブル</li>
						<li>コメントテーブル</li>
						<li>通知テーブル</li>
					</ul>
				</div>
			</section>

			<!-- 環境構築 -->
			<section id="environment" class="works-group">
				<div class="works-group-heading">
					<span class="works-group-number">03</span>
					<div>
						<h2>環境構築</h2>
						<p>環境構築が早く終わったため、マニュアルを作成し、メンバーの環境構築の手助けを行いました。
							学校指定の環境だけでなく、EclipseやGitHub関連の作業手順も整理しました。</p>
					</div>
				</div>

				<div class="works-link-menu">
					<a href="#linux-setup">Linux・学校サーバー関連</a> <a href="#eclipse-github">Eclipse・GitHub関連</a>
					<a href="#manual-create">マニュアル作成</a>
				</div>
			</section>

			<section id="linux-setup" class="works-detail">
				<div class="works-detail-text">
					<span class="works-label">環境構築</span>
					<h3>学校指定URLを参照したLinux関連の環境構築</h3>
					<p>
						学校指定の参照URLをもとに、仮想環境やLinux、Apache、Tomcat、PostgreSQLなどの設定を行いました。
						Webアプリケーションをサーバー上で動作させるための基礎環境を整えました。</p>

					<h4>行った内容</h4>
					<ul>
						<li>Hyper-Vによる仮想環境の準備</li>
						<li>AlmaLinuxの設定</li>
						<li>Apache・Tomcatの動作確認</li>
						<li>PostgreSQLの設定・接続確認</li>
						<li>JSPファイルの配置と表示確認</li>
					</ul>

					<h4>工夫した点</h4>
					<p>手順を進めながら、後から確認しやすいようにコマンドや注意点を記録しました。</p>
				</div>

				<div class="works-detail-image">
					<a
						href="https://docs.google.com/document/d/1GbtfcZ_ujy8cuBMa1MbV_9eSQ083WbBSeeKhQOtI11Q/edit?tab=t.0#heading=h.14okyaorbmez"
						target="_blank" class="works-doc-card">
						<h4>開発環境構築マニュアル</h4>
						<p>学校指定URLを参照して作成した環境構築手順です。</p>
					</a>
				</div>
			</section>

			<section id="eclipse-github" class="works-detail reverse">
				<div class="works-detail-text">
					<span class="works-label">環境構築</span>
					<h3>Eclipse・GitHub関連の環境構築</h3>
					<p>学校指定の手順だけでは不足しやすいEclipseやGitHub関連の設定についても整理しました。
						GitHubのデータをEclipseに取り込み、チーム開発で作業しやすい環境を整えました。</p>

					<h4>行った内容</h4>
					<ul>
						<li>GitHubからプロジェクトを取得</li>
						<li>Eclipseへのプロジェクトインポート</li>
						<li>GitHubとEclipseの連携手順整理</li>
						<li>Spring BootやMaven関連の手順整理</li>
					</ul>

					<h4>工夫した点</h4>
					<p>授業で使用経験のあるEclipseとチーム開発に欠かせないGitHubの導入でスムーズに開発が進められるようにし、画面操作や手順をマニュアルとしてまとめました。</p>
				</div>

				<div class="works-detail-image">
					<a
						href="https://docs.google.com/document/d/1GbtfcZ_ujy8cuBMa1MbV_9eSQ083WbBSeeKhQOtI11Q/edit?tab=t.vqqxls94r4fa#heading=h.24dfz4dggf0z"
						target="_blank" class="works-doc-card">
						<h4>GitHub・Eclipse連携マニュアル</h4>
						<p>GitHubのデータをEclipseにインポートする手順です。</p>
					</a>
				</div>
			</section>

			<section id="manual-create" class="works-detail">
				<div class="works-detail-text">
					<span class="works-label">環境構築</span>
					<h3>マニュアル作成によるチーム支援</h3>
					<p>自分が環境構築で確認した内容をマニュアルとして整理し、メンバーが同じ手順で作業できるようにしました。
						特に、DB連携やデプロイ手順など、つまずきやすい部分を重点的にまとめました。</p>

					<h4>作成したマニュアル</h4>
					<ul>
						<li>DB連携マニュアル</li>
						<li>デプロイマニュアル</li>
						<li>GitHub・Eclipse連携マニュアル</li>
						<li>Linux頻出コマンドマニュアル</li>
						<li>開発環境構築マニュアル</li>
					</ul>

					<h4>工夫した点</h4>
					<p>自分だけが理解できる資料にならないように、手順・コマンド・注意点を分けて整理しました。
						チームメンバーが見ても再現できる内容にすることを意識しました。</p>
				</div>

				<div class="works-detail-image">
					<a href="docs.jsp" class="works-doc-card">
						<h4>資料ページ</h4>
						<p>作成したマニュアルを資料ページにまとめています。</p>
					</a>
				</div>
			</section>

			<!-- 要件設計資料 -->
			<section id="requirements" class="works-group">
				<div class="works-group-heading">
					<span class="works-group-number">04</span>
					<div>
						<h2>要件設計資料</h2>
						<p>要件定義や設計イメージの共有をチーム間で会議しながら行い、資料としてまとめました。
							実装前に必要な機能や画面構成を整理することで、開発の方向性を合わせました。</p>
					</div>
				</div>

				<div class="works-link-menu">
					<a href="#requirement-doc">要件定義</a> <a href="#sitemap-doc">サイトマップ</a>
					<a href="#screen-design">画面設計</a>
				</div>
			</section>

			<section id="requirement-doc" class="works-detail">
				<div class="works-detail-text">
					<span class="works-label">要件設計資料</span>
					<h3>要件定義</h3>
					<p>タスク管理アプリに必要な機能や、管理する情報、想定する利用者などを整理しました。
						チーム内で認識を合わせるため、会議を行いながら資料化しました。</p>

					<h4>まとめた内容</h4>
					<ul>
						<li>システムの目的</li>
						<li>必要な機能の洗い出し</li>
						<li>画面ごとの役割</li>
						<li>管理するデータ項目</li>
					</ul>

					<h4>工夫した点</h4>
					<p>いきなり実装に入るのではなく、必要な機能やデータを先に整理することで、 画面設計やDB設計につなげやすいようにしました。
					</p>
				</div>

				<div class="works-detail-image">
					<a
						href="https://docs.google.com/document/d/1bLK_RccCXs_kWZ8ZoiIOnSZFUnnXGzcgLwy71rcgpk8/edit?tab=t.dwdiudsxg6q6"
						target="_blank" class="works-doc-card">
						<h4>要件定義書</h4>
						<p>システムの目的や必要機能をまとめた資料です。</p>
					</a>
				</div>
			</section>

			<section id="sitemap-doc" class="works-detail reverse">
				<div class="works-detail-text">
					<span class="works-label">要件設計資料</span>
					<h3>サイトマップ</h3>
					<p>タスク管理アプリの画面構成やページ間の関係を整理するため、サイトマップを作成しました。
						どの画面からどの機能を利用するかを確認しやすくしました。</p>

					<h4>まとめた内容</h4>
					<ul>
						<li>ログイン画面</li>
						<li>ダッシュボード</li>
						<li>タスクボード</li>
						<li>プロジェクト画面</li>
						<li>マイタスク画面</li>
						<li>通知・ログ・設定画面</li>
					</ul>

					<h4>工夫した点</h4>
					<p>画面数が増えても構成が分かりやすいように、機能単位でページを整理しました。</p>
				</div>

				<div class="works-detail-image">
					<a href="img/サイトマップ.png" target="_blank"> <img
						src="img/サイトマップ.png" alt="サイトマップ">
					</a>
					<p>サイトマップ</p>
				</div>
			</section>

			<section id="screen-design" class="works-detail">
				<div class="works-detail-text">
					<span class="works-label">要件設計資料</span>
					<h3>画面設計</h3>
					<p>タスク管理アプリの各画面について、画面レイアウトや必要な表示項目を整理しました。
						手書きの画面設計とAIで整えた画面イメージを用意し、チーム内で共有しました。</p>

					<h4>作成した画面設計</h4>
					<ul>
						<li>ダッシュボード画面</li>
						<li>タスクボード画面</li>
						<li>プロジェクト画面</li>
						<li>マイタスク画面</li>
						<li>通知画面</li>
						<li>設定画面</li>
					</ul>

					<h4>工夫した点</h4>
					<p>実装時に迷わないように、画面ごとに必要な項目や表示内容を整理しました。
						また、資料ページから各画面設計を確認できるようにしました。</p>
				</div>

				<div class="works-detail-image">
					<a href="img/タスクボード画面設計AI.png" target="_blank"> <img
						src="img/タスクボード画面設計AI.png" alt="タスクボード画面設計">
					</a>
					<p>タスクボード画面設計</p>
				</div>
			</section>

			<div class="back-to-top">
				<a href="#works-top">ページ上部へ戻る</a>
			</div>

		</main>
	</div>
</body>
</html>