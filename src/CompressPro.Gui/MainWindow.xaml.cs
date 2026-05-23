using System.ComponentModel;
using System.Diagnostics;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Input;
using System.Windows.Controls;
using CompressPro.Core.Models;
using CompressPro.Gui.Services;
using CompressPro.Gui.Views;
using Microsoft.Win32;

namespace CompressPro.Gui;

/// <summary>
/// 主窗口
/// </summary>
public partial class MainWindow : Window
{
    private readonly ISevenZipService _sevenZip;
    private List<ArchiveFileInfo> _currentEntries = [];
    private string _currentArchivePath = string.Empty;

    public MainWindow()
    {
        InitializeComponent();

        // SevenZipService (7z.dll) → 回退 SevenZipExeService (7z.exe)
        try
        {
            _sevenZip = new SevenZipService();
        }
        catch
        {
            _sevenZip = new SevenZipExeService();
        }

        // 拖拽打开
        AllowDrop = true;
        Drop += MainWindow_Drop;

        // 快捷键
        KeyDown += (s, e) =>
        {
            if (e.Key == Key.O && (Keyboard.Modifiers & ModifierKeys.Control) == ModifierKeys.Control)
                BtnOpen_Click(s, e);
            if (e.Key == Key.E && (Keyboard.Modifiers & ModifierKeys.Control) == ModifierKeys.Control)
                BtnExtract_Click(s, e);
        };
    }

    // ══════════════════════════════════════════
    //  菜单栏
    // ══════════════════════════════════════════

    private void MenuExit_Click(object sender, RoutedEventArgs e)
    {
        Application.Current.Shutdown();
    }

    private void MenuHelp_Click(object sender, RoutedEventArgs e)
    {
        try
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = "https://github.com/compresspro/compresspro/wiki",
                UseShellExecute = true
            });
        }
        catch { /* 静默失败 */ }
    }

    private async void MenuCheckUpdate_Click(object sender, RoutedEventArgs e)
    {
        StatusText.Text = "正在检查更新...";
        await Task.Delay(500); // 模拟网络检查

        // TODO: 接入 GitHub Releases API 检查最新版本
        var current = "1.0.0";
        MessageBox.Show(
            $""""
            当前版本: v{current}

            检查更新功能将在接入 GitHub Releases API 后生效。
            目前请前往 GitHub 查看最新版本:
            https://github.com/compresspro/compresspro/releases
            """",
            "检查更新",
            MessageBoxButton.OK,
            MessageBoxImage.Information);

        StatusText.Text = "就绪";
    }

    private void MenuAbout_Click(object sender, RoutedEventArgs e)
    {
        MessageBox.Show(
            $""""
            CompressPro v1.0.0
            🗜️ 轻量、高效的开源压缩解压工具

            基于 7-Zip 引擎 (LGPL-2.1)
            支持 30+ 压缩格式

            © 2024 CompressPro Contributors
            GitHub: https://github.com/compresspro/compresspro
            """",
            "关于 CompressPro",
            MessageBoxButton.OK,
            MessageBoxImage.Information);
    }

    // ══════════════════════════════════════════
    //  工具栏 / 文件操作
    // ══════════════════════════════════════════

    private async void BtnOpen_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog
        {
            Title = "选择压缩包",
            Filter = "压缩文件|*.7z;*.zip;*.rar;*.tar;*.gz;*.bz2;*.xz;*.zst;*.lz4|所有文件|*.*"
        };

        if (dialog.ShowDialog() == true)
        {
            await LoadArchive(dialog.FileName);
        }
    }

    private async Task LoadArchive(string path)
    {
        try
        {
            StatusText.Text = "正在读取压缩包...";
            _currentArchivePath = path;
            TbPath.Text = path;
            TbPath.Foreground = System.Windows.Media.Brushes.Black;

            _currentEntries = await _sevenZip.ListArchiveAsync(path);

            FileList.ItemsSource = _currentEntries;

            // 更新空状态
            UpdateEmptyState();

            // 更新状态栏
            var folders = _currentEntries.Count(e => e.IsFolder);
            var files = _currentEntries.Count(e => !e.IsFolder);
            var totalSize = _currentEntries.Sum(e => e.UncompressedSize);
            StatusText.Text = $"已打开: {System.IO.Path.GetFileName(path)}";
            StatusCount.Text = $"{files} 个文件  {folders} 个文件夹  总计: {FormatSize(totalSize)}";

            // 启用相关按钮
            SetArchiveButtonsEnabled(true);
        }
        catch (NotImplementedException)
        {
            MessageBox.Show(
                "SevenZipSharp 尚未集成，当前使用 7z.exe 模式的回退方案。\n" +
                "请确保已安装 7-Zip (https://7-zip.org/) 或放置 7z.dll 到程序目录。",
                "功能待实现",
                MessageBoxButton.OK,
                MessageBoxImage.Information);
            StatusText.Text = "就绪";
        }
        catch (Exception ex)
        {
            MessageBox.Show($"无法打开压缩包:\n{ex.Message}", "错误",
                MessageBoxButton.OK, MessageBoxImage.Error);
            StatusText.Text = "就绪";
        }
    }

    private void UpdateEmptyState()
    {
        EmptyOverlay.Visibility = _currentEntries.Count == 0
            ? Visibility.Visible
            : Visibility.Collapsed;
    }

    private void EmptyOverlay_MouseDown(object sender, RoutedEventArgs e)
    {
        BtnOpen_Click(sender, e);
    }

    private void SetArchiveButtonsEnabled(bool enabled)
    {
        MenuAdd.IsEnabled = enabled;
        MenuExtract.IsEnabled = enabled;
        MenuExtractHere.IsEnabled = enabled;
        MenuTest.IsEnabled = enabled;
        MenuDelete.IsEnabled = enabled;
        MenuInfo.IsEnabled = enabled;

        BtnAdd.IsEnabled = enabled;
        BtnExtract.IsEnabled = enabled;
        BtnExtractHere.IsEnabled = enabled;
        BtnTest.IsEnabled = enabled;
        BtnDelete.IsEnabled = enabled;
        BtnInfo.IsEnabled = enabled;
    }

    // ─── 添加文件 ───

    private void BtnAdd_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog
        {
            Title = "选择要添加到压缩包的文件",
            Multiselect = true
        };

        if (dialog.ShowDialog() == true)
        {
            MessageBox.Show($"已选择 {dialog.FileNames.Length} 个文件\n(压缩功能待 SevenZipSharp 集成)", "提示");
        }
    }

    // ─── 解压 ───

    private async void BtnExtract_Click(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrEmpty(_currentArchivePath)) return;

        var dialog = new FolderPickerDialog();
        if (dialog.ShowDialog() == true)
        {
            await ExtractArchive(dialog.SelectedPath);
        }
    }

    private async void BtnExtractHere_Click(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrEmpty(_currentArchivePath)) return;

        var dir = System.IO.Path.GetDirectoryName(_currentArchivePath)
                  ?? Environment.CurrentDirectory;
        await ExtractArchive(dir);
    }

    private async Task ExtractArchive(string outputDir)
    {
        try
        {
            StatusText.Text = "正在解压...";
            await _sevenZip.ExtractAsync(_currentArchivePath, outputDir);
            StatusText.Text = "解压完成";

            var result = MessageBox.Show(
                $"解压完成!\n文件已保存到:\n{outputDir}\n\n是否打开目标文件夹?",
                "解压完成",
                MessageBoxButton.YesNo,
                MessageBoxImage.Information);

            if (result == MessageBoxResult.Yes)
            {
                Process.Start("explorer.exe", outputDir);
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show($"解压失败:\n{ex.Message}", "错误",
                MessageBoxButton.OK, MessageBoxImage.Error);
            StatusText.Text = "就绪";
        }
    }

    // ─── 测试 ───

    private async void BtnTest_Click(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrEmpty(_currentArchivePath)) return;

        try
        {
            StatusText.Text = "正在测试压缩包完整性...";
            var ok = await _sevenZip.TestArchiveAsync(_currentArchivePath);
            MessageBox.Show(
                ok ? "压缩包完整 ✅" : "压缩包可能损坏 ⚠️",
                "测试结果",
                MessageBoxButton.OK,
                ok ? MessageBoxImage.Information : MessageBoxImage.Warning);
            StatusText.Text = ok ? "测试通过" : "测试发现错误";
        }
        catch (Exception ex)
        {
            MessageBox.Show($"测试失败:\n{ex.Message}", "错误");
            StatusText.Text = "就绪";
        }
    }

    // ─── 删除 ───

    private void BtnDelete_Click(object sender, RoutedEventArgs e)
    {
        if (FileList.SelectedItems.Count == 0) return;

        var result = MessageBox.Show(
            $"确定要从压缩包中删除选中的 {FileList.SelectedItems.Count} 个文件?",
            "确认删除",
            MessageBoxButton.YesNo,
            MessageBoxImage.Warning);

        if (result == MessageBoxResult.Yes)
        {
            // TODO: 调用删除方法
        }
    }

    // ─── 信息 ───

    private void BtnInfo_Click(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrEmpty(_currentArchivePath)) return;

        var fi = new System.IO.FileInfo(_currentArchivePath);
        var entries = _currentEntries;
        var msg = $"""
            压缩包: {fi.Name}
            路径: {fi.FullName}
            大小: {FormatSize(fi.Length)}
            文件数: {entries.Count(e => !e.IsFolder)}
            文件夹: {entries.Count(e => e.IsFolder)}
            原始总大小: {FormatSize(entries.Sum(f => f.UncompressedSize))}
            创建时间: {fi.CreationTime:yyyy-MM-dd HH:mm:ss}
            修改时间: {fi.LastWriteTime:yyyy-MM-dd HH:mm:ss}
            """;

        MessageBox.Show(msg, "压缩包信息", MessageBoxButton.OK, MessageBoxImage.Information);
    }

    // ─── 拖拽 ───

    private async void MainWindow_Drop(object sender, DragEventArgs e)
    {
        if (e.Data.GetDataPresent(DataFormats.FileDrop))
        {
            var files = (string[])e.Data.GetData(DataFormats.FileDrop);
            if (files.Length > 0)
            {
                await LoadArchive(files[0]);
            }
        }
    }

    private static string FormatSize(long bytes) => bytes switch
    {
        < 0 => "0 B",
        < 1024 => $"{bytes} B",
        < 1024 * 1024 => $"{bytes / 1024.0:F1} KB",
        < 1024L * 1024 * 1024 => $"{bytes / (1024.0 * 1024):F1} MB",
        _ => $"{bytes / (1024.0 * 1024 * 1024):F2} GB"
    };
}
