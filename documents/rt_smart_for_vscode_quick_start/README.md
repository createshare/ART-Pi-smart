## RT-Thread Smart for Vscode 快速上手

#### 安装 RT-Thread Smart 扩展

在 Vscode 应用商店中，搜索 RT-Thread Smart,  选择下图所示扩展，点击 `安装` 即可：

![安装扩展](figures/smart_install.png)

#### 创建工程

执行快捷键 `Ctrl_Shift+P`, 输入 `RT-Thread` 关键字，选择 `创建 RT-Thread Smart 工程`, 然后按提示执行以下操作：

- 输入 SDK 根目录
- 输入工程名称
- 选择构建工具（linux 平台支持 CMake、Make、Scons， Windows 平台只支持 Scons） 

![创建工程](figures/smart_create_project.png)

接下来你就会看到一个自动创建好的 RT-Thread Smart 工程：

![Smart工程目录](figures/smart_project.png) 



#### 编译/清理/下载

点击 Vscode 左下角的 `编译`、`清理` 或者 `下载` 工具，会为您自动 `编译工程`、`清理工程`或者 `推送程序到开发板`

![Smart工具栏](figures/smart_tool.png) 

您需要注意的是，`下载前`，如果您未设置 Server 的 ip 地址，插件为为您自动定位到 IP 的设置位置，你只需要填写 IP 地址并重新点击 `下载` 即可。

![ip配置](figures/smart_server_ip.png)

您也可以直接在 .vscode/settings/json 中修改对应的 ip 地址

![settings.json](figures/smart_settings_json.png)

#### 调试

直接快捷键 `F5`, 即可启动调试

![Smart调试](figures/smart_debug.png)

如果你想在调试前添加一些任务或者删除一些任务，只要到修改 .vscode/tasks.json 中的内容即可：

![tasks.json](figures/smart_tasks_json.png)