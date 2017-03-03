{% extends '_layout.swig' %}
{% import '_macro/post.swig' as post_template %}
{% import '_macro/sidebar.swig' as sidebar_template %}


{% block title %} {{ page.title }} | {{ config.title }} {% endblock %}

{% block page_class %}page-post-detail{% endblock %}


{% block content %}

  <div id="posts" class="posts-expand">
    {{ post_template.render(page) }}

    <div class="post-spread">
      {% if theme.jiathis %}
        {% include '_partials/share/jiathis.swig' %}
      {% elseif theme.baidushare %}
        {% include '_partials/share/baidushare.swig' %}
      {% elseif theme.add_this_id %}
        {% include '_partials/share/add-this.swig' %}
      {% elseif theme.duoshuo_shortname and theme.duoshuo_share %}
        {% include '_partials/share/duoshuo_share.swig' %}
      {% endif %}
    </div>
  </div>

	<style type="text/css">
	.donate_bar.hidden {
		display: none;
	}
	.donate_bar.center {
		text-align: center;
	}
	.donate_bar a#btn_donate{
		margin-top: 0.8em;
		display: inline-block;
		width: 82px;
		height: 82px;
		background: url("/images/btn_reward.gif") no-repeat;
		_background: url("/images/btn_reward.gif") no-repeat;

		-webkit-transition: background 0s;
		-moz-transition: background 0s;
		-o-transition: background 0s;
		-ms-transition: background 0s;
		transition: background 0s;
	}
	.donate_bar a#btn_donate:hover{ background-position: 0px -82px; }
	.donate_bar .donate_txt {
		display: block;
		color: #9d9d9d;
		font: 14px/2 "Microsoft Yahei";
	}
	.bold{ font-weight: bold; }
	</style>
	<div class ="post-donate">
		<div id="donate_board" class="donate_bar center">
			<a id="btn_donate" href="/images/donate.svg" class="fancybox" title="Donate 打赏"></a>
			<span class="donate_txt">
				&uarr;<br>
				Enjoy it ? Donate me !  欣赏此文？求鼓励，求支持！
			</span>
			<br>
		</div>
	</div>
{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(true) }}
{% endblock %}


{% block script_extra %}
  {% include '_scripts/pages/post-details.swig' %}
{% endblock %}
