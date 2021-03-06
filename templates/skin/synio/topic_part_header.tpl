{assign var="oBlog" value=$oTopic->getBlog()}
{assign var="oUser" value=$oTopic->getUser()}
{assign var="oVote" value=$oTopic->getVote()}

{if $oVote || ($oUserCurrent && $oTopic->getUserId() == $oUserCurrent->getId()) || strtotime($oTopic->getDateAdd()) < $smarty.now-$oConfig->GetValue('acl.vote.topic.limit_time')}
	{assign var="bVoteInfoShow" value=true}
{/if}

<article class="topic topic-type-{$oTopic->getType()} js-topic">
    <header class="topic-header">
        {strip}
            <h1 class="topic-title word-wrap">
                {if $bTopicList}
                    <a href="{$oTopic->getUrl()}">{$oTopic->getTitle()|escape:'html'}</a>
                {else}
                    {$oTopic->getTitle()|escape:'html'}
                {/if}

                {if $oTopic->getPublish() == 0}
                    <i class="icon-synio-topic-draft" title="{$aLang.topic_unpublish}"></i>
                {/if}
            </h1>
		{/strip}
		<div class="topic-info">
			<div class="topic-info-vote">
				<div id="vote_area_topic_{$oTopic->getId()}" class="vote-topic
					{if $oVote || ($oUserCurrent && $oTopic->getUserId() == $oUserCurrent->getId()) || strtotime($oTopic->getDateAdd()) < $smarty.now-$oConfig->GetValue('acl.vote.topic.limit_time')}
						{if $oTopic->getRating() > 0}
							vote-count-positive
						{elseif $oTopic->getRating() < 0}
							vote-count-negative
						{elseif $oTopic->getRating() == 0}
							vote-count-zero
						{/if}
					{/if}
					
					{if !$oUserCurrent or ($oUserCurrent && $oTopic->getUserId() != $oUserCurrent->getId())}
						vote-not-self
					{/if}
					
					{if $oVote} 
						voted
						{if $oVote->getDirection() > 0}
							voted-up
						{elseif $oVote->getDirection() < 0}
							voted-down
						{elseif $oVote->getDirection() == 0}
							voted-zero
						{/if}
					{else}
						not-voted
					{/if}
					
					{if (strtotime($oTopic->getDateAdd()) < $smarty.now-$oConfig->GetValue('acl.vote.topic.limit_time') && !$oVote) || ($oUserCurrent && $oTopic->getUserId() == $oUserCurrent->getId())}
						vote-nobuttons
					{/if}
					
					{if strtotime($oTopic->getDateAdd()) > $smarty.now-$oConfig->GetValue('acl.vote.topic.limit_time')}
						vote-not-expired
					{/if}">

					<div class="vote-item vote-up"{if $oUserCurrent and $oUserCurrent->isAdministrator()} style="display: block;"{/if} onclick="return ls.vote.vote({$oTopic->getId()},this,1,'topic');"><span><i></i></span></div>
					<div class="vote-item vote-count" title="{$aLang.topic_vote_count}: {$oTopic->getCountVote()}">
						<span id="vote_total_topic_{$oTopic->getId()}">
							{if $bVoteInfoShow}
								{if $oTopic->getRating() > 0}+{/if}{$oTopic->getRating()}
							{else}
								<i onclick="return ls.vote.vote({$oTopic->getId()},this,0,'topic');">?</i>
							{/if}
						</span>
					</div>
					<div class="vote-item vote-down"{if $oUserCurrent and $oUserCurrent->isAdministrator()} style="display: block;"{/if} onclick="return ls.vote.vote({$oTopic->getId()},this,-1,'topic');"><span><i></i></span></div>
				</div>
			</div>

			<a href="{$oUser->getUserWebPath()}"><img src="{$oUser->getProfileAvatarPath(24)}"  class="avatar" /></a>
			<a rel="author" href="{$oUser->getUserWebPath()}">{$oUser->getLogin()}</a> в блоге
			<a href="{$oBlog->getUrlFull()}" class="topic-blog{if $oBlog->getType()=='close'} private-blog{/if}">{$oBlog->getTitle()|escape:'html'}</a>


		{if $oTopic->getIsAllowAction()}
			<span class="topic-actions">
				{if $oTopic->getIsAllowEdit()}
					<span class="edit"><i class="icon-synio-actions-edit"></i><a href="{$oTopic->getUrlEdit()}" title="{$aLang.topic_edit}" class="actions-edit">{$aLang.topic_edit}</a></span>
				{/if}

				{if $oTopic->getIsAllowDelete()}
					<span class="delete"><i class="icon-synio-actions-delete"></i><a href="{router page='topic'}delete/{$oTopic->getId()}/?security_ls_key={$LIVESTREET_SECURITY_KEY}" title="{$aLang.topic_delete}" onclick="return confirm('{$aLang.topic_delete_confirm}');" class="actions-delete">{$aLang.topic_delete}</a></span>
				{/if}
			</span>
		{/if}
		</div>
	</header>
