#!/bin/sh

root='./'
werc_root='./werc/'

alias mkdir='mkdir -p'

# If $werc_root folder doesn't exist & Mercurial is installed, clone it.
[ ! -d $werc_root ] && command -v hg \
	&& hg clone https://code.9front.org/hg/werc $werc_root \
	&& cd $werc_root \
	&& hg checkout 700 # Switch to the last version having extra CSS style

mkdir "$root/layouts/partials/" \
      "$root/layouts/_default/"

echo '    {{ range .Site.Menus.main }}
    <a href="{{ .URL | relURL }}">{{ .Name }}</a>
    {{ end }}' > "$root/layouts/partials/top_bar.html"

sed '
s/<html>/<html lang="{{ .Site.LanguageCode }}">/;
s/%($pageTitle%)/{{ .Title }}/;
s,/pub/style/style.css,\{\{ "/pub/style/style.css" | relURL \}\},g;
/\s*%/d;
/^$/d;
' "$werc_root/lib/headers.tpl" > "$root/layouts/partials/headers.html"

echo {{ partial '"headers.html"' . }} > "$root/layouts/partials/default_master.html"
sed '
s/% cat `{ get_lib_file top_bar.inc }/        {{ partial "top_bar.html" . }}/;
s,%($"siteTitle%).*</a,{{ .Site.Title }}</a,;
s,%       run_handler $$h,\
        <ul class="dir-list">\
            {{ range .Site.Home.Pages }}\
            <li>\
                <a href="{{ .RelPermalink }}">› {{ .Title | markdownify }}/</a>\
            </li>\
            {{ end }}\
        </ul>\
,;
/<article>/q
/\s*%/d;
' "$werc_root/lib/default_master.tpl" >> "$root/layouts/partials/default_master.html"

echo '</article>
<footer>' > "$root/layouts/partials/footer.html"
cat "$werc_root/lib/footer.inc" >> "$root/layouts/partials/footer.html"
echo '</body></html>' >> "$root/layouts/partials/footer.html"

echo '{{ partial "default_master" . }}' > "$root/layouts/_default/single.html"
echo '{{ .Content }}' >> "$root/layouts/_default/single.html"
echo '{{ partial "footer" . }}' >> "$root/layouts/_default/single.html"

cp "$root/layouts/_default/single.html" "$root/layouts/_default/list.html"
sed -i '
s/<article>/<ul>/;
s,{{ .Content }},\
    {{ range .Pages }}\
    <li>\
        <a href="{{ .RelPermalink }}">{{ .Title | markdownify }}</a>\
    </li>\
    {{ end }}\
,;
s,</article>,</ul>,;
' "$root/layouts/_default/list.html"

echo '{{ partial "default_master" . }}' > "$root/layouts/404.html"
sed '
s/at .*'\'' //;
s/%($base_url%)/{{ .Site.BaseURL }}/;
/\s*%/d;
' "$werc_root/lib/404.tpl" >> "$root/layouts/404.html"
echo '{{ partial "footer" . }}' >> "$root/layouts/404.html"

mkdir "$root/static"
cp "$werc_root/pub/default_favicon.ico" "$root/static/favicon.ico"
mkdir "$root/static/pub/style"
cp "$werc_root/pub/style/style.css" "$root/static/pub/style/style.css"
