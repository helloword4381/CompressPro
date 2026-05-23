using System.IO;
using System.Windows;
using System.Windows.Controls;

namespace CompressPro.Gui.Views;

/// <summary>
/// 简化的文件夹选择对话框 (纯 WPF，无 WinForms 依赖)
/// </summary>
public partial class FolderPickerDialog : Window
{
    public string SelectedPath { get; set; } = string.Empty;

    public FolderPickerDialog()
    {
        InitializeComponent();
        LoadDrives();
    }

    private void LoadDrives()
    {
        FolderTree.Items.Clear();
        foreach (var drive in DriveInfo.GetDrives())
        {
            if (drive.IsReady)
            {
                var item = new TreeViewItem
                {
                    Header = $"{drive.Name} ({drive.VolumeLabel})",
                    Tag = drive.RootDirectory.FullName
                };
                item.Items.Add("..."); // placeholder for lazy loading
                item.Expanded += Drive_Expanded!;
                FolderTree.Items.Add(item);
            }
        }
    }

    private void Drive_Expanded(object sender, RoutedEventArgs e)
    {
        var item = (TreeViewItem)sender;
        if (item.Tag is not string path) return;

        item.Items.Clear();
        LoadSubDirectories(item, path);
    }

    private static void LoadSubDirectories(TreeViewItem parent, string path)
    {
        try
        {
            foreach (var dir in Directory.GetDirectories(path))
            {
                try
                {
                    var di = new DirectoryInfo(dir);
                    var child = new TreeViewItem
                    {
                        Header = di.Name,
                        Tag = dir
                    };

                    // Check if it has subdirectories
                    try
                    {
                        if (Directory.GetDirectories(dir).Length > 0)
                            child.Items.Add("...");
                    }
                    catch { }

                    child.Expanded += (_, _) =>
                    {
                        child.Items.Clear();
                        LoadSubDirectories(child, dir);
                    };

                    parent.Items.Add(child);
                }
                catch { /* skip inaccessible */ }
            }
        }
        catch { /* skip inaccessible */ }
    }

    private void FolderTree_SelectedItemChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
    {
        if (e.NewValue is TreeViewItem item && item.Tag is string path)
        {
            SelectedPath = path;
            PathInput.Text = path;
        }
    }

    private void Ok_Click(object sender, RoutedEventArgs e)
    {
        if (!string.IsNullOrWhiteSpace(PathInput.Text))
            SelectedPath = PathInput.Text;
        DialogResult = true;
        Close();
    }

    private void Cancel_Click(object sender, RoutedEventArgs e)
    {
        DialogResult = false;
        Close();
    }
}
