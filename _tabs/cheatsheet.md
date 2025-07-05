---
title: Cheatsheet
icon: fas fa-book
order: 4
layout: page
---

<a id="skip-to-content" href="#cheatsheet-content" style="position:absolute;left:-9999px;top:auto;width:1px;height:1px;overflow:hidden;">
  Aller au contenu
</a>

<nav id="toc" style="margin: 2rem auto; max-width: 900px;">
  <h2>Table des matières</h2>
  <ul>
    {% assign sorted_cheatsheets = site.cheatsheets | sort: "title" %}
    {% for cheatsheet in sorted_cheatsheets %}
    <li><a href="{{ cheatsheet.url }}">{{ cheatsheet.title }}</a></li>
    {% endfor %}
  </ul>
</nav>

<hr id="cheatsheet-content" />

<style>
.card-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 20px;
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.card {
  background: linear-gradient(145deg, #252525, #1a1a1a);
  border: 1px solid #3a3a3a;
  border-radius: 10px;
  padding: 24px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
  transition: all 0.3s ease;
  color: #e6e6e6;
  text-align: center;
  display: flex;
  flex-direction: column;
  justify-content: center;
  min-height: 150px;
}

.card:hover {
  transform: scale(1.03);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.4);
  border-color: #58a6ff;
}

.card h3 {
  margin: 0 0 12px;
  font-size: 1.25em;
  font-weight: 600;
  color: #58a6ff;
}

.card p {
  margin: 0;
  font-size: 0.85em;
  color: #b3b3b3;
  line-height: 1.4;
}

.card a {
  text-decoration: none;
  color: inherit;
  display: block;
}

.card a:hover {
  text-decoration: none;
}
</style>

<div class="card-container">
  {% for cheatsheet in site.cheatsheets %}
  <div class="card">
    <a href="{{ cheatsheet.url }}">
      <h3>{{ cheatsheet.title }}</h3>
      <p>{{ cheatsheet.description }}</p>
    </a>
  </div>
  {% endfor %}
</div>
