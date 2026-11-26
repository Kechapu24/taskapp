
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<div class="task-shared-modal"
     id="sharedTaskModal"
     hidden>

    <div class="task-shared-modal__dialog"
         role="dialog"
         aria-modal="true"
         aria-labelledby="sharedTaskModalTitle"
         tabindex="-1">

        <div class="task-shared-modal__header">

            <h2 id="sharedTaskModalTitle">
                タスク
            </h2>

            <button type="button"
                    class="task-shared-modal__close"
                    data-task-modal-close
                    aria-label="閉じる">
                ×
            </button>

        </div>

        <div class="task-shared-modal__body"
             id="sharedTaskModalBody">
        </div>

    </div>

</div>
