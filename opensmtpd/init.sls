{% from 'opensmtpd/map.jinja' import opensmtpd -%}
{% from 'opensmtpd/defaults.jinja' import defaults -%}
opensmtpd:
    pkg:
        - installed
{%- if opensmtpd.pkg != 'opensmtpd' %}
        - name: {{ opensmtpd.pkg }}
{%- endif %}
    service.running:
{%- if opensmtpd.service != 'opensmtpd' %}
        - name: {{ opensmtpd.service }}
{%- endif %}
        - enable: True
        - require:
            - file: smtpd.conf

smtpd.conf:
    file.managed:
        - name: {{ opensmtpd.configdir }}/smtpd.conf
        - source: salt://opensmtpd/files/smtpd.conf
        - template: jinja
        - mode: 644
        - require:
            - pkg: opensmtpd

{% if salt['pillar.get']('opensmtpd:mailname', False) -%}
mailname:
    file.managed:
        - name: {{ opensmtpd.configdir }}/mailname
        - contents_pillar: opensmtpd:mailname
        - required_in:
            - service: opensmtpd
{% endif -%}

{% for table, details in salt['pillar.get'](
        'opensmtpd:tables', defaults['tables']).items() -%}
    {% if 'type' in details and details.type != 'inline' -%}
table {{ table }}:
    file.managed: 
        - name: {% 
        if details.path.startswith('/') -%}
            {{ details.path }}
        {% else -%}
            {{ opensmtpd.configdir }}/{{ details.path }}
        {% endif -%}
    {%- endif %}
{%- endfor %}
