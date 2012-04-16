@HelloWorld = 
	onLoad: -> 
		this.initialized = true
	
	onMenuItemCommand: -> 
		window.open "chrome://helloworld/content/hello.xul", "", "chrome"

window.addEventListener "load", 
  (e) -> HelloWorld.onLoad(e)