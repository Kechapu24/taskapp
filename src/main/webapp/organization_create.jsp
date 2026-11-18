<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ja">

<head>
<meta charset="UTF-8">
<title>団体作成</title>
</head>

<body>

<h2>団体作成</h2>

<form action="OrganizationCreateServlet"
      method="post">

    <label>
        団体名
    </label>

    <input type="text"
           name="orgName"
           required>

    <button type="submit">
        作成
    </button>

</form>

</body>

</html>