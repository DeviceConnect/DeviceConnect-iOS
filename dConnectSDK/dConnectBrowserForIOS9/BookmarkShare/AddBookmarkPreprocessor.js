//
//  AddBookmarkPreprocessor.js
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

var AddBookmarkPreprocessor = function() {};

AddBookmarkPreprocessor.prototype = {
    run: function(arguments) {
        arguments.completionFunction({"URL": document.URL, "pageSource": document.documentElement.outerHTML, "title": document.title, "selection": window.getSelection().toString()});
        location.href = "gotapi://start?url=" + document.URL;
    }
};

var ExtensionPreprocessingJS = new AddBookmarkPreprocessor;
