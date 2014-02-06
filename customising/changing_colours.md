---
layout: default
title: Changing colours
author: dave
---

# Customisation example: changing the colours

<p class="lead">
  This page describes how to change the colour scheme of your installation &mdash;
  which is a good starting point for further customisations.
</p>

You can override any of the CSS or HTML templates of your FixMyStreet
installation, but to begin with it's a good idea to just change the colours.
That way you can learn how FixMyStreet customisation works, before tackling
more complex layout, design, or code changes.

## Start simple!

FixMyStreet's default CSS comes with a few basic colour settings which you can
change. Remember that ultimately **you can override any styling for your own
site** but most of this page shows how to set your own colours *without adding
any new HTML or CSS*. We know that you'll want to change more than just the
default colours: but this is the best way to start.

Once you've done this, you'll have your own <a href="/glossary/#cobrand"
class="glossary">cobrand</a>, and can start changing other stylesheets and
templates in the same way.


##Why you should create a cobrand

A cobrand is just FixMyStreet's way of separating your customisation from
everybody else's. To start with, this is almost as simple as putting what you
need in its own directory.

<div class="attention-box warning">
  You <em>can</em> simply edit the default colours (just edit the values in
  <code>web/cobrands/default/_colours.scss</code> and run
  <code>bin/make_css</code>) but we <strong>strongly recommend</strong> you do
  not do that. It's OK if you just want to play with the colours to see what's
  possible, but the right way to change how your site looks is to make a
  cobrand.
</div>

By making your own cobrand you'll be keeping your changes separate from the
core code, but also keeping it within the main repository. This has serious
benefits later on: it means you can easily update the FixMyStreet code (we
frequently add new features, for example) while retaining your changes.


## How to change the colours


This is the process:

1. pick a name for your cobrand
2. update your config to use the new cobrand
3. create a directory for it in `web/cobrands`
4. copy the default cobrand's CSS into it
5. edit the colours
6. run `bin/make_css`


The rest of this page describes each step in detail.


### Pick a name for your cobrand

Choose a name for your cobrand. In the examples below, we've used `fixmypark`,
but you can use anything provided it's not a cobrand already in use in the
code. Only use lower case letters. This name is never seen by the public &mdash;
it's FixMyStreet's internal name for it.

### Update your config to use the new cobrand

You need to tell FixMyStreet to use your cobrand instead of the default one.

FixMyStreet uses the `ALLOWED_COBRANDS` <a href="glossary/#config-variable"
class="glossary">config variable</a> to decide which cobrand to use.

In `conf/general.yml`, change `ALLOWED_COBRANDS` to include just one entry,
with your new cobrand like this:

    ALLOWED_COBRANDS:
      - fixmypark

In fact, `ALLOWED_COBRANDS` is a little more complex that it looks. If you give
it a list of cobrands, it will decide which one to use depending on string
matches on the incoming URL *for every request* (see the explanation about
[ALLOWED_COBRANDS in the config
file](https://github.com/mysociety/fixmystreet/blob/master/conf/general.yml-exam
ple#L123) for details). But for most cases you don't want it to switch. So if
you just specify just one cobrand like this, FixMyStreet will simply use it.

### Create a directory for your cobrand in web/cobrands

Make a new directory with your cobrand's name in `web/cobrands/` For example,
on the command line, do:
   
    cd fixmystreet
    mkdir web/cobrands/fixmypark


### Copy the default cobrand's CSS into yours

Copy the contents of `web/cobrands/default` into that directory.

    cp web/cobands/default/* web/cobrands/fixmypark
   
This puts the stylesheet files you need, as well as the "magic" `config.rb`
that enables auto-generation of the CSS (from SCSS files), into your cobrand.
At this point, your cobrand is effectively a copy of the default one.

### Edit the colours

The default cobrand's colour scheme, which you have copied, will be blue and
orange &mdash; we picked startling colours to force people to want to customise it.

We use SCSS (instead of CSS) because it's a more powerful way of defining and
managing styles. This means that when you make any changes, FixMyStreet needs
to compile those SCSS files to rebuild the CSS &mdash; see the following
section.

You can edit the colours defined in `web/cobrands/fixmypark/_colours.scss`.
You'll need to use [web colour
codes](https://developer.mozilla.org/en-US/docs/Web/Guide/CSS/Getting_started/Co
lor) to specify the colours you want.

Be careful: if you're not familiar with SCSS, the syntax of that file is a
little strict. Typically, those colours *must* always be either exactly three
or six hex characters long. And there must be a `#` before and a semicolon after each one.

These are the colours which you can easily change within the existing (default)
stylesheet.

<table class="table">
    <tr>
        <th>
            colour variable
        </th>
        <th>
            examples of where it's used in the default cobrand
        </th>
    </tr>
    <tr>
        <td>
            <code>$primary</code>
        </td>
        <td>
            the front page's main banner background
        </td>
    </tr>
    <tr>
        <td>
            <code>$primary_b</code>
        </td>
        <td>
            border around the the front page street/area input
        </td>
    </tr>
    <tr>
        <td>
            <code>$primary_text</code>
        </td>
        <td>
            text on the front page banner
        </td>
    </tr>
    <tr>
        <td>
            <code>$base_bg</code>
        </td>
        <td>
            page background (bleeding to edge)
        </td>
    </tr>
    <tr>
        <td>
            <code>$col_click_map</code><br>
            <code>$col_click_map_dark</code>
        </td>
        <td>
            background of the "click map to report problem" banner on the
            map page, and its darker underside
        </td>
    </tr>
    <tr>
        <td>
            <code>$col_fixed_label</code><br>             <code>$col_fixed_label_dark</code>
        </td>
        <td>
            background of the colour of the "fixed" label that appears on
            fixed reports, and its darker underside
        </td>
    </tr>
</table>

SCSS supports functions such as `darken` so you can specify colours that are
calculated from other colours like this:

    $col_click_map: #ee6040;
    $col_click_map_dark: darken($col_click_map, 10%);

For more about SCSS, see [the SASS website](http://sass-lang.com).


### Run make_css so FixMyStreet's CSS uses the new values

FixMyStreet now needs to absorb those changes by rebuilding the CSS. There's a
task in the `bin` directory called `make_css` that will do this for you. You'll
need to be logged into your shell in the `fixmystreet` directory, then do:

    bin/make_css

This will update the CSS files.

Keep an eye on the output of that command &mdash; if there's a problem (for
example, if you've made a mistake in the SCSS syntax, which is easy to do), it
will report it here.


### See the new colours

If you look at your site in a browser, you'll see the new colours. Remember
that every time you edit them, you need to run `bin/make_css` to make
FixMyStreet include the changes.


## Or... use your own CSS and HTML

Remember that *all* you've done here is change the colours, **using the
existing default CSS and HTML**. Of course any and all of this can be
overridden (by overriding CSS files and overriding the bits of HTML that you
want to change in the <a href="/glossary/#template"
class="glossary">templates</a>) but this is just so you can get going.

## Next steps...

Now you have your own cobrand, ading your own HTML <a href="/glossary/#template" class="glossary">templates</a> is simple. 

When it's building a page, FixMyStreet always looks in your cobrand's web
template directory first: if it finds a template there, it uses it, and if it
doesn't it falls back and uses the `default` one instead.

To see how this works, look at some of the cobrands that already exist in the
`/templates/web` directory. You need to create a new directory with your
cobrand's name: for example, do:

    mkdir  /templates/web/fixmypark

Then, to override an existing template, copy it into the
`/templates/web/fixmypark/` directory and edit it there. You *must* use the
same directory and file names as in the `default` cobrand (that is, in
`templates/web/default`).

For example, it's likely you'll want to change the footer template, which puts
text right at the bottom of every page. Copy the footer template into your
cobrand like this:

    cp templates/web/default/footer.html templates/web/fixmypark

The templates use the popular <a
href="http://www.template-toolkit.org">Template Toolkit</a> system &mdash; look
inside and you'll see HTML with placeholders like `[% THIS %]`. The `[% INCLUDE
...%]` marker pulls in another template, which, just like the footer, you can
copy into your own cobrand from `default` and edit.

<div class="attention-box warning">
    One thing to be careful of: <strong>only edit the <code>.html</code> files</strong>. FixMyStreet
    generates <code>.ttc</code> versions, which are cached copies &mdash; don't edit these, they
    automatically get created (and overwritten) when FixMyStreet is running.
</div>

There are also email templates that FixMyStreet uses when it constructs email
messages to send out. You can override these in a similar way: look in the
`templates/email` directory and you'll see cobrands overriding the templates in
`templates/email/default`.

### Feeding back changes

Finally, when you've finished creating your cobrand you should consider [feeding it back to us]({{site.baseurl}}feeding-back) so it becomes part of the FixMyStreet repository.




