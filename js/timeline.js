var tl;
function onLoad() {
    var eventSource = new Timeline.DefaultEventSource();

    var theme = Timeline.ClassicTheme.create();
		            theme.event.bubble.width = 500;
		            theme.event.bubble.height = 100;

		            var d = Timeline.DateTime.parseGregorianDateTime("2000")
		            var bandInfos = [
		                Timeline.createBandInfo({
		                    width:          "80%", 
		                    intervalUnit:   Timeline.DateTime.DECADE, 
		                    intervalPixels: 200,
		                    eventSource:    eventSource,
		                    date:           d,
		                    theme:          theme,
		                    layout:         'original'  // original, overview, detailed
		                }),
		                Timeline.createBandInfo({
		                    width:          "20%", 
		                    intervalUnit:   Timeline.DateTime.CENTURY, 
		                    intervalPixels: 200,
		                    eventSource:    eventSource,
		                    date:           d,
		                    theme:          theme,
		                    layout:         'overview'  // original, overview, detailed
		                })
		            ];
		            bandInfos[1].syncWith = 0;
		            bandInfos[1].highlight = true;
		


    tl = Timeline.create(document.getElementById("tl"), bandInfos, Timeline.HORIZONTAL);
}

var resizeTimerID = null;
function onResize() {
    if (resizeTimerID == null) {
        resizeTimerID = window.setTimeout(function() {
            resizeTimerID = null;
            tl.layout();
        }, 500);
    }
}