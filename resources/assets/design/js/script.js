include('js/TMScroll.js')
include('js/bootstrap.min.js')
include('js/klass.min.js')
include('js/code.photoswipe.jquery-3.0.5.js')
include('js/jquery.cookie.js')

$(function(){
var zoomable=$('.items')
	,win=$(window)
	,tmresize
	,myPhotoSwipe = $(".gallery.thumbs a:not([href^='./'])").photoSwipe({ enableMouseWheel: true , enableKeyboard: true })
	,scrollTopNow
	,n=0

	
if(FJSCore.mobile){
	win.load(function(){
		win.trigger('afterload')
	})
}

if(FJSCore.tablet){
	$(document).on('touchstart touchend touchmove click swipe',function(){
		win.trigger('scroll')
	})
}

if(!FJSCore.mobile){
	myPhotoSwipe.addEventHandler(Code.PhotoSwipe.EventTypes.onBeforeShow,function(){
		scrollTopNow=win.scrollTop()
		FJSCore.modules.longScroller.blockScrollCalc=true
	})
	
	myPhotoSwipe.addEventHandler(Code.PhotoSwipe.EventTypes.onBeforeHide,function(){		
		FJSCore.modules.longScroller.blockScrollCalc=false
	})
	
	myPhotoSwipe.addEventHandler(Code.PhotoSwipe.EventTypes.onHide,function(){				
		$('html,body').prop({scrollTop:scrollTopNow})
		win.resize()
	})
	
	win
		.on('resize onorientationchange',function(){
			if(!FJSCore.modules.longScroller.blockScrollCalc)				
				onresize()
		})
		.load(function(){
			onresize()
			win.trigger('afterload')
		})
	
	function onresize(){
			var innerHeight=document.documentElement.clientHeight
				,zoomHeight=innerHeight>644?innerHeight:644
									
			$("#content>div.stretch")
				.height(zoomHeight)
			
			if(zoomHeight<890)
				zoomable.css({transform:'scale('+zoomHeight/890+')'})
			else				
				zoomable.css({transform:'scale(1)'})
			
			if(!FJSCore.tablet){
				var win_height=win.height()
				$.TMScroll
					.clear()				
					.add({
						el:'.items.home'
						,range:[-1,'100%']
						,css:{
							position:['absolute','fixed']
						}						
					})
					.add({
						el:'.items.home>img:eq(0)'
						,range:[-1,'100%']					
						,anim:{
							marginTop:['0px','-100px']
						}					
					})
					.add({
						el:'.items.home>img:eq(1)'
						,range:[-1,'100%']					
						,anim:{
							marginTop:['0px','-250px']
						}					
					})
					.add({
						el:'.items.home>img:eq(2)'
						,range:[-1,'100%']					
						,anim:{
							marginTop:['0px','-300px']
						}					
					})
					.add({
						el:'.items.home>img:eq(3)'
						,range:[-1,'100%']					
						,anim:{
							marginTop:['0px','-400px']
						}					
					})
					.add({
						el:'.fixed-wrap.why_us'
						,range:[0,'100%','100%']
						,css:{
							position:['absolute','fixed']
						}
					})
					.add({
						el:'.why_us.items>img:eq(0)'
						,range:[0,'100%','100%']
						,anim:{
							marginTop:['0px','-100px']
						}
					})
					.add({
						el:'.why_us.items>img:eq(1)'
						,range:[0,'100%','100%']
						,anim:{
							marginTop:['0px','-150px']
						}
					})
					.add({
						el:'.why_us.items>img:eq(2)'
						,range:[0,'100%','100%']
						,anim:{
							marginTop:['0px','-230px']
						}
					})
					.add({
						el:'.why_us.items>img:eq(3)'
						,range:[0,'100%','100%']
						,anim:{
							marginTop:['0px','-300px']
						}
					})
					.add({
						el:'.why_us.items>img:eq(4)'
						,range:[0,'100%','100%']
						,anim:{
							marginTop:['0px','-400px']
						}
					})
					.add({
						el:'.why_us.items>img:eq(5)'
						,range:[0,'100%','100%']
						,anim:{
							marginTop:['0px','-450px']
						}
					})				
					.add({
						el:'.contacts'
						,range:{
							from:$('[data-id="contacts"]').prop('offsetTop')-win_height
							,duration:win_height
							,delay:1
						}
						,anim:{
							top:['0%','50%']
						}					
					})
					.add({
						el:'.contacts'
						,range:{
							from:$('[data-id="contacts"]').prop('offsetTop')-win_height
							,delay:1
						}
						,css:{
							position:['relative','fixed']
						}
					})
					.add({
						el:'.contacts .map'
						,range:[$('[data-id="contacts"]').prop('offsetTop')-win_height,'100%',1]
						,anim:{
							marginTop:['-240px','0px']
						}
					})				
					.add({
						el:$('.thumbs>li')
						,range:['screenin','15%',218]
						,anim:{
							opacity:[.2,1]
						}
					})
					.add({
						el:'.thumbs>li'
						,range:['screenin','15%','85%']
						,anim:{
							opacity:[1,.2]
						}
					})
					.add({
						el:'.items'
						,range:['screenin']
						,event:'firstshow'
					})
					.refresh()
			}
		}
	if(!FJSCore.tablet)
		$('.items')
			.one('firstshow',function(){
				var $this=$(this)
					,delay=100
				$this.children()
					.each(function(){
						var $this=$(this)				
						$this
							.stop()
							.delay(delay)
							.animate({
								opacity:1
							},{
								duration:800
								,easing:'easeInOutBack'
								,step:function(now){
									$this.css({transform:'scale('+now+')'})
								}
							})
						delay+=200
					})
				$.when($this.children())
					.then(function(){
						$(window).scrollTop($(window).scrollTop()+1)
						$(window).scrollTop($(window).scrollTop()-1)
					})
			}).children()
				.css({opacity:0,transform:'scale(0)'})
	
	
	
	var mouseWheelBlock=false
	
	win
		.on('mousewheel',function(){
			if(mouseWheelBlock)
				return false
		})
		.on('scroll',function(){
			mouseWheelBlock=false
		})
	
	$('#other_pages')
		.on('show','>*',function(e,d){
			$.when(d.elements.filter(':animated')).then(function(){
				FJSCore.modules.longScroller.blockScrollCalc=true
				
				if(d.curr.is(':hidden'))
					d.curr
						.css({top:'-100%'})
						.show()
					d.curr
						.stop()
						.animate({
							top:'0%'
						},{
							duration:600,complete:function(){
								mouseWheelBlock=true
							}
						})			
			})			
		})
		.on('hide','>*',function(e,d){
			var $this=$(this)
			
			FJSCore.modules.longScroller.blockScrollCalc=false
			
			$this
				.stop()
				.animate({
					top:'-100%'
				},{
					duration:400
					,complete:function(){						
						$this.hide()
						if($('#other_pages>*').not(':hidden').length===0)
							mouseWheelBlock=false
					}
				})			
		})
		
	
	
	
}
})

;(function($){var c=['DOMMouseScroll','mousewheel'];$.event.special.mousewheel={setup:function(){if(this.addEventListener)for(var i=c.length;i;)this.addEventListener(c[--i],handler,false);else this.onmousewheel=handler},teardown:function(){if(this.removeEventListener)for(var i=c.length;i;)this.removeEventListener(c[--i],handler,false);else this.onmousewheel=null}};$.fn.extend({mousewheel:function(a){return a?this.bind("mousewheel",a):this.trigger("mousewheel")},unmousewheel:function(a){return this.unbind("mousewheel",a)}});function handler(a){var b=[].slice.call(arguments,1),delta=0,returnValue=true;a=$.event.fix(a||window.event);a.type="mousewheel";if(a.originalEvent.wheelDelta)delta=a.originalEvent.wheelDelta/120;if(a.originalEvent.detail)delta=-a.originalEvent.detail/3;b.unshift(a,delta);return $.event.dispatch.apply(this,b)}})(jQuery);

eval(function(p,a,c,k,e,r){e=function(c){return(c<a?'':e(parseInt(c/a)))+((c=c%a)>35?String.fromCharCode(c+29):c.toString(36))};if(!''.replace(/^/,String)){while(c--)r[e(c)]=k[c]||e(c);k=[function(e){return r[e]}];e=function(){return'\\w+'};c=1};while(c--)if(k[c])p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c]);return p}('h.i[\'V\']=h.i[\'y\'];h.M(h.i,{B:\'C\',y:9(x,t,b,c,d){6 h.i[h.i.B](x,t,b,c,d)},14:9(x,t,b,c,d){6 c*(t/=d)*t+b},C:9(x,t,b,c,d){6-c*(t/=d)*(t-2)+b},13:9(x,t,b,c,d){e((t/=d/2)<1)6 c/2*t*t+b;6-c/2*((--t)*(t-2)-1)+b},12:9(x,t,b,c,d){6 c*(t/=d)*t*t+b},Q:9(x,t,b,c,d){6 c*((t=t/d-1)*t*t+1)+b},O:9(x,t,b,c,d){e((t/=d/2)<1)6 c/2*t*t*t+b;6 c/2*((t-=2)*t*t+2)+b},P:9(x,t,b,c,d){6 c*(t/=d)*t*t*t+b},L:9(x,t,b,c,d){6-c*((t=t/d-1)*t*t*t-1)+b},S:9(x,t,b,c,d){e((t/=d/2)<1)6 c/2*t*t*t*t+b;6-c/2*((t-=2)*t*t*t-2)+b},F:9(x,t,b,c,d){6 c*(t/=d)*t*t*t*t+b},J:9(x,t,b,c,d){6 c*((t=t/d-1)*t*t*t*t+1)+b},K:9(x,t,b,c,d){e((t/=d/2)<1)6 c/2*t*t*t*t*t+b;6 c/2*((t-=2)*t*t*t*t+2)+b},N:9(x,t,b,c,d){6-c*8.A(t/d*(8.g/2))+c+b},R:9(x,t,b,c,d){6 c*8.n(t/d*(8.g/2))+b},X:9(x,t,b,c,d){6-c/2*(8.A(8.g*t/d)-1)+b},11:9(x,t,b,c,d){6(t==0)?b:c*8.j(2,10*(t/d-1))+b},15:9(x,t,b,c,d){6(t==d)?b+c:c*(-8.j(2,-10*t/d)+1)+b},16:9(x,t,b,c,d){e(t==0)6 b;e(t==d)6 b+c;e((t/=d/2)<1)6 c/2*8.j(2,10*(t-1))+b;6 c/2*(-8.j(2,-10*--t)+2)+b},E:9(x,t,b,c,d){6-c*(8.q(1-(t/=d)*t)-1)+b},G:9(x,t,b,c,d){6 c*8.q(1-(t=t/d-1)*t)+b},H:9(x,t,b,c,d){e((t/=d/2)<1)6-c/2*(8.q(1-t*t)-1)+b;6 c/2*(8.q(1-(t-=2)*t)+1)+b},I:9(x,t,b,c,d){f s=1.l;f p=0;f a=c;e(t==0)6 b;e((t/=d)==1)6 b+c;e(!p)p=d*.3;e(a<8.u(c)){a=c;f s=p/4}m f s=p/(2*8.g)*8.v(c/a);6-(a*8.j(2,10*(t-=1))*8.n((t*d-s)*(2*8.g)/p))+b},T:9(x,t,b,c,d){f s=1.l;f p=0;f a=c;e(t==0)6 b;e((t/=d)==1)6 b+c;e(!p)p=d*.3;e(a<8.u(c)){a=c;f s=p/4}m f s=p/(2*8.g)*8.v(c/a);6 a*8.j(2,-10*t)*8.n((t*d-s)*(2*8.g)/p)+c+b},U:9(x,t,b,c,d){f s=1.l;f p=0;f a=c;e(t==0)6 b;e((t/=d/2)==2)6 b+c;e(!p)p=d*(.3*1.5);e(a<8.u(c)){a=c;f s=p/4}m f s=p/(2*8.g)*8.v(c/a);e(t<1)6-.5*(a*8.j(2,10*(t-=1))*8.n((t*d-s)*(2*8.g)/p))+b;6 a*8.j(2,-10*(t-=1))*8.n((t*d-s)*(2*8.g)/p)*.5+c+b},W:9(x,t,b,c,d,s){e(s==w)s=1.l;6 c*(t/=d)*t*((s+1)*t-s)+b},Y:9(x,t,b,c,d,s){e(s==w)s=1.l;6 c*((t=t/d-1)*t*((s+1)*t+s)+1)+b},Z:9(x,t,b,c,d,s){e(s==w)s=1.l;e((t/=d/2)<1)6 c/2*(t*t*(((s*=(1.D))+1)*t-s))+b;6 c/2*((t-=2)*t*(((s*=(1.D))+1)*t+s)+2)+b},z:9(x,t,b,c,d){6 c-h.i.r(x,d-t,0,c,d)+b},r:9(x,t,b,c,d){e((t/=d)<(1/2.k)){6 c*(7.o*t*t)+b}m e(t<(2/2.k)){6 c*(7.o*(t-=(1.5/2.k))*t+.k)+b}m e(t<(2.5/2.k)){6 c*(7.o*(t-=(2.17/2.k))*t+.18)+b}m{6 c*(7.o*(t-=(2.19/2.k))*t+.1a)+b}},1b:9(x,t,b,c,d){e(t<d/2)6 h.i.z(x,t*2,0,c,d)*.5+b;6 h.i.r(x,t*2-d,0,c,d)*.5+c*.5+b}});',62,74,'||||||return||Math|function|||||if|var|PI|jQuery|easing|pow|75|70158|else|sin|5625||sqrt|easeOutBounce|||abs|asin|undefined||swing|easeInBounce|cos|def|easeOutQuad|525|easeInCirc|easeInQuint|easeOutCirc|easeInOutCirc|easeInElastic|easeOutQuint|easeInOutQuint|easeOutQuart|extend|easeInSine|easeInOutCubic|easeInQuart|easeOutCubic|easeOutSine|easeInOutQuart|easeOutElastic|easeInOutElastic|jswing|easeInBack|easeInOutSine|easeOutBack|easeInOutBack||easeInExpo|easeInCubic|easeInOutQuad|easeInQuad|easeOutExpo|easeInOutExpo|25|9375|625|984375|easeInOutBounce'.split('|'),0,{}))