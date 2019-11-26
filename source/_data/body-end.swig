{%- if page.reactive %}
{% set vCollapsed = page.reactive.collapsed or false %}
<script src='/assets/js/imarkdown-0.4.0.js'></script><script>
window.iMarkdown.makeActive({"collapsed_code":{{vCollapsed}},"debug":false,"filename":"{{page.title}}.md"});</script>
{%- endif %}
