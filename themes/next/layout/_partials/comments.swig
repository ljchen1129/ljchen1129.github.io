{% if page.comments %}
  <div class="comments" id="comments">
    {% if (theme.duoshuo and theme.duoshuo.shortname) or theme.duoshuo_shortname %}
      <div class="ds-thread" data-thread-key="{{ page.path }}"
           data-title="{{ page.title }}" data-url="{{ page.permalink }}">
      </div>
    {% elseif theme.facebook_sdk.enable and theme.facebook_comments_plugin.enable %}
      <div class="fb-comments"
           data-href="{{ page.permalink }}"
           data-numposts="{{ theme.facebook_comments_plugin.num_of_posts }}"
           data-width="{{ theme.facebook_comments_plugin.width }}"
           data-colorscheme="{{ theme.facebook_comments_plugin.scheme }}">
      </div>
    {% elseif theme.vkontakte_api.enable and theme.vkontakte_api.comments %}
      <div id="vk_comments"></div>
    {% elseif theme.disqus.enable %}
      <div id="disqus_thread">
        <noscript>
          Please enable JavaScript to view the
          <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a>
        </noscript>
      </div>
    {% elseif theme.hypercomments_id %}
      <div id="hypercomments_widget"></div>
    {% elseif theme.youyan_uid %}
      <div id="uyan_frame"></div>
    {% elseif theme.livere_uid %}
      <div id="lv-container" data-id="city" data-uid="{{ theme.livere_uid }}"></div>
    {% elseif theme.changyan.appid and theme.changyan.appkey %}
      <div id="SOHUCS"></div>

       {% elseif theme.wildfire.enable %}
      <style type="text/css">
        .wildfire_thread a {border-bottom: none}
      </style>
      <div class="wildfire_thread"></div>
      <script type="text/javascript">
        var wildfireConfig = () => ({
          databaseProvider: '{{ theme.wildfire.database_provider }}',
          databaseConfig: {
          {% if (theme.wildfire.database_provider) === 'wilddog' %}
            siteId: '{{ theme.wildfire.site_id }}'
          {% elseif (theme.wildfire.database_provider) === 'firebase' %}
            apiKey: '{{ theme.wildfire.api_key }}',
            authDomain: '{{ theme.wildfire.auth_domain }}',
            databaseURL: '{{ theme.wildfire.database_url }}',
            projectId: '{{ theme.wildfire.project_id }}',
            storageBucket: '{{theme.wildfire.storage_bucket}}',
            messagingSenderId: '{{theme.wildfire.messaging_sender_id}}'
          {% endif %}
          },
          theme: '{{theme.wildfire.theme}}',
          locale: '{{theme.wildfire.locale}}'
        })
      </script>
      <script src='https://unpkg.com/wildfire/dist/wildfire.auto.js'></script>
      

    {% endif %}
  </div>
{% endif %}
