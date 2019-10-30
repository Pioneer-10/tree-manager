[% WRAPPER page.tpl %]
[% IF (error_message) %]
<div class="alert alert-danger" role="alert">[% error_message |html %]</div>
[% END %]
<form method="POST" action="/add_node/">
	<table class="table table-striped">
		<thead><tr>
			<th>ID</th>
			<th>Level</th>
			<th></th>
			<th></th>
		</tr></thead>
		<tbody>
			[% FOREACH item IN node_list %]
			<tr>
				<td>[% item.id |html %]</td>
				<td>[% item.level |html %]</td>
				<td style="padding-left: [% item.level * 3 |html %]em">[% PROCESS node_item.tpl |html %]</td>
				<td>
					<button class="btn btn-primary" name="pid" value="[% item.id |html %]">Add</button>
				</td>
			</tr>
			[% END %]
		</tbody>
		[% IF (pager) %]
		<tfoot>
			<tr><td colspan="4">
				<nav><ul class="pager">
				[% IF (pager.prev_page) %]
					[% IF (pager.prev_page > 1) %]
					<li><a href="?page=1">1</a></li>
					[% END %]
					<li><a href="?page=[% pager.prev_page |html %]">Previous</a></li>
				[% END %]
					<li>[% pager.page |html %]</li>
				[% IF (pager.next_page) %]
					<li><a href="?page=[% pager.next_page |html %]">Next</a></li>
				[% END %]
				</ul></nav>
			</td></tr>
		</tfoot>
		[% END %]
	</table>
</form>
[% END %][%# WRAPPER %]
