---
layout: page
title: All Posts
permalink: /all-posts/
---

Here are all blog posts, listed chronologically:

<div class="post-list">
  {%- assign all_posts = site.posts | sort: 'date' | reverse -%}
  
  {%- for post in all_posts -%}
    <article class="post-item">
      <header class="post-header">
        <h3 class="post-title">
          <a class="post-link" href="{{ post.url | relative_url }}">
            {{ post.title | escape }}
          </a>
        </h3>
        <p class="post-meta">
          <time class="dt-published" datetime="{{ post.date | date_to_xmlschema }}" itemprop="datePublished">
            {%- assign date_format = site.minima.date_format | default: "%b %-d, %Y" -%}
            {{ post.date | date: date_format }}
          </time>
        </p>
      </header>
      
      {%- if post.excerpt -%}
        <div class="post-excerpt">
          {{ post.excerpt | strip_html | truncate: 150 }}
        </div>
      {%- endif -%}
    </article>
  {%- endfor -%}
</div>

<div class="back-link">
  <a href="{{ '/' | relative_url }}">← Back to Home</a>
</div>

<style>
.post-list {
  margin: 2rem 0;
}

.post-item {
  border-bottom: 1px solid #e1e4e8;
  padding: 1.5rem 0;
}

.post-item:last-child {
  border-bottom: none;
}

.post-item .post-header {
  margin-bottom: 0.5rem;
}

.post-item .post-title {
  margin: 0 0 0.25rem 0;
  font-size: 1.125rem;
}

.post-item .post-link {
  text-decoration: none;
  color: #0366d6;
}

.post-item .post-link:hover {
  text-decoration: underline;
}

.post-item .post-meta {
  margin: 0;
  font-size: 0.875rem;
  color: #586069;
}

.post-item .post-excerpt {
  margin: 0.75rem 0 0 0;
  color: #444;
  line-height: 1.5;
}

.back-link {
  margin: 2rem 0;
  padding-top: 1rem;
  border-top: 1px solid #e1e4e8;
}

.back-link a {
  color: #0366d6;
  text-decoration: none;
}

.back-link a:hover {
  text-decoration: underline;
}
</style>