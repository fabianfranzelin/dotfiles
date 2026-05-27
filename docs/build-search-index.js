#!/usr/bin/env node

/**
 * build-search-index.js
 *
 * Scans the published HTML files, extracts title and text content,
 * and generates a pre-built lunr.js search index (search-index.json).
 *
 * Usage: node build-search-index.js <public-dir>
 * Example: node build-search-index.js ./public/internal/org
 */

const fs = require('fs');
const path = require('path');
const lunr = require('lunr');

const publicDir = process.argv[2] || './public/internal/org';

function getHtmlFiles(dir) {
  let results = [];
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      results = results.concat(getHtmlFiles(fullPath));
    } else if (entry.name.endsWith('.html')) {
      results.push(fullPath);
    }
  }
  return results;
}

function stripHtml(html) {
  // Remove script/style content
  html = html.replace(/<(script|style)[^>]*>[\s\S]*?<\/\1>/gi, '');
  // Remove HTML tags
  html = html.replace(/<[^>]+>/g, ' ');
  // Decode common entities
  html = html.replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&nbsp;/g, ' ');
  // Collapse whitespace
  html = html.replace(/\s+/g, ' ').trim();
  return html;
}

function extractTitle(html) {
  // Try <title> tag first
  const titleMatch = html.match(/<title[^>]*>(.*?)<\/title>/i);
  if (titleMatch) return titleMatch[1].replace(/<[^>]+>/g, '').trim();
  // Try <h1>
  const h1Match = html.match(/<h1[^>]*>(.*?)<\/h1>/i);
  if (h1Match) return h1Match[1].replace(/<[^>]+>/g, '').trim();
  return '';
}

function extractContent(html) {
  // Try to get just the #content div
  const contentMatch = html.match(/<div id="content">([\s\S]*?)<\/div>\s*<div id="postamble"/i);
  if (contentMatch) return stripHtml(contentMatch[1]);
  // Fallback: get body content
  const bodyMatch = html.match(/<body[^>]*>([\s\S]*?)<\/body>/i);
  if (bodyMatch) return stripHtml(bodyMatch[1]);
  return stripHtml(html);
}

// Main
const htmlFiles = getHtmlFiles(publicDir);
const documents = {};

htmlFiles.forEach(function (filePath) {
  const html = fs.readFileSync(filePath, 'utf-8');
  const title = extractTitle(html);
  const content = extractContent(html);
  const url = path.relative(publicDir, filePath);

  if (!title && !content) return;

  const id = path.relative(publicDir, filePath);
  const snippet = content.substring(0, 150) + (content.length > 150 ? '...' : '');

  documents[id] = {
    title: title,
    url: url,
    snippet: snippet,
    content: content
  };
});

// Build the lunr index
const idx = lunr(function () {
  this.ref('id');
  this.field('title', { boost: 10 });
  this.field('content');

  var builder = this;
  Object.keys(documents).forEach(function (id) {
    const filePath = path.join(publicDir, id);
    const html = fs.readFileSync(filePath, 'utf-8');
    const content = extractContent(html);

    builder.add({
      id: id,
      title: documents[id].title,
      content: content
    });
  });
});

// Write the index
const output = {
  index: idx.toJSON(),
  documents: documents
};

const outputPath = path.join(publicDir, 'search-index.json');
fs.writeFileSync(outputPath, JSON.stringify(output));
console.log('Search index written to ' + outputPath);
console.log('Indexed ' + Object.keys(documents).length + ' documents');
