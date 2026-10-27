---
layout: default 
title: Home 
sidebar_link: true
---

# Featured Projects  

{% assign sorted_projects = site.projects | sort: 'priority' %}

<div class="card_box">
    {% for project in sorted_projects %}
        {% if project.featured %}
            {% include card.html project=project %}
        {% endif %}
    {% endfor %}
</div>

# Other Projects

<div class="card_box">
    {% for project in sorted_projects %}
        {% unless project.featured %}
            {% include card.html project=project %}
        {% endunless %}
    {% endfor %}
</div>