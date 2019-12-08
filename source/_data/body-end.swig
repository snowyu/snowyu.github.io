{# {%- if page.reactive %}
{% set vCollapsed = page.reactive.collapsed or false %}
<script {{ pjax }}>
NexT.utils.getScript('/assets/js/imarkdown-0.4.0-min.js', () => {
  window.iMarkdown.makeActive({"collapsed_code":{{vCollapsed}},"debug":false,"filename":"{{page.title}}.md"});
}, window.iMarkdown);
</script>
{%- endif %} #}

{# {%- if theme.mermaid.enable and page.mermaid %} #}
<script {{ pjax }}>
if (document.querySelectorAll('pre code.mermaid').length) {
  NexT.utils.getScript('//cdn.jsdelivr.net/npm/mermaid@8/dist/mermaid.min.js', () => {
    mermaid.initialize({
      theme: 'forest',
      logLevel: 3,
      flowchart: { curve: 'linear' },
      gantt: { axisFormat: '%m/%d/%Y' },
      sequence: { actorMargin: 50 }
    });
  }, window.mermaid);
}
</script>
{# {%- endif %} #}
