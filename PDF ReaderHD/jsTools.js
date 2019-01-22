function MyAppGetHTMLElementsAtPoint(x,y) {
    var tags = ",";
    var e = document.elementFromPoint(x,y);
    while (e) {
        if (e.tagName) {
            tags += e.tagName + ',';
        }
        e = e.parentNode;
    }
    return tags;
}

function documentCoordinateToViewportCoordinate(x,y) {
    var coord = new Object();
    coord.x = x - window.pageXOffset;
    coord.y = y - window.pageYOffset;
    return coord;
}

function viewportCoordinateToDocumentCoordinate(x,y) {
    var coord = new Object();
    coord.x = x + window.pageXOffset;
    coord.y = y + window.pageYOffset;
    return coord;
}

function attributesOfElementAtPoint(x,y) {
    //var coord = new Object();
    var str = "attributes:"
    var e = document.elementFromPoint(x,y).attributes;
    for (var i=0; i<e.length; i++)
    {
        str+=e[i].name+';';
    }
    return str;
}

function elementFromPointIsUsingViewPortCoordinates() {
    if (window.pageYOffset > 0) {     // page scrolled down
        return (window.document.elementFromPoint(0, window.pageYOffset + window.innerHeight -1) == null);
    } else if (window.pageXOffset > 0) {   // page scrolled to the right
        return (window.document.elementFromPoint(window.pageXOffset + window.innerWidth -1, 0) == null);
    }
    return false; // no scrolling, don't care
}

function elementFromDocumentPoint(x,y) {
    if (elementFromPointIsUsingViewPortCoordinates()) {
        var coord = documentCoordinateToViewportCoordinate(x,y);
        return window.document.elementFromPoint(coord.x,coord.y);
    } else {
        return window.document.elementFromPoint(x,y);
    }
}

function elementFromViewportPoint(x,y) {
    if (elementFromPointIsUsingViewPortCoordinates()) {
        return window.document.elementFromPoint(x,y);
    } else {
        var coord = viewportCoordinateToDocumentCoordinate(x,y);
        return window.document.elementFromPoint(coord.x,coord.y);
    }
}

function hasSRC(x,y) {
    
    var e;
    if (elementFromPointIsUsingViewPortCoordinates()) {
        e = window.document.elementFromPoint(x,y);
        
    } else {
        var coord = viewportCoordinateToDocumentCoordinate(x,y);
        e =window.document.elementFromPoint(coord.x,coord.y);
        
    }
    
    if (e.hasOwnProperty("src")){
        return "YES";
    }
    return "NO";
}

function hrefOrSrcOfElementAtPoint(x,y) {
    //var coord = new Object();
    var str = "attributes:"
    var e;
    if (elementFromPointIsUsingViewPortCoordinates()) {
        e = window.document.elementFromPoint(x,y);
        
    } else {
        var coord = viewportCoordinateToDocumentCoordinate(x,y);
        e =window.document.elementFromPoint(coord.x,coord.y);
        
    }
    
    
    if (e.hasOwnProperty("src")){
        return e.attributes.getNamedItem("src").value;
    }
    if (e.hasOwnProperty("href")){
        return e.attributes.getNamedItem("href").value
    }
        
     
}