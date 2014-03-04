import org.decatime.Facade;
import org.decatime.wonderpad.App;
import org.decatime.utils.Logger;

class Main {

	private static var LOG_PATH:String = "TODO define a good way to handle log path!!";

	public function new () {
		#if !flash
			var args:Array<String> = Sys.args();
			if (args.length == 0) {
				runClient();
			} else {
				runServer(args);
			}
        #else
        	runClient();
        #end
	}

	#if !flash
		private function runServer(args:Array<String>): Void {
			if (args.length != 2) {
				//trace ("Warning arguments must be Ip address followed by port number");
			}
			try {
				//trace ("Wonderpad server is starting up at " + args[0] + " on port " + Std.parseInt(args [1]));
			} catch(e:Dynamic) {
				//trace ("Warning arguments must be Ip address followed by port number");
				return;
			}
			
			// var app:org.decatime.wdpsrv.App = new org.decatime.wdpsrv.App(args[0], Std.parseInt(args[1]));

			// Facade.getInstance().setDefaultFont('assets/Vera.ttf');
			// Facade.getInstance().setDefaultFontSize(14);

			// Facade.getInstance().run(app);
		}
	#end
	
	private function runClient(): Void {
		var app:org.decatime.wonderpad.App = new org.decatime.wonderpad.App();

		Facade.getInstance().setDefaultFont('assets/Vera.ttf');
		Facade.getInstance().setDefaultFontSize(14);
		Facade.doLog('Starting application...', this);
		Facade.getInstance().run(app);
	}
}