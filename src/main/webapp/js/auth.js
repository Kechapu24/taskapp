/**
 * ログイン画面・新規登録画面で共通して使うスクリプト。
 *  1. パスワードの表示/非表示の切り替え(目のアイコン)
 *  2. 送信ボタンを押した後の無効化(二重送信の防止)
 */

// 目のアイコン(SVG)。
//   EYE     = 今は隠れている(押すと表示される)
//   EYE_OFF = 今は表示中(押すと隠れる)
var EYE =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ' +
    'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' +
    '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>' +
    '<circle cx="12" cy="12" r="3"/></svg>';

var EYE_OFF =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ' +
    'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' +
    '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/>' +
    '<path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>' +
    '<path d="M14.12 14.12a3 3 0 1 1-4.24-4.24"/>' +
    '<line x1="1" y1="1" x2="23" y2="23"/></svg>';

document.addEventListener('DOMContentLoaded', function () {

    // ---------- 1. パスワードの表示/非表示 ----------
    // <button class="password-toggle" data-target="入力欄のid"> を押すと、
    // data-target で指定された入力欄の type を password <-> text に切り替える
    document.querySelectorAll('.password-toggle').forEach(function (btn) {

        // 最初は「隠れている」状態のアイコンを入れる
        btn.innerHTML = EYE;
        btn.setAttribute('aria-label', 'パスワードを表示する');
        btn.setAttribute('aria-pressed', 'false');

        btn.addEventListener('click', function () {
            var input = document.getElementById(btn.dataset.target);
            if (!input) { return; }

            var show = (input.type === 'password');
            input.type = show ? 'text' : 'password';
            btn.innerHTML = show ? EYE_OFF : EYE;
            btn.setAttribute('aria-label',
                show ? 'パスワードを隠す' : 'パスワードを表示する');
            btn.setAttribute('aria-pressed', show ? 'true' : 'false');
        });
    });

    // ---------- 2. 二重送信の防止 ----------
    // data-prevent-double-submit が付いたフォームだけが対象
    document.querySelectorAll('form[data-prevent-double-submit]').forEach(function (form) {
        form.addEventListener('submit', function (event) {

            // すでに送信済みなら、2回目の送信を止める(Enterキーの連打対策)
            if (form.dataset.submitted === 'true') {
                event.preventDefault();
                return;
            }
            form.dataset.submitted = 'true';

            // 送信ボタンを押せない状態にして、文字を変える
            var submitBtn = form.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.dataset.originalText = submitBtn.textContent;
                submitBtn.textContent = '送信中...';
                submitBtn.disabled = true;
            }
        });
    });
});

// ブラウザの「戻る」で戻ってきたとき、ボタンが無効のまま残らないようにする
window.addEventListener('pageshow', function (event) {
    if (!event.persisted) { return; }

    document.querySelectorAll('form[data-prevent-double-submit]').forEach(function (form) {
        form.dataset.submitted = 'false';
        var submitBtn = form.querySelector('button[type="submit"]');
        if (submitBtn && submitBtn.dataset.originalText) {
            submitBtn.textContent = submitBtn.dataset.originalText;
            submitBtn.disabled = false;
        }
    });
});