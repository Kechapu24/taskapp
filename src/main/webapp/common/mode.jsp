<%@ page import="model.User"%>

<%
User loginUser = (User) session.getAttribute("loginUser");

// 未ログインならログイン画面へ
if (loginUser == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

// ログインユーザーID
int loginUserId = loginUser.getUserId();

// 現在選択中の団体
Integer activeOrgId =
    (Integer) session.getAttribute("activeOrgId");

// nullなら個人モード
boolean personalMode =
    (activeOrgId == null);

//現在のモードで基準となるID
int scopeId =
 personalMode ? loginUserId : activeOrgId;
%>