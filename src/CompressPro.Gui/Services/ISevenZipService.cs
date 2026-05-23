using CompressPro.Core.Models;

namespace CompressPro.Gui.Services;

/// <summary>
/// 7z 操作服务接口 — 支持 SevenZipSharp 和 7z.exe 两种实现
/// </summary>
public interface ISevenZipService
{
    /// <summary>列出压缩包内容</summary>
    Task<List<ArchiveFileInfo>> ListArchiveAsync(string archivePath);

    /// <summary>解压到目录</summary>
    Task ExtractAsync(string archivePath, string outputDir, string? password = null);

    /// <summary>测试完整性</summary>
    Task<bool> TestArchiveAsync(string archivePath);

    /// <summary>创建压缩包</summary>
    Task CompressAsync(IEnumerable<string> files, string archivePath, CompressionOptions? options = null, IProgress<double>? progress = null);
}
