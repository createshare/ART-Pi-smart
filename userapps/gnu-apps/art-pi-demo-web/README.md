# ART-Pi Demo Web 使用说明

首先需要下载kcomponents组件并重新编译kernel:
```bash
  $ cd ~
  $ git clone https://git.rt-thread.com/alliance/rt-smart/art-pi-smart
  $ ln -s art-pi-smart/kcomponents kernel/bsp/imx6ull-artpi-smart/kcomponents
  $ cd kernel/bsp/imx6ull-artpi-smart
```

由于宏定义"RT_USING_SYSINFO"默认未定义，导致sysinfo.c不会被编译；  
所以需要修改kcomponents/sysinfo/SConscript, 将sysinfo.c直接添加到src的定义里面：
```bash
@@ -11,12 +11,10 @@
 sysinfo_dfs.c
 sysinfo_gcc.c
 sysinfo_date.c
+sysinfo.c
 ''')
 CPPPATH = [cwd]
 
-if GetDepend('RT_USING_SYSINFO'):
-	src		+= ['sysinfo.c']
-
 group = DefineGroup('Sysinfo', src, depend = [''], CPPPATH = CPPPATH)
 
 Return('group')
```

然后再重新编译kernel:
```bash
  $ scons
```

然后编译gnu-apps libs:
```bash
  $ cd userapps/gnu-apps
  $ ./build.sh libs
```
如果已经编译过则跳过。

接着编译uhttpd和cgi:
```bash
  $ cd uhttpd
  $ ./build_uhttpd.sh
  $ cd ../sqlite
  $ ./build_sqlite.sh
```
编译后，demo需要的所有cgi都会被拷贝到root/var/dist目录下。  
由于大部分cgi都需要操作数据库，所以为编译方便，都放到sqlite下了。  
uhttpd.elf会被拷贝到root/bin下。

然后拷贝Web: 
```bash
  $ cd art-pi-demo-web
  $ ./build_web.sh
```
该脚本会将dist下所有内容拷贝到root/var/dist下。

测试：
将root下内容拷贝到SD卡，然后启动ART-Pi板子，确保SD卡挂载到根目录。
启动uhttpd服务:
```bash
  msh /> uhttpd.elf -f -p 80 -h /var/dist &
```
然后通过浏览器访问ART-Pi的IP地址就行了。  
默认可以使用admin/admin进行登录。

首页展示：
  * CPU, 内存，空间的使用情况，默认5s刷新一次，可以设置;
  * 表格形式展示系统版本、编译日期、GCC版本以及网络信息等；
  * 支持系统时间显示，每隔一定时间与系统同步一次，间隔可设置；
  * 支持网络状态监测，与CPU, 内存等的刷新频率一致。

用户管理：
  * 表格形式展示系统所有用户；
  * 支持修改密码；
  * 支持删除用户;
  * 支持增加用户。

LED控制：
  * 支持对LED进行开关操作；
  * 支持对LED状态实时显示, 刷新频率可设置。

系统日志：
  * 表格形式展示日志内容，用户的所有行为都会记录到日志中；
  * 支持删除日志。

系统设置：
  * 设置首页的系统信息刷新频率；
  * 设置LED状态刷新频率；
  * 设置时间同步间隔频率。

## Web源文件目录说明
  * vue-antd-admin - vue源文件目录，可以通过Webstorm或VSCode等IDE进行二次开发：
  * dist - vue编译生成的web资源文件, 会用于uhttpd服务的home根目录。

## LED测试说明
需要注释掉kernel/bsp/imx6ull-artpi-smart/application/main.c里面的for循环逻辑，该循环会以500毫秒的频率闪烁LED灯，导致看到不到控制的效果。

## Web Demo详细设计
[ART-Pi Demo Web设计说明](https://docs.qq.com/doc/DZXFpT0h2bXpMRktj)

