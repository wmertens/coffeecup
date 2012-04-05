#!/usr/bin/env coffee

count = 50000

log = console.log

maybeDo = (engine) ->
  try
    require engine
  catch error
    log "#{engine} not installed, not running tests"
    null

coffeecup = require './src/coffeecup'
ck = maybeDo "ck"
jade = maybeDo 'jade'
ejs = maybeDo 'ejs'
eco = maybeDo 'eco'
haml = maybeDo 'haml'

data =
  title: 'test'
  inspired: no
  users: [
    {email: 'house@gmail.com', name: 'house'}
    {email: 'cuddy@gmail.com', name: 'cuddy'}
    {email: 'wilson@gmail.com', name: 'wilson'}
  ]

coffeecup_template = ->
  doctype 5
  html lang: 'en', ->
    head ->
      meta charset: 'utf-8'
      title @title
      style '''
        body {font-family: "sans-serif"}
        section, header {display: block}
      '''
    body ->
      section ->
        header ->
          h1 @title
        if @inspired
          p 'Create a witty example'
        else
          p 'Go meta'
        ul ->
          for user in @users
            li user.name
            li -> a href: "mailto:#{user.email}", -> user.email

coffeecup_compiled_template = coffeecup.compile coffeecup_template
coffeecup_compiled_template_f = coffeecup.compile coffeecup_template, format: yes

coffeecup_optimized_template = coffeecup.compile coffeecup_template, optimize: yes
coffeecup_optimized_template_f = coffeecup.compile coffeecup_template, optimize: yes, format: yes

ck_compiled_template = ck.compile coffeecup_template if ck
ck_compiled_template_f = ck.compile coffeecup_template, format: yes if ck

jade_template = '''
  !!! 5
  html(lang="en")
    head
      meta(charset="utf-8")
      title= title
      style
        | body {font-family: "sans-serif"}
        | section, header {display: block}
    body
      section
        header
          h1= title
        - if (inspired)
          p Create a witty example
        - else
          p Go meta
        ul
          - each user in users
            li= user.name
            li
              a(href="mailto:"+user.email)= user.email
'''

jade_compiled_template = jade.compile jade_template if jade

ejs_template = '''
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
      <title><%= title %></title>
      <style>
        body {font-family: "sans-serif"}
        section, header {display: block}
      </style>
    </head>
    <body>
      <section>
        <header>
          <h1><%= title %></h1>
        </header>
        <% if (inspired) { %>
          <p>Create a witty example</p>
        <% } else { %>
          <p>Go meta</p>
        <% } %>
        <ul>
          <% for (user in users) { %>
            <li><%= user.name %></li>
            <li><a href="mailto:<%= user.email %>"><%= user.email %></a></li>
          <% } %>
        </ul>
      </section>
    </body>
  </html>
'''

eco_template = '''
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
      <title><%= @title %></title>
      <style>
        body {font-family: "sans-serif"}
        section, header {display: block}
      </style>
    </head>
    <body>
      <section>
        <header>
          <h1><%= @title %></h1>
        </header>
        <% if @inspired: %>
          <p>Create a witty example</p>
        <% else: %>
          <p>Go meta</p>
        <% end %>
        <ul>
          <% for user in @users: %>
            <li><%= user.name %></li>
            <li><a href="mailto:<%= user.email %>"><%= user.email %></a></li>
          <% end %>
        </ul>
      </section>
    </body>
  </html>
'''

eco_compiled_template = eco.compile eco_template if eco

haml_template = '''
  !!! 5
  %html{lang: "en"}
    %head
      %meta{charset: "utf-8"}
      %title= title
      :css
        body {font-family: "sans-serif"}
        section, header {display: block}
    %body
      %section
        %header
          %h1= title
        :if inspired
          %p Create a witty example
        :if !inspired
          %p Go meta
        %ul
          :each user in users
            %li= user.name
            %li
              %a{href: "mailto:#{user.email}"}= user.email
'''

haml_template_compiled = haml(haml_template) if haml

benchmark = (title, code) ->
  start = new Date
  for i in [1..count]
    code()
  log "#{title}: #{new Date - start} ms"

hr = -> log "===================================================================="

log "Resulting template code:\n"

log "Coffeecup:"
log coffeecup_compiled_template_f.toString()
hr()
log "Coffeecup optimized:"
log coffeecup_optimized_template_f.toString()
if ck
  hr()
  log "ck: all hidden, sorry. Here's the frontend that uses a private fn and scope:"
  log ck_compiled_template.toString()
log "\n\n"
hr()
log "\nResulting HTML:"
log "Coffeecup:"
log coffeecup_compiled_template_f data
hr()
log "Coffeecup optimized:"
log coffeecup_optimized_template_f data
if ck
  hr()
  log "ck:"
  log ck_compiled_template context:data
if jade
  hr()
  log "Jade:"
  log jade_compiled_template data
if haml
  hr()
  log "HAML:"
  log haml_template_compiled data
if eco
  hr()
  log "Eco:"
  log eco_compiled_template data

log "\n\n"
hr()
log "\nTime for #{count} runs (lower is better):"
benchmark 'coffeecup (precompiled)', -> coffeecup_compiled_template data
benchmark 'coffeecup (precompiled,format)', -> coffeecup_compiled_template data
benchmark 'coffeecup (precompiled,optimized)', -> coffeecup_optimized_template data
benchmark 'coffeecup (precompiled,optimized,format)', -> coffeecup_optimized_template data
if ck
  benchmark 'ck (precompiled)', -> ck_compiled_template context:data
  benchmark 'ck (precompiled,format)', -> ck_compiled_template context:data
if jade
  benchmark 'Jade (precompiled)', -> jade_compiled_template data
if haml
  benchmark 'haml-js (precompiled)', -> haml_template_compiled data
if eco
  benchmark 'Eco (precompiled)', -> eco_compiled_template data

log "\nRuntime, not precompiled:\n"

benchmark 'coffeecup (function, cache on)', -> coffeecup.render coffeecup_template, data, cache: on
benchmark 'coffeecup (function, cache on, optimized)', -> coffeecup.render coffeecup_template, data, cache: on, optimize: on
if jade
  benchmark 'Jade (cache on)', -> jade.render jade_template, locals: data, cache: on, filename: 'test'
if ejs
  benchmark 'ejs (cache on)', -> ejs.render ejs_template, locals: data, cache: on, filename: 'test'
if eco
  benchmark 'Eco', -> eco.render eco_template, data

