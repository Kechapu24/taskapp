<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="../../css/Higashi.css">
<title>作業報告 開発演習 個人ページ</title>
</head>
<body>
	<div class="page-layout">
		<aside class="side-menu">
			<h1>Higashi</h1>
			<p>個人ページ</p>

			<nav>
				<a href="Higashi.jsp">トップページ</a> <a href="report.jsp" class="active">作業報告</a>
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
				<h1>作業報告</h1>
			</header>
			<p>システム開発演習での作業内容を日付ごとにまとめています</p>

			<section>
				<table>
					<tr>
						<th>日付</th>
						<th>作業内容</th>
						<th>成果物</th>
					</tr>
					<tr>
						<td>6/3</td>
						<td>学校サーバーのデプロイ環境設定<br> 個人ページ作成
						</td>
						<td><a
							href="https://docs.google.com/document/d/1GbtfcZ_ujy8cuBMa1MbV_9eSQ083WbBSeeKhQOtI11Q/edit?tab=t.jtkxe2u9i6cq#heading=h.5qygexbhsf38">デプロイマニュアル</a></td>
					</tr>
					<tr>
						<td>6/4</td>
						<td>チームで要件定義<br> 画面レイアウト作成
						</td>
						<td><a href="screen_design.jsp">画面設計資料</a></td>
					</tr>

					<tr>
						<td>6/10</td>
						<td>チームで要件定義とドキュメント化<br> データベース設計<br>
							テーブル構成・リレーションの整理
						</td>
						<td><a
							href="https://docs.google.com/document/d/1bLK_RccCXs_kWZ8ZoiIOnSZFUnnXGzcgLwy71rcgpk8/edit?tab=t.0">議事録</a><br>
							<a
							href="https://docs.google.com/document/d/18JocBzKV1NvO4i1Fk5y7DczQ5QyGgMpbzW-w6hjGvtg/edit?tab=t.0#heading=h.slgvjhb6dtrl">DB設計書</a><br>
							<a href="img/DB設計図_ERD.png">ER図</a></td>
					</tr>
					<tr>
						<td>6/11</td>
						<td>データベース設計<br> DB作成SQLファイル作成<br> サンプルデータの追加<br>
							タスクボードページのHTML作成<br> タスクコラム、タスクカード作成
						</td>
						<td><a
							href="https://docs.google.com/document/d/18JocBzKV1NvO4i1Fk5y7DczQ5QyGgMpbzW-w6hjGvtg/edit?tab=t.7zud46w646e9">サンプルデータ</a><br>
							<a href="../../taskboard.jsp">タスクボード</a></td>
					</tr>
					<tr>
						<td>6/17</td>
						<td>タスクボードページ編集<br> タスクカードの表示調整<br>
							コメント・添付ファイル表示用アイコンの追加<br> タスク詳細表示用モーダルの作成<br>
							自身の仮想環境DB連携実験
						</td>
						<td><a href="../../taskboard.jsp">タスクボード</a></td>
					</tr>
					<tr>
						<td>6/18</td>
						<td>タスクボードページ編集<br> DBから取得したデータをタスクボードで表示<br>
							学校サーバーDB連携<br> データベース連携方法共有
						</td>
						<td><a
							href="https://docs.google.com/document/d/1GbtfcZ_ujy8cuBMa1MbV_9eSQ083WbBSeeKhQOtI11Q/edit?tab=t.989reewvcl8w#heading=h.6ze914wglamt">DB連携マニュアル</a><br>
						<a href="../../taskboard.jsp">タスクボード</a></td>
					</tr>
					<tr>
						<td>7/1</td>
						<td>タスクボードページ編集<br> タスク詳細モーダル表示機能の実装
						</td>
						<td><a href="../../taskboard.jsp">タスクボード</a></td>
					</tr>
					<tr>
						<td>7/2</td>
						<td>タスクボードページ編集<br> タスク編集機能の実装<br> 期限日を用いた強調表示枠の実装
						</td>
						<td><a href="../../taskboard.jsp">タスクボード</a></td>
					</tr>
					<tr>
						<td>7/8</td>
						<td>個人ページ編集<br> 画面レイアウト基盤作成<br> 作業報告ページ編集
						</td>
						<td><a href="report.jsp">作業報告</a></td>
					</tr>
					<tr>
						<td>7/9</td>
						<td>個人ページ編集<br> 資料ページ編集 <br>
							Wordマニュアルを画像データGoogleドキュメントへ変換
						</td>
						<td><a href="docs.jsp">資料</a></td>
					</tr>
					<tr>
						<td>7/14</td>
						<td>個人ページ編集<br> 画面設計資料ページ作り<br> 作業報告に成果物欄追加</td>
						<td><a href="docs.jsp">資料</a><br><a href="report.jsp">作業報告</a><br><a href="screen_design.jsp">画面設計資料</a></td>
					</tr>
					<tr>
						<td></td>
						<td></td>
						<td></td>
					</tr>
					<tr>
						<td></td>
						<td></td>
						<td></td>
					</tr>
					<tr>
						<td></td>
						<td></td>
						<td></td>
					</tr>
				</table>

			</section>

		</main>

	</div>

</body>
</html>