<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Set"%>
<%@ page import="java.util.Collections"%>

<%
@SuppressWarnings("unchecked")
List<Map<String, Object>> editorTagOptions = (List<Map<String, Object>>) request.getAttribute("tagOptions");

@SuppressWarnings("unchecked")
Set<Integer> selectedTagIds = (Set<Integer>) request.getAttribute("selectedTagIds");

if (editorTagOptions == null) {
	editorTagOptions = Collections.emptyList();
}

if (selectedTagIds == null) {
	selectedTagIds = Collections.emptySet();
}
%>

<div class="tag-editor">

	<label>タグ</label>

	<div class="tag-editor-combobox">

		<div class="tag-editor-control">

			<input type="text" class="tag-editor-search" placeholder="タグを検索して追加"
				autocomplete="off" onfocus="openTagEditor(this)"
				oninput="filterTagEditor(this)">

			<button type="button" class="tag-editor-toggle"
				onclick="toggleTagEditor(this)">▼</button>

		</div>

		<div class="tag-editor-menu">

			<%
			for (Map<String, Object> tag : editorTagOptions) {

				int tagId = (Integer) tag.get("tagId");

				String tagName = (String) tag.get("tagName");

				String tagColor = (String) tag.get("color");
			%>

			<button type="button" class="tag-editor-option"
				data-tag-id="<%=tagId%>" data-tag-color="<%=tagColor%>"
				onclick="selectExistingTag(this)">

				<span class="tag-color-dot" style="background-color:<%=tagColor%>">
				</span>

				<%=tagName%>

			</button>

			<%
			}
			%>

		</div>

	</div>


	<div class="selected-tags">

		<%
		for (Map<String, Object> tag : editorTagOptions) {

			int tagId = (Integer) tag.get("tagId");

			if (!selectedTagIds.contains(tagId)) {
				continue;
			}

			String tagName = (String) tag.get("tagName");

			String tagColor = (String) tag.get("color");
		%>

		<span class="selected-tag" style="background-color:<%=tagColor%>">

			<%=tagName%> <input type="hidden" name="tag_ids" value="<%=tagId%>">

			<button type="button" onclick="removeTagChip(this)">×</button>

		</span>

		<%
		}
		%>

	</div>


	<label>新しいタグ</label>

	<div class="new-tag-row">

		<input type="text" class="new-tag-name" maxlength="50"
			placeholder="タグ名"> <input type="color" class="new-tag-color"
			value="#6B7280">

		<button type="button" onclick="addNewTag(this)">追加</button>

	</div>

</div>