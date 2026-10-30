<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

</body>
</html><%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%--
  プロフィール画像の「変更ウィンドウ」(ダイアログ)。
  ホバーカードの大きいアイコンに、カメラのマークを付け、押すとこのウィンドウが開く。

  ・user_badge.jsp の最後に1回だけ差し込む:
        <jsp:include page="/common/icon_modal.jsp" />
  ・画像を選ぶとプレビューが変わり、「保存」を押して初めてDBに反映される。
  ・保存は画面遷移なし(fetch)で /uploadIcon?ajax=1 に送り、成功したらページを再読み込みする。
  ・※ このファイルの <script> の中には、EL式の開始記号(ドルと波括弧)を書かないこと。
    JSPが、サーバー側で先に置き換えて、空にしてしまう。必要な値は data- 属性で渡している。
--%>
<c:if test="${not empty loginUser}">
	<link rel="stylesheet"
		href="${pageContext.request.contextPath}/css/icon_modal.css">

	<dialog id="iconDialog" class="icon-dialog"
		aria-labelledby="iconDialogTitle"
		data-upload-url="${pageContext.request.contextPath}/uploadIcon"
		data-icon-url="${pageContext.request.contextPath}/icon?userId=${loginUser.userId}"
		data-has-icon="${loginUser.iconSet}"
		data-initial="<c:out value='${fn:substring(loginUser.userName, 0, 1)}'/>"
		data-hue="${(loginUser.userId * 67) % 360}">

		<div class="icon-dialog__body">
			<h2 id="iconDialogTitle" class="icon-dialog__title">プロフィール画像の変更</h2>

			<div class="icon-dialog__preview avatar avatar--xl"></div>

			<p class="icon-dialog__msg" role="alert"></p>

			<div class="icon-dialog__actions">
				<button type="button" class="icon-dialog__link" data-action="pick">
					<svg viewBox="0 0 24 24" width="18" height="18" fill="none"
						stroke="currentColor" stroke-width="2" stroke-linecap="round"
						stroke-linejoin="round" aria-hidden="true">
						<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
						<polyline points="17 8 12 3 7 8" />
						<line x1="12" y1="3" x2="12" y2="15" /></svg>
					アップロード
				</button>
				<button type="button" class="icon-dialog__link" data-action="remove">
					<svg viewBox="0 0 24 24" width="18" height="18" fill="none"
						stroke="currentColor" stroke-width="2" stroke-linecap="round"
						stroke-linejoin="round" aria-hidden="true">
						<polyline points="3 6 5 6 21 6" />
						<path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6" />
						<path d="M10 11v6" />
						<path d="M14 11v6" />
						<path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2" /></svg>
					削除
				</button>
				<input type="file" hidden
					accept="image/png,image/jpeg,image/gif,image/webp">
			</div>

			<div class="icon-dialog__footer">
				<span class="icon-dialog__note">変更は、このアプリのすべての画面に反映されます。</span>
				<button type="button" class="icon-dialog__btn" data-action="close">閉じる</button>
				<button type="button"
					class="icon-dialog__btn icon-dialog__btn--primary"
					data-action="save" disabled>保存</button>
			</div>
		</div>
	</dialog>

	<script>
	(function () {
	    var dlg = document.getElementById('iconDialog');
	    if (!dlg || typeof dlg.showModal !== 'function') { return; }

	    // ホバーカード(:hover で出し入れしている)や、他の要素の重なりの影響を受けないよう、
	    // ダイアログは body の直下へ移す
	    document.body.appendChild(dlg);

	    var cfg = {
	        uploadUrl: dlg.dataset.uploadUrl,
	        iconUrl: dlg.dataset.iconUrl,
	        hasIcon: dlg.dataset.hasIcon === 'true',
	        initial: dlg.dataset.initial || '',
	        hue: dlg.dataset.hue || '200'
	    };
	    var MAX_BYTES = 2 * 1024 * 1024; // サーバー側の上限(2MB)と同じ
	    var OK_TYPES = ['image/png', 'image/jpeg', 'image/gif', 'image/webp'];
	    var MESSAGES = {
	        empty: 'ファイルを選択してください。',
	        invalid: 'PNG / JPEG / GIF / WebP の画像を選んでください。',
	        toolarge: '画像は2MB以下にしてください。',
	        error: '保存できませんでした。もう一度ログインして、やり直してください。',
	        network: '通信に失敗しました。接続を確認して、もう一度試してください。'
	    };
	    var CAMERA_SVG = '<svg viewBox="0 0 24 24" width="30" height="30" fill="none" ' +
	        'stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' +
	        '<path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>' +
	        '<circle cx="12" cy="13" r="4"/></svg>';

	    var preview = dlg.querySelector('.icon-dialog__preview');
	    var msgEl = dlg.querySelector('.icon-dialog__msg');
	    var fileInput = dlg.querySelector('input[type=file]');
	    var pickBtn = dlg.querySelector('[data-action=pick]');
	    var removeBtn = dlg.querySelector('[data-action=remove]');
	    var closeBtn = dlg.querySelector('[data-action=close]');
	    var saveBtn = dlg.querySelector('[data-action=save]');

	    var pendingFile = null;   // これから保存する新しい画像
	    var pendingUrl = null;    // そのプレビュー用の一時URL
	    var pendingDelete = false; // 今の画像を削除するか
	    var saving = false;

	    function showMsg(text) { msgEl.textContent = text || ''; }

	    function clearPending() {
	        if (pendingUrl) { URL.revokeObjectURL(pendingUrl); }
	        pendingFile = null;
	        pendingUrl = null;
	    }

	    // いまの状態に合わせて、プレビューとボタンを描き直す
	    function render() {
	        preview.textContent = '';
	        preview.style.setProperty('--h', cfg.hue);

	        var src = null;
	        if (pendingFile) { src = pendingUrl; }
	        else if (!pendingDelete && cfg.hasIcon) { src = cfg.iconUrl; }

	        if (src) {
	            var img = document.createElement('img');
	            img.src = src;
	            img.alt = '';
	            preview.appendChild(img);
	        } else {
	            preview.textContent = cfg.initial; // 画像なし: 頭文字
	        }

	        var changed = !!pendingFile || pendingDelete;
	        saveBtn.disabled = !changed || saving;
	        pickBtn.disabled = saving;
	        removeBtn.disabled = saving || (!pendingFile && (!cfg.hasIcon || pendingDelete));
	    }

	    function resetState() {
	        clearPending();
	        pendingDelete = false;
	        saving = false;
	        fileInput.value = '';
	        saveBtn.textContent = '保存';
	        showMsg('');
	        render();
	    }

	    function openDialog() {
	        resetState();
	        dlg.showModal();
	    }

	    // ----- 大きいアイコンに、カメラのボタンを重ねる -----
	    var big = document.querySelector('.user-badge__card .avatar--lg');
	    if (big) {
	        big.classList.add('avatar--editable');
	        var cam = document.createElement('button');
	        cam.type = 'button';
	        cam.className = 'avatar-edit';
	        cam.setAttribute('aria-label', 'プロフィール画像を変更');
	        cam.innerHTML = CAMERA_SVG;
	        cam.addEventListener('click', openDialog);
	        big.appendChild(cam);
	    }

	    // ----- ウィンドウの中の操作 -----
	    pickBtn.addEventListener('click', function () { fileInput.click(); });

	    fileInput.addEventListener('change', function () {
	        var f = fileInput.files[0];
	        fileInput.value = ''; // 同じファイルをもう一度選べるようにする
	        if (!f) { return; }
	        if (OK_TYPES.indexOf(f.type) < 0) { showMsg(MESSAGES.invalid); return; }
	        if (f.size > MAX_BYTES) { showMsg(MESSAGES.toolarge); return; }

	        showMsg('');
	        clearPending();
	        pendingFile = f;
	        pendingUrl = URL.createObjectURL(f);
	        pendingDelete = false;
	        render();
	    });

	    removeBtn.addEventListener('click', function () {
	        showMsg('');
	        clearPending();
	        pendingDelete = cfg.hasIcon; // 元の画像があるときだけ「削除する」状態にする
	        render();
	    });

	    closeBtn.addEventListener('click', function () { dlg.close(); });
	    dlg.addEventListener('click', function (e) { if (e.target === dlg) { dlg.close(); } }); // 外側を押したとき
	    dlg.addEventListener('close', resetState); // Escキーで閉じたときも、状態を戻す

	    saveBtn.addEventListener('click', async function () {
	        if (saving) { return; }
	        saving = true;
	        saveBtn.textContent = '保存中...';
	        render();

	        var fd = new FormData();
	        if (pendingFile) { fd.append('icon', pendingFile); }
	        else if (pendingDelete) { fd.append('action', 'delete'); }

	        var code = 'error';
	        try {
	            // ?ajax=1 を付けると、サーバーは画面遷移せずに、結果だけを返す
	            var res = await fetch(cfg.uploadUrl + '?ajax=1', {
	                method: 'POST',
	                body: fd,
	                credentials: 'same-origin'
	            });
	            try {
	                code = (await res.json()).result;
	            } catch (e) {
	                // JSONでなかったとき(上限超過などで画面遷移された場合)は、遷移先のURLから結果を読む
	                code = new URL(res.url).searchParams.get('iconResult') || 'error';
	            }
	        } catch (e) {
	            code = 'network';
	        }

	        if (code === 'ok' || code === 'deleted') {
	            location.reload(); // 全画面のアイコンを最新にするため、再読み込みする
	            return;
	        }

	        saving = false;
	        saveBtn.textContent = '保存';
	        showMsg(MESSAGES[code] || MESSAGES.error);
	        render();
	    });
	})();
	</script>
</c:if>
