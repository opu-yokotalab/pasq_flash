//新
package {
	import flash.display.*;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.display.MovieClip;
	import XML;
	import flash.net.*;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.LocalConnection;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
	import flash.geom.*;
	import flash.geom.Point;
	import flash.text.*;
	import flash.external.ExternalInterface;
	//import flash.events.MouseEvent;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapType;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.controls.MapTypeControl;
	import com.google.maps.controls.MapTypeControlOptions;
	import com.google.maps.controls.ZoomControl;
	import com.google.maps.controls.ZoomControlOptions;
	import com.google.maps.controls.PositionControl;
	import com.google.maps.controls.PositionControlOptions;
	import com.google.maps.controls.ControlPosition;
	import com.google.maps.controls.OverviewMapControl;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.overlays.Polyline;
	import com.google.maps.overlays.PolylineOptions;
	import com.google.maps.overlays.EncodedPolylineData;
	import com.google.maps.overlays.GroundOverlay;
	import com.google.maps.overlays.GroundOverlayOptions;
	import com.google.maps.styles.StrokeStyle;
	import com.google.maps.styles.FillStyle;
	import com.google.maps.LatLngBounds;
	import com.google.maps.LatLng;
	import com.google.maps.ProjectionBase;
	import com.google.maps.interfaces.IProjection;
	import com.google.maps.interfaces.IMapType;
	
	import org.papervision3d.cameras.*;
	import org.papervision3d.view.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.objects.primitives.*
	import org.papervision3d.materials.utils.*;
	import org.papervision3d.core.render.sort.NullSorter;
	import org.papervision3d.typography.Text3D;
	import org.papervision3d.typography.fonts.HelveticaBold;
	import org.papervision3d.typography.Letter3D;
	import org.papervision3d.materials.special.Letter3DMaterial;
	import flashx.textLayout.formats.Float;
	
	

	
	[SWF(backgroundColor="#000000",width="1000",height="620")]
	public class PasQk extends BasicView {	
	
	var rend:Array = new Array();//画像切り替え判定のrange_end
	var rstart:Array = new Array();//画像切り替え判定のrange_start
	var src : String;//画像のsource
	var meta:XML;
	var xml:XML;//PCD格納用
	var ccd:XML;//CCD格納用
	var pcd_name:String;
	var ccd_name:String;
	
	var len : int;
	var p_len : int;
	var snorth : int;
	var loader:Loader = new Loader();//メインの画像ローダ
	var fullon : Loader = new Loader();
	var fulloff : Loader = new Loader();
	var btn : Loader = new Loader();
				
	
	
	var panoid:Number;//パノラマＩＤ格納
	var ch:Number;//チェンジパノラマカウンター
	var chid:Array = new Array();//チェンジパノラマＩＤ格納用配列
	var north:Number;//北位置変数
	var startdir:int;//スタート方位
	var cn:int;//content数カウンター
	var n_bmp_data : BitmapData;//newBitmapData用（新しい画像を読み込むBitmapData）
	var n_loader:Loader = new Loader();//newLoader用（新しい画像を読み込むLoader）
	var moving : int;//移動用変数(+1,-1,0)、+1なら前進、-1なら後進、0なら移動なし
	var moving_damy : int;//movingの値を保持するための変数
	var lat:Number;//メインパノラマの緯度
	var lng:Number;//メインパノラマの経度
	var ch_lat: Array = new Array();//チェンジパノラマの緯度
	var ch_lng: Array = new Array();//チェンジパノラマの経度
	var latsa: Number;//2点の緯度の差＜メインパノラマとコンテンツの距離に使用＞
	var lngsa: Number;//2点の経度の差＜同上＞
	var pi : Number = 3.1415926535;//円周率
	
	var fa:Number;//for文用開始変数
	var la:Number;//for文用終了変数
	var pm:Number;//for文用増減変数(+1 or -1)
	var rad:Number;//cameraの角度
	var leng:Number;//中心点からのカメラの距離
	var range:Number;//中心点からのカメラの角度
					
	var level:int = 0;//バグ取り用
						
	var xsa:Number;//cameraのx座標の移動距離
	var ysa:Number;//cameraのy座標の移動距離(正確にはz座標)
	var un_leng:Number;//xsaとysaを利用した移動距離
	var lengsa:Number;//un_lengとlengの移動距離の差
	var i:int;//ただのカウンター用変数
	var c_length:Number;//コンテンツの距離
	var c_height:Number;//コンテンツの高さ
	var c_radius:Number;//コンテンツの半径…？
	var c_name:String;//コンテンツの名前
	var c_data:Text3D;//コンテンツデータ
	//var c_data = new TextField();
	var c_id:String;//コンテンツID
	var contents_lng:Array = new Array();//コンテンツの経度を格納する変数
	var contents_lat:Array = new Array();//コンテンツの緯度を格納する変数
	var letterformat:Letter3DMaterial;//c_data用のフォーマット
	var view_width:Number;
	var view_height:Number;
	var map:Map = new Map();
	var marker:Marker;
	
	var text_field = new TextField();
	
	var cont_line:int;
	
	var debug:Number = 0;
	
		public function PasQk() {
			stage.align = StageAlign.TOP;
			var viewport:Viewport3D = new Viewport3D(900,350,false,false);//Viewportの準備(パノラマ画像表示)
			super(900, 350, false, false, CameraType.FREE);//camera設定
			view_width = viewport.viewportWidth;
			view_height = viewport.viewportHeight;
			
			var metaloader:URLLoader = new URLLoader;
			metaloader.addEventListener(Event.COMPLETE,complete_meta);
			metaloader.load(new URLRequest("resource/meta.xml"));
							
			function complete_meta(event:Event):void{
				meta = new XML(event.target.data);
				pcd_name = "resource/" + meta.InitialDataUrl.PCD.@src;
				ccd_name = "resource/" + meta.InitialDataUrl.CCD.@src;
				
				var ccdloader:URLLoader = new URLLoader;//ccdloaderの宣言＜XMLを読み込む＞
				ccdloader.addEventListener(Event.COMPLETE,complete_ccd);//completeイベント。読み込み完了してくれる。
				ccdloader.load(new URLRequest(ccd_name));//URLRequestでccd.xmlを読み込む
				
				function complete_ccd(event:Event):void{//CCD読み込み終了後
					ccd = new XML(event.target.data);//event.target.dataにより関数complete_ccdを呼んだccdloaderの内容を格納
					
					var ccd_len:uint = ccd.Contents.Content.length();//ccd.xml内のContentの長さ（数）を格納
					for(cn=0;cn<ccd_len;cn++){
						contents_lng[cn] = ccd.Contents.Content[cn].coords.@lng;//各contentの経度を格納
						contents_lat[cn] = ccd.Contents.Content[cn].coords.@lat;//各contentの緯度を格納
						
					}
				}
				
				
				
				var pcdloader:URLLoader = new URLLoader;//pcdを読み込むLoader
				pcdloader.addEventListener(Event.COMPLETE,complete_pcd);//COMPLETEハンドラ
				pcdloader.load(new URLRequest(pcd_name));//pcd読み込み(コンテンツごとに変更)
				
				function complete_pcd(event:Event):void{
						xml = new XML(event.target.data);//complete_pcdを呼んだpcdloaderの情報を格納  
					var paramid : String;
					var id : String;
					var dir:String;
					var param:Object = loaderInfo.parameters;
					paramid = param["id"];
					dir = param["dir"];
					if(paramid != null){
	
					id = paramid.split("pano").join("");
					id = "pano" + id;
					}
					else{
					id = xml.Panoramas.@startpano;//.split("pano").join("");
					////panoid = pano256などとなっている"pano"を除いた数字をidに格納
					}
					if(dir != null){
						startdir = int(dir);
						snorth = startdir;
					}
					else{
					startdir = xml.Panoramas.@startdir;	
					snorth = startdir;
					}
					len = xml.Panoramas.Panorama.(@panoid == id).chpanos.chpano.length();
					p_len = xml.Panoramas.Panorama.length();
					//startpanoのchpano（チェンジパノラマ）数を格納
					for(ch=0; ch<len; ch++){//チェンジパノラマの情報の読み込み
						rend[ch] = xml.Panoramas.Panorama.(@panoid == id).chpanos.chpano[ch].range.@end;//切替可能角度の終点
//						rend[ch] = xml.Panoramas.Panorama.(@panoid= id).chpanos.chpano[ch].range.@end;//切替可能角度の終点
						rstart[ch] = xml.Panoramas.Panorama.(@panoid == id).chpanos.chpano[ch].range.@start;//切替可能角度の始点
						chid[ch] = xml.Panoramas.Panorama.(@panoid == id).chpanos.chpano[ch].@panoid.split("pano").join("");//chpanoのID
						ch_lat[ch] = xml.Panoramas.Panorama[chid[ch]].coords.@lat;//chpanoの緯度
						ch_lng[ch] = xml.Panoramas.Panorama[chid[ch]].coords.@lng;//chpanoの経度
					}
//					panoid = xml.Panoramas.Panorama.(@panoid == id).split("pano").join("");//startpanoのid
					panoid = xml.Panoramas.@startpano.split("pano").join("");//startpanoのid
					src = xml.Panoramas.Panorama.(@panoid == id).img.@src;//startpanoの画像のソース
					north = xml.Panoramas.Panorama.(@panoid == id).direction.@north;//startpanoの北情報
					lat = xml.Panoramas.Panorama.(@panoid == id).coords.@lat;//startpanoの緯度を
					lng = xml.Panoramas.Panorama.(@panoid == id).coords.@lng;//startpanoの経度
					//snorth=north;
				}
			}
			addEventListener(Event.ENTER_FRAME, loadloop);//Event-Enter_FRAMEいわゆる無限ループ
			function loadloop(event:Event):void{//XMLの処理が遅いので処理が終わるまで無限ループ
				if(src !=null){
				 removeEventListener(Event.ENTER_FRAME, loadloop);
				start();
				}
			}
			
		}
		
		function start(){//ここからメイン
			
			
			letterformat = new Letter3DMaterial(0xffffff , 1);//コンテンツの表示フォーマット（色、透明度）
			
			for(i=0;i<cn;i++){//コンテンツの個数分ループ
				lngsa = contents_lng[i]-lng;//コンテンツと表示パノラマの経度の差
				latsa = contents_lat[i]-lat;//コンテンツと表示パノラマの緯度の差
				c_length = Math.sqrt(lngsa*lngsa+latsa*latsa);//コンテンツと表示パノラマとの距離
				if(c_length <0.0005){//コンテンツと表示パノラマの距離がある程度小さければ
					c_height = ccd.Contents.Content[i].coords.@height;//近いコンテンツの情報を格納していく
					c_radius = ccd.Contents.Content[i].range.@radius;//コンテンツは複数同時表示もある
					c_name = ccd.Contents.Content[i].detail.@name;//現在は単一のコンテンツのみ
					c_id = ccd.Contents.Content[i].@contentid;//次期対応しなければ…
					c_data = new Text3D(c_id, new HelveticaBold() , letterformat);//Text3Dの設定HelveticaBoldはフォント(*注：日本語日対応)

					c_data.x = lngsa*2600000;//コンテンツを表示するx座標を指定
					c_data.z = latsa*2600000;//コンテンツを表示するy座標を指定
					
					//c_data.x = 50*i;
					//c_data.z = 50*i;
					
					c_data.y = c_height;//コンテンツを表示するy座標(高さ)を指定
					c_data.scale = 0.2;//表示するコンテンツ名の倍率を指定
					c_data.rotationY = 180 + Math.atan(c_data.x/c_data.z)*180/pi;//コンテンツ名が中心点に対して正面を向く処理
					//scene.addChild(c_data);
				}
				//c_data.addEventListener(MouseEvent.CLICK,tracer);
			}
			
			
			// 表示リストに登録する
			stage.addChild(text_field);
			
			text_field.border = true;	// 枠を表示する
			text_field.x = 50;		// x 座標
			text_field.y = 360;		// y 座標
			text_field.width  = 190;	// 幅
			text_field.height = 250;	// 高さ
			text_field.background = true;
			text_field.backgroundColor = 0xFFFFFF;
			
			//var strTag:String = "";
			
			
			for(i=0;i<cn;i++){
				text_field.appendText(ccd.Contents.Content[i].detail.@name + "\n");
				//strTag += "<p><a href='event:i'><font color='#0000FF'><b>ccd.Contents.Content[i].detail.@name</b></font></a></p>"
			}
			
			
			var material:BitmapMaterial;//パノラマ画像をはるBitmapData
			var sphere:Sphere = new Sphere(material, 800, 20, 10);//BitmapDataを張り付ける球体マテリアル
			
			loader.load(new URLRequest("resource/"+src));//パノラマ画像を読み込む
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,comHandler);//パノラマ画像読み込み完了ハンドラー
			function comHandler(e:Event){
				
				var panoheight:Number = (750-loader.height)/2;//パノラマ画像をBitmapDataの真ん中に張り付けるための値
				var bmp_data : BitmapData = new BitmapData(1500,750);//BitmapDataの準備1500ｘ750
				var matrix : Matrix = new Matrix(-1,0,0,1,1500,panoheight);//matrixにより画像を左右反転
				var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);//color指定
				var rect : Rectangle = new Rectangle(0,0,1500,750);//rentangle指定
				bmp_data.draw(loader, matrix, color, BlendMode.NORMAL, rect, true);//LoaderからBitmapdataに貼り付け
				material = new BitmapMaterial(bmp_data,true);//マテリアルにBitmapDataを格納
				sphere = new Sphere(material,500,30,30);//球体マテリアルにマテリアルを適用
				
				material.smooth = true;//画像のスムージング処理
				
				var forword : Loader = new Loader();//前進用画像読み込みローダー
				var back : Loader = new Loader();//後進用画像読み込みローダー
				var right : Loader = new Loader();//右視点移動用画像読み込みローダー
				var left : Loader = new Loader();//左視点移動用画像読み込みローダー
				var up : Loader = new Loader();//上視点移動用画像読み込みローダー
				var down : Loader = new Loader();//下視点移動用画像読み込みローダー
				//var fullon : Loader = new Loader();
				//var fulloff : Loader = new Loader();
				
				
				forword.load(new URLRequest("image/forword.jpg"));//前進用のボタンの画像を読み込む
				back.load(new URLRequest("image/back.jpg"));//以下省略
				right.load(new URLRequest("image/right.jpg"));
				left.load(new URLRequest("image/left.jpg"));
				up.load(new URLRequest("image/up.jpg"));
				down.load(new URLRequest("image/down.jpg"));
				fullon.load(new URLRequest("image/big.jpg"));
				fulloff.load(new URLRequest("image/small.jpg"));
				btn.load(new URLRequest("image/logo.png"));
				
				forword.x = stage.stageWidth -150;//ボタンの配置位置をFlashの窓情報から一定位置に
				forword.y = stage.stageHeight -150;//配置できるよう、stageの横幅縦幅を利用して
				back.x = stage.stageWidth - 150;//ボタンの配置位置を指定
				back.y = stage.stageHeight - 50;
				right.x= stage.stageWidth - 100;
				right.y= stage.stageHeight - 100;
				left.x = stage.stageWidth - 200;
				left.y = stage.stageHeight - 100;
				up.x = stage.stageWidth - 50;
				up.y = stage.stageHeight - 128;
				down.x = stage.stageWidth - 50;
				down.y = stage.stageHeight - 72;
				fullon.x = stage.stageWidth -250;
				fullon.y = stage.stageHeight - 128;
				fulloff.x = stage.stageWidth - 250;
				fulloff.y = stage.stageHeight - 128;
				fulloff.x = stage.stageWidth - 200;
				fulloff.y = stage.stageHeight - 170;
				btn.x = stage.stageWidth - 250;
				btn.y = stage.stageHeight - 250;
				
							
				forword.name = "1";//前進時+1
				back.name = "-1";//後進時-1
				right.name = "1";//右振り時+1
				left.name = "-1";//左振り時-1
				up.name = "-1";//上向き時-1
				down.name = "1";//下向き時+1
				fullon.name = "1";
				fulloff.name = "-1";
				btn.name = "1";
				
				
				// カメラを原点に配置
				camera.x = camera.y = camera.z = 0;
				camera.y= 0;
				sphere.rotationY = -90;//sphereにずれがあるため修正
				sphere.rotationY -= north*0.24;//さらに修正
				//camera.rotationY -= (443 - 340)*0.24; //cameraの向きを変更
				camera.rotationY = startdir;
				// 画質を「低」にして高速化もあり
				stage.quality = StageQuality.BEST;
				
				material.opposite = true;
				
				addChild(forword);//画像を窓上に張り付ける
				addChild(back);
				addChild(right);
				addChild(left);
				addChild(up);
				addChild(down);
				addChild(fullon);
				//addChild(btn);
				
				viewport.x = (stage.stageWidth - viewport.viewportWidth)/2;
				//viewport.y = (stage.stageHeight - viewport.viewportHeight)/2;
				scene.addChild(sphere);//球体を窓上に張り付ける
				
				//scene.addChild(c_data);//コンテンツを窓上に張り付ける
				
				/*var text_field = new TextField();//コンテンツのテキストや画像表示用
				text_field.border = true;//現在未対応です、ごめんなさい
				text_field.x = 50;
				text_field.y = 400;
				text_field.width  = 200;
				text_field.height = 20;

				// 表示したいテキスト
				text_field.text = "表示テスト";
				
				stage.addChild(text_field);*/
				
				
				
				map.key = "ABQIAAAAr7G747VYUhx_Ve6QBOJOhRSVcrJ7PFdwRvRBXyUpDeq-1cSJ-RSbpVuxnj5GTfGsIUU36flganXBxg";
				map.language = "ja";//言語
				map.setSize(new Point(500, 250));
				map.x = 250;
				map.y = 360;
				//地図サイズ設定;
				map.addControl(new PositionControl());//ポジションキーボタン;
				map.addControl(new ZoomControl(new ZoomControlOptions({hasScrollTrack : false})));//拡大縮小スライダー;
				//map.addControl(new MapTypeControl());//地図タイプセレクトボタン;
				
				map.sensor = "false";
				map.addEventListener(MapEvent.MAP_READY, onMapReady);
				map.addEventListener(MapEvent.MAP_READY, addMarkers);
				//addChild(map);
				
				//マウス操作によるイベント群
				right.addEventListener(MouseEvent.MOUSE_DOWN, rl_slide);//右ボタンをドラッグしたときのイベント(rl_slide関数へ)
				left.addEventListener(MouseEvent.MOUSE_DOWN, rl_slide);//左ボタンをドラッグしたときのイベント(rl_slide関数へ）
				//ここで同じ関数を使っているが、左右に振り向ける＜nameプロパティを活用＞
				forword.addEventListener(MouseEvent.MOUSE_DOWN, fb_slide);//前進ボタンをドラッグしたときのイベント
				back.addEventListener(MouseEvent.MOUSE_DOWN, fb_slide);//以下省略
				up.addEventListener(MouseEvent.MOUSE_DOWN, u_d_slide);
				down.addEventListener(MouseEvent.MOUSE_DOWN, u_d_slide);
				fullon.addEventListener(MouseEvent.CLICK, full_slide);
				fulloff.addEventListener(MouseEvent.CLICK, full_slide);
				
				btn.addEventListener(MouseEvent.MOUSE_DOWN, btnMouseDown);
				
				viewport.addEventListener(MouseEvent.MOUSE_DOWN, slide);//パノラマ画像表示部のドラッグ
				//c_data.addEventListener(MouseEvent.CLICK,trace_c);//コンテンツをクリックしたときのイベント（現在利用不可）
				text_field.addEventListener(MouseEvent.CLICK,cont_select);
				// レンダリングを開始
				startRendering();
				
			}
			
			
			function cont_select(event:MouseEvent):void{
				cont_line = text_field.getLineIndexAtPoint(event.localX, event.localY);
				var p_lat:Number;
				var p_lng:Number;
				var p_length:Number;
				var p_lngsa:Number;
				var p_latsa:Number;
				var pln:int = 0;
				var q:int;
				var r:int;
				var sikii:Number;
				
				for(q=0;q<20;q++){
					sikii = 0.00001+0.00002*q;
					for(i=0;i<p_len ;i++){
						p_lat = xml.Panoramas.Panorama[i].coords.@lat;//startpanoの緯度を
						p_lng = xml.Panoramas.Panorama[i].coords.@lng;//startpanoの経度
						p_lngsa = contents_lng[cont_line]-p_lng;
						p_latsa = contents_lat[cont_line]-p_lat;
						p_length = Math.sqrt(p_lngsa*p_lngsa+p_latsa*p_latsa);
				

						if(p_length < sikii){
							pln = 1;
							break;
						}
					}
						if(pln ==1){
							break;
						}
				}
				
				
				//id1に切替るパノラマIDを保存
				
				trace("i=",i);
				//camera.rotationY = Math.atan(p_lngsa/p_latsa):
				lat = xml.Panoramas.Panorama[i].coords.@lat;//latを切り替えるパノラマのものに更新
				lng = xml.Panoramas.Panorama[i].coords.@lng;//lngを切り替えるパノ（ｒｙ
									
									//if((latsa <0.000028) && (lngsa <0.000028)){//lngsaが遠いものには切り替わらないようにしたかった…
					for(ch=0; ch<xml.Panoramas.Panorama[i].chpanos.chpano.length(); ch++){//chpano更新
						rend[ch] = xml.Panoramas.Panorama[i].chpanos.chpano[ch].range.@end;
						rstart[ch] = xml.Panoramas.Panorama[i].chpanos.chpano[ch].range.@start;
						chid[ch] = xml.Panoramas.Panorama[i].chpanos.chpano[ch].@panoid.split("pano").join("");
						ch_lat[ch] = xml.Panoramas.Panorama[chid[ch]].coords.@lat;
						ch_lng[ch] = xml.Panoramas.Panorama[chid[ch]].coords.@lng;
					}
										
									
					panoid = xml.Panoramas.Panorama.@panoid[i].split("pano").join("");//新しいパノラマ画像の情報を取得
					north = xml.Panoramas.Panorama[i].direction.@north;
					//snorth=north;
					n_loader.load(new URLRequest("resource/" + xml.Panoramas.Panorama[i].img.@src));//新しいパノラマ画像を読み込む
					n_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,texture2);
				function texture2(event:Event){//表示しているパノラマ画像の更新
				
					for(i=0;i<cn;i++){
						c_id = ccd.Contents.Content[i].@contentid;
						c_data = new Text3D(c_id, new HelveticaBold() , letterformat);
						scene.removeChild(c_data);//表示しているコンテンツを除去（いずれはここは配列）
					}
					
					
					//map.setCenter(new LatLng(lat,lng));
					//marker.setLatLng(new LatLng(lat,lng));
					var panoheight:Number = (750-n_loader.height)/2;//いつもの初期設定
					var bmp_data : BitmapData = new BitmapData(1500,750);
					var matrix : Matrix = new Matrix(-1,0,0,1,1500,panoheight);
					var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
					var rect : Rectangle = new Rectangle(0,0,1500,750);
					camera.x=0;//カメラの初期位置を中心点へ
					camera.z=0;//カニ歩きだから、実際は中心点じゃないほうが違和感がない
					sphere.rotationY = -90 - (north*0.24);
					n_bmp_data = new BitmapData(1500,750);//new_bmp_dataを用意
					n_bmp_data.draw(n_loader, matrix, color, BlendMode.NORMAL, rect, true);
					material.texture = n_bmp_data;//materialのtextureに新しいBitmapdataを貼り付け
					n_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,texture2);//テクスチャを完了
					
					
					
					
					for(i=0;i<cn;i++){//新しいコンテンツの検索（先述のものと同様）
						
						lngsa = contents_lng[i]-lng;
						latsa = contents_lat[i]-lat;
						c_length = Math.sqrt(lngsa*lngsa+latsa*latsa);
						if(c_length <0.00021){
							c_height = ccd.Contents.Content[i].coords.@height;
							c_radius = ccd.Contents.Content[i].range.@radius;
							c_name = ccd.Contents.Content[i].detail.@name;
							c_id = ccd.Contents.Content[i].@contentid;
							//c_data = new Text3D(c_id, new HelveticaBold() , letterformat);
							c_data.text = c_id;
							c_data.x = lngsa*2000000;
							c_data.z = latsa*2000000;
							c_data.y = c_height;
							c_data.scale = 0.1;
							c_data.rotationY = 180 + Math.atan(c_data.x/c_data.z)*180/pi;
							//scene.addChild(c_data);
						}
					}
					var cam:Number = Math.atan(p_lngsa/p_latsa)*180/pi;
					camera.rotationY = int(cam);
					moving = moving_damy;//移動許可
					//addEventListener(Event.ENTER_FRAME,fb_loop);
					leng = Math.sqrt(camera.x * camera.x + camera.z * camera.z);//一応いる？
					level = 0;//いらない子
					
				}
				
			}
			
			function onMapReady(event:Event):void{
 			map.setCenter(new LatLng(lat,lng), 18, MapType.NORMAL_MAP_TYPE);
			map.enableScrollWheelZoom();
			map.enableContinuousZoom()
		
			var cmap:Loader = new Loader();
			cmap.load(new URLRequest("image/map_opu.png"));	
			cmap.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
			var groundOverlay:GroundOverlay = new GroundOverlay(
        	cmap,
        	new LatLngBounds(new LatLng(34.68802784236585, 133.77511024475098), new LatLng(34.697016895486406, 133.78812432289123)));
    		map.addOverlay(groundOverlay);
  			});
			}
			
			function addMarkers(event:Event):void{//マーカー設定
            marker = new Marker(
                        new LatLng(lat,lng),
                        new MarkerOptions({strokeStyle: new StrokeStyle({color: 0xFF0000}), 
										  fillStyle: new FillStyle({color: 0xFFFFFF, alpha: 0.5}), radius:10, hasShadow:true})
            );
			map.removeOverlay(marker);
            
			map.addOverlay(marker);//マーカー配置
			
			var cont_marker:Marker;
			var markerOptions:MarkerOptions = new MarkerOptions();
			for(i=0;i<cn;i++){
				markerOptions.tooltip =  ccd.Contents.Content[i].detail.@name;
				markerOptions.strokeStyle = new StrokeStyle({color: 0xFFFF00});
				markerOptions.fillStyle = new FillStyle({color: 0xFFFF00, alpha: 0.5});
				markerOptions.radius = 10;
				markerOptions.hasShadow = true;
				cont_marker =  new Marker(
                        new LatLng(contents_lat[i],contents_lng[i]),markerOptions);
				map.addOverlay(cont_marker);
			}
			
	        }


			function trace_c(e:MouseEvent):void{//コンテンツをクリックしたときのイベント（現在利用不可）
				
			}
			
			function slide(e:MouseEvent):void {//マウスの位置により上下左右にカメラの視点を移動
				var Ypoint:Number = mouseY;//ドラッグ時のマウスのY座標を保存
				var Xpoint:Number = mouseX;//ドラッグ時のマウスのX座標を保存
				
				addEventListener(Event.ENTER_FRAME, loop);//ENTER_FRAMEによるループのイベント追加
					
				function loop(e:Event):void{//ループ関数
					var Ymove:Number = (Ypoint - mouseY)*0.03;//ドラッグ時とマウス移動時のマウス座標の差を計算
					var Xmove:Number = (Xpoint - mouseX)*0.03;//その3%をカメラの視点が移動する
					camera.rotationY -= Xmove;
					if(camera.rotationX-Ymove>-20 && camera.rotationX-Ymove < 15){
						camera.rotationX -= Ymove;
					}
				}
				stage.addEventListener(MouseEvent.MOUSE_UP, r_loop);//ドラッグ終了時のイベント
				function r_loop(e:MouseEvent):void{//remove_loop
					removeEventListener(Event.ENTER_FRAME, loop);//ENTER_FRAMEによるイベントの除去
					stage.removeEventListener(MouseEvent.MOUSE_UP, r_loop);//ドラッグ終了時のイベントの除去
				}
			}
		
			function u_d_slide(event:MouseEvent):void{//up_down_slide
				moving = event.target.name;//nameプロパティにより+1or-1を取得(これにより上か下かを指定)
				addEventListener(Event.ENTER_FRAME, u_d_loop);//loop関数
				
				function u_d_loop(event:Event):void{//ドラッグ中はずっと動く
					if(camera.rotationX <-20){//角度制限（白いとこが見えないように）
						if(moving > 0){
							camera.rotationX += moving;//
						}
					}
					else if(camera.rotationX > 15){
						if(moving <0){
							camera.rotationX += moving;
						}
					}
					else{
						camera.rotationX += moving;
					}
					stage.addEventListener(MouseEvent.MOUSE_UP, r_u_d_loop);//ドラッグ終了時のイベント
					function r_u_d_loop(event:MouseEvent):void{
						removeEventListener(Event.ENTER_FRAME, u_d_loop);//ループの除去
						stage.removeEventListener(MouseEvent.MOUSE_UP, r_u_d_loop);//ループ除去用のイベントの除去
					}
				}
			}
		
		
				function btnMouseDown(event:MouseEvent):void {
					//trace(lat);
					//trace(lng);
					//trace(snorth);
					//trace(north);
					//trace(startdir);
					var street:String;
					street="http://localhost/test/spot.php?"+"lat="+lat +"&lng="+lng + "&dir="+snorth+"&view=street";
    				var url:URLRequest = new URLRequest(street);
    				navigateToURL(url, "_self");
				}
		
				
			function full_slide(event:MouseEvent):void {
				moving = event.target.name;
				if(moving>0){
				viewport.viewportWidth = stage.stageWidth;//デバッグ、プレビューでの上限1078pix
				viewport.viewportHeight = stage.stageHeight+75;
				viewport.x=0;
				viewport.y=0;
				//stage.displayState = StageDisplayState.FULL_SCREEN;
				camera.zoom = 65;
				removeChild(map);
				stage.removeChild(text_field);
				removeChild(fullon);
				addChild(fulloff);
				//trace("stage.width = " + stage.stageWidth);
				//trace("stage.height = " + stage.stageHeight);
				//trace("camera.zoom = " + camera.zoom);
				}
				else{
				viewport.viewportWidth = view_width;
				viewport.viewportHeight = view_height;
				viewport.x = (stage.stageWidth - viewport.viewportWidth)/2;
				//viewport.y = (stage.stageHeight - viewport.viewportHeight)/2;
				//stage.displayState = StageDisplayState.NORMAL;
				camera.zoom = 40;
				addChild(map);
				stage.addChild(text_field);
				removeChild(fulloff);
				addChild(fullon);
				//trace("stage.width = " + stage.stageWidth);
				//trace("stage.height = " + stage.stageHeight);
				//trace("camera.zoom = " + camera.zoom);
				}

			}
			function rl_slide(event:MouseEvent):void {//right_left_slide
				moving = event.target.name;//nameプロパティにより左右の判定
				addEventListener(Event.ENTER_FRAME, rl_loop);
				
				function rl_loop(event:Event):void{//
					//for(var k :Number = 0; k < 20; k++){//滑らかさがほしいなら//を消してmoving*1をmoving*0.1にする（重くなる）
					camera.rotationY += moving*2;
					snorth += moving*2;
					//}
				}
				stage.addEventListener(MouseEvent.MOUSE_UP, st_rl_loop);//いつものごとく除去
				function st_rl_loop(e:MouseEvent):void{
					removeEventListener(Event.ENTER_FRAME, rl_loop);
					stage.removeEventListener(MouseEvent.MOUSE_UP, st_rl_loop);
				}
			 }
		
			function fb_slide(event:MouseEvent):void {//foward_back_slide（ここから本番）
				moving = event.target.name;//前進か後進か
				moving_damy = moving;//movingのダミーを用意
				var material:BitmapMaterial = sphere.material as BitmapMaterial;//ちょっと小細工
				
				var panoheight:Number = (750-loader.height)/2;//前述通り
				var bmp_data : BitmapData = new BitmapData(1500,750);
				var matrix : Matrix = new Matrix(-1,0,0,1,1500,panoheight);
				var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
				var rect : Rectangle = new Rectangle(0,0,1500,750);
				var i :Number;
				var id1 :String;
				
				addEventListener(Event.ENTER_FRAME,fb_loop);
				function fb_loop(event:Event):void{
					
					rad= camera.rotationY/180*pi;//カメラの角度のラジアン
					xsa= camera.x+Math.sin(rad) * moving*3;//rad方向に進むとx方向にxsa進む
					ysa = camera.z+Math.cos(rad) * moving*3;//rad方向に進むとy方向にysa進む
					un_leng = Math.sqrt(xsa*xsa + ysa*ysa);//前述通り
					lengsa= un_leng - leng;
					
					if(moving != 0){//movingが0でなければ、lengを計算
						leng = Math.sqrt(camera.x * camera.x + camera.z * camera.z);
					}
					level++;//不必要
					
					
					range = Math.acos( camera.z / leng)*180/pi;//ラジアン⇒角度
					

					if(lengsa >0){//中心から外部へ移動
						if(un_leng < 250){//距離250までの制限
						camera.x += Math.sin(rad) * moving*10;//もともと5
						camera.z += Math.cos(rad) * moving*10;
						}
					}
					else{//中心へ移動
						camera.x += Math.sin(rad) * moving*10;
						camera.z += Math.cos(rad) * moving*10;
					}
					
					if(camera.x < 0){//x座標がマイナスの時
						range = 360 - range;//角度補正
					}
					
					if (leng > 40){//距離が40になったら：切替判定開始
						
						leng = 39;//切替発生中止用(もういらないかも？)
						if(range < 180){//range0-180の間が0⇒ch
							fa = 0;
							la = ch-1;
							pm = 1;
						}
						else{//range180-360の間がch⇒0
							fa = ch-1;
							la = 0;
							pm = -1;
						}
						
						for(i = fa; i!=la+pm ; i+=pm){//切替パノラマ検索
							if(rend[i] - rstart[i] >=0){//rangeend-rangestartが0より大きければ（270-200とか）
								if(rstart[i]<=range && range<=rend[i]){//（200～270とか普通に計算できる）
									moving = 0;//切替中は移動禁止
									id1 = "pano" + chid[i].toString();//id1に切替るパノラマIDを保存
									
									//latsa =Math.abs(lat - ch_lat[i]);
									//lngsa =Math.abs(lng - ch_lng[i]);
									
									lat = ch_lat[i];//latを切り替えるパノラマのものに更新
									lng = ch_lng[i];//lngを切り替えるパノ（ｒｙ
									
									//if((latsa <0.000028) && (lngsa <0.000028)){//lngsaが遠いものには切り替わらないようにしたかった…
										for(ch=0; ch<xml.Panoramas.Panorama.(@panoid == id1).chpanos.chpano.length(); ch++){//chpano更新
											rend[ch] = xml.Panoramas.Panorama.(@panoid == id1).chpanos.chpano[ch].range.@end;
											rstart[ch] = xml.Panoramas.Panorama.(@panoid == id1).chpanos.chpano[ch].range.@start;
											chid[ch] = xml.Panoramas.Panorama.(@panoid == id1).chpanos.chpano[ch].@panoid.split("pano").join("");
											ch_lat[ch] = xml.Panoramas.Panorama.(@panoid == "pano" + chid[ch]).coords.@lat;
											ch_lng[ch] = xml.Panoramas.Panorama.(@panoid == "pano" + chid[ch]).coords.@lng;
										}
										
										panoid = xml.Panoramas.Panorama.(@panoid == id1).@panoid.split("pano").join("");//新しいパノラマ画像の情報を取得
										north = xml.Panoramas.Panorama.(@panoid == id1).direction.@north;
										//snorth=north;
										n_loader.load(new URLRequest("resource/" + xml.Panoramas.Panorama.(@panoid == id1).img.@src));//新しいパノラマ画像を読み込む
										n_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,texture);//新しいパノラマ画像を貼り付けに
										break;//for文が無駄にまわらないようにbreak
									//}
								}
							}
							else{
								if((rstart[i]<=range && range<360)||(0<=range && range<=rend[i])){//rendが20、rstart350のときとか…たぶんもう少し簡単にできる
									moving = 0;//切替判定中移動禁止
									id1 = "pano"+ chid[i];//ID保存
									//latsa =Math.abs(lat - ch_lat[i]);
									//lngsa =Math.abs(lng - ch_lng[i]);
									
									lat = ch_lat[i];//あとは大体一緒
									lng = ch_lng[i];
									
									//if((latsa <0.000028) &&(lngsa < 0.000028) ){
										
										for(ch=0; ch<xml.Panoramas.Panorama.(@panoid == id1).chpanos.chpano.length(); ch++){
											rend[ch] = xml.Panoramas.Panorama.(@panoid == id1).chpanos.chpano[ch].range.@end;
											rstart[ch] = xml.Panoramas.Panorama.(@panoid == id1).chpanos.chpano[ch].range.@start;
											chid[ch] = xml.Panoramas.Panorama.(@panoid == id1).chpanos.chpano[ch].@panoid.split("pano").join("");
											ch_lat[ch] = xml.Panoramas.Panorama.(@panoid == "pano" + chid[ch]).coords.@lat;
											ch_lng[ch] = xml.Panoramas.Panorama.(@panoid == "pano" + chid[ch]).coords.@lng;
										}
										
										
										panoid = xml.Panoramas.Panorama.(@panoid == id1).@panoid.split("pano").join("");
										north = xml.Panoramas.Panorama.(@panoid == id1).direction.@north;
										//snorth=north;
										n_loader.load(new URLRequest("resource/" + xml.Panoramas.Panorama.(@panoid == id1).img.@src));
										n_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,texture);
										break;
									//}
								}
							}
						}
					}
					
					
				}
				
				stage.addEventListener(MouseEvent.MOUSE_UP, st_fb_loop);//マウスのドラッグが離れたとき、EnterFrame終了
				function st_fb_loop(e:MouseEvent):void{
					removeEventListener(Event.ENTER_FRAME, fb_loop);
					stage.removeEventListener(MouseEvent.MOUSE_UP, st_fb_loop);
				}
				
				function texture(event:Event){//表示しているパノラマ画像の更新
				
					for(i=0;i<cn;i++){
						c_id = ccd.Contents.Content[i].@contentid;
						c_data = new Text3D(c_id, new HelveticaBold() , letterformat);
						scene.removeChild(c_data);//表示しているコンテンツを除去（いずれはここは配列）
					}
					
					//map.setCenter(new LatLng(lat,lng));
					//marker.setLatLng(new LatLng(lat,lng));
					var panoheight:Number = (750-n_loader.height)/2;//いつもの初期設定
					var bmp_data : BitmapData = new BitmapData(1500,750);
					var matrix : Matrix = new Matrix(-1,0,0,1,1500,panoheight);
					var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
					var rect : Rectangle = new Rectangle(0,0,1500,750);
					camera.x=0;//カメラの初期位置を中心点へ
					camera.z=0;//カニ歩きだから、実際は中心点じゃないほうが違和感がない
					sphere.rotationY = -90 - (north*0.24);
					n_bmp_data = new BitmapData(1500,750);//new_bmp_dataを用意
					n_bmp_data.draw(n_loader, matrix, color, BlendMode.NORMAL, rect, true);
					material.texture = n_bmp_data;//materialのtextureに新しいBitmapdataを貼り付け
					n_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,texture);//テクスチャを完了
					
					
					
					
					for(i=0;i<cn;i++){//新しいコンテンツの検索（先述のものと同様）
						
						lngsa = contents_lng[i]-lng;
						latsa = contents_lat[i]-lat;
						c_length = Math.sqrt(lngsa*lngsa+latsa*latsa);
						if(c_length <0.00021){
							c_height = ccd.Contents.Content[i].coords.@height;
							c_radius = ccd.Contents.Content[i].range.@radius;
							c_name = ccd.Contents.Content[i].detail.@name;
							c_id = ccd.Contents.Content[i].@contentid;
							//c_data = new Text3D(c_id, new HelveticaBold() , letterformat);
							c_data.text = c_id;
							c_data.x = lngsa*2000000;
							c_data.z = latsa*2000000;
							c_data.y = c_height;
							c_data.scale = 0.1;
							c_data.rotationY = 180 + Math.atan(c_data.x/c_data.z)*180/pi;
							//scene.addChild(c_data);
						}
					}
					moving = moving_damy;//移動許可
					//addEventListener(Event.ENTER_FRAME,fb_loop);
					leng = Math.sqrt(camera.x * camera.x + camera.z * camera.z);//一応いる？
					level = 0;//いらない子
					
				}
			}
		}
	}
}