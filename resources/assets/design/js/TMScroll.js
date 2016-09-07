!function($,undefined){
	var TMScroll=$.TMScroll={}
		,win=$(window)
		,ranges=TMScroll.ranges=[]
		,sets=TMScroll.sets=[]
		,timeLine=TMScroll.timeLine=[]
		,kf=[0] //keyframes
		,currN
		,scrollable=$('html,body')
		,winHeight=win.height()
		,scrollHeight=scrollable.prop('scrollHeight')-winHeight
	
	$.extend(TMScroll,{
		add:add
		,refresh:refresh
		,clear:clear		
	})
	
		
	win
		.on('resize',onResize)
		.on('scroll touchmove',onScroll)
	
	function onScroll(){
		var scrollTop=window.pageYOffset||document.body.scrollTop
			,i=0,l			
		
		while(kf[i++]<=scrollTop);
		
		if(currN!==i-2){
			currN=i-2
			closeFinished(scrollTop)
		}
		
		for(i=0,l=timeLine[currN]&&timeLine[currN].length;i<l;i++)
			processStep(timeLine[currN][i],scrollTop)
	}
	
	function closeFinished(scrollTop){
		var i
			,l=timeLine.length
		
		for(i=timeLine.length-1;i>currN;i--)			
			$.each(timeLine[i],function(){				
				if(this.range.from>scrollTop&&this.range.pos!==0)
					applyByPos(this,0)
					,this.range.pos=0				
			})
		for(i=0;i<currN;i++)
			$.each(timeLine[i],function(){
				if(this.range.to<scrollTop&&this.range.pos!==1)
					applyByPos(this,1)
					,this.range.pos=1
			})
	}
			
	function processStep(o,scrollTop){		
		var pos
		if(o.range.to!==Infinity)
			pos=(scrollTop-o.range.from)/(o.range.to-o.range.from)			
		else
			pos=scrollTop>o.range.from?1:0
		
		if(pos>1)
			pos=1
			
		if(pos<0)
			pos=0
		
		applyByPos(o,pos)
	}
	
	function applyByPos(o,pos){		
		var el=o.el
			,anim_now
			,inRange			
			,styleName
		
		o.range.pos=pos>0&&pos<1?null:pos
		
		if(o.range.to!==Infinity)
			inRange=o.range.pos===null?'in':'out'
		else
			inRange=['out','in'][o.range.pos]
		
		if(o.anim!==undefined){			
			for(styleName in o.anim)
				if(o.anim.hasOwnProperty(styleName))
					anim_now=(o.anim[styleName].start+o.anim[styleName].delta*pos)+o.anim[styleName].unit
					,el.css(styleName,anim_now)
		}
		
		if(o.css!==undefined&&inRange!==o.css.inRange){
			for(styleName in o.css)
				if(o.css.hasOwnProperty(styleName))
					el.css(styleName,o.css[styleName][inRange])
			o.css.inRange=inRange
		}
		
		if(o["class"]!==undefined&&inRange!==o["class"].inRange){
			if(inRange==='in')
				el.addClass(o["class"]['in'])
				,el.removeClass(o["class"]['out'])
			if(inRange==='out')
				el.addClass(o["class"]['out'])
				,el.removeClass(o["class"]['in'])			
			o["class"].inRange=inRange
		}
		
		if(o.event!==undefined&&inRange!==o.event.inRange){
			if(inRange==='in')
				el.trigger(o.event["in"])				
			if(inRange==='out'&&o.event.out)
				el.trigger(o.event["out"])
			o.event.inRange=inRange
		}
	}
	
	function add(o){
		if(o.el.constructor!==$)
			o.el=$(o.el)
			
		TMScroll.sets.push(o)
		
		return TMScroll
	}
	
	function refresh(){
		$.each(TMScroll.sets,function(n,o){			
			o.el.each(function(){
				var $this=$(this)
					,range
					,obj=$.extend({},o)
				ranges.push(range={
					el:$this
					,range:prepareRange(obj,$this)
					,anim:prepareAnim(obj,$this)
					,css:prepareCSS(obj,$this)
					,"class":prepareClass(obj,$this)
					,event:prepareEvent(obj,$this)
				})				
				kf[range.range.from]=true
				kf[range.range.to]=true
			})			
		})
	
		kf=(function(kf){
			var ret=[]
				,i
			for(i in kf)
				if(kf.hasOwnProperty(i))
					ret.push(i)			
			return ret.sort(function(a,b){return a-b})
		})(kf)
		
		timeLine=TMScroll.timeLine=(function(kf){
			var i,l=kf.length
				,timeLine=[]
			for(i=1;i<l;i++)
				timeLine[i-1]=$.map(ranges,function(range){
					if(range.range.from<=kf[i-1]&&range.range.to>=kf[i])
						return range
				})
			
			return timeLine
		})(kf)
		
		onScroll()
		
		return TMScroll
	}
	
	// addClass, removeClass
	
	function prepareClass(o,el){
		if(o["class"]===undefined)
			return undefined
		if($.isArray(o["class"]))
			o["class"]={
				out:o["class"][0]
				,"in":o["class"][1]
			}
		if(!$.isPlainObject(o["class"]))
			o["class"]={"in":o["class"]}
		
		return o["class"]
	}
	
	function prepareEvent(o,el){
		if(o.event===undefined)
			return undefined
		if($.isArray(o.event))
			o.event={
				out:o.event[0]
				,"in":o.event[1]
			}
		if(!$.isPlainObject(o.event))
			o.event={"in":o.event}
		
		return o.event
	}
	
	function prepareCSS(o,el){
		var styleName
		for(styleName in o.css)
			if(o.css.hasOwnProperty(styleName)){
				if($.isArray(o.css[styleName]))
					o.css[styleName]={
						out:o.css[styleName][0]
						,"in":o.css[styleName][1]
					}
				if(!$.isPlainObject(o.css[styleName]))					
					o.css[styleName]={"in":o.css[styleName]}
					,o.css[styleName].out=el.css(styleName)
			}
		return o.css
	}
	
	function prepareAnim(o,el){		
		var styleName,style
		for(styleName in o.anim)
			if(o.anim.hasOwnProperty(styleName)){
				if($.isArray(o.anim[styleName]))
					o.anim[styleName]={
						start:o.anim[styleName][0]
						,end:o.anim[styleName][1]
					}
				if(!$.isPlainObject(o.anim[styleName]))
					o.anim[styleName]={end:o.anim[styleName]}
					,o.anim[styleName].start=el.css(styleName)
				
				if($.cssNumber[styleName])
					o.anim[styleName].unit=''
				else
					o.anim[styleName].unit=o.anim[styleName].start.toString().replace(/[\-\.0-9]+/,'')
					,o.anim[styleName].start=parseFloat(o.anim[styleName].start)
					,o.anim[styleName].end=parseFloat(o.anim[styleName].end)
					
				if(!$.cssNumber[styleName]&&o.anim[styleName].unit==='')
					o.anim[styleName].unit='px'
					
				o.anim[styleName].delta=o.anim[styleName].end-o.anim[styleName].start
			}
				
		return o.anim
	}
	
	function prepareRange(o,el){
		winHeight=win.height()
		scrollHeight=scrollable.prop('scrollHeight')-winHeight
		
		if($.isArray(o.range))
			o.range={
				from:o.range[0]
				,duration:o.range[1]
				,delay:o.range[2]
			}
			
		if(!$.isPlainObject(o.range))
			o.range={from:o.range}
					
		if(o.range.from.constructor===String){
			if(~o.range.from.indexOf('%'))
				o.range.from=scrollHeight/100*parseFloat(o.range.from)				
			if(o.range.from==='screenin')
				o.range.from=el.offset().top-winHeight
		}
		
		if(o.range.delay!==undefined&&o.range.delay.constructor===String&&~o.range.delay.indexOf('%'))
			o.range.delay=winHeight/100*parseFloat(o.range.delay)
			
		if(o.range.delay!==undefined)
			o.range.from+=o.range.delay
		
		if(o.range.duration!==undefined&&o.range.duration.constructor===String&&~o.range.duration.indexOf('%'))
			o.range.duration=winHeight/100*parseFloat(o.range.duration)
		
		if(o.range.to===undefined&&o.range.duration!==undefined)
			o.range.to=o.range.from+o.range.duration
		
		if(o.range.to===undefined&&o.range.duration===undefined)			
			o.range.duration=o.range.to=Infinity
		
		return o.range
	}
	
	function clear(){
		TMScroll.ranges.splice(0,TMScroll.ranges.length)
		TMScroll.sets.splice(0,TMScroll.sets.length)
		TMScroll.timeLine.splice(0,TMScroll.timeLine.length)
		kf=[]
		return TMScroll
	}
	
	function onResize(){			
		winHeight=win.height()
		scrollHeight=scrollable.prop('scrollHeight')-winHeight		
	}
			
}(jQuery);