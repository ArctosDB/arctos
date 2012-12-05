

    jQuery The core JS framework that allows you to write less, do more.
    jQuery UI The officially supported User Interface library for jQuery.
    jQuery Mobile Build mobile web apps with jQuery using this framework.
    SizzleJS A smoking fast CSS selector engine for JavaScript.
    QUnit Write solid JavaScript apps by unit testing with QUnit.

    jQuery
    jQuery UI
    jQuery Mobile
    All Projects

    Support
    Community
    Contribute
    About

jQuery UI

    Demos
    Download
    API Documentation
    Themes
    Development
    Support
    Blog
    About

Search jQuery UI
Sortable
Examples

    Default functionality
    Connect lists
    Connect lists with Tabs
    Delay start
    Display as grid
    Drop placeholder
    Handle empty lists
    Include / exclude items
    Portlets

To arrange sortable items as a grid, give them identical dimensions and float them using CSS.
view source

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41

<!doctype html>

<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>jQuery UI Sortable - Display as grid</title>
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" />
    <script src="http://code.jquery.com/jquery-1.8.3.js"></script>
    <script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>
    <link rel="stylesheet" href="/resources/demos/style.css" />
    <style>
    #sortable { list-style-type: none; margin: 0; padding: 0; width: 450px; }
    #sortable li { margin: 3px 3px 3px 0; padding: 1px; float: left; width: 100px; height: 90px; font-size: 4em; text-align: center; }
    </style>
    <script>
    $(function() {
        $( "#sortable" ).sortable();
        $( "#sortable" ).disableSelection();
    });
    </script>
</head>
<body>

<ul id="sortable">
    <li class="ui-state-default">1</li>
    <li class="ui-state-default">2</li>
    <li class="ui-state-default">3</li>
    <li class="ui-state-default">4</li>
    <li class="ui-state-default">5</li>
    <li class="ui-state-default">6</li>
    <li class="ui-state-default">7</li>
    <li class="ui-state-default">8</li>
    <li class="ui-state-default">9</li>
    <li class="ui-state-default">10</li>
    <li class="ui-state-default">11</li>
    <li class="ui-state-default">12</li>
</ul>


</body>
</html>
