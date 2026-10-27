---
layout: default 
title: Home 
sidebar_link: true
---
# Welcome!

Welcome to my page!
This page serves as a prettier version of my github profile page, giving my projects more context
and better formatting than a normal readme allows. 
The following lists are segmented into two categories: "Featured projects", which are projects of a more defined
scope and a substential time investment, and smaller and more open-ended projects.   

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