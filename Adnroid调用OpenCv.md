## 下载SDK

从OpenCv官网上下载opencv for android的sdk,这里以3.4版本为例，SDK下载解压后结果目录为

* OpenCV-android-sdk
   * apk
   * samples
   * sdk
      * etc
      * java
      * native
         * 3rdparty
         * jni
         * libs
         * staticlibs
      * build.gradle
   * LICENSE
   * README.android

## Android工程添加Opencv

创建一个支持C++的安卓工程，其中C++标准选择C++11，然后"File"->"New"->"Import Module"，将OpenCv的SDK作为Module添加进工程

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Android_opencv/21.png)

这里是SDk的选择目录为~/OpenCV-android-sdk/sdk/java

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Android_opencv/22.png)

添加完成后点击"Project Structure..."

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Android_opencv/23.png)

"Dependencies"->"app"->"+"->"3 Module Dependency",将Opencv模组添加

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Android_opencv/24.png)
![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Android_opencv/25.png)

点击"apply"后Android Studio会报错，类似这样

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Android_opencv/26.png)

这里需要将Opencv的AndroidManifest.xml中的这句注释掉，同时将OpenCv模组的build.gradle中的compileSdkVersion，buildToolsVersion，minSdkVersion，targetSdkVersion的值修改为和app/build.gradle的值一致，然后点击"sync now"

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Android_opencv/27.png)

接下来，需要在app/src/main/目录下，右键选择"New"->Directory,创建一个jinLibs的目录（注意该目录名称区分大小写）

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Android_opencv/31.png)

然后将~/OpenCV-android-sdk/sdk/native/libs目录下的全部文件复制至该目录下

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Android_opencv/32.png)

然后修改app的build.gradle文件，在dependencies内添加
```shell
implementation fileTree(dir: "$buildDir/native-libs", include: 'native-libs.jar')
```
然后添加
```shell
task nativeLibsToJar(type: Jar,description:'create a jar archive of the native libs'){
    destinationDir file("$buildDir/native-libs")
    baseName 'native-libs'
    from fileTree(dir: 'libs',include: '**/*.so')
    into 'lib/'
}
tasks.withType(JavaCompile){
    compileTask -> compileTask.dependsOn(nativeLibsToJar)
}
```
类似下图

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Android_opencv/33.png)

示例代码如下，这个Activity是新建工程是默认添加的，做了少许修改
```java
public class MainActivity extends AppCompatActivity {

    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");   //注释1
    }

    private ImageView showImageView;
    private Bitmap lenaBitMap;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        OpenCVLoader.initDebug();     //注释2

        showImageView = findViewById(R.id.showImageView);
        Button addImgBtn = findViewById(R.id.addImgBtn);
        Button blurImgBtn = findViewById(R.id.blurImgBtn);
        Button cannyImgBtn = findViewById(R.id.cannyImgBtn);

        addImgBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                lenaBitMap = BitmapFactory.decodeResource(getResources(),R.mipmap.lena);
                showImageView.setImageBitmap(lenaBitMap);
            }
        });

        blurImgBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Mat resMat = new Mat();
                Mat blurMat = new Mat();
                Mat dstMat = new Mat();

                Utils.bitmapToMat(lenaBitMap,resMat);   //注释3
                Imgproc.cvtColor(resMat,blurMat,Imgproc.COLOR_RGB2GRAY);
                Imgproc.blur(blurMat,dstMat,new Size(5,5));

                Bitmap dstMap = Bitmap.createBitmap(lenaBitMap.getWidth(),lenaBitMap.getHeight(),Bitmap.Config.RGB_565);
                Utils.matToBitmap(dstMat,dstMap);
                showImageView.setImageBitmap(dstMap);   //注释4
            }
        });

    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    public native String stringFromJNI();
}
```
+ 注释1 这个是添加C++支持的默认添加的代码，用于C++代码相关，OpenCv作为C++的类库，只能在支持C++的工程中使用

+ 注释2 调用OpenCv库，该函数必须在所有OpenCv相关代码之前调用，如果有OpenCv代码位于该函数之前，则会报错。该函数返回一个布尔值，用于判断工程调用OpenCv库是否成功

+ 注释3 这里演示了Opencv的Mat类和安卓的BitMap类之间的转换

* 注释4 将图片通过OpenCv处理后，再进行显示

结果如下

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Android_opencv/41.png)
![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Android_opencv/42.png)