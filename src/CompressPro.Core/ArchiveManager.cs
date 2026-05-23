using CompressPro.Core.Models;

namespace CompressPro.Core;

/// <summary>
/// 压缩解压核心管理器 — 封装 7z.dll 的所有操作
/// 占位: 待 SevenZipSharp 集成后实现
/// </summary>
public class ArchiveManager : IDisposable
{
    private bool _disposed;

    public Task<List<ArchiveFileInfo>> ListArchiveAsync(string archivePath)
    {
        // TODO: using var extractor = new SevenZipExtractor(archivePath);
        // return extractor.ArchiveFileData.Select(...).ToList();
        return Task.FromException<List<ArchiveFileInfo>>(
            new NotImplementedException("待 SevenZipSharp 集成"));
    }

    public Task ExtractAsync(
        string archivePath,
        string outputDir,
        string? password = null,
        IProgress<double>? progress = null,
        CancellationToken ct = default)
    {
        return Task.FromException(
            new NotImplementedException("待 SevenZipSharp 集成"));
    }

    public Task CompressAsync(
        IEnumerable<string> files,
        string archivePath,
        CompressionOptions? options = null,
        IProgress<double>? progress = null,
        CancellationToken ct = default)
    {
        return Task.FromException(
            new NotImplementedException("待 SevenZipSharp 集成"));
    }

    public Task<bool> TestArchiveAsync(string archivePath)
    {
        return Task.FromException<bool>(
            new NotImplementedException("待 SevenZipSharp 集成"));
    }

    public static string[] GetSupportedFormats() =>
    [
        "7z", "zip", "tar", "gz", "bzip2", "xz", "lzma",
        "lzma86", "cab", "iso", "udf", "wim", "vhd",
        "dmg", "hfs", "ntfs", "fat", "mbr", "gpt",
        "squashfs", "cpio", "rpm", "deb"
    ];

    public void Dispose()
    {
        if (_disposed) return;
        _disposed = true;
        GC.SuppressFinalize(this);
    }
}
