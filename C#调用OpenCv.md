## 工具选择

目前C#调用OpenCv有两种比较流行的方法，分别为[EmguCv](https://github.com/emgucv)和[OpenCvSharp](https://github.com/shimat/opencvsharp),这里使用OpenCvSharp

## 安装
1. 新建任意一个C#项目

2. OpenCvSharp支持Nuget安装，要求VS2017或更新的版本，点击“工具”->“NuGet 包管理器”->“管理解决方案的NuGet程序包...”
![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/c_sharp_cpp/1.png)

3. 在“浏览”中搜索“OpenCvSharp”,其最新版本为4.x,然后选择“安装”，VS2017会下载该包并将需要的dll复制到工程目录下
![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/c_sharp_cpp/2.png)

## 使用

```c#
using OpenCvSharp;  //使用OpenCvSharp
namespace C2{
    class HelloWorld{

        static void Main(string[] args){
            Console.WriteLine("Hello World");

            Mat mat = new Mat(@"F:/Face/LN.jpg");   //加载本地图片
            Size matSize = new Size(5, 5);
            Mat dst = new Mat(matSize, mat.Type());
            Mat dst1 = new Mat(matSize, mat.Type());
            Mat dst2 = new Mat(matSize, mat.Type());

            Cv2.CvtColor(mat, dst, ColorConversionCodes.BGR2GRAY);  //转换图片为灰度图
            Cv2.Blur(dst, dst1, matSize);    //模糊图片
            Cv2.Canny(dst1, dst2, 10, 240);  //使用Canny()函数检索边界


            Cv2.ImShow("src", mat);
            Cv2.ImShow("dst1", dst1);
            Cv2.ImShow("dst2", dst2);
            Cv2.WaitKey(0);
            Cv2.DestroyAllWindows();

            Console.ReadKey();
        }
    }
}
```

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/c_sharp_cpp/3.png)