				{hook run='content_end'}
			</div> <!-- /content -->
		</div> <!-- /content-wrapper -->
	</div> <!-- /wrapper -->


	
	<footer id="footer">
		<p>Все права принадлежат пони. Весь мир принадлежит пони.</p>
		{hook run='footer_end'}
	</footer>
</div> <!-- /container -->

{include file='toolbar.tpl'}
{if isset($sMarkItUpBundle)}
	<script src="{cfg name='path.static.url'}/{$sMarkItUpBundle}.bundle.js" type="text/javascript"></script>
{/if}
{hook run='body_end'}

</body>
</html>
