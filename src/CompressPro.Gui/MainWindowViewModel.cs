using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using CompressPro.Core.Models;

namespace CompressPro.Gui;

/// <summary>
/// 主窗口 ViewModel (MVVM 模式辅助)
/// </summary>
public class MainWindowViewModel : INotifyPropertyChanged
{
    private ObservableCollection<ArchiveFileInfo> _entries = [];
    private string _archivePath = string.Empty;
    private string _statusMessage = "就绪";
    private bool _isArchiveLoaded;
    private string _fileCountInfo = string.Empty;

    public ObservableCollection<ArchiveFileInfo> Entries
    {
        get => _entries;
        set { _entries = value; OnPropertyChanged(); }
    }

    public string ArchivePath
    {
        get => _archivePath;
        set { _archivePath = value; OnPropertyChanged(); }
    }

    public string StatusMessage
    {
        get => _statusMessage;
        set { _statusMessage = value; OnPropertyChanged(); }
    }

    public string FileCountInfo
    {
        get => _fileCountInfo;
        set { _fileCountInfo = value; OnPropertyChanged(); }
    }

    public bool IsArchiveLoaded
    {
        get => _isArchiveLoaded;
        set { _isArchiveLoaded = value; OnPropertyChanged(); }
    }

    public event PropertyChangedEventHandler? PropertyChanged;

    protected void OnPropertyChanged([CallerMemberName] string? name = null)
        => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
}
