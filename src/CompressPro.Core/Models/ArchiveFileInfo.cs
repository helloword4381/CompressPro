namespace CompressPro.Core.Models;

/// <summary>
/// 压缩包内的文件条目信息
/// </summary>
public class ArchiveFileInfo
{
    public required string FileName { get; set; }
    public long UncompressedSize { get; set; }
    public long CompressedSize { get; set; }
    public double CompressionRatio => UncompressedSize > 0
        ? Math.Round((double)CompressedSize / UncompressedSize * 100, 1)
        : 0;
    public DateTime ModifiedDate { get; set; }
    public string? Attributes { get; set; }
    public string? Crc { get; set; }
    public bool IsFolder { get; set; }
    public string FullPath { get; set; } = string.Empty;

    /// <summary>显示用的大小字符串</summary>
    public string UncompressedSizeDisplay => FormatSize(UncompressedSize);
    public string CompressedSizeDisplay => FormatSize(CompressedSize);

    private static string FormatSize(long bytes) => bytes switch
    {
        < 1024 => $"{bytes} B",
        < 1024 * 1024 => $"{bytes / 1024.0:F1} KB",
        < 1024L * 1024 * 1024 => $"{bytes / (1024.0 * 1024):F1} MB",
        _ => $"{bytes / (1024.0 * 1024 * 1024):F2} GB"
    };

    /// <summary>获取文件扩展名对应的图标类型</summary>
    public string IconKey
    {
        get
        {
            if (IsFolder) return "Folder";
            var ext = Path.GetExtension(FileName)?.ToLowerInvariant();
            return ext switch
            {
                ".zip" or ".7z" or ".rar" or ".tar" or ".gz" => "Archive",
                ".exe" or ".dll" => "Executable",
                ".txt" or ".md" or ".log" => "Text",
                ".jpg" or ".png" or ".bmp" or ".gif" => "Image",
                _ => "Generic"
            };
        }
    }
}
