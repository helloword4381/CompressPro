using System.Windows;
using Application = System.Windows.Application;

namespace CompressPro.Gui;

/// <summary>
/// App.xaml 代码后置
/// </summary>
public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        // 处理命令行参数: 右键菜单 "extract" / "add" 命令
        var args = e.Args;
        if (args.Length > 0)
        {
            var command = args[0].ToLowerInvariant();
            var files = args.Skip(1).ToArray();

            switch (command)
            {
                case "extract":
                    // 右键 "解压到..." → 打开目标选择对话框
                    break;
                case "extracthere":
                    // 右键 "解压到当前目录"
                    break;
                case "add":
                    // 右键 "添加到压缩包..."
                    break;
            }
        }
    }
}
